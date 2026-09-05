# Tone: Textbook

**Use for:** coursebook and academic monograph chapters: definitions, theory, derivations,
exercises with model answers.

**Person and personality level:** `restrained`. Third person for the subject. The expository "we"
("we now show...") is the one sanctioned first person; it means author and reader working
together, never the author's biography.

**Sentence rhythm:** even and unhurried is correct here; this is the one book tone where a steady
cadence is a feature. Complexity goes into precision, not into subordinate-clause nesting.

**Linking:** the even cadence of this tone rests on connection, not juxtaposition. Each section
opens with a sentence that hooks into the previous section's conclusion ("the bound above holds
only while...", "so far we have..."); within a paragraph each sentence attaches to the one before
through a relation word, a pronoun with a clear antecedent, or repetition of the topic. Economy
cuts the warm-up paragraph, not the transition sentence: one sentence joining two sections is the
argument's thread, not padding.

**Economy:** `standard` as the floor, widened by the difficulty of what is being explained. A
passage explaining a hard definition or concept takes the room it needs, `expansive` for that
passage alone: intermediate steps written out, an example the reader can compute, a sentence on
why the object is needed before what it is. Easy or familiar material stays at `standard`. The
four `tight` tests still apply to every added sentence, so widening adds steps and examples,
never restatement. A derivation shows every step, and a step is not padding. What still gets cut
is the prose around the mathematics: the paragraph announcing the theorem to come, and the one
summarizing what the section proved. See ECONOMY in `SKILL.md`.

**Terminology:** define a term before first use, then one name per concept for the whole book.
§11 does more damage here than any other pattern: a beginner reads "model", "network", and
"architecture" as three different things. Number definitions and theorems if the book's apparatus
does, and cite them by number thereafter.

## Tells specific to this tone

- **Promotional framing of the field** (§1, §4). "Machine learning has revolutionized...", "plays
  a crucial role in modern...". A textbook assumes the reader is already in the room.
- **Anecdote intrusion.** A war story mid-derivation belongs in a practitioner chapter or a marked
  sidebar. The running text stays impersonal.
- **Difficulty-flattening.** "simply", "it is easy to see", "obviously", "the proof is trivial".
  If it were, the sentence would not need saying.
- **Uncited consensus** (§5). "It is widely accepted that...". Cite it or derive it.
- **Enthusiasm markers.** Exclamation points, "remarkably", "beautifully". Let the result be
  remarkable on its own; the reader can tell.
- **A reference with no antecedent.** "this", "that notion", "the next section" with no target
  the reader can point to. Name the section, chapter or theorem.
- **A source's term used as if familiar.** A symbol or word taken from the cited paper appears
  before it is defined, and the sentence means something only to a reader who has read that
  paper. Define or gloss at first use; a symbol never first appears inside a numbered theorem.
- **A technical result compressed into one sentence.** Three or four unexplained concepts in
  one sentence: the reader parses the grammar and extracts nothing. Split into steps, one
  concept per sentence, and widen economy for that passage.

## Before and after

**Before:** Gradient descent is a truly remarkable algorithm that plays a pivotal role in the
modern deep learning landscape. It is easy to see that it converges. Simply follow the negative
gradient!

**After:** Gradient descent updates the parameters in the direction of the negative gradient of
the loss. Under the convexity assumption of Section 3.2, Theorem 3.4 shows that the iterates
converge to the global minimum.
