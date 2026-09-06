# Chapter 16 - the three escape routes and what each one costs

Date: 2026-09-06. Ninth chapter note in this folder, one per chapter from
chapter 08 on (decision 35), and the second outside Part IV.

**This is the first chapter in the book that reads no new paper.** Its four
papers, 21, 24, 18 and 32, were each close-read by an earlier chapter, so the
work of this session was not reading but re-reading: going back to the pages for
the one question no earlier chapter asked of them, which is what each escape
route costs. That turned out to be the right question to re-open the PDFs for,
because **two of the four papers do not say what the chapter's own
table-of-contents line assumed they said**, and one of them says the opposite.

The single most important entry is the paper 24 finding below. The initialized
TOC line prices all three routes, and paper 24 argues at length that the price
of its route is not the obstacle. That is a new way for a TOC line to fail and
it is recorded as such.

## Source pins

No new key. Every paper here is already in refs.bib with a `note` field
recording the revision read; this session re-verified all four stamps against
the PDFs and, where the record moved, says so.

| Key | arXiv | Revision | Pages | First read by | Re-verified this session |
|---|---|---|---|---|---|
| `p21metrics` | 2605.25052 | v1, the only one | 31 | chapters 08 and 09 | stamp, page count, submission history |
| `p24humangap` | 2503.16507 | v1, the only one | 7 | chapter 12 | stamp, page count, submission history |
| `p18unified` | 2501.18887 | v3 | 25 | chapter 07 | see the paper 18 section |
| `p32cbmsae` | 2512.10805 | v2, the later of two | 15 | chapter 15 | see the paper 32 section |

Paper 18 is the one paper of the four that **has no research note anywhere**,
because chapter 07 was drafted before this folder existed (decision 35 starts
the notes at chapter 08). Everything this chapter prints from it is therefore
recorded here for the first time, and this note is the anchor for it.

## Corrections this session made to earlier notes

All three were found by re-reading rendered pages rather than extractions, and
**none of the three reached the manuscript**, so nothing shipped wrong. They are
recorded because a note is what the next session quotes from.

1. `ch12-con-nguoi-vang-mat.md` had `expertise, knowledge, education` inside a
   verbatim block where paper 24 p. 5 prints `expertise, workplace, education`.
2. The same file had `domain experts who are not working on the tool with you`
   where the page prints `domain experts who you are not working on the tool
   with`.
3. `ch09-bai-bao-neo.md` filed a main-text sentence from paper 21 p. 5 under an
   appendix A.1 anchor and printed `that` where the page prints `which`. The
   same file's structure line is off by one at both seams: paper 21's conclusion
   opens on p. 10, references run 10 to 18, appendix A opens on 18.

The lesson is the one decision 73's second half already records, arriving in a
smaller form: a transcription is checked against the page, not against the note
that copied it.

## Route 1 - ground truth dựng sẵn (paper 21)

Structure re-derived from the PDF: main text 1-10, references 10-18, appendices
A through G on 18-31.

### What the paper says its own construction costs

**The paper has exactly one Limitations paragraph, on p. 9, and it is narrower
than the chapter's first draft of the argument assumed.** Verbatim, read from
the rendered page:

> Using our methodology, we can obtain ground-truth knowledge for specific steps
> we know had to have occurred in the model. However, any given CoT will contain
> many additional steps for which our setting provides no signal. This
> precision-first design also skews the distribution of CoT-level labels.
> Labeling a CoT as faithful requires every one of its steps to be either
> faithful or inert, while a single unfaithful step or a missing bottleneck step
> suffices to label it unfaithful. Faithful CoTs are therefore harder to certify
> than unfaithful ones, and BONAFIDE contains fewer of the former than the
> latter.

Two costs, both internal to the construction: **partial coverage inside a single
trace**, and **label skew**. Nothing about narrowness of the task set, nothing
about realism, nothing about transfer.

### The external-validity charge is the book's, and the paper pre-empts it

Full-text search over all 31 pages, `pdftotext -layout`, page-anchored:

| String | Count |
|---|---|
| `external validity` | 0 |
| `generaliz` / `generalis` | 0 |
| `artificial` | 0 |
| `realis*` | 0 |
| `real-world` | 0 |
| `narrow` | 0 |
| `limitation` | 2 (the p. 9 heading; p. 9 related work, about *prior* benchmarks) |
| `synthetic` | 2 (p. 9, about another paper's synthetic explanations; p. 17, a title) |

So the sentence "constructed ground truth buys a criterion and pays in
representativeness" cannot be attributed to paper 21. **The chapter states it as
the book's own reading**, and it has to, because the paper answers the charge
directly, p. 9 related work:

> Our approach instead evaluates real CoTs against computations we have
> ground-truth knowledge about having occurred.

The paper's claim is that the *traces* are real even where the *tasks* are
built. The chapter quotes this rather than pretending the question was never
faced, and then prices the route on the numbers below, which are the paper's own.

The paper's own hedge, contribution (b), p. 2, is the honest version of the same
concession and the chapter uses it: the methodology rests on

> task designs that make a model's internal computations partially recoverable
> from its outputs

### Table 10, p. 28 - what the designed tasks actually reach

Read from the rendered page. The `-layout` extraction interleaves this table and
produces wrong rows; do not take it from there.

| Step type | SimpleQA | HLE | DDXPlus | Outright | Total |
|---|---|---|---|---|---|
| Misattribution | 660 | 209 | 32 | 0 | 901 |
| Bottleneck execution | 0 | 87 | 0 | 486 | 573 |
| Faithful commitment | 115 | 191 | 122 | 0 | 428 |
| Tool call | 15 | 28 | 1 | 0 | 44 |
| Total | 790 | 515 | 155 | 486 | 1946 |

Caption, p. 28, verbatim: `Step-level label distribution by dataset and step
type. Faithful commitment and misattribution arise only in the diversionary
setting.`

Arithmetic the chapter prints, and it is the book's own reading of the paper's
own table: the procedurally designed tasks, the `Outright` column, supply
**486 of 1946 step-level labels**, and they supply exactly **one of the four
step types**. The other three quarters come from planting a hint in a
pre-existing QA dataset. Column and row totals both check: 790 + 515 + 155 + 486
= 1946, and 901 + 573 + 428 + 44 = 1946.

Figure 9 caption, p. 30, verbatim: `CoT-only metrics have no results for ddxplus
since it sourced no faithful CoTs.` That is the label skew of the Limitations
paragraph made concrete on one dataset.

### The sentence that sets up the whole chapter

Section 3 opening, p. 4, read from the rendered page:

> According to our definitions, this means knowing what computations the model
> performed. But LLMs' internal computations are not directly observable, and
> current interpretability tools do not provide reliable and scalable access to
> the reasoning process underlying a given output. We overcome this challenge by
> relying on a simple observation that for certain task designs, the model's
> output informs us of which intermediate computations must have produced it.

**Route 1 exists in this paper because route 3 was judged unavailable.** The
three routes are not three parallel options in the source that proposes the
first of them; one is the consequence of another being ruled out. This is the
single most useful thing the re-read produced and section 16.7 turns on it.

Related, and it sits exactly on the route-1 / route-3 seam: paper 21 cites
**Yeo, Satapathy and Cambria, an activation-patching method for faithfulness of
natural-language explanations (EMNLP 2025)**, once, on p. 1, inside the list
`recent work has proposed various metrics for evaluating CoT faithfulness`, and
then **never benchmarks it**. Citation search finds the reference marker on p. 1
and in the bibliography and nowhere else. So the one metric in the paper's own
opening list that reads the model from the inside is the one metric BONAFIDE
does not score. The book does not read that paper and adds no key for it; it is
named through paper 21, on decision 45's precedent.

### `mechanistic` in paper 21

Two occurrences, p. 3 and p. 5, and both mean the **mechanistic reading of
faithfulness**, the reading chapter 09 already settled as `cách đọc cơ chế`. The
phrase `mechanistic interpretability` occurs **zero times**. The chapter must
not let one be read as the other. **The chapter does not in the end say so
anywhere, and that is deliberate rather than an omission:** chapter 16 never uses
`cách đọc cơ chế`, so there is no collision on the page to name, and a sentence
about a word one of its papers uses in a section about a different paper would
be a digression. Recorded here so the next session does not go looking for it.

## Route 2 - human study (paper 24)

7 pages, cs.HC, `Extended Abstracts of the CHI Conference` in Comments, no
journal-ref. Verified again this session.

### The census, re-verified from the rendered page

Table 3, p. 4, read as an image because the two-column extraction shreds it:

| Down-selection criteria | Count | % |
|---|---|---|
| Has explainability-related keywords | 18254 | 100% |
| Has claims about human explanability [sic] | 253 | 1.39% |
| Were on-topic (not surveys, etc.) | 237 | 1.30% |
| Were validated on human subjects | 128 | 0.70% |

128 of 18254 and 0.70 percent both confirmed. The `explanability` misspelling is
the paper's, confirmed at magnification rather than inferred from extraction, so
chapter 12's `[sic]` stands.

### The finding that changes this chapter

**Paper 24 does not price its route, and it argues against pricing it.**
Full-text search over all 7 pages, on both a `-layout` and a reading-order
extraction:

| String | Count |
|---|---|
| `cost` | 0 (the only hit is inside the surname *Lacoste*, ref [19], p. 7) |
| `expensive` | 0 |
| `power` | 0 |
| `IRB`, `consent`, `compensat*`, `pay`, `budget`, `burden`, `effort` | 0 each |
| `recruit` | 1 (p. 5) |
| `faithful` / `faithfulness` | 0 |
| `ground truth` | 0 |
| `fidelity` | 0 |

The one sentence in the paper that reads as a cost, p. 5:

> Of course, it can be difficult to assemble domain experts to test methods and
> tools, especially domain experts who you are not working on the tool with.
> Perhaps that is why we observed a number of papers only having two or three
> domain experts as part of the evaluation (Figure 2b).

and the paper withdraws the excuse in the next sentence:

> Regardless, it is difficult to trust generalizable claims about explainability
> when the participant pool is very small or dissimilar to the target users.

Then, p. 6, it names the cost objection as an objection and rebuts it. This is
the load-bearing passage for section 16.5:

> Common objections to empirical evaluations are that humans are biased, or it
> is difficult to assemble a representative sample of humans. We note that the
> same can be said of every commonly-used machine learning benchmark, from
> ImageNet, to IMBD movie reviews, to medical question-and-answer. All contain
> human biases from their generation, curation, cultural context, or other
> factors. They may or may not match the intended application of the system
> being tested and took extensive time to collect. Nonetheless, they are used.

> The methods to test XAI clearly exist - our literature review shows that there
> are researchers using them and publishing about them. Undoubtedly there are
> challenges in moving from testing AI solely with static datasets into testing
> with humans, but they are not insurmountable.

The reference inside `The methods to test XAI clearly exist [9]` is
**Doshi-Velez and Kim, arXiv:1702.08608**, which is the book's `p14rigorous`,
the source of the three-tier taxonomy chapter 01 and chapter 08 both use. So
paper 24's answer to "why is the human check not run" is not that it is
expensive; it is that the taxonomy has been on the table since 2017 and the
field's incentives do not require it.

### What paper 24 does document, which is a different cost

Not a resource cost, a **quality** cost, and this is what section 16.5 charges.
Body, p. 5:

> In some cases, the participants in the evaluation were never directly
> discussed. Seen in Figure 2, 13 of the papers that involved a validation did
> not report their human subject count and 3 papers reported an approximate
> count. Furthermore, in many of the papers, the authors do not disclose the
> subjects' expertise, workplace, education, or relationship to the authors.

Figure 2 and its caption are on **p. 4**, not p. 5. Caption verbatim:

> Distribution of counts for human subjects involved in an evaluation,
> experiment, interview, etc. for validated XAI papers. It is important to note
> that 13 papers did not report their human subject count and 3 papers
> approximated their count. In the bottom figure, a subset of distribution
> counts up to N=152 and a bin size of 5.

Figure 2b bin counts, read off the rendered page at 300 dpi, bin size 5 over
N in [2, 152]:

```
[2,7]=11  (7,12]=4   (12,17]=7  (17,22]=8  (22,27]=8  (27,32]=5
(32,37]=4 (37,42]=4  (42,47]=1  (47,52]=6  (52,57]=3  (57,62]=5
(62,67]=2 (67,72]=3  (72,77]=1  (77,82]=0  (82,87]=2  (87,92]=0
(92,97]=0 (97,102]=2 (102,107]=1 (107,112]=0 (112,117]=2
(117,122]=5 (122,127]=0 (127,132]=0 (132,137]=2 (137,142]=0
(142,147]=3 (147,152]=2
```

**Sum = 91**, which equals figure 2a's first bin exactly, so the transcription
checks against a second reading of a different figure. Safe readings for the
chapter: the modal validated study has **between 2 and 7 participants (11
papers)**; **38 of the 91** have 27 or fewer; the axis's left edge is **N = 2**.

**Do not print figure 2a's per-bin counts.** A visual count of 2a's bars totals
114 against the 115 that 128 minus 13 requires, and the off-by-one could not be
resolved at the available resolution. What is safe from 2a is the range, roughly
2 to 3300 subjects, and the concentration, 91 of them at 152 or fewer.

### The route's own ceiling, in the paper's words

- p. 5: `it takes confirmation that the signal was received and understood
  correctly to confirm a claim of explainability.`
- p. 5: `a validation that such signals were received and understood is still
  necessary, as previous work has shown that it is not always the case. For
  example, domain experts can be vastly overconfident in their understanding of
  XAI methods that they helped craft.` The reference for that is Siu, Leahy and
  Mann, *STL: Surprisingly Tricky Logic (for System Validation)*, IROS 2023, and
  Ho Chit Siu is an author of paper 24, so **the one piece of evidence the paper
  offers that human confidence and human correctness come apart is its own prior
  work**. Named through paper 24 on decision 45's precedent; no key added.
- p. 6, conclusion: `Without empirical evidence, it is impossible to assess
  whether explainability methods truly address the needs of end-users.`
- p. 6: `Empirical human testing is necessarily the gold standard for
  explainability claims.`

Note the noun in both of the last two: **needs of end-users**, and
**explainability claims**. Neither is definition 1.2. That is the real limit of
route 2, it is better sourced than the cost story, and section 16.5 makes it the
route's price: the route is affordable and it answers a different question.

## Route 3 - mechanistic interpretability (papers 18 and 32)

### Paper 18's record, recorded here for the first time

Paper 18 is the one paper of the four with **no research note anywhere**, because
chapter 07 read it before decision 35 started this folder. Its record, verified
this session:

- Stamp `arXiv:2501.18887v3 [cs.LG] 29 May 2025`, confirmed against the abstract
  page. Submission history v1 2025-01-31, v2 2025-02-13, v3 2025-05-29. **v3 is
  the latest of three** and is the revision refs.bib names.
- `pdfinfo` reports **25 pages**. Body 1-9, references 9-14, appendices A-G on
  15-25.
- **The abstract page carries no `Comments` row at all and no `journal-ref`**,
  and there is no publisher DOI. Primary cs.LG, cross-listed cs.AI. So arXiv
  records no venue: paper 27's and paper 31's case rather than decision 48's,
  and the chapter names no venue. The running head reads `A PREPRINT`.
- Verified against the arXiv API? **No.** Only the abstract page was reachable,
  the same single-source limitation chapter 15's session recorded.
- **It runs no experiment and reports no measurement.** One figure, a schematic
  on p. 2, and three tables; `we experiment`, `our experiment`, `we train` and
  `Figure 2` all return zero.

Extraction trap, chapter 13's trap again: `pdftotext -layout` drops every Greek
letter, so the three attribution scores come out as `i(x)`, `j(x)` and `k(x)`
with the symbol gone, and Table 1 on p. 3 extracts with its technique bands
merged. Everything below was read from a render.

### `faithful` occurs zero times in paper 18

Checked with both `pdftotext -layout` and plain `pdftotext`. The nearest
neighbour is `fidelity`, five occurrences, all in appendix F.3 on pp. 24-25, all
naming the counterfactual insertion and deletion family chapter 08 reads, never
the property of an explanation being right about the model.

That makes paper 18 the second tier-A paper the book has verified the word
absent from, after paper 20 in chapter 08's session (decision 34).

### Paper 18 is not a mechanistic-interpretability paper

`mechanistic` occurs 11 times in 25 pages and **only six outside the
bibliography**: three on p. 1, one each on pp. 5, 8 and 9. The paper never
defines mechanistic interpretability as a research programme. It defines
component attribution and says that arm *is a branch of* mechanistic
interpretability. Three placements, verbatim:

- p. 1: `Component attribution (CA), a key branch of mechanistic
  interpretability, examines how internal model components, such as neurons or
  layers within a neural network (NN), contribute to model behavior`.
- p. 5: `It plays a central role in the emerging mechanistic interpretability
  research which seeks to understand AI models by reverse engineering their
  internal mechanisms into interpretable algorithms.`
- p. 8, inside the *alternative views* section the paper argues against, in the
  paper's own scare quotes: `CA has emerged as a branch of 'mechanistic
  interpretability' aimed at reverse-engineering algorithms in foundation
  models.`

Table 1 on p. 3 gives component attribution **12 entries against feature
attribution's 19 and data attribution's 17**, and two of the table's three empty
cells. Appendix B, p. 15: `Most of the empty cells in Table 1 (labeled as '-')
represent methods that may be promising but have not yet been explored in the
literature.`

### The unification covers feature attribution alone

Three confirmations, and the structural ones are stronger than the sentence:

1. **Section structure.** Section 3 has exactly one unification subsection,
   3.1.1, `Unifying feature attribution methods via local function
   approximation`. Sections 3.2 and 3.3, the data and component arms, have no
   counterpart. Appendix C.6 repeats the asymmetry with nothing like it in D
   or E.
2. **Stated scope**, p. 4: `Eight prominent FA methods (Occlusion, KernelSHAP,
   Vanilla Gradients, Gradients x Input, Integrated Gradients, SmoothGrad, LIME,
   and C-LIME) are instances of this framework`. Appendix Table 3, p. 19, is
   captioned `(Table reproduced from Han et al. [2022])`, so the formalism is
   imported and arrives already restricted to feature attribution.
3. **The hedges**, section 4.1.2, p. 7, under the heading `Cross-attribution
   innovation`, four in four sentences: `This framework may also apply to DA and
   CA. ... One may hypothesize that DAs perform function approximation of the
   model's weights over the space of training data points and that CAs perform
   function approximation of the model's predictions over the space of model
   components. If so, function approximation may unify DA methods and unify CA
   methods as well.`

`hypothes` occurs twice in the whole paper, this passage and one unrelated use
on p. 23; `conjectur` occurs zero times. So this is the paper's only stated
hypothesis about its own framework.

### The evaluation gap, stated by paper 18 as shared across all three arms

**The strongest thing in paper 18 for this chapter, and the TOC line does not
name it.** Section 4.1.1, p. 7:

> Evaluation challenges arise in all three types of attribution due to multiple
> factors. ... For the shared evaluation metrics among all three types of
> attribution discussed in Section 3.4, counterfactual evaluation could provide
> more rigorous validation, but computational constraints often make this
> approach impractical. Task-specific evaluations offer easier alternatives but
> frequently lack generalizability across different contexts. Human evaluation,
> despite being considered the gold standard, faces scalability issues and
> potential biases. The diversity of evaluation metrics and their varying
> definitions of importance make the evaluation more challenging. An attribution
> result may perform well by one metric but poorly according to another. These
> challenges emphasize the pressing need for developing more reliable and
> generalizable attribution evaluation metrics.

Appendix F.3, p. 24, opening:

> Evaluating attribution methods presents significant challenges due to the lack
> of ground truth and the inherent complexity of modern AI systems. These
> challenges stem partially from the inconsistency problem, the computational
> cost and generalizability of some evaluation metrics, and the lack of
> universal definitions of importance and ground truth.

and closing, p. 25: `The development of more robust and comprehensive evaluation
frameworks remains a crucial research direction for advancing all attribution
methods.`

The three evaluation approaches paper 18 names in section 3.4 and appendix F.3
are **counterfactual, task-specific and human**, which is chapter 08's metric
families, the constructed-setting route and route 2. Paper 18 lists this
chapter's own routes as the options and calls all three inadequate.

### `ground truth` in paper 18: three occurrences, none for components

- p. 24, F.3, first sentence: `Evaluating attribution methods presents
  significant challenges due to the lack of ground truth`.
- p. 24, F.3, second sentence: `the lack of universal definitions of importance
  and ground truth`.
- p. 19, appendix D preamble: `Complete retraining-based methods like LOO are
  often used as a ground truth for evaluating other data attribution methods.`
  That is a ground truth for **attribution du lieu**.

**This session first recorded the count as two, and the cold audit corrected it.**
The cause is worth writing down because it is this session's own subject arriving
from the other side: the second F.3 occurrence is split across a line break in
the extraction, `... importance and ground` / `truth`, so a line-based search for
`ground.truth` never sees it. That is exactly the failure the Gloss check has
with a wrapped multi-word term, met here in a research tool rather than in the
gate. **A phrase count taken with a line-based search is a lower bound, not a
count**, and any absence or count this book prints from a multi-word phrase has
to be taken from a whitespace-normalised search or from the rendered page.

**The paper names no ground truth for component attribution anywhere in 25
pages**, verified by full-text search plus a read of sections 3.3 and 3.4 and
appendices E and F.3. So the arm the chapter's title calls an escape from the
ground-truth problem is, in the one paper that maps all three arms, the arm with
no ground truth at all.

`validat` occurs seven times and **none reports a validation performed**: one on
p. 7, two on p. 22 about a validation *set*, four on p. 25 inside F.3's hedges.

### What the techniques cost, in paper 18's own sentences

- **Causal mediation analysis**, p. 5: three separate runs per component, clean,
  corrupted, and corrupted-with-restoration, and `The corrupted run can be
  repeated multiple times with different random noise added to obtain more
  robust CA scores.` The aliases are named on the same page: `causal tracing`,
  `activation patching`, and `path patching` when applied to paths.
- **The free choice, appendix E.1, p. 23, and this is the load-bearing one.**
  Ablations `can consist of zero ablations ..., mean ablations ..., smoothed
  Gaussian noising ..., interchange interventions ..., learned ablations. In all
  cases, the dataset used to generate the activations must be chosen to elicit
  the desired model behavior, with a matching metric that measures the success
  of the behavior.` **You must already know which behaviour you are looking for
  and already have a metric that says whether you found it.** The paper never
  calls this an oracle and never calls it a ground truth. It is chapter 08's
  first two free choices moved from features to components, and section 16.6
  says so as the book's reading.
- **Attribution patching**, p. 5: `only two forward passes and a single backward
  pass`.
- **Neuron Shapley**, p. 5: `mitigates computational cost through sampling and a
  multi-armed bandit algorithm`.
- **COAR**, pp. 5-6: `Given the computational complexity, COAR employs linear
  approximations ... Thus, the complexity of relationships between components is
  abstracted away.` An accuracy cost paid to buy compute.
- **Neuron granularity**, E.3, p. 23: work has moved off individual neurons `due
  to the computational intractability of considering individual neurons in
  larger models and due to hypotheses of entanglement and polysemanticity`.

**Retraining is the cost of the wrong arm, and the chapter says so**, because it
defeats the easy version of "route 3 is expensive". F.1, p. 24: `The
computational burden is also severer for data attribution methods, which require
model retraining for each perturbation`, while component attribution `operates
primarily at test time` (p. 5).

### The seam paper 18 draws and this chapter crosses

Appendix E.3, p. 23:

> Recent research has demonstrated that SAEs can successfully extract
> interpretable components, but since SAEs focus on learning new components
> rather than attributing to existing ones in the original model, we do not
> consider them as strictly component attribution methods in this paper. They
> can rather serve as a technique for discovering interpretable features that
> can subsequently be used for attribution.

Chapter 07 already prints this boundary. What is new is that chapter 16 puts
papers 18 and 32 on one route across a line paper 18 draws **in order to keep
them apart**, so the joining is the book's move and the chapter says so on the
page.

### Paper 32: what 18.84 percent is a percentage of

Re-verified: 65,536 neurons of a Matryoshka Batch Top-k SAE, expansion factor
64, layer 22 of CLIP-ViT-L/14-336, ImageNet-1k, concepts from Broden with
`|C| = 1197`, steering read through LLaVA-1.5-7B. The four counts sum to 65,536
exactly and the shares to 100.00.

**The framing detail chapter 15 did not state and this chapter needs.** The
quadrants are cut at **the means of the two score distributions themselves**,
not at any absolute bar. p. 4: `Fig. 3 illustrates the trade-off between
interpretability and steerability scores, with dashed horizontal and vertical
lines marking their respective mean values to delineate four distinct neuron
groups.` So "readable" here means *more readable than this dictionary's own
average*, and no absolute standard of either property is set anywhere.

### The three numbers that price route 3, all new

1. **The share is 11.88 to 19.82 percent, and the abstract prints the best of
   three.** Appendix C.2, p. 10. LLaVA with DINOv2-L and Gemma-9B: 33.07 /
   23.35 / 23.75 / **19.82** percent, counts 21,675 + 15,304 + 15,565 + 12,992 =
   65,536. UnCLIP with CLIP-ViT-L and SD 2.1: 30.84 / 14.53 / 42.76 / **11.88**
   percent, counts 20,209 + 9,517 + 28,022 + 7,788 = 65,536. The paper's own
   summary, p. 10: `only a small portion of neurons (12-20%) are useful for both
   interpretability and steerability`.
2. **The share moves to 29.14 percent on one change of threshold.** Appendix
   C.3, p. 11: the alternative threshold is the average steerability of the
   original model's neurons with no SAE at all, measured at **0.173** against
   the 0.232 the figure uses, and at that threshold the four shares become
   17.86 / 9.58 / 43.42 / **29.14**, summing to 100.00. A factor of 1.55 on the
   headline, and the alternative threshold is arguably better motivated, since
   it asks whether an SAE neuron steers better than an ordinary neuron rather
   than better than the average SAE neuron.
3. **Steerability does not transfer across downstream models.** p. 12: `we
   computed the Pearson correlation between the steerability scores of 1329
   common CB concepts from LLaVA and UnCLIP CB-SAEs, which is 0.06 with a
   p-value 0.035. Hence, steerability seems to be largely downstream task/model
   -dependent.` **The strongest single number either route-3 paper supplies**:
   the same concept, in two dictionaries trained the same way, scores
   essentially independently depending on which downstream model reads the
   steering, so the steerable half of the 18.84 percent is a property of a pair
   rather than of a neuron. The p-value at n = 1329 says the correlation is
   distinguishable from zero, which is a statement about sample size, and the
   paper's own next clause says so.

### The one tool on both sides, anchored at three places

- p. 3: `Our interpretability score is the similarity score computed in
  CLIP-Dissect.`
- p. 9, appendix B: each neuron is assigned the concept `arg max_k sim(P_{:,k},
  q_j)`, and `The maximum similarity itself (averaged across all neurons) is
  used as our interpretability score.` The assigned name is the argmax and the
  score is that same argmax's value; nothing asks a human whether the name fits.
- p. 3, steerability: `We then compute the cosine similarity between the steered
  output and the neuron's CLIP-Dissect-assigned concept in a sentence
  -transformer embedding space.`

**And the paper closed this gap on purpose.** p. 3: `Unlike [37], which compared
steered outputs to top-activating images in CLIP's image-text space, our method
compares the output with concepts identified by CLIP-Dissect, ... yielding a
more robust, semantically grounded steerability metric.` The baseline it
improves on kept the two sides apart. Chapter 15's finding stands and gets
sharper: the paper does not merely fail to notice the circularity, it argues for
it. Its only acknowledgement is a hope, appendix A p. 9.

### Judge dependence, Table 6, p. 12

The interpretability score of the same neurons under seven vision-language
models inside CLIP-Dissect: 0.198, 0.154, 0.189, 0.188, 0.176, 0.220, 0.207 for
the SAE, against 0.307, 0.244, 0.289, 0.290, 0.272, 0.347, 0.312 for CB-SAE. **A
factor of 1.43 between lowest and highest**, and the model the paper chose,
CLIP-ViT-L-14-336, gives the lowest of the seven. The paper concludes, p. 12,
`validating that our choice of CLIP-like model for interpretability score does
not affect our evaluation.` That word earns the **ordinal** claim only, that
CB-SAE beats SAE under all seven judges. It does not earn the level, and the
quadrant boundary is a level. The chapter reports the spread and does not extend
the paper's word.

### Three more defects named and declined in paper 32

1. p. 10: `a majority of neurons (30-36%) are unsuitable for both`. Those three
   figures are 36.26, 33.07 and 30.84 percent, which are **pluralities, not
   majorities**. The abstract's version of the same claim is correct and
   different, because it is about the union of three quadrants: 36.26 + 19.87 +
   25.03 = 81.16 percent. The defect is confined to the appendix sentence.
2. p. 11, closing the threshold analysis: `our original claim of SAEs having low
   proportion (29%) of high utility neurons is still valid.` **The original
   claim was about 19 percent**, in the abstract on p. 1. The paper writes the
   new number into a sentence whose grammar attributes it to the old claim. The
   substantive point survives and the sentence does not, which is decision 62's
   class, so the chapter quotes the arrow and not the sentence.
3. An inconsistency the session could not resolve and therefore reports rather
   than smooths: p. 11 gives the mean steerability of figure 3 as **0.232**,
   while Table 2 on p. 7 gives the all-SAE-neuron steerability as **0.198** and
   **0.203** for the two steering variants, and section 3 describes figure 3's
   steering as the white-image procedure. `0.232` occurs twice in the paper,
   here and as an unrelated CB-AE cell in Table 4. Both figures were read from
   renders; the paper never reconciles them and no explanation was found in 15
   pages. **The chapter does not print 0.232 or 0.173 without saying this.**

### Paper 32's future work does not cross

Every item is about building a better dictionary: transcoders, better
steerability losses, task-specific losses, the feature-splitting question. The
one item that gestures at the instrument problem, the CLIP-Dissect dependence,
is answered by expecting better vision-language models rather than by proposing
a measurement. **The route's own literature does not name the route's own
instrument problem as a problem to be solved.**

## The table-of-contents re-check (decision 80)

The open item decision 56 opened, narrowed to chapters 16 and 17 by decision 74,
requires the line to be checked three ways before drafting, plus the fourth leg
decision 74 added: whether any clause is a claim the book makes rather than one
its papers make.

The line: `Ground truth dựng sẵn, human study, và mechanistic interpretability -
the three escape routes the critique points at, each with its cost. Papers 21,
24, 18, 32 re-used; no new corpus paper.`

- **More than the papers contain: yes, and in a way none of the seven earlier
  checks met.** The failure is not in a noun but in the line's organising
  predicate. `each with its cost` is **argued against by paper 24**, which
  prints `cost` zero times, `expensive` zero times and `power` zero times, and
  which devotes a passage on p. 6 to naming the cost objection and rejecting it:
  `Undoubtedly there are challenges in moving from testing AI solely with static
  datasets into testing with humans, but they are not insurmountable.` A chapter
  written to the line would have said paper 24 shows the human study is too
  costly to run, which states its own source backwards. This is the eighth
  init-written line to fail and the fourth distinct mode.
- **Also more, in the third noun.** `mechanistic interpretability` names paper
  18, and paper 18 is a position paper about attribution that files mechanistic
  interpretability as one of three arms. It practises none of it and measures
  nothing.
- **Less than the papers contain: yes, three times, and the first is the one
  that matters.** The line leaves `cost` unnamed, and the strongest thing in
  paper 18 is what the cost turns out to be: the evaluation gap is **shared
  across all three arms**, stated twice, on p. 7 and in appendix F.3 on p. 24,
  with `lack of ground truth` named and no ground truth for components named
  anywhere. Route 3 inherits the missing instrument rather than escaping it.
  Second, the line does not say paper 32 **measured** the cost: `r = 0.06`, the
  11.88 to 19.82 percent range, the 1.55 factor on the threshold and the 1.43
  factor on the judge are measurements, not qualitative prices. Third, it gives
  the chapter no room to state the circularity.
- **The relation between the four: false as stated, and this is the chapter's
  subject.** The line arranges three parallel exits and the sources do not stand
  that way. Paper 21 takes route 1 **because it judges route 3 unavailable**
  (p. 4). Paper 18 says route 3 shares route 1's and route 2's evaluation
  problem. Paper 24 says its own route's obstacle is not the one the line
  assigns it. And papers 18 and 32 are not two papers on one route: paper 18
  sits above it as a taxonomy and excludes paper 32's object from its own
  framework on p. 23. This is decision 69's mode a second time and at a larger
  scale, because here the false arrangement is the chapter's whole organising
  idea rather than one sentence.
- **A clause the book makes rather than its papers: yes, `escape route`
  itself.** No paper of the chapter offers its route as an escape from the
  faithfulness-metric critique. Paper 21 comes closest and genuinely answers the
  ground-truth problem the critique poses; paper 24 answers a different
  critique, the unvalidated-explainability-claim one, which is chapter 01's
  other side; papers 18 and 32 answer neither. The chapter owns the word on the
  page in section 16.1 rather than letting the chapter title carry it.

The corrected line is recorded in the SPEC and in the chapter folder's scope
comment.

## Verified absences

- `faithful` occurs **zero times** in paper 18 (25 pages, both extraction modes)
  and **zero times** in paper 24 (7 pages), re-confirmed, and **zero times** in
  paper 32, re-confirmed from chapter 15. Paper 21 is the only one of the four
  that uses the word, and it uses it about chuoi suy luan.
- `ground truth` occurs **zero times** in paper 24 and **twice** in paper 18,
  neither for components.
- `fidelity` occurs **zero times** in paper 24 and **five times** in paper 18,
  all naming chapter 08's counterfactual family.
- `mechanistic interpretability` occurs **zero times** in paper 21; its two uses
  of `mechanistic` both mean the mechanistic reading of faithfulness, which
  chapter 09 settled as `cach doc co che`.
- `external validity`, `generaliz`, `artificial`, `realis*`, `real-world` and
  `narrow` all occur **zero times** in paper 21.
- `expensive`, `power`, `IRB`, `consent`, `compensat*`, `budget`, `burden` and
  `effort` all occur **zero times** in paper 24. **`cost` occurs once**, inside
  the surname *Lacoste* in reference [19] on p. 7, and nowhere in the body. The
  first draft of this note and of section 16.4 said `cost` was absent outright;
  the chapter now says one occurrence in a proper name, because that is what the
  file contains.

### Every absence above was re-counted after the cold audit, and how

The `ground truth` undercount was found by the audit, so all of these were
re-run with whitespace normalised: the extraction is de-hyphenated at line ends
(`-\s*\n\s*` removed), all runs of whitespace collapsed to one space, and the
search run over the whole text rather than line by line. Under that method every
absence in the list above holds, `ground truth` in paper 18 comes out at three,
`fidelity` at five, `mechanistic` at eleven, and paper 32's `ground truth`
resolves as zero bare plus three hyphenated inside `pseudo-ground-truth`. **The
rule for any later chapter printing a phrase count: a line-based search over a
PDF extraction returns a lower bound, because a phrase that wraps is invisible
to it. Normalise the whitespace or read the page.**

## Statements the chapter makes that are the book's, not its papers'

Listed together because decision 74's fourth leg asks for them and because the
chapter marks each on the page.

1. That the three routes are escape routes at all.
2. That route 1 pays in representativeness. Paper 21's Limitations paragraph
   charges only within-trace coverage and label skew, and it answers the
   representativeness charge on p. 9. The book's evidence is the paper's own
   Table 10: 486 of 1946, one step type of four.
3. That the three routes are not parallel, and that what each charges is a
   change of question rather than a price. Each leg is a source's sentence; the
   assembly is the book's.
4. That paper 32's naming tool stands on both sides of its own measurement.
   Chapter 15 states this; chapter 16 restates it as the route's cost.
5. That paper 18's shared-evaluation-gap statement is a statement about route 3
   specifically. Paper 18 states it about all three arms at once, and reading it
   as the price of this route is the book's move.
