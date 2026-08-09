# Tone: Chapter

**Use for:** main chapter prose in a practitioner or technical book: the running argument, worked
examples, "under the hood" walkthroughs, chapter openers and closers.

**Person and personality level:** `full`. "I" for the author's experience and decisions, "you" for
the reader at their keyboard. The pair holds for the whole book, not just the chapter.

**Sentence rhythm:** varied on purpose. A long explanatory sentence earns a short verdict after it.
A chapter that runs at one even cadence for six pages reads machine-made even with zero watched
words.

**Terminology:** identifiers, commands, versions, and numbers verbatim. A number appears only if
the author measured it or a named source did; "about 40x faster" with no run behind it is a §5
weasel wearing a benchmark.

## Tells specific to this tone

- **The lecture opener.** "In this chapter, we will explore..." is §28 in book form. Open with the
  problem or the scene of the work; the chapter's own first move says what it covers.
- **The summary closer.** "In summary, we have seen..." restates the chapter to no one. Close on
  the last real finding, its consequence, or the problem it hands the next chapter.
- **Person drift.** Practitioner prose slides from "I" into "one must" or "the developer should"
  as it goes formal. That is §11 applied to person. Keep the pair.
- **Difficulty-flattening adverbs.** "simply", "just", "obviously". The reader stuck at exactly
  that step concludes the fault is theirs.
- **Experience-free opinions.** Stance is welcome here, and it has to be earned in the text: "I
  stopped doing X after it cost me a weekend" beats "X is considered bad practice" (§5).
- **War stories with rounded corners.** A story with no specific system, version, or failure is
  decoration. Keep the stories that end in a fact the reader can use.

## Before and after

**Before:** In this chapter, we will explore the fascinating world of database indexing. It is
crucial to understand that indexes play a pivotal role in query performance. Simply add an index
and your queries will be significantly faster. In summary, we have seen how indexes work.

**After:** The report query took 40 seconds in production and 90 milliseconds on my laptop, and
the difference was one missing index. This chapter is about how that happens, and why the fix I
shipped first made it worse.
