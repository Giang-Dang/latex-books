"""Flatten a book's LaTeX tree into the single file pandoc needs.

pandoc's LaTeX reader does not follow this repository's \\input and \\include
lines. That is measured, not assumed: splitting-the-graph's main.tex comes back
from pandoc as four \\part headings and nothing else, and rewriting all 25
\\include lines to \\input changes the output by zero bytes. Whatever the
reason, the fix does not depend on it.

Flattening is also the better shape for a converter. It is explicit, it reports
what it read, and a missing file stops the run instead of quietly producing a
book with a chapter missing - which is the failure mode that matters here,
because nothing downstream can tell an absent chapter from a short one.

One consequence worth knowing: this ignores \\includeonly. A book left with
that drafting aid uncommented builds a PDF with chapters missing, but its EPUB
comes out complete, because every \\include is inlined regardless.
"""

from __future__ import annotations

import re
from pathlib import Path

# One inclusion per line, which is how every book in this repository writes
# them. Anything more adventurous should fail loudly rather than half-work.
INCLUSION = re.compile(r"^([ \t]*)\\(input|include)\{([^}]+)\}[ \t]*$", re.MULTILINE)

MAX_DEPTH = 20


class FlattenError(RuntimeError):
    """A book's LaTeX tree could not be read as a single document."""


def flatten(book: Path) -> tuple[str, list[Path]]:
    """Return (flattened source, files read) for the book at *book*.

    Paths inside \\input and \\include are resolved from the book root, which
    is what this repository's AGENTS.md requires of every one of them.
    """
    read: list[Path] = []
    text = _expand(book, book / "main.tex", read, depth=0)
    return text, read


def _expand(book: Path, path: Path, read: list[Path], depth: int) -> str:
    if depth > MAX_DEPTH:
        raise FlattenError(f"inclusions nested more than {MAX_DEPTH} deep at {path}")
    if not path.exists():
        raise FlattenError(f"{path} does not exist")
    read.append(path)
    source = path.read_text(encoding="utf-8")

    def replace(match: re.Match[str]) -> str:
        indent, command, target = match.groups()
        child = book / target
        if child.suffix != ".tex":
            child = child.with_suffix(".tex")
        if not child.exists():
            raise FlattenError(
                f"{path}: \\{command}{{{target}}} does not resolve to a file "
                f"({child} is missing)"
            )
        body = _expand(book, child, read, depth + 1)
        # The markers are comments, so they change nothing for pandoc, and they
        # make the flattened file navigable when a conversion goes wrong in a
        # 600,000 character document.
        return f"{indent}% >>> {target}\n{body}\n{indent}% <<< {target}"

    return INCLUSION.sub(replace, source)
