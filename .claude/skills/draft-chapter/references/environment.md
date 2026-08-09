# Build and tooling traps

Things that cost real time in this repo. Read before the first build of a
session.

## Contents

- latexmk needs perl
- Never sed a LaTeX macro
- Overfull boxes
- Citation keys
- Concurrent builds
- minted and Pygments
- Page numbers in the PDF
- Line endings

## latexmk needs perl

`latexmk` is a perl script. On this machine perl is on Git Bash's PATH but not
PowerShell's, so running it from PowerShell fails with "MiKTeX could not find
the script engine 'perl'". Run builds through the Bash tool. The pre-commit
hook is a `sh` script, so it works there for the same reason.

## Never sed a LaTeX macro

GNU sed reads `\c` in a replacement as a control-character escape, so
`sed -e 's/\\url{/\\code{/'` silently emits a `0x0F` byte followed by `de{`.
The result looks almost right in a terminal, puts a control character into the
source, and survives until something scans the bytes.

Use the Edit tool, or Python, for anything containing a backslash. The scan that
catches this class of damage is the character check in
`scripts/check-chapter.ps1`; run that rather than rescanning by hand. It holds
under the looser policy too: `Punctuation` mode admits letters of any script but
still rejects control characters, and the byte a mangled `sed` emits is a
control character. Only `Characters.Mode = 'Off'` loses this warning.

## Overfull boxes

The build gate is zero overfull boxes, and the usual cause is a long inline
`\code{}` span: a 40-character identifier has no break points and will not fit
the measure. That measure is 155mm for a book still on the template's
`\geometry` (A4, 30mm inner, 25mm outer); a book that changes the geometry
changes the number, so take it from its `preamble/packages.tex`. Fixes, in order
of preference:

1. Reword so the identifier sits where it fits, or name the thing in words.
2. Promote it to a displayed listing.
3. For a single stubborn captured output, set `fontsize=\footnotesize` on that
   one verbatim block. Do not alter captured text to make it fit.

Locate them with:

```
grep -A3 Overfull build/main.log
```

The `lines X--Y` in each report refer to the source file named in the enclosing
`(./path/to/file.tex` line above it.

## Citation keys

A subagent writing the bibliography picks its own key names, which will not
match the keys already written into prose. Reconcile after that agent
finishes: `pwsh scripts/check-chapter.ps1 books/<name>` flags every key the
prose cites that `refs.bib` does not define. Undefined citations do not fail
the build loudly; they render as bold question marks.

## Concurrent builds

Two subagents running a build against the same project collide on intermediate
output. Either give each agent its own project, or have agents write files only
and compile centrally.

## minted and Pygments

minted is not in the template, so this applies only to a book whose
`preamble/packages.tex` loads it. Where it is loaded, it needs `-shell-escape`,
a Python with Pygments, and `TEXMF_OUTPUT_DIRECTORY`. All three belong in that
book's `.latexmkrc`; do not remove them.

Which lexers are available is a Pygments question, not a LaTeX one. Check that a
lexer exists before writing a listing against it, and if the book aliases one
under another name with `\newminted`, its SPEC says why.

## Page numbers in the PDF

Frontmatter uses roman numerals, so the printed page number and the physical
page index differ by a constant. When reading `build/main.pdf` to inspect a
chapter, get the printed page from `build/main.toc` first, then add the offset.
A chapter's page count is the difference between its own TOC entry and the next
chapter's.

## Line endings

`.gitattributes` normalises to LF in the repository while the working tree on
Windows is CRLF, so git prints "LF will be replaced by CRLF" warnings on commit.
These are expected and not a problem. A schema or output file compared
byte-for-byte across platforms needs its line endings normalised first.
