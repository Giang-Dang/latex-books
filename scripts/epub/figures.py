"""Render a book's TikZ figures to SVG.

Nothing draws TikZ in an EPUB, so each picture is compiled on its own and
swapped in as an image. The pictures in this repository are bare tikzpicture
bodies in figures/tikz/NAME.tex, pulled into a figure environment at the call
site, which is what makes compiling them one at a time possible.

Each picture goes through lualatex with the standalone class, then dvisvgm,
then scour. The middle step is where the size comes from and the last is where
it goes away again: measured on splitting-the-graph's 13 figures, dvisvgm emits
2.6 MB of SVG, most of it metadata and coordinate precision no reader needs.
"""

from __future__ import annotations

import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

# Text is converted to paths rather than embedded as fonts. A reader that
# cannot resolve a font renders the figure wrongly with no way to notice, and
# these figures carry little enough text that the paths cost about the same:
# measured at 131 KB against 134 KB on the first figure.
DVISVGM = ["--pdf", "--no-fonts", "--optimize"]

# The preamble each picture is compiled against. It is deliberately not the
# book's own preamble: a picture needs the TikZ libraries and the sans font it
# labels with, and pulling in minted, tcolorbox, biblatex and hyperref to draw
# a line drawing makes every figure pay for the whole book.
#
# This default carries what splitting-the-graph's figures use. A book whose
# pictures need other libraries writes its own at epub/figures-preamble.tex,
# the same split as check-chapter.psd1: the script is shared, the policy is the
# book's. The %s is where the figure's file name goes.
DEFAULT_PREAMBLE = r"""\documentclass[border=2pt]{standalone}
\usepackage{fontspec}
\setsansfont{texgyreheros}[
  Extension = .otf, UprightFont = *-regular, BoldFont = *-bold,
  ItalicFont = *-italic, BoldItalicFont = *-bolditalic,
]
\usepackage{tikz}
\usetikzlibrary{arrows.meta, positioning, calc, fit}
\begin{document}
\input{figures/tikz/%s}
\end{document}
"""

PREAMBLE_OVERRIDE = "epub/figures-preamble.tex"


class FigureError(RuntimeError):
    """A figure could not be rendered."""


@dataclass
class Rendered:
    name: str
    path: Path
    bytes_before: int
    bytes_after: int


def render_all(book: Path, out_dir: Path) -> list[Rendered]:
    """Render every figures/tikz/*.tex in *book* into *out_dir* as SVG."""
    sources = sorted((book / "figures" / "tikz").glob("*.tex"))
    if not sources:
        return []
    out_dir.mkdir(parents=True, exist_ok=True)

    override = book / PREAMBLE_OVERRIDE
    preamble = override.read_text(encoding="utf-8") if override.exists() \
        else DEFAULT_PREAMBLE
    if "%s" not in preamble:
        raise FigureError(
            f"{override} has no %s for the figure's file name to go into."
        )
    return [_render(book, out_dir, source.stem, preamble) for source in sources]


def _render(book: Path, out_dir: Path, name: str, preamble: str) -> Rendered:
    wrapper = out_dir / "wrap.tex"
    wrapper.write_text(preamble % name, encoding="utf-8")

    # lualatex runs from the book root so that \input{figures/tikz/NAME}
    # resolves the way it does in the book itself, and writes its droppings
    # into out_dir.
    _run(
        ["lualatex", "-interaction=nonstopmode", "-halt-on-error",
         f"-output-directory={out_dir}", str(wrapper)],
        cwd=book,
        what=f"lualatex on figure {name}",
        log=out_dir / "wrap.log",
    )

    pdf = out_dir / "wrap.pdf"
    if not pdf.exists():
        raise FigureError(f"lualatex produced no PDF for figure {name}")

    svg = out_dir / f"{name}.svg"
    _run(
        ["dvisvgm", *DVISVGM, f"--output={svg}", str(pdf)],
        cwd=book,
        what=f"dvisvgm on figure {name}",
    )
    before = svg.stat().st_size

    # scour rewrites in place through a temporary file; it refuses to use the
    # same path for both ends.
    #
    # Called as a module through this interpreter rather than as the scour
    # command, because release-epub.ps1 runs the environment's python directly
    # instead of activating the environment, so the environment's Scripts
    # directory is not on PATH. Going through sys.executable reaches the scour
    # that was installed alongside this interpreter, which is the one
    # environment.yml pinned.
    minified = out_dir / f"{name}.min.svg"
    _run(
        [sys.executable, "-m", "scour.scour", "-i", str(svg), "-o", str(minified),
         "--enable-viewboxing", "--enable-id-stripping",
         "--enable-comment-stripping", "--shorten-ids", "--indent=none"],
        cwd=book,
        what=f"scour on figure {name}",
    )
    minified.replace(svg)

    return Rendered(name, svg, before, svg.stat().st_size)


def _run(command: list[str], cwd: Path, what: str, log: Path | None = None) -> None:
    result = subprocess.run(command, cwd=cwd, capture_output=True, text=True,
                            encoding="utf-8", errors="replace")
    if result.returncode == 0:
        return
    detail = (result.stderr or result.stdout or "").strip()
    if log is not None and log.exists():
        # lualatex says almost nothing useful on stderr; the error is in the log.
        lines = log.read_text(encoding="utf-8", errors="replace").splitlines()
        errors = [line for line in lines if line.startswith("! ")]
        if errors:
            detail = "\n".join(errors[:5])
    raise FigureError(f"{what} failed:\n{detail[:800]}")
