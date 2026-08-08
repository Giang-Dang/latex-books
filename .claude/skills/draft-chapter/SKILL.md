---
name: draft-chapter
description: Drafts, outlines, or continues a chapter, section, or appendix of a book under books/ in this repo, following that book's SPEC.md. Use for any request to write or continue book content, even phrased loosely, e.g. "draft chapter 7", "continue the federation book", "write the next section", "outline chapter 12".
---

# Draft a chapter

Thin v1: mechanics only. Fold style lessons learned back into this skill after
the first few chapters are written.

1. Identify the target book and chapter. One book in books/ -> that one;
   otherwise take it from the request or ask. Read books/<name>/SPEC.md fully:
   the TOC entry scopes the chapter, the decision log constrains content, the
   progress table shows prior state.
2. Scaffold to convention if missing: chapters/NN-slug/ch.tex holds \chapter
   and \label and \input's one file per section (NN-name.tex, zero-padded,
   paths written from the book root).
3. Draft following the writing defaults in CLAUDE.md plus the SPEC's writing
   rules. Code listings come from the companion repo named in SPEC; if the
   repo or a snippet does not exist yet, record that in SPEC open items
   instead of inventing code.
4. Compile: cd books/<name> && latexmk. While iterating, uncomment
   \includeonly in main.tex for the chapter; comment it back out and rebuild
   clean before finishing.
5. Update SPEC.md: the progress row, the TOC (only if structure changed), and
   open items.

Done when the full book compiles with zero errors and SPEC.md reflects the new
state.
