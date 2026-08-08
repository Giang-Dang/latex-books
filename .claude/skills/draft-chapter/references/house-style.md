# House style

LaTeX and prose conventions shared by books in this repo. A book's own
`SPEC.md` overrides anything here; read its writing-rules section first.

## Contents

- Prose voice
- Citations and quoting
- Inline code and listings
- Figures
- Index entries
- Labels and cross-references
- Chapter apparatus

## Prose voice

Take the voice from the previous drafted chapter's files rather than from this
list. What follows is what those files already do, recorded so a drift is
noticeable.

First person singular, opinionated where experience warrants, and willing to
concede. No contractions in the author's own voice; they appear only inside
quoted material. Sentence length varies, and a short declarative sentence lands
the end of a paragraph or section. Sections end on a hinge into the next one.

Claims are concrete: a company, a date, a number, a name. Vague authorities
("experts argue", "industry reports") are the thing this style exists to avoid.

Spelling follows the book. The federation book is British-leaning
("organisation", "centre", "labelled", "initialisation"), with the exception
that product and API names keep their own spelling: HotChocolate ships
`Types.Analyzers`, so its analyzers are analyzers.

## Citations and quoting

- `~\autocite{key}`, **always** with the tilde, so a bracketed number can never
  begin a line.
- `\enquote{...}` for every quotation. Never a literal `"` in prose.
- One `refs.bib` per book, grouped under `%---` banner comments by chapter.
  Every `@online` entry carries a real `urldate`, and a `note` or `addendum`
  recording provenance caveats.
- Fetch every URL before citing it. Cite the final form after redirects.
- Vendor sources are usable only when a named engineer is named in the prose.
  Check the byline, not the domain: two posts on the same vendor blog can have
  different authors.

## Inline code and listings

`\code{...}` is the only custom macro for inline code. Do not redefine it;
drafted chapters depend on its current behaviour.

Listings sit inline in the prose. They are not floats, carry no caption and no
label, and the surrounding text introduces them.

Language environments, per the federation book's decision 23:

- `\begin{minted}{csharp}` for C#
- `\begin{minted}{graphql}` for executable operations (queries, mutations)
- `\begin{graphqlsdl}` for schema definition language
- `\begin{minted}{text}` for shell commands and compiler output
- `\begin{minted}{json}` for responses

`graphqlsdl` is minted's Ruby lexer under an honest name, because Pygments has
no SDL lexer and its `graphql` lexer emits Error boxes on type definitions.

**Every listing is real code from the companion repo at the chapter's tag.**
Before the repo exists, a book may permit illustrative sketches, but the prose
must frame them as sketches; check the book's decision log.

Long inline `\code{}` spans cause overfull boxes because a 40-character
identifier will not break. Display it as a listing or reword around it.

## Figures

TikZ sources live in `figures/tikz/chNN-<slug>.tex` as a **bare
`tikzpicture`**. The `figure` environment, `\caption` and `\label` stay at the
call site in the section file.

Only `arrows.meta` and `positioning` are loaded. Using `calc`, `fit`,
`shapes.geometric` or `backgrounds` will not compile. Existing figures use
hand-placed absolute coordinates, `-{Stealth[length=2mm]}` arrowheads,
`rounded corners=2pt`, node dimensions in mm, and `font=\small`.

Beware reserved TikZ key names when declaring styles: `in`, `out`, `step`,
`shift`, `scale`, `text` and `style` are all taken and fail confusingly.

Captions argue a point in two or three sentences rather than naming the picture,
and the prose references the figure before it appears. Books are likely printed
in mono, so carry meaning with dashed/solid, grey, and fill shade rather than
colour.

## Index entries

On their own line, immediately before the paragraph they belong to, terminated
with `%` so no spurious space enters the text:

```latex
\index{schema!governance}%
The paragraph starts here.
```

Use `!` for subentries. For a concept that spans a section, open and close a
range with `\index{Mosaic|(}` and `\index{Mosaic|)}`. The index is maintained
while writing, never retrofitted.

## Labels and cross-references

- Chapters: `\label{ch:<slug>}`, already present in every stub.
- Numbered sections: `\label{sec:chNN-<slug>}`.
- Figures: `\label{fig:chNN-<slug>}`.
- Appendices: `\label{app:<slug>}`.

Reference them with a lowercase word and a non-breaking tilde:
`chapter~\ref{ch:composition}`, `section~\ref{sec:ch02-dev-loop}`,
`figure~\ref{fig:ch02-mosaic-v1}`.

Never hardcode a chapter number in prose. Forward references to undrafted
chapters resolve because every stub already carries its label.

## Chapter apparatus

`ch.tex` holds `\chapter`, `\label`, a short opener of a few paragraphs, then
one `\input` per section. All paths are written from the book root, never
relative to the current file.

Section files are `NN-name.tex`, zero-padded so filesystem order matches book
order.

The end-of-chapter lab is a plain `\section*{Your turn}`: no label, no TOC
entry. It opens with framing, then a numbered list whose items begin with a
bolded imperative (`\item \textbf{Map the owners.}`), and closes by saying what
a dull result would mean or pointing forward.
