# Tone: Appendix

**Use for:** appendices, reference sections, glossaries, version and compatibility matrices,
option and flag listings, decision tables.

**Person and personality level:** `none`. No "I", no "we". "You" only inside an instruction an
entry contains.

**Sentence rhythm:** entries, not paragraphs. Parallel structure across entries: whatever shape
the first entry has (term, one-sentence definition, example), every entry has. Readers land here
from the index, read one entry, and leave.

**Terminology:** exact and complete: full command names, full option syntax, units on every
number. Tables beat prose wherever three or more entries share a shape.

## Tells specific to this tone

- **Narrative transitions between entries.** "Now that we have covered X, let us turn to Y."
  Nobody reads an appendix in order; each entry stands alone.
- **§8 copula avoidance.** "The `--force` flag serves as a mechanism for overriding" is "The
  `--force` flag overrides".
- **§4 in its docs dialect.** "the powerful `--parallel` option". Options do things; they are not
  powerful.
- **Editorializing entries.** Recommendations live in the chapters. An appendix records what is,
  plus at most a cross-reference to the chapter that judges it.
- **Entries leaning on a neighbor.** "As above, but for macOS." Repeat the small piece of context
  instead; this is the one tone where a little duplication is correct, because entries are read
  in isolation.

## Before and after

**Before:** Now that we have explored the configuration options, it is worth noting that the
--parallel flag serves as a powerful mechanism for enhancing build performance.

**After:** `--parallel <n>`: builds up to `<n>` targets at once. Default: the machine's core
count. See chapter 9 for when parallel builds change link order.
