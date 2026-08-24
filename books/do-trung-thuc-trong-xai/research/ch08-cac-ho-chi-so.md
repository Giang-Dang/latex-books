# Chapter 08 - the faithfulness metric families

Date: 2026-08-24. This is the first note in this folder, so it is the file that
crossed the cliff described in README.md: from here every decimal printed
anywhere in the book must appear in some note here.

What that cost, measured rather than guessed: arming the check produced 38
findings and none of them was a measurement. 32 were the arXiv identifiers in
appendix D's corpus table and 6 were LaTeX column widths in appendices A and D.
The widths moved into `preamble/macros.tex`, which the gate does not scan,
because they are typographic settings and not numbers the book claims. The
identifiers cannot move, so `check-chapter.psd1` grew one anchored hole,
`^\d{4}\.\d{4,5}$`. That pattern cannot swallow a score, a proportion or an
AUROC, none of which carry four digits before the point.

**Chapter 08 itself prints no decimal.** The measurements below are recorded
because chapter 09 will print them and because chapter 18 needs the limitation
log; they are not in chapter 08's prose. Anyone checking the chapter against
this note should expect that.

## Sources read

| Key | arXiv | Revision read | Date | Venue as stated |
|---|---|---|---|---|
| `p21metrics` | 2605.25052 | v1 (only revision) | 2026-05-24 | preprint, cs.CL, no venue named |
| `mrise` | 1806.07421 | v3 of 3 | 2018-09-25 | none on the arXiv record |
| `meraser` | 1911.03429 | v2 of 2 | 2020-04-24 | ACL 2020 long paper |
| `mroar` | 1806.10758 | v3 of 3 | 2019-11-05 | NeurIPS 2019 |
| `msensn` | 1711.06104 | v4 of 4 | 2018-03-07 | ICLR 2018 |
| `minfid` | 1901.09392 | v4 of 4 | 2019-11-03 | NeurIPS 2019 |
| `mood` | 2106.00786 | v2 of 2 | 2021-10-27 | NeurIPS 2021 |
| `msanity` | 1810.03292 | v3 of 3 | 2020-11-06 | none on the arXiv record |

Paper 21 was read from the PDF at
`F:\repo\thesis-xai-faithfulness\3-tier-b-critique-core\21_xai-eval_faithfulness-metrics-dont-measure-faithfulness_2026.pdf`
(31 pages: main text 1-9, references 10-17, appendices A-G 18-31). The other
seven were fetched from arXiv and ar5iv. No orientation note was used for any
claim here, per decision 13.

## The finding that changed the chapter

Paper 21's object is the faithfulness of the chain of thought, not of feature
attribution. Checked by full-text search across all 31 pages: **deletion,
insertion, comprehensiveness, sufficiency, ROAR, sensitivity-n, infidelity and
monotonicity appear nowhere in it.** Its eight metrics are Adding Mistakes,
Early Answering, Filler Tokens, SCM, FUR, CC-SHAP, Simulatability and
Paraphrasing.

Two consequences recorded so a later session does not rediscover them:

1. SPEC decision 9's open item, that the corpus holds no dedicated
   CoT-faithfulness paper, is false. Paper 21 is one, and it is the book's
   anchor. Chapter 17 is unblocked from a direction nobody expected.
2. The anchor's evidence is CoT evidence while chapters 10 to 14 critique
   attribution. That is a book-spine question and it is recorded as a SPEC open
   item rather than settled here.

Verified negative, worth keeping so nobody re-checks: paper 20 (Long et al.,
2505.07005v1) **defines no faithfulness metric at all**; the string "faithful"
occurs zero times in its full extracted text. It is citable in chapter 08 only
for the shape of the field, never for a metric definition.

Also verified negative, and a correction to a framing this session started
with: local Lipschitz continuity in Alvarez-Melis and Jaakkola is
**robustness**, not faithfulness. The word "faithfulness" does not appear in
arXiv:1806.08049 at all; in arXiv:1806.07538 faithfulness is named as a
desideratum but is then operationalised with the same feature-removal proxy as
everyone else, so those papers supply no distinct faithfulness formalism. The
chapter claims none. Neither paper is cited, and neither was added to
`refs.bib`, because a source read only to rule something out does not belong in
a bibliography.

## Paper 21's abstract, the three sentences chapter 08 rests on

Transcribed from the arXiv abstract page, cross-checked against page 1 of the
PDF. Chapter 08 uses these three and nothing else from the abstract, so they are
recorded rather than left to the reader to find.

1. "Several faithfulness metrics have been proposed, but whether they indeed
   measure faithfulness remains unknown."
2. "most works proposing metrics report only absolute scores or comparisons to
   prior metrics, and the few existing benchmarks rely on proxies like
   plausibility or importance, properties orthogonal to faithfulness that can
   mislead about whether a CoT can be trusted"
3. "Answering this requires ground-truth labels, which are hard to obtain since
   internal computations are not directly observable."

Sentence 2 is the chapter's thesis sentence and it is quoted about the CoT
literature; the chapter applies it to the attribution metrics only as far as
sentence 2's own wording goes, which is a claim about how metric papers report
results, not about which metrics they cover.

## Paper 21's four categories, and its stated diagnosis per category

The grouping is the paper's own, used as tags in its tables and figures
(pp. 7-8, and as literal section headers in appendix D.1, pp. 24-25).

| Tag | Category | Metrics in it |
|---|---|---|
| IMP | importance-based | Adding Mistakes, Early Answering, Filler Tokens, SCM |
| PAR | parameter-based | FUR |
| ATT | attribution-based | CC-SHAP |
| SEM | semantic-utility | Simulatability, Paraphrasing |

What each category intervenes on, since chapter 08 uses that and not the tags.
IMP perturbs part of the chain of thought and watches the answer. PAR is FUR,
which "performs a localized unlearning update that suppresses the information
conveyed by that step from the model's weights, then re-runs the model on the
original input" (p. 7, p. 24-25) - so it intervenes on weights, not on the
input, which is the sentence chapter 08 leans on. ATT is CC-SHAP, which
"computes two SHAP-based contribution distributions over the input tokens"
(p. 25). SEM "provides the CoT as additional context to a weaker simulator
model and tests whether the simulator can reproduce the original model's
answer" (p. 25).

The diagnosis, quoted from p. 8-9. On importance-based metrics: "they conflate
importance with faithfulness, potentially labeling as unfaithful a faithful
step that is not critical for the final answer", and "since they perturb
individual steps and measure the effect on the answer, their signal might
weaken as CoTs grow longer". On semantic-utility metrics: "even unfaithful CoTs
typically contain enough verbalized reasoning to convey the answer. A
plausible-sounding but fabricated justification will still allow a weaker model
to reproduce the answer or yield the same answer after paraphrasing."

The paper prints **no formula for any of the eight metrics**; all are described
procedurally in prose. A draft stating a formula "from" this paper would be
inventing it.

## The attribution-side families, with the source for each

Definitions quoted from the papers themselves.

**Deletion and insertion** (`mrise`). Deletion "measures a decrease in the
probability of the predicted class as more and more important pixels are
removed... A sharp drop and thus a low area under the probability curve...
means a good explanation." Insertion "measures the increase in probability as
more and more pixels are introduced, with higher AUC indicative of a better
explanation." Stated intuition: "The intuition behind the deletion metric is
that the removal of the 'cause' will force the base model to change its
decision." The insertion metric starts from a blurred image because blurring
"takes away most of the finer details of an image without exposing it to sharp
edges" - the paper choosing a replacement value to reduce an artifact it does
not name.

**Comprehensiveness and sufficiency** (`meraser`). Comprehensiveness is
`m(x_i)_j - m(x_i \ r_i)_j`, on the reasoning that "the model ought to be less
confident in its prediction once rationales are removed". Sufficiency is
`m(x_i)_j - m(r_i)_j`, "the degree to which the snippets within the extracted
rationales are adequate for a model to make a prediction". The authors' own
hedge, quoted: "How best to measure rationale faithfulness is an open question.
In this first version of ERASER we propose simple metrics motivated by prior
work."

**ROAR** (`mroar`). Remove the top-k features by importance, replace with an
uninformative value, **retrain**, and measure accuracy degradation. The reason
for retraining, in the paper's words: "Samples where a subset of the features
are removed come from a different distribution"; "This approach clearly
violates one of the key assumptions in machine learning: the training and
evaluation data come from the same distribution"; and "The replacement value
can only be considered uninformative if the model is trained to learn it as
such. Without retraining, it is unclear whether degradation in performance is
due to the introduction of artifacts outside of the original training
distribution or because we actually removed information."

**Sensitivity-n** (`msensn`). "An attribution method satisfies Sensitivity-n
when the sum of the attributions for any subset of features of cardinality n is
equal to the variation of the output Sc caused removing the features in the
subset." Formally, for every subset `x_S` of `x` with `|x_S| = n`:
`Σ R_i^c(x) = S^c(x) - S^c(x[x_S = 0])`. The `x_S = 0` in that formula is the
whole of the paper's answer to what a removed feature is replaced by, and it is
why chapter 08 says the second box is fixed to zero for this metric; there is no
separate sentence in the paper choosing or defending zero.

Chapter 08 also states that with `n` equal to the total number of features the
condition becomes completeness. That is **the book's derivation, not a claim
made by the paper**: at that `n` the left side is the sum of all attributions
and the right side is `S^c(x) - S^c(0)`, which is the completeness identity
chapter 05 states for Integrated Gradients. Recorded here so a later reader does
not go looking for it in Ancona et al.

Recorded so it is not re-derived: **no assumption sentence for this
metric was found in the paper's own text.** The chapter therefore states none
on the paper's behalf. Whether the metric is scored as a correlation
coefficient was not confirmed from primary text and is not claimed.

**Infidelity and max-sensitivity** (`minfid`). Definition 2.1:
`INFD(Phi,f,x) = E_{I~mu_I}[(I^T Phi(f,x) - (f(x) - f(x-I)))^2]`, where I is "a
random variable... which represents meaningful perturbations of interest".
Definition 3.1: `SENS_MAX(Phi,f,x,r) = max_{||y-x||<=r} ||Phi(f,y) -
Phi(f,x)||`. The perturbation distribution `mu_I` is user-chosen and the paper
does not defend a particular choice; that is what chapter 08 reads it for.

**The out-of-distribution objection** (`mood`). "the fact that these
counterfactual inputs are out-of-distribution (OOD) to models implies that the
resulting explanations are socially misaligned. The crux of the problem is that
the model prior and random weight initialization influence the explanations
(and explanation metrics) in unintended ways." The abstract names ERASER's
sufficiency metric directly, and names the form it has in mind: "in the standard
Sufficiency metric, only the top-k most important tokens are kept". That
quotation is what licenses chapter 08 to describe the target as sufficiency in
its top-k form rather than as the family in general.

**Sanity checks** (`msanity`). "The model parameter randomization test compares
the output of a saliency method on a trained model with the output of the
saliency method on a randomly initialized untrained network of the same
architecture." "The data randomization test compares a given saliency method
applied to a model trained on a labeled data set with the method applied to the
same model architecture but trained on a copy of the data set in which we
randomly permuted all labels." The framing is necessity, not degree: "saliency
methods that fail our proposed tests are incapable of supporting tasks that
require explanations that are faithful to the model or the data generating
process." Chapter 08 turns on that distinction and must not call these metrics.

## Doshi-Velez and Kim's three tiers, exact names

From `p14rigorous`, arXiv:1702.08608v2 (2017-03-02), section 3. Chapter 01
already uses these; recorded here because chapter 08 places the metric families
in the third tier.

1. "Application-grounded Evaluation: Real humans, real tasks"
2. "Human-grounded Metrics: Real humans, simplified tasks"
3. "Functionally-grounded Evaluation: No humans, proxy tasks"

What section 3.3 says about when the third tier is usable, quoted, because
chapter 08 rests a paragraph on it: "Functionally-grounded evaluations are most
appropriate once we have a class of models or regularizers that have already
been validated, e.g. via human-grounded experiments. They may also be
appropriate when a method is not yet mature or when human subject experiments
are unethical." The two worked examples under it each carry an explicit
assumption clause of the same shape, "assumes that someone has run human
experiments to show that the model class is interpretable" and "assumes someone
has run human experiments to show that the regularizer is appropriate".

Recorded because a first draft of chapter 08 got this wrong in a way no gate
would catch. It attributed to the paper a general epistemic principle, that a
proxy is usable when there is some basis for believing it relates to what is
wanted. **That sentence appears nowhere in the paper.** What the paper actually
supplies is narrower and, for this chapter, stronger: a named precondition that
something has already been validated by a human-grounded experiment. The draft
was reworded to the real claim. The paper also does not resolve which proxies
are valid in general; it defers that to its open-problems section, "In section
4, we describe open problems in determining what proxies are reasonable", and
lists "What are the important factors to consider when characterizing proxies
for explanation quality?" there.

Verified negative on the same paper: "faithful" and "faithfulness" occur zero
times in it, checked through two independent extractions. The book's central
term is not this paper's term, and chapter 01 already takes only the taxonomy
from it.

## Measurements from paper 21 - for chapter 09, not printed in chapter 08

Recorded now because the PDF was open now. Every value below is as printed,
with its anchor.

AUROC per metric, figure 2a table, p. 7, caption "AUROC +- 95% DeLong margin
per metric". Step level then CoT level; an em space means the paper ran no
variant at that level.

| Metric | Step | CoT |
|---|---|---|
| Adding Mistakes | 0.51 +- 0.02 | 0.51 +- 0.04 |
| Early Answering | 0.51 +- 0.01 | 0.45 +- 0.03 |
| Filler Tokens | 0.59 +- 0.01 (best step) | 0.50 +- 0.02 |
| SCM | not run | 0.38 +- 0.03 |
| FUR | 0.52 +- 0.02 | not run |
| CC-SHAP | 0.41 +- 0.03 | 0.70 +- 0.04 (best CoT) |
| Simulatability | not run | 0.50 +- 0.01 |
| Paraphrasing | not run | 0.61 +- 0.03 |
| LM Judge, skyline | 0.87 +- 0.02 | 0.82 +- 0.04 |
| LM Judge, generic baseline | 0.68 +- 0.02 | 0.67 +- 0.04 |
| Random | 0.5 +- 0 | 0.5 +- 0 |

Surrounding text, p. 8: "The strongest performer at the CoT level is CC-SHAP
(0.70), while at the step level it is Filler Tokens (0.59). Notably, even these
relative successes do not transfer across settings: CC-SHAP drops to below
random at the step level, and Filler Tokens is near chance at the CoT level."

Other numbers, each with its anchor:

- Prediction skew, p. 2 abstract and p. 8, figure 3: importance-based metrics
  label 90% to 96% of CoTs unfaithful; semantic-utility metrics label 94% to
  96% faithful, on a label-balanced sample.
- Inter-metric agreement, figure 7, p. 28: most Cohen's kappa around 0, highest
  at CoT level 0.35 (Adding Mistakes against Early Answering), highest at step
  level 0.12.
- Cost: CC-SHAP "requiring up to 10^3 seconds per instance" (p. 2, p. 8). A
  CoT-level FUR variant was **not run** at all, at an estimated "up to 10^5
  seconds per CoT (over an entire day)" (p. 25).
- BonaFide composition, p. 7: 3,066 CoTs, 10 models, 13 tasks; 1,946 step-level
  labels (51% faithful, 49% unfaithful); 1,120 CoT-level labels (15% faithful,
  85% unfaithful). Unfiltered pool, p. 28: 19,459 labels over 9,302 unique
  chains.
- Labeling pipeline precision, p. 7 and p. 23: 98.9%, 95% CI [96.6%, 100%],
  against 6 human annotators; inter-annotator agreement 96.6%, Gwet's AC1
  0.976. Pipeline cost about $2,100 (p. 7).
- Ground-truth validation, p. 5: models answer correctly with an empty CoT only
  1.5% of the time (100 tasks x 10 models); models guess the planted wrong
  answer without a hint 0.9% of the time (100 questions x 10 models).
- Implementation validation against published reference values, table 4, p. 25:
  Early Answering 27% published against 26.5% reproduced; Filler Tokens 27%
  against 26.0%; Adding Mistakes 18% against 27.1%; Paraphrasing 71% against
  75.4%; CC-SHAP 13% against 11.0%.

## Limitation and future-work statements, paper 21

For chapter 18, per the SPEC open item. Quoted or closely paraphrased with page
numbers.

- p. 9, limitations, in full: "Using our methodology, we can obtain ground-truth
  knowledge for specific steps we know had to have occurred in the model.
  However, any given CoT will contain many additional steps for which our
  setting provides no signal. This precision-first design also skews the
  distribution of CoT-level labels. Labeling a CoT as faithful requires every
  one of its steps to be either faithful or inert, while a single unfaithful
  step or a missing bottleneck step suffices to label it unfaithful. Faithful
  CoTs are therefore harder to certify than unfaithful ones, and BonaFide
  contains fewer of the former than the latter."
- p. 9: skew against CoT length shows "no consistent trend, leaving this an open
  question".
- p. 6, footnote 1: the method is restricted to open-weight models "since most
  metrics require access to model internals... The former is impossible with
  closed models".
- p. 25: the CoT-level FUR variant was omitted for computational cost - a
  metric the benchmark could not afford to test at all.
- p. 9, on prior benchmarks, which doubles as the gap this paper claims to
  fill: they "omit reasoning models, whose long nonlinear traces pose distinct
  challenges", "evaluate faithfulness only at the CoT level, leaving individual
  steps unevaluated", and do not "make efficiency a first-order concern".
- p. 1 abstract and p. 9 conclusion: the results "expose fundamental gaps in
  current faithfulness evaluation and call for the development of more reliable
  and efficient metrics"; BonaFide is released "to facilitate the development of
  faithfulness metrics that are both reliable and practical".

## Methodology note

One web fetch in this session returned confident, plausible, and wrong metadata
for a mistyped arXiv identifier (1701.08608, which is actually a paper on sweet
pepper harvesting) before a direct re-fetch caught it. Every identifier in the
table above was re-verified against the arXiv abstract page. Recorded because
the failure mode is invisible: the fabricated answer matched the paper that was
being looked for.
