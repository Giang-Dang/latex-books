# latex-books

Multiple independent LaTeX books. Each folder under books/ is a self-contained
LuaLaTeX project built with latexmk. Books deliberately share no styling or
preamble code; repo-wide consistency is structural only.

## Layout

- template/ - skeleton copied to start a new book (same layout as a real book)
- books/<book-name>/ - one folder per book, fully self-contained
- dist/ - final released PDFs, one per book, tracked with Git LFS
- scripts/ - new-book.ps1, release.ps1 (PowerShell 7+)
- .github/workflows/build.yml - CI compile check for template/ and every book

Inside a book: main.tex, .latexmkrc, refs.bib, preamble/{packages,fonts,macros}.tex,
frontmatter/, chapters/NN-name/, backmatter/, figures/{images,tikz}/, build/ (generated).

## Build commands

- Build one book: `cd books/<name> && latexmk` (output: build/main.pdf)
- Clean: `latexmk -C`
- New book: `pwsh scripts/new-book.ps1 <kebab-case-name>`
- Release all books into dist/: `pwsh scripts/release.ps1`

## Hard rules

- LuaLaTeX only ($pdf_mode = 4 in each book's .latexmkrc). Never switch a book
  to pdflatex or xelatex.
- Never commit build/ output. dist/ is updated only via scripts/release.ps1 at
  milestones, never by hand-copying a draft PDF.
- Books stay independent: never extract style files shared by several books.
  Improvements meant for future books go into template/ only; existing books
  adopt them manually if wanted.
- This is an independent git repo nested inside F:\repo (which is a separate
  repo). Run all git commands from the latex-books root.

## Conventions

- Naming: kebab-case book folders; zero-padded numeric prefixes (01-, 02-) on
  chapter folders and section files so filesystem order matches book order.
- Chapters: chapters/NN-title/ch.tex holds \chapter{...} and \input's its
  section files. main.tex loads chapters only via \include (this is what makes
  \includeonly work).
- All \input/\include paths are written from the book root
  (e.g. \input{chapters/01-intro/02-concepts}), never relative to the current file.
- Drafting a big book: uncomment \includeonly in main.tex to rebuild a single
  chapter; always comment it out again before a release build.
- Bibliography: biblatex + biber, one refs.bib per book. Cite with \autocite.
- Languages: fontspec + babel configured in preamble/fonts.tex. English default;
  the TeX Gyre fonts already cover Vietnamese; CJK is enabled per book via the
  commented \babelfont block in that file.
- Figures: TikZ sources in figures/tikz/, bitmap/PDF assets in figures/images/;
  both are on \graphicspath, so reference them by bare filename.
