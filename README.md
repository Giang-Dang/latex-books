# latex-books

LaTeX sources for my books. Each folder under `books/` is an independent
LuaLaTeX project; `template/` is the skeleton new books start from. Books share
structure and tooling, not styling.

## Prerequisites

- A TeX distribution with LuaLaTeX, latexmk and biber
  - Windows: MiKTeX (enable automatic package installation) or TeX Live
- Git LFS (`git lfs install` once per machine) - final PDFs in `dist/` are LFS-tracked
- PowerShell 7+ for the helper scripts
- Once per clone: `git config core.hooksPath .githooks` to enable the
  pre-commit build gate

## Quick start

```powershell
# start a new book from the template
pwsh scripts/new-book.ps1 my-first-book

# build it (output lands in build/main.pdf)
cd books/my-first-book
latexmk

# rebuild all books from scratch and refresh dist/
pwsh scripts/release.ps1
```

## Repository layout

```
template/                  skeleton for new books (kept compiling by the build gate)
books/<name>/              one self-contained folder per book
  main.tex                 class options, \includeonly switch, \include list
  .latexmkrc               lualatex + build/ output dir + biber
  refs.bib                 biblatex database
  preamble/                packages.tex, fonts.tex, macros.tex
  frontmatter/             titlepage, copyright, preface
  chapters/NN-title/       ch.tex + one file per section
  backmatter/              appendices
  figures/                 images/ (assets) and tikz/ (drawn figures)
  build/                   latexmk output, gitignored
dist/                      final PDF per book, committed via Git LFS
scripts/                   new-book.ps1, release.ps1
.githooks/                 pre-commit build gate (see Prerequisites)
```

## Working on a large book

Uncomment the `\includeonly` line in that book's `main.tex` and list only the
chapters you are editing - latexmk then recompiles just those while keeping
page numbers and cross-references intact. Comment it out again before a
release build.

## Build gate

There is no CI. The pre-commit hook in `.githooks/` compiles every book
touched by the staged changes and aborts the commit on a broken build. The
committed PDFs in `dist/` are only refreshed locally via `scripts/release.ps1`.
