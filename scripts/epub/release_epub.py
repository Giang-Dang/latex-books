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
import shutil
import subprocess
import sys
import zipfile
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

import booksource
import figures

# Where a book keeps the pandoc filters describing its own environments. Same
# split as check-chapter.psd1: the script is shared, the policy is the book's.
BOOK_FILTER_DIR = "epub"

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
    "epubcheck": "validates the finished EPUB; without it nothing checks it",
}


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


def build(book: Book, work: Path, verbose: bool) -> Path:
    # Checked before anything is compiled. A book without filters cannot be
    # released, and finding that out after rendering its figures wastes a
    # minute and reports the wrong problem.
    filters = sorted((book.path / BOOK_FILTER_DIR).glob("*.lua"))
    if not filters:
        raise SystemExit(
            f"{book.name}: no pandoc filters in {BOOK_FILTER_DIR}/. Without them "
            f"every custom environment in the book converts to prose with its "
            f"formatting gone, and nothing reports it. Add them, or leave the "
            f"book out of the release."
        )

    work.mkdir(parents=True, exist_ok=True)

    flat, read = booksource.flatten(book.path)
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
            except (booksource.FlattenError, figures.FigureError) as failure:
                # These say precisely what went wrong and where. A traceback
                # on top of that only buries it.
                raise SystemExit(f"{book.name}: {failure}") from None
            summarise(epub)
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
