# Research notes

One file per chapter or topic, holding the sources, the commands, and the raw
measurements a chapter was written from. Nothing here is typeset; this folder
exists so that a claim in the book can be traced back to where it came from,
months later, by someone who is not the person who made it.

## The cliff

`scripts/check-chapter.ps1` reads this folder. Its behaviour changes completely
the first time a note lands, and the change is not gradual:

- **No notes on disk.** The number check and the verbatim check are skipped
  entirely. Not relaxed - skipped. The book can print any decimal it likes and
  call any listing a capture, and the run still says clean.
- **One note on disk.** Every decimal printed anywhere in the book must now
  appear in some note in this folder, and every substantial line of a listing
  the prose calls a capture must appear too. A number nobody wrote down becomes
  a finding on the next run.

That is a deliberate cliff rather than an oversight. A book with no measurements
should not be nagged about the ones it does not have, and a book that has
started measuring should not be allowed to mix traced numbers with remembered
ones. But it means an author can switch the strictest two checks on by dropping
a file here, so meet that transition on purpose: add the first note when the
book starts printing measurements, and expect the next run to have something to
say about the decimals already in the manuscript.

This README is itself a `*.md` file in this folder, and it does not count. A
README documents the folder rather than recording a measurement, so
`check-chapter.ps1` excludes it from the notes it reads; otherwise a new book
would cross the cliff before writing a single note, and a number could trace to
the very file explaining what tracing means.

Do not leave the transition half-way once you have crossed it. A folder of
notes that does not contain the numbers in the book is a gate that fails for
the wrong reason, and the usual next move is to switch the check off, which
costs more than it saves.

## What a note holds

Enough to reproduce the claim without the author. In practice that means the
exact command or query, the version of everything involved, the raw output
rather than a summary of it, and the date. Numbers are recorded as measured, to
whatever precision they came out at; the book may round when it prints them.
Record what was measured and turned out to be uninteresting as well, because the
alternative is measuring it again.
