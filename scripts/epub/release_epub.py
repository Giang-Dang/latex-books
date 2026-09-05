#!/usr/bin/env python3
"""Rebuild books from scratch and copy the final EPUBs into dist/ (LFS-tracked).

The EPUB counterpart of scripts/release.ps1: the same menu, the same
"1,3 / 1-3 / a / empty cancels" selection grammar, the same dist/ discipline. A
different converter underneath, and a different language, because the
conversion needs a flattening pass, a figure render and two pandoc filters, and
that is more program than a release script should carry inline.

Run it through scripts/release-epub.ps1, which builds the conda environment
this expects. Running it directly works too, given a python with scour and a
PATH holding pandoc, lualatex and dvisvgm.

    python scripts/epub/release_epub.py --root <repo> [names] [--all] [--dry-run]

Why pandoc rather than tex4ebook, which this replaced: tex4ht configures each
LaTeX package by hand in a .4ht file, and those files run years behind the
packages. minted.4ht is dated 2022 and patches minted v2 internals; the books
here use minted v3.8.0, and every listing in a 279-listing book failed to
parse. pandoc reads the source itself, needs no change to any book, and emits
semantic markup - class="sourceCode csharp" against tex4ht's per-token
<span id="textcolor128"> and a CSS rule for each.
"""

from __future__ import annotations

import argparse
import posixpath
import re
import shutil
import subprocess
import sys
import zipfile
from dataclasses import dataclass
from datetime import datetime, timezone
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

import booksource
import figures

# Two of the four books are written in Vietnamese, and pandoc quotes their
# prose back in its warnings. On Windows the console encoding is cp1252,
# which cannot represent that, and printing a warning killed the build with
# a UnicodeEncodeError - the report about a problem becoming a worse
# problem. Every stream this writes to is UTF-8 from here on.
for stream in (sys.stdout, sys.stderr):
    if hasattr(stream, "reconfigure"):
        stream.reconfigure(encoding="utf-8", errors="replace")

# Where a book keeps the pandoc filters describing its own environments. Same
# split as check-chapter.psd1: the script is shared, the policy is the book's.
BOOK_FILTER_DIR = "epub"
SHARED_FILTERS = [Path(__file__).with_name("tables.lua")]

REQUIRED_TOOLS = {
    "pandoc": "converts the flattened LaTeX; the whole pipeline is built on it",
    "lualatex": "compiles each TikZ figure on its own",
    "dvisvgm": "turns those figures into SVG",
}

# epubcheck is the only thing here that reads the finished file the way a store
# will. It is not installable as a dependency of this environment, so it cannot
# be required - but a release that skipped its one validation step should say
# so rather than passing quietly.
OPTIONAL_TOOLS = {
    "epubcheck": "validates full EPUB conformance; internal links are still checked",
}


class SourceError(RuntimeError):
    """The flattened LaTeX cannot be prepared without losing structure."""


def _is_comment_start(source: str, position: int) -> bool:
    """Return whether the percent sign at *position* starts a TeX comment."""
    backslashes = 0
    position -= 1
    while position >= 0 and source[position] == "\\":
        backslashes += 1
        position -= 1
    return backslashes % 2 == 0


def _brace_group(source: str, position: int) -> tuple[str, int]:
    """Read one balanced brace group after *position*."""
    while position < len(source) and source[position].isspace():
        position += 1
    if position == len(source) or source[position] != "{":
        raise SourceError(r"\multicolumn must have three brace groups")

    depth = 1
    start = position + 1
    position = start
    while position < len(source) and depth:
        if (source[position] == "\\" and position + 1 < len(source)
                and source[position + 1] in "{}\\"):
            position += 2
            continue
        if source[position] == "{":
            depth += 1
        elif source[position] == "}":
            depth -= 1
        position += 1
    if depth:
        raise SourceError(r"unclosed brace group after \multicolumn")
    return source[start:position - 1], position


def _prepare_table(table: str) -> str:
    r"""Mark spanning cells and remove rules pandoc renders as text."""
    multicolumn = r"\multicolumn"
    cmidrule = r"\cmidrule"
    pieces: list[str] = []
    cursor = 0
    while cursor < len(table):
        if table[cursor] == "%" and _is_comment_start(table, cursor):
            newline = table.find("\n", cursor)
            if newline < 0:
                pieces.append(table[cursor:])
                break
            pieces.append(table[cursor:newline + 1])
            cursor = newline + 1
            continue

        if table.startswith(multicolumn, cursor):
            position = cursor + len(multicolumn)
            span_text, position = _brace_group(table, position)
            _, position = _brace_group(table, position)
            content, position = _brace_group(table, position)
            try:
                span = int(span_text)
            except ValueError as failure:
                raise SourceError(
                    rf"\multicolumn span is not an integer: {span_text!r}"
                ) from failure
            if span < 1:
                raise SourceError(rf"\multicolumn span must be positive: {span}")
            pieces.append(
                rf"\href{{epub-colspan:{span}}}{{{content}}}"
                + " &" * (span - 1)
            )
            cursor = position
            continue

        if table.startswith(cmidrule, cursor):
            position = cursor + len(cmidrule)
            while position < len(table) and table[position].isspace():
                position += 1
            if position < len(table) and table[position] == "(":
                option_end = table.find(")", position + 1)
                if option_end < 0:
                    raise SourceError(r"unclosed option after \cmidrule")
                position = option_end + 1
            _, cursor = _brace_group(table, position)
            continue

        pieces.append(table[cursor])
        cursor += 1
    return "".join(pieces)


def prepare_tables(source: str) -> str:
    r"""Prepare actual table environments without rewriting comments or code.

    Pandoc leaves a whole table as raw LaTeX when it sees ``\multicolumn``.
    Lua filters run after that parse and cannot recover the float's caption or
    label. Spanning cells therefore become temporary links before parsing;
    ``tables.lua`` consumes those markers and restores their column spans.
    """
    table_begin = re.compile(r"\\begin\{(tabular|longtable)\}")
    verbatim_names = {"verbatim", "Verbatim", "lstlisting", "minted"}
    verbatim_names.update(re.findall(r"\\newminted\[([^]]+)\]", source))

    pieces: list[str] = []
    cursor = 0
    while cursor < len(source):
        if source[cursor] == "%" and _is_comment_start(source, cursor):
            newline = source.find("\n", cursor)
            if newline < 0:
                pieces.append(source[cursor:])
                break
            pieces.append(source[cursor:newline + 1])
            cursor = newline + 1
            continue

        if source.startswith(r"\begin{", cursor):
            name, after_begin = _brace_group(source, cursor + len(r"\begin"))
            if name in verbatim_names:
                end_marker = rf"\end{{{name}}}"
                end = source.find(end_marker, after_begin)
                if end < 0:
                    raise SourceError(f"unclosed verbatim environment {name}")
                end += len(end_marker)
                pieces.append(source[cursor:end])
                cursor = end
                continue

        match = table_begin.match(source, cursor)
        if match:
            name = match.group(1)
            end_marker = rf"\end{{{name}}}"
            end = source.find(end_marker, match.end())
            if end < 0:
                raise SourceError(f"unclosed table environment {name}")
            end += len(end_marker)
            pieces.append(_prepare_table(source[cursor:end]))
            cursor = end
            continue

        pieces.append(source[cursor])
        cursor += 1
    return "".join(pieces)


# ---------------------------------------------------------------------------
# What the list knows about each book
# ---------------------------------------------------------------------------


@dataclass
class Book:
    name: str
    path: Path
    changed: int | None       # commit time of the newest commit touching it
    released: int | None      # commit time of its EPUB in dist/
    dirty: bool
    has_dist: bool

    @property
    def sort_key(self) -> int:
        # A book with no commit yet is the most recent thing there is.
        return self.changed if self.changed is not None else 1 << 62

    @property
    def age(self) -> str:
        return "uncommitted" if self.changed is None else format_age(self.changed)

    @property
    def dist_state(self) -> str:
        if not self.has_dist:
            return "never released"
        if self.released is None:
            return "released, not committed"
        if self.changed is None or self.released < self.changed:
            return f"stale (released {format_age(self.released)})"
        return f"current ({format_age(self.released)})"


def git(root: Path, *args: str) -> str | None:
    """Run git, returning None for any failure.

    Recency and the dist/ column come from git rather than from file
    timestamps: a fresh clone stamps every file with the clone time, which
    would order the list at random and call every released EPUB current.
    """
    if shutil.which("git") is None:
        return None
    result = subprocess.run(["git", "-C", str(root), *args],
                            capture_output=True, text=True,
                            encoding="utf-8", errors="replace")
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def last_commit_epoch(root: Path, pathspec: str) -> int | None:
    # The "--" is what keeps git from having to guess whether a path that does
    # not exist yet is a revision. Without it, the first release of any book
    # fails with "ambiguous argument".
    out = git(root, "log", "-1", "--format=%ct", "--", pathspec)
    return int(out) if out else None


def format_age(epoch: int) -> str:
    delta = datetime.now(timezone.utc) - datetime.fromtimestamp(epoch, timezone.utc)
    minutes = delta.total_seconds() / 60
    if minutes < 1:
        return "just now"
    if minutes < 60:
        return f"{int(minutes)}m ago"
    if delta.days < 1:
        return f"{int(minutes // 60)}h ago"
    if delta.days < 90:
        return f"{delta.days}d ago"
    return datetime.fromtimestamp(epoch, timezone.utc).astimezone().strftime("%Y-%m-%d")


def survey(root: Path) -> list[Book]:
    books = []
    for folder in sorted((root / "books").iterdir()):
        if not folder.is_dir():
            continue
        name = folder.name
        books.append(Book(
            name=name,
            path=folder,
            changed=last_commit_epoch(root, f"books/{name}"),
            released=last_commit_epoch(root, f"dist/{name}.epub"),
            dirty=bool(git(root, "status", "--porcelain", "--", f"books/{name}")),
            has_dist=(root / "dist" / f"{name}.epub").exists(),
        ))
    # Newest first, name as the tie-break so the numbering is stable between runs.
    books.sort(key=lambda b: (-b.sort_key, b.name))
    return books


# ---------------------------------------------------------------------------
# Choosing
# ---------------------------------------------------------------------------


def resolve_selection(answer: str, count: int) -> tuple[str, list[int] | str]:
    """Turn one answer into positions, or into a reason to ask again.

    Books are picked by number only. That is what keeps 'a' free to mean all of
    them without colliding with a book whose name starts with an a.
    """
    text = answer.strip()
    if text == "" or text in ("q", "quit"):
        return "cancel", []
    if text in ("a", "all"):
        return "select", list(range(1, count + 1))

    picked: list[int] = []
    for token in text.replace(",", " ").split():
        if "-" in token[1:]:
            first, _, last = token.partition("-")
            if not (first.isdigit() and last.isdigit()):
                return "invalid", f"not a range: {token!r}"
            a, b = int(first), int(last)
            if not (1 <= a <= count and 1 <= b <= count):
                return "invalid", f"no such book in {token!r} - the list has {count}"
            for i in range(min(a, b), max(a, b) + 1):
                if i not in picked:
                    picked.append(i)
        elif token.isdigit():
            i = int(token)
            if not 1 <= i <= count:
                return "invalid", f"no such book: {i} - the list has {count}"
            if i not in picked:
                picked.append(i)
        else:
            return "invalid", f"not a number: {token!r}"
    # Sorted, so what gets built follows the list people read the numbers off
    # rather than the order they typed them. '3, 1' and '1, 3' are one request.
    return "select", sorted(picked)


def show_menu(books: list[Book]) -> None:
    def width(values, heading):
        return max(len(str(v)) for v in [*values, heading])

    num_w = width([len(books)], "#")
    name_w = width([b.name for b in books], "Book") + 2
    age_w = width([b.age for b in books], "Last change")

    print()
    print("Books, most recently changed first:")
    print()
    print(f"  {'#':>{num_w}}  {'Book':<{name_w}}  {'Last change':<{age_w}}  dist/ (epub)")
    for i, book in enumerate(books, start=1):
        label = f"{book.name} *" if book.dirty else book.name
        print(f"  {i:>{num_w}}  {label:<{name_w}}  {book.age:<{age_w}}  {book.dist_state}")
    if any(b.dirty for b in books):
        print()
        print("  * uncommitted changes in the working tree")
    print()


def choose(books: list[Book], names: list[str], want_all: bool) -> list[Book]:
    if want_all:
        return books

    if names:
        by_name = {b.name.casefold(): b for b in books}
        unknown = [n for n in names if n.casefold() not in by_name]
        if unknown:
            print("Books under books/: " + ", ".join(sorted(b.name for b in books)))
            raise SystemExit(f"No such book: {', '.join(unknown)}")
        # Keep list order, not the order they were typed, so the build order
        # and the numbering people saw in the menu agree. Duplicates collapse.
        wanted = {by_name[n.casefold()].name for n in names}
        return [b for b in books if b.name in wanted]

    show_menu(books)
    while True:
        try:
            answer = input("Release which? (1,3 / 1-3 / a=all / empty=cancel) ")
        except EOFError:
            # A caller that redirected stdin and passed no names. Nothing here
            # waits forever.
            print("Nothing selected - nothing built.")
            print("Pass book names or --all when running this without a terminal.")
            raise SystemExit(0)
        action, payload = resolve_selection(answer, len(books))
        if action == "cancel":
            print("Nothing selected - nothing built.")
            raise SystemExit(0)
        if action == "invalid":
            print(f"  {payload}")
            continue
        return [books[i - 1] for i in payload]


# ---------------------------------------------------------------------------
# Building
# ---------------------------------------------------------------------------


def book_metadata(book: Path) -> dict[str, str]:
    """Read the title, subtitle and author out of the book's macros.

    They are defined once in preamble/macros.tex, which is where the book
    already states them for its own title page. Reading them here rather than
    asking for them again keeps one source for the name of the book.
    """
    macros = (book / "preamble" / "macros.tex").read_text(encoding="utf-8")
    wanted = {"thebooktitle": "title",
              "thebooksubtitle": "subtitle",
              "thebookauthor": "author"}
    found: dict[str, str] = {}
    for macro, key in wanted.items():
        for line in macros.splitlines():
            marker = "\\newcommand{\\" + macro + "}{"
            if line.startswith(marker):
                found[key] = line[len(marker):].rstrip().rstrip("}")
                break
    return found


def filters_for(book: Book) -> list[Path]:
    """The book's pandoc filters, in the order their names sort.

    Order is the book's to choose and matters: splitting-the-graph's
    01-environments.lua re-parses the bodies of its box environments, which is
    what exposes the cross-references inside them to 02-crossrefs.lua - 416
    references before that pass, 430 after.
    """
    return sorted((book.path / BOOK_FILTER_DIR).glob("*.lua"))


def build(book: Book, work: Path, verbose: bool) -> Path:
    filters = [*SHARED_FILTERS, *filters_for(book)]
    work.mkdir(parents=True, exist_ok=True)

    flat, read = booksource.flatten(book.path)
    flat = prepare_tables(flat)
    flat_path = work / "flat.tex"
    flat_path.write_text(flat, encoding="utf-8")
    print(f"    flattened {len(read)} files ({len(flat):,} characters)")

    figure_dir = work / "figures"
    rendered = figures.render_all(book.path, figure_dir)
    if rendered:
        before = sum(r.bytes_before for r in rendered)
        after = sum(r.bytes_after for r in rendered)
        print(f"    rendered {len(rendered)} figures, "
              f"{before / 1024:.0f} KB -> {after / 1024:.0f} KB after scour")

    print(f"    filters: {', '.join(f.name for f in filters)}")

    epub = work / f"{book.name}.epub"
    meta = book_metadata(book.path)
    command = [
        "pandoc", "-f", "latex+raw_tex", str(flat_path), "-t", "epub3",
        "--top-level-division=chapter",
        "--split-level=2",
        "--toc", "--toc-depth=3",
        # EPUB 3 is the only ebook format that carries MathML, and
        # without asking for it pandoc writes maths as TeX inside a
        # span, which a reader shows as source. Measured on
        # do-trung-thuc-trong-xai: no --mathml, no <math> element in the
        # whole book; with it, every equation converts.
        "--mathml",
        "--citeproc", "--bibliography=refs.bib",
        "-M", f"figure_dir={figure_dir.as_posix()}",
        "-M", "lang=en",
        "-o", str(epub),
    ]
    for lua in filters:
        command += ["--lua-filter", str(lua)]
    for key, value in meta.items():
        command += ["-M", f"{key}={value}"]

    cover = book.path / "figures" / "images" / "cover.png"
    if cover.exists():
        command += ["--epub-cover-image", str(cover)]
    else:
        print("    no figures/images/cover.png - the EPUB ships without a cover")

    if verbose:
        print("    " + " ".join(command))
    result = subprocess.run(command, cwd=book.path, capture_output=True,
                            text=True, encoding="utf-8", errors="replace")
    if result.returncode != 0:
        raise SystemExit(f"pandoc failed for {book.name}:\n{result.stderr.strip()}")
    if result.stderr.strip():
        for line in result.stderr.strip().splitlines():
            print(f"    pandoc: {line}")
    return epub


def summarise(epub: Path) -> None:
    """Say what came out, so an empty conversion cannot look like a success."""
    with zipfile.ZipFile(epub) as archive:
        pages = [n for n in archive.namelist() if n.endswith(".xhtml")]
        body = "".join(archive.read(n).decode("utf-8") for n in pages)
        images = [n for n in archive.namelist()
                  if n.lower().endswith((".svg", ".png", ".jpg", ".jpeg"))]
    print(f"    {epub.stat().st_size / 1024:.0f} KB, {len(pages)} documents, "
          f"{body.count('<pre')} code listings, {len(images)} images, "
          f"{body.count('#ch:') + body.count('#sec:') + body.count('#fig:')} "
          f"cross-references")


class _LinkCollector(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.identifiers: set[str] = set()
        self.hrefs: list[str] = []

    def handle_starttag(self, tag: str,
                        attrs: list[tuple[str, str | None]]) -> None:
        for name, value in attrs:
            if name == "id" and value:
                self.identifiers.add(value)
            elif name == "href" and value:
                self.hrefs.append(value)


def validate_internal_links(epub: Path) -> None:
    """Reject links whose archive member or XHTML fragment does not exist."""
    print("    validating internal links")
    with zipfile.ZipFile(epub) as archive:
        members = set(archive.namelist())
        documents: dict[str, _LinkCollector] = {}
        for name in members:
            if not name.endswith(".xhtml"):
                continue
            collector = _LinkCollector()
            collector.feed(archive.read(name).decode("utf-8"))
            documents[name] = collector

    broken: list[str] = []
    for source, collector in documents.items():
        for href in collector.hrefs:
            target = urlsplit(href)
            if target.scheme or target.netloc:
                continue
            path = unquote(target.path)
            destination = source if not path else posixpath.normpath(
                posixpath.join(posixpath.dirname(source), path))
            if destination not in members:
                broken.append(f"{source}: {href} (missing file)")
                continue
            if target.fragment:
                fragment = unquote(target.fragment)
                document = documents.get(destination)
                if document is None or fragment not in document.identifiers:
                    broken.append(f"{source}: {href} (missing fragment)")

    if broken:
        detail = "\n".join(f"  {item}" for item in broken[:20])
        extra = "" if len(broken) <= 20 else f"\n  ...and {len(broken) - 20} more"
        raise SystemExit(
            f"internal link validation rejected {epub.name}:\n{detail}{extra}"
        )


def validate(epub: Path) -> None:
    if shutil.which("epubcheck") is None:
        return
    print("    validating")
    result = subprocess.run(["epubcheck", str(epub)], capture_output=True,
                            text=True, encoding="utf-8", errors="replace")
    if result.returncode != 0:
        raise SystemExit(
            f"epubcheck rejected {epub.name} - dist/ left untouched:\n"
            f"{(result.stdout + result.stderr).strip()[:2000]}"
        )


# ---------------------------------------------------------------------------


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build books into EPUBs in dist/.",
        epilog="Normally run through scripts/release-epub.ps1.")
    parser.add_argument("--root", required=True, type=Path,
                        help="the repository root")
    parser.add_argument("names", nargs="*",
                        help="book folder names, as they appear under books/")
    parser.add_argument("--all", action="store_true",
                        help="every book, without asking")
    parser.add_argument("--dry-run", action="store_true",
                        help="resolve the selection, print it, build nothing")
    parser.add_argument("--verbose", action="store_true",
                        help="print the pandoc command line")
    args = parser.parse_args()

    root: Path = args.root.resolve()
    if args.all and args.names:
        parser.error("--all releases everything; naming books as well is "
                     "contradictory. Use one or the other.")

    books = survey(root)
    if not books:
        print("No books under books/ yet - nothing to release.")
        return 0

    selected = choose(books, args.names, args.all)

    if args.dry_run:
        print(f"Would release (dry run), {len(selected)} of {len(books)}:")
        for book in selected:
            print(f"  {book.name} -> dist/{book.name}.epub")
        return 0

    missing = [f"{tool} ({why})" for tool, why in REQUIRED_TOOLS.items()
               if shutil.which(tool) is None]
    if missing:
        raise SystemExit("Not on PATH:\n  " + "\n  ".join(missing))
    for tool, why in OPTIONAL_TOOLS.items():
        if shutil.which(tool) is None:
            print(f"Not on PATH: {tool} ({why})")

    # Every selected book is checked before the first one is built. Finding a
    # book unreleasable halfway through a selection leaves dist/ half updated,
    # which is what happened the first time this ran on two books: one landed,
    # the second was refused, and the release had to be sorted out afterwards.
    unreleasable = [b for b in selected if not filters_for(b)]
    if unreleasable:
        raise SystemExit(
            "No pandoc filters in {dir}/ for: {names}.\n"
            "Without them every custom environment in a book converts to prose "
            "with its formatting gone, and nothing reports it. Add the filters, "
            "or leave those books out of the release.".format(
                dir=BOOK_FILTER_DIR,
                names=", ".join(b.name for b in unreleasable),
            )
        )

    print(f"Releasing {len(selected)} of {len(books)} book(s): "
          f"{', '.join(b.name for b in selected)}")

    updated: list[str] = []
    try:
        for book in selected:
            print(f"==> Building {book.name}")
            # From scratch every time, the equivalent of release.ps1's
            # latexmk -gg: a cached figure or a stale flattened file is exactly
            # the sort of thing that makes a release differ from a rebuild.
            work = book.path / "build" / "epub"
            if work.exists():
                shutil.rmtree(work)
            try:
                epub = build(book, work, args.verbose)
            except (booksource.FlattenError, figures.FigureError,
                    SourceError) as failure:
                # These say precisely what went wrong and where. A traceback
                # on top of that only buries it.
                raise SystemExit(f"{book.name}: {failure}") from None
            summarise(epub)
            validate_internal_links(epub)
            validate(epub)
            shutil.copyfile(epub, root / "dist" / f"{book.name}.epub")
            updated.append(book.name)
            print(f"==> dist/{book.name}.epub updated")
    except SystemExit:
        # A selection of several stops at the first failure, and what already
        # landed in dist/ is committable work: say so rather than leaving it to
        # be discovered in git status.
        if updated:
            print(f"Stopped after a failure. Already updated: {', '.join(updated)}")
        raise

    print(f"Release build complete: {', '.join(updated)}. "
          f"Review and commit the dist/ changes.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
