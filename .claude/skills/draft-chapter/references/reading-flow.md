# Reading flow

How a chapter stays followable by the reader the SPEC describes. No family of
`check-chapter.ps1` can see any of this, so two things carry it: the order the
prose is drafted in, and the audit's report item for it. Read this before
drafting the first section, because these are decisions about order, and order
is expensive to fix after the fact. The same failures have recurred across books
written in different voices and different languages, which is why they live here
and not in one book's SPEC.

## Contents

- The reader
- The hand-off
- Openers
- Defined before used
- Behaviour before concept
- Antecedents and forward references
- Room for hard material
- One example the reader can compute
- Printed output
- A scoping decision propagates
- The correction pass
- Before and after

## The reader

Write and judge as the reader the SPEC describes, wherever it describes them.
That reader holds only the pages before this one: not the sources, not the
research note, not the session's memory of what a sentence was meant to say.
Where the SPEC does not say who the book is for, that is the one question worth
asking the author before drafting, and the answer becomes a decision row so the
next session inherits it.

The first chapter of a book states what it assumes the reader already knows and
names where later chapters build what they need. A reader who cannot find that
paragraph cannot tell a gap in the book from a gap in themselves, and most of
them decide it is theirs and stop.

## The hand-off

A chapter's closing paragraph is a promise to the reader: it hands the next
chapter a case, a question or an unresolved result. The opener answers that
paragraph, not a thread from the previous chapter's middle. So the closing
paragraph is read twice in Orient: once as part of the voice specification, and
once on its own, as the sentence the opener has to answer. If the opener cannot
answer it, change the closing paragraph in the same session. A promise left
standing is what an audit reads as a chapter that starts in the wrong place.

Drafting chapters out of order costs exactly one opener, and it is cheap only
under two conditions: the debt is written into the SPEC's open items the moment
it is incurred, and the borrowed opener states the shape of the previous
chapter's argument rather than a finding from it. A shape survives the previous
chapter being drafted; a finding does not.

## Openers

The chapter's first move is one sentence saying what the chapter establishes. A
chapter that needs two such sentences is two chapters. Every section opens with
a sentence that ties to the previous section's conclusion.

This is not the setup paragraph the humanizer cuts. The test is what the
sentence carries. A connective sentence states the relation between the last
claim and the next one ("the bound above holds only while the table is sparse,
which is the assumption this section removes") and stays. An announcing
paragraph says that a claim is coming ("in this section we will look at") and
goes. Economy cuts the second, never the first: one sentence joining two
sections is the argument's thread, not padding.

## Defined before used

A term or symbol is defined or glossed at its first use in the chapter, or the
sentence points to where the book defined it (`section~\ref{...}`), never
neither. A symbol never appears for the first time inside a numbered theorem or
definition: the statement is the hardest place on the page to stop and learn a
name, so introduce the symbol in the prose before it.

A source's term is not familiar to the reader because it is familiar to the
source. A sentence that only means something to someone who has read the cited
paper is a sentence about the paper, not for the reader. A table of results
whose rows name procedures the prose has never described is the largest single
failure this file exists to prevent: one sentence per row, before or beside the
table.

One name per concept for the whole book is already a rule in every humanizer
tone profile a chapter is drafted under; it holds here for the same reason.

## Behaviour before concept

No concept is explained before the reader has seen the behaviour or the need it
explains. A definition is preceded by a sentence on why the object is needed; a
mechanism is preceded by the thing it accounts for. Material the book has not
built yet, a piece of mathematics, a tool, a protocol, is built just before it
is needed, in the chapter that needs it, not imported by reference to something
outside the book.

An aside, callout or sidebar is skippable. A reader who skips every one of them
still follows the thread; if they would not, the content belongs in the running
text.

## Antecedents and forward references

Within a paragraph, consecutive sentences connect through a relation word, an
explicit antecedent or repetition of the topic, never bare juxtaposition. "This",
"that view", "the third one" each point at something the reader can name aloud.

A forward reference names its target, `section~\ref{sec:...}` or
`chapter~\ref{ch:...}`, never "the next section" or "later". House-style's label
rules make this free, because every stub already carries its label.

## Room for hard material

A reader finishes a passage without knowing what it said in one of four shapes:

- a derivation that skips the step defining its object;
- a technical result compressed into one sentence with several terms the
  reader has not met;
- a term or symbol used before its definition;
- a reference with no antecedent.

All four are compression, so the fix is the same: economy flexes with the
difficulty of what is being explained. A hard definition or concept takes the
room it needs, the intermediate steps written out, an example the reader can
compute, why-before-what, while easy or familiar material stays at the level the
book's tone profile sets. Widening adds steps and examples, never restatement;
the tests of tight economy still apply to every added sentence.

## One example the reader can compute

A run of chapters that offers no example the reader could work by hand is a run
the reader takes on trust. One small worked example threaded through several
chapters beats a new example per chapter: each new concept is shown on the
example the reader already holds, and the example is small enough to compute on
paper. Choose it early, record it in the SPEC as a decision, and reuse it rather
than reaching for a fresh one.

## Printed output

A captured block, console text, a JSON response, a query plan, an error, is
part of the argument or it is a hole in it. The reader stops reading at a block
they have to scan, and does not reliably start again.

The sentence before a block names the one thing the reader is meant to see in
it, and the block is cut to the lines that carry that thing. Two blocks never
sit back to back: the prose between them says what changed. A long capture that
the chapter needs whole gets its own subsection or an appendix, not the middle
of a paragraph.

Trimming is legitimate only where the prose does not call the block a capture.
The book's `Listings:` line and the verbatim family of the check script decide
that, so read both before cutting, and where the SPEC requires it, say on the
page what was cut.

## A scoping decision propagates

When a section narrows or settles what the book means by something, every later
passage in the chapter holds to it, and later chapters inherit it.
Half-propagated scoping is a comprehension failure the auditor reads as a
contradiction: the chapter asserts in section five what it denied in section
two. After making such a decision, search the chapter for the term and re-read
each hit, then record the decision in the SPEC so the next session cannot undo
it by accident.

## The correction pass

A session that has just found an error is at its least suspicious of the fix.
In a whole-book correction pass, the cold audit's findings land mostly in the
pass's own additions. So treat every passage a revision adds as new prose: audit
it under the same brief, name it nowhere in the brief (the rule against
self-assessment in `references/audit.md` already covers this), and re-read the
fix with the suspicion you brought to the defect.

## Before and after

Prose first. The domain is one no book in this repo touches.

**Before:**

> Because $\alpha$ stays below the threshold, the amortised argument of the
> previous section applies and the theorem gives $O(1)$ expected cost per
> operation with $\alpha$ in place of $n/m$. This is why resizing is cheap. The
> next section makes this precise.

**After:**

> Section~\ref{sec:ch07-chaining} ended with a table that slows as it fills: the
> average chain held $n/m$ keys and the lookup cost grew with it. That ratio is
> what this section turns on, so give it a name: the *load factor*
> $\alpha = n/m$ is the number of stored keys divided by the number of slots. On
> the running example, eight slots holding six keys give $\alpha = 0.75$;
> inserting two more pushes it to $1.0$, which is where the chains in the last
> section began to lengthen. Resizing keeps $\alpha$ below a fixed bound by
> doubling $m$ whenever the bound is crossed. The theorem below shows that the
> doubling costs $O(1)$ per insertion averaged over the run, and
> section~\ref{sec:ch07-choosing-bound} says how the bound is chosen.

What moved: the opener ties to the named previous section's conclusion;
$\alpha$ is defined before use and outside the theorem; the behaviour (chains
lengthening) comes before the concept (resizing); the definition is computed on
the running example; "this" and "the next section" are replaced by targets the
reader can name.

Then printed output.

**Before:**

> Running it gives:
>
> (forty lines of stack trace)
>
> (twelve lines of the same command's output after the fix)

**After:**

> Running it fails, and the line that matters is the third one: the lookup is
> called with the table's old size after the resize has already run.
>
> (the three lines that show that)
>
> Moving the resize after the lookup changes one line of the output: the count
> now matches the number of keys inserted.
>
> (the one line that shows that)

What moved: each block is introduced by a sentence naming what to look at; each
is cut to the lines that carry it; prose between the two says what changed.
