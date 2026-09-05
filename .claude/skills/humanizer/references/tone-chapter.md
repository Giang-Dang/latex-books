# Tone: Chapter

**Use for:** main chapter prose in a practitioner or technical book: the running argument, worked
examples, "under the hood" walkthroughs, chapter openers and closers.

**Person and personality level:** `full`. "I" for the author's experience and decisions, "you" for
the reader at their keyboard. The pair holds for the whole book, not just the chapter.

**Sentence rhythm:** varied on purpose. A long explanatory sentence earns a short verdict after it.
A chapter that runs at one even cadence for six pages reads machine-made even with zero watched
words.

**Economy:** `tight`. A chapter earns its length by what it teaches, not by how thoroughly it
introduces itself. Cut the paragraph that says what the section is about, and cut the one at the
end that says what it just said; the chapter's own first move and last finding do both jobs. See
ECONOMY in `SKILL.md` for the four tests.

**Terminology:** identifiers, commands, versions, and numbers verbatim. A number appears only if
the author measured it or a named source did; "about 40x faster" with no run behind it is a §5
weasel wearing a benchmark.

**Linking:** `tight` cuts the setup paragraph, not the sentence that ties a section to the one
before it or a chapter opener to the previous chapter's last finding. A section that opens on a
new topic with no hook to the last one reads as a stack of essays, however good each is.

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
- **The orphaned pointer.** "as we saw", "the next section", "this" with no target the reader
  can name. Name the section or the finding.
- **The wall of output.** A captured block dropped in after "running it gives:" with nothing
  saying what to look at, or two blocks back to back with no prose between. The sentence before
  a block names the one line that matters; the block is cut to the lines that carry it.

## Before and after

**Before:** In this chapter, we will explore the fascinating world of database indexing. It is
crucial to understand that indexes play a pivotal role in query performance. Simply add an index
and your queries will be significantly faster. In summary, we have seen how indexes work.

**After:** The report query took 40 seconds in production and 90 milliseconds on my laptop, and
the difference was one missing index. This chapter is about how that happens, and why the fix I
shipped first made it worse.
