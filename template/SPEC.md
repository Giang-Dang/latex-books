# SPEC - Book Title

Source of truth for this book: decisions, approved TOC, and progress. Read it
fully before working on the book; update the progress table before finishing a
working session.

## Status

One line: current phase and the next action.

## Decision log

Settled decisions as question -> answer. Add rows as decisions are made. A
settled row is re-opened only by recording what changed and why, in the row.

| # | Question | Decision |
|---|----------|----------|

## Version baseline

Toolchain and library versions the book is written against, with the date they
were last verified.

## Table of contents

The approved part/chapter structure with a one-line scope per chapter. If
drafting deviates from this list, update the list in the same session.

## Progress

Status values: not-started / outlined / drafted / reviewed / final.

| Chapter | Status | Notes |
|---------|--------|-------|

## Writing rules (book-specific)

Deviations from and additions to the library-wide defaults in AGENTS.md. The
machine-checkable half of these rules is check-chapter.psd1 in this folder; keep
the two in step, because a rule here that nothing enforces and a setting there
that no rule explains both rot.

Fill in every slot, including the ones where the answer is the library default
or "none". A slot left blank reads as an oversight; a slot that says "none"
reads as a decision.

- **Voice:** name the voice, even when it is AGENTS.md's first-person
  practitioner, because the draft-chapter skill reads this line to pick a
  humanizer tone profile and has nothing to go on without it.
- **Language and spelling:** the language the book is written in, the spelling
  variety, and the words exempt from it; set the same variety in
  check-chapter.psd1's Spelling.Preset.
- **Humanizer skill:** which humanizer the book's language needs (humanizer for
  English, humanizer-vi for Vietnamese).
- **Listings:** which listing environments the book uses and what each is for,
  where code comes from, and what proves it runs - or "no code".
- **Figures:** this book's figure idiom: what a picture is drawn with, which
  file its source lives in, and what stays at the call site.
- **Chapter apparatus:** the end-of-chapter lab's heading and shape, and
  anything else every chapter is expected to carry - or "none".
- **Companion code:** the repo, the one command that verifies a chapter's code
  before its prose is written, and the tag convention chapter prose cites - or
  "none".
- **Research:** whether the book keeps notes under research/, and what a note
  has to record; see research/README.md for what the first note switches on.
- **Sources:** the citation and vendor-source rules this book adds on top of
  AGENTS.md, and how a number the author measured is presented.

## Open items

Unresolved questions and deferred work, each with the condition that unblocks
it.
