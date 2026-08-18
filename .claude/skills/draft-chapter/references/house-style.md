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

Take the voice from the previous drafted chapter's files rather than from any
description of it, this one included. A paraphrase of a voice is a different
voice; the prose is the specification.

The library default in `AGENTS.md` is a first-person practitioner: direct,
concrete, opinionated where experience warrants it. What a given book actually
sounds like is the `Voice:` line in its SPEC's writing-rules section, which is
also where the specifics live - contractions, sentence rhythm, how a section
ends. That line wins over this one.

Claims are concrete: a company, a date, a number, a name. Vague authorities
("experts argue", "industry reports") are the thing this style exists to avoid.

Spelling follows the book. Which variety, and which words are exempt from it,
are settings in the book's `check-chapter.psd1`; the reasons they were chosen
are in its SPEC. Read the psd1 rather than guessing the variety from the prose,
because an exemption looks exactly like an inconsistency.

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

A book declares its listing environments in its SPEC, and adding one is a
decision recorded there rather than a choice made mid-chapter. What the check
script actually discovers is different and narrower: the `\newminted[NAME]`
aliases in that book's `preamble/packages.tex`. Read both before picking an
environment for a new listing - an environment named only in prose is one that
nothing typesets and nothing checks.

**Every listing has a source outside the draft, and the prose is honest about
which.** Where that source is, is the `Listings:` line in the book's SPEC. A book
with a companion repo takes every listing from it at the chapter's tag. A book
with none ships no listings at all, unless that line names what it may show
instead - pseudo-code, a sketch, a fragment quoted from a cited source - and says
how the prose frames each, in which case the prose calls each one what it is. A
line that names only environments has not answered this, and silence in it is not
permission. A book whose repo is planned but not yet created is in the same
position meanwhile, and what it allows until then is a row in its decision log.

What no book does is print invented code as though it ran. That is the half the
SPEC does not get to set: a book chooses which sources are legitimate for it, and
a listing that claims a provenance it does not have is not a choice any wording
makes available.

Long inline `\code{}` spans cause overfull boxes because a 40-character
identifier will not break. Display it as a listing or reword around it.

A listing has a column budget of its own, set per book in `check-chapter.psd1`
as `Listings.MaxLineLength`. Over it, the line wraps on the page and the build
log stays silent, so write the listing to fit rather than trusting a clean log;
a block that needs more width declares its own `fontsize`. See
`references/environment.md`.

## Figures

TikZ sources live in `figures/tikz/chNN-<slug>.tex` as a **bare
`tikzpicture`**. The `figure` environment, `\caption` and `\label` stay at the
call site in the section file.

The template loads `arrows.meta` and `positioning` and nothing else, so a book
that wants `calc`, `fit`, `shapes.geometric` or `backgrounds` adds the
`\usetikzlibrary` line to its own `preamble/packages.tex`. Read that file before
reaching for a library: a missing one fails at compile time with an error that
names the key rather than the library.

Match the idiom of the book's existing figures - how coordinates are placed,
which arrowhead, corner radius, node sizing, font sizes - and read one of them
end to end before drawing a new one. The book's SPEC records the idiom, but the
figures themselves are the authority, and a picture drawn to a different idiom
reads on the page as a picture from another book.

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
\index{deployment!rollback}%
The paragraph starts here.
```

Use `!` for subentries. For a concept that spans a section, open and close a
range: `\index{<term>|(}` on the first paragraph and `\index{<term>|)}` on the
last. The index is maintained while writing, never retrofitted.

## Labels and cross-references

- Chapters: `\label{ch:<slug>}`, already present in every stub.
- Numbered sections: `\label{sec:chNN-<slug>}`.
- Figures: `\label{fig:chNN-<slug>}`.
- Appendices: `\label{app:<slug>}`.

Reference them with a lowercase word and a non-breaking tilde:
`chapter~\ref{ch:example}`, `section~\ref{sec:ch02-first-section}`,
`figure~\ref{fig:ch02-diagram}`.

Never hardcode a chapter number in prose. Forward references to undrafted
chapters resolve because every stub already carries its label.

## Chapter apparatus

`ch.tex` holds `\chapter`, `\label`, a short opener of a few paragraphs, then
one `\input` per section. All paths are written from the book root, never
relative to the current file.

Section files are `NN-name.tex`, zero-padded so filesystem order matches book
order.

If the book has an end-of-chapter lab, it is a plain `\section*{<heading>}`: no
label, no TOC entry, because nothing cross-references a lab and a starred
heading is one line rather than a macro. The heading itself and the shape of
the exercises belong to the book, and its SPEC records both.
