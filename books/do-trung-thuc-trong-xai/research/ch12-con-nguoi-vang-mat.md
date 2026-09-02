# Chapter 12 - the human validation gap, and the one study that measured it

Date: 2026-09-02. Fourth note in this folder, one per chapter from chapter 08 on
(decision 35). Chapter 12 reads two papers with very different shapes: a
seven-page census of the XAI literature that prints four counts and four
percentages, and a fifteen-page user study that prints correlations, $R^2$
values and a full set of study parameters. Both print decimals, so this note
carries every one of them with its page anchor, and it carries the two places
where a paper contradicts itself or where the book reads a paper against its own
framing.

## Source pins

| Key | arXiv | Revision read | Pages read | Submitted |
|---|---|---|---|---|
| `p24humangap` | 2503.16507 | v1, the only revision | 1-6 in full; 6-7 are the bibliography, scanned only | 2025-03-13 |
| `p25userperception` | 2603.15607 | v1, the only revision | 1-13 in full; 14-15 are the bibliography, scanned only | 2026-03-16 |

Read from
`F:\repo\thesis-xai-faithfulness\3-tier-b-critique-core\24_xai-eval_human-validation-gap-xai_2025.pdf`
and
`F:\repo\thesis-xai-faithfulness\3-tier-b-critique-core\25_xai-eval_counterfactual-metrics-vs-user-perception_2026.pdf`.
The PDF stamps read `arXiv:2503.16507v1 [cs.HC] 13 Mar 2025` and
`arXiv:2603.15607v1 [cs.AI] 16 Mar 2026`.

Verified this session against the arXiv abstract pages and the arXiv API, raw,
without a summarising fetch in the loop:

- **2503.16507** has v1 and nothing after it, submitted 13 Mar 2025 18:39:50
  UTC. Primary category cs.HC, cross-listed cs.AI. No `journal-ref`. The
  `Comments` field reads, verbatim: `Extended Abstracts of the CHI Conference on
  Human Factors in Computing Systems (CHI EA '25)`. The PDF's own footer carries
  the fuller venue line, `CHI EA '25, April 26-May 1, 2025, Yokohama, Japan`,
  the ACM ISBN `979-8-4007-1395-8/2025/04` and the DOI
  `https://doi.org/10.1145/3706599.3719964`. So unlike paper 22 this one does
  have a publisher DOI printed on the paper itself; arXiv still records no
  `journal-ref`, and the book cites the arXiv version with the venue named in the
  `note` field.
- **2603.15607** has v1 and nothing after it, submitted 16 Mar 2026 17:56:54
  UTC. Primary category cs.AI, cross-listed cs.HC. No `journal-ref`. The
  `Comments` field reads, verbatim: `Accepted at the 4th World Conference on
  eXplainable Artificial Intelligence (XAI 2026)`. That is the same conference
  series paper 22 was accepted to one year earlier, and it is handled the same
  way: the book cites the arXiv version (decision 48's precedent).

Titles and author lists on both seeded refs.bib entries check out character for
character against the arXiv record, diacritic in `Düsing` included. Nothing was
corrected in refs.bib this session except the `note` fields, which were seeded
with the placeholder sentence and now record what was read.

Authors and affiliations from page 1 of each PDF:

- Paper 24: Ashley Suh, Isabelle Hurley, Nora Smith, Ho Chit Siu, all four at
  MIT Lincoln Laboratory, Lexington, MA, USA. The acknowledgment names Air Force
  Contract No. FA8702-15-D-0001 and carries `DISTRIBUTION STATEMENT A`.
- Paper 25: Felix Liedeker, Basil Ell, Philipp Cimiano, Christoph Düsing, all
  four at Bielefeld University, Bielefeld, Germany.

No orientation note was used for anything here (decision 13). The corpus README
names notes for neither paper.

## Paper 24: what kind of paper this is

**A late-breaking work, and it says so in its own first sentence.** Seven pages
in the CHI Extended Abstracts track, of which pages 1-6 are body and the
bibliography starts on page 6. It is not a full paper and does not present
itself as one; section 5.1 is headed `Beyond this Late-Breaking Work` and calls
the piece a `"prequel" to future work`.

What it does is a literature census, not an experiment on models. There is no
model, no dataset of predictions, no metric computed. The measured object is
the XAI literature itself: how many papers claim human explainability and how
many test that claim with humans.

That settles what chapter 12 may say from it. The chapter may report the
counts and the percentages as the census's own findings. It may **not** treat
the 0.7% as a statement about faithfulness metrics; see the claim of absence
below.

## Paper 24: the census pipeline and every printed number

Method, from section 2, pages 2-3:

- Search over the **Scopus** database, published and preprint literature,
  designed over three months with a professional librarian, iterating on the
  keyword set. The exact Scopus query strings are printed in table 1, page 3,
  so the search is reproducible.
- Exclusions written into the query: `review OR survey OR overview` in the
  title, document types `cr` and `re`, and `LANGUAGE (english)`. Workshop
  papers are excluded too; section 5.1 lists review articles, workshop papers
  and non-English papers together as the generalizability limitation.
- Scoring: the validation criterion is taken from Miller et al. Each paper gets
  1 if the paper itself validates explainability claims with humans, 0
  otherwise. `Each article in the final review set was scored by 3 people in
  total` (p. 2). Disagreements resolved collaboratively.
- Scope deliberately narrowed: `we limit our scope to only the use of humans in
  a behavioral study to evaluate the XAI method (i.e., the validation criteria)
  for simplicity` (p. 2). Miller et al.'s second, data-driven criterion, which
  scores whether a paper cites or implements social-science work, is **not**
  applied, and the paper says why: it `was determined in 2017` and `may be
  outdated`.

The four situations that draw a 0, p. 2, quoted in full because chapter 12's
sections 12.2 and 12.4 both turn on them and review question 3 is built on the
fourth. The paper introduces them as `several reasons to assign a 0 in our
validation scoring`:

1. `The paper claims it is explainable-by-design, so it does not require human
   experiments.`
2. `The paper contributes a framework or evaluation method that claims to be
   explainable but does not test the framework or evaluation method with
   humans.`
3. `The paper claims human explainability because it used data derived from
   humans in its training of the AI model or XAI method but does not evaluate
   with humans. We discuss this further in Section 4.2.`
4. `The paper conducted a quantitative study comparing to human-annotated data
   or human labels (e.g., as a baseline), but does not provide human
   validation.`

The off-topic exclusion, same page: `Finally, we excluded 16 papers from the
final set that were agreed upon as off topic. Off topic papers did not present
an XAI method but rather were meta-reviews of the field of XAI, philosophical
arguments about explainability, or were summaries of several papers by
particular graduate students.` The paper says the 16 were `agreed upon`; it
does not say by how many of the three scorers, so the chapter says only that
they were agreed to be off topic.

Table 1, p. 3, prints **two** Scopus query strings, one per column: `All XAI
papers` and `XAI with claims about humans`. The left column is a natural-language
description of the strategy rather than a query.

**Table 3, page 4**, is the number source and the four rows are the whole
funnel:

| Down-selection criterion | Count | Percentage printed in the table |
|---|---|---|
| Has explainability-related keywords | 18,254 | 100% |
| Has claims about human explanability [sic] | 253 | 1.39% |
| Were on-topic (not surveys, etc.) | 237 | 1.30% |
| Were validated on human subjects | 128 | 0.70% |

The `explanability` misspelling is the paper's, in the table's own row label.

**Table 2, page 3**, is the scoring breakdown of the 253: validation score 0 for
109 papers, score 1 for 128, off topic 16. Those three add to 253, and
253 - 16 = 237, so the two tables agree.

Split of the 18,254 from page 2: `13,839 published papers, 4,394 preprints`.
Those add to 18,233, not 18,254, a difference of 21. The paper does not
explain the gap and chapter 12 prints neither of the two components, only the
total, so nothing in the book rests on it. Recorded here so no later session
re-derives it.

Every decimal paper 24 prints, with its anchor:

| Number | Where | What it is |
|---|---|---|
| `0.7%` | abstract p. 1; p. 2 col. 1; p. 2 col. 2; p. 5 col. 1; conclusion p. 6 | 128 of 18,254, the headline |
| `0.70%` | table 3, p. 4 | the same figure at one more digit |
| `1.39%` | table 3, p. 4 | 253 of 18,254 |
| `1.30%` | table 3, p. 4 | 237 of 18,254 |

And the derived arithmetic the book may print because it follows from the
counts: 128 / 237 = 0.5401, and 128 / 18,254 = 0.007012.

### The paper contradicts itself on one percentage

- **Section 3, page 2**, on the 237: `the difference between those that actually
  conduct a human evaluation and those that do not is very small (54% of papers
  provide an evaluation, 46% do not)`.
- **Section 4.1, page 3**, on the same 237: `We find that out of the 237 papers
  that claimed some form of human explainability, only 56% of them provided an
  evaluation with humans.`

128 / 237 = 54.0%, so section 3 is right and section 4.1's 56% is wrong. The
counts in tables 2 and 3 are consistent with each other and with section 3.
Chapter 12 prints the counts, `128 trong 237`, rather than either percentage,
and names the discrepancy once as the book's own observation. Same class as
decision 40: where a source's own statement does not follow from its own result,
state what follows and say what the source wrote.

### Other quantitative statements, verified

- p. 3, on the sensitivity of the headline: `Even if our search criteria were
  dramatically incorrect, say, an order of magnitude off, a ten-fold increase in
  validation rates in the literature would only result in 7% of works being
  tested with humans.`
- p. 3: `over 98% of XAI papers do not appear with human evaluation keywords,
  and over 99% of XAI papers do not contain empirical human evaluation.`
- p. 2, the per-thousand restatement: `for every 1,000 XAI papers that do not
  explicitly mention humans, fewer than 8 of them provide explainability
  validation with empirical evidence.`
- p. 5: extrapolating the off-topic fraction to the whole set leaves the
  percentage `still approximately 0.7%`.
- p. 3, on citation of the paper they build on: `Of the 253 papers in our
  search, only 11 cited Miller et al. Of those 11, 6 provided a human evaluation
  and 5 did not.`
- p. 5, figure 2's caption: `13 papers did not report their human subject count
  and 3 papers approximated their count.` The bin counts inside figure 2 itself
  are readable but small; the chapter prints none of them and this note records
  none, on chapter 10's precedent for the tick marks it declined to count.

### Prior work paper 24 reports, and which the chapter attributes through it

The book has read none of these three, so every one of them is attributed
through paper 24 in the prose, on decision 45's precedent.

- Miller, Howe and Sonenberg (2017): of 23 papers at the 2017 IJCAI XAI
  workshop, `only 4 articles referenced relevant social science research, only 1
  of them built a model on this research, and none of the 23 included any
  empirical testing` (p. 1). The paper describes that survey as self-described
  `"light scan of the literature"`.
- Wells and Bednarz: `17 out of the 25 papers they surveyed on explainable AI
  for reinforcement learning did not include any user testing` (p. 1).
- Nauta et al.: `surveyed 300 papers published at top AI/ML conferences and
  found that 1 in 3 papers evaluated their methodology exclusively with
  anecdotal evidence, and only 1 in 5 papers evaluated with actual users`
  (p. 1).

### Claim of absence, verified by full-text search

Searched the extracted text of the whole PDF with `pdftotext -layout` and
`grep -i`:

- **`faithful` and `faithfulness` occur zero times**, body and bibliography
  alike.
- **`ground truth` occurs zero times.**
- **`attribution` occurs zero times**, and so do `LIME`, `SHAP` and `saliency`.

This is the third time the book has recorded an absence of this kind: chapter
08's note records that paper 20 defines no faithfulness metric, chapter 10's
records that paper 22 never writes `faithfulness` or `ground truth`, and now a
census of 18,254 XAI papers names neither the property nor a single attribution
method.

It matters more here than in either earlier case, and it is a constraint on the
chapter rather than a rhetorical point. Paper 24 counts papers that validate
**claims of human explainability** with humans. Faithfulness in this book's
definition~1.2 sense is a relation between the explanation and the model, and a
human rater is not in a position to check it. So the 0.7% is not a count of
faithfulness validation and the chapter must not print it as one. What it
counts is the other side of chapter 01's split, the plausibility side, and even
there it counts the presence of a study rather than its quality, which the
paper itself flags in section 5.1.

### Paper 24's limitation and future-work statements, for chapter 18

Recorded per the open item; this is the third of the seven Part IV chapters to
be logged.

1. **Search scope.** Review articles, workshop papers and non-English papers are
   excluded by construction, so the estimate is of the peer-reviewed and preprint
   English literature Scopus indexes, and section 5.1 names widening this as
   future work.
2. **The scoring criterion is binary and shallow.** `The validation score we
   used may also need to be reworked, as the sole presence of an evaluation may
   not be equivalent to a paper that presents a 'good' evaluation (as discussed
   in Section 3, some evaluations did not report a participant count or
   participant expertise).`
3. **The borrowed criterion is dated.** Miller et al.'s data-driven criterion is
   from 2017 and the authors call it possibly outdated and somewhat unclear;
   they applied only the validation criterion.
4. **The subject pool inside the 128 is undescribed.** Section 4.1 asks `who are
   the evaluation subjects?` and section 5.1 asks for a distribution over subject
   types, experts versus students, as future work. 13 of the 128 report no
   participant count at all.
5. **Venue effects unexamined.** Section 5.1 asks whether papers that validate
   with humans tend to appear at human-centred venues such as ACM CHI rather than
   at AI venues such as NeurIPS.

The blocking limitation, in one line: **the field has no record of whether its
explanations work on people, and this paper measures the absence rather than
filling it.**

### Passages the chapter quotes or argues from

- Section 4.2, page 5, the signal argument, verbatim: `If we think about the
  production of a possibly-explainable artifact as a signal being sent, it is
  straightforward for us to realize that it takes confirmation that the signal
  was received and understood correctly to confirm a claim of explainability.
  Otherwise, there is no difference between "explainable" AI and any other kind
  of AI, and the many examples of possibly-explainable methods are simply
  sending signals into a void.`
- Section 4.1, page 5, on the questions asked of participants, verbatim: `"Do
  you think this is explainable - yes or no?"` and `"Which is more explainable:
  our explainable method, or this other baseline explanation that is clearly
  worse (e.g., contains grammatical errors or has logical flaws)?"` The paper
  comments: `It is important that evaluation scenarios are crafted realistically
  to their intended target use case.`
- Section 4.1, page 5, on who the subjects are: `in many of the papers, the
  authors do not disclose the subjects' expertise, knowledge, education, or
  relationship to the authors. We found ourselves asking: who are the evaluation
  subjects? If we know nothing about these users' backgrounds, or potential
  motivations to call an XAI technique 'good,' one might argue this introduces
  an unfair bias into the validation.`
- Section 4.1, page 5, on the mismatch between subject and intended user:
  `many of the papers recruited college students as evaluation participants`,
  while `the end-users of these XAI techniques are intended to be cybersecurity
  experts, pilots, doctors, and so on`. The paper concedes the difficulty:
  `Of course, it can be difficult to assemble domain experts to test methods and
  tools, especially domain experts who are not working on the tool with you.`
  And: `we observed a number of papers only having two or three domain experts
  as part of the evaluation`.
- Section 4.2, page 5, on Rudin's distinction: `explainable` as a post-hoc
  treatment of an otherwise black-box model, `interpretable` as stemming from
  model design grounded in expert domain understanding. A number of papers
  scored 0 developed their models with domain experts, meeting the
  `interpretable` definition, yet ran no formal evaluation with those experts.
- Section 5.2, page 6, the call to action, the drug analogy: `A pharmaceutical
  company would never distribute a newly developed drug without extensive
  clinical trials, even if they truly believed in its efficacy from biological
  principles, evidence collected in simulation, mouse trials, and so on. Why can
  XAI models, which may impact high-risk decision-making, be released untested
  with their human users?`
- Section 5.2, page 6, the answer to the bias objection: the same objection
  applies to `every commonly-used machine learning benchmark, from ImageNet, to
  IMDB movie reviews, to medical question-and-answer`, all of which `contain
  human biases from their generation, curation, cultural context, or other
  factors`.

## Paper 25: what kind of paper this is

**A user study with a computed comparison, and it is the first paper in this
book's corpus that puts an automated explanation metric and a human rating of
the same explanation side by side and reports the correlation.** Fifteen pages
in Springer LNCS style, body pages 1-13, accepted at XAI 2026.

Its object is **counterfactual explanations**, not feature attribution. The
metrics it evaluates are the counterfactual metric set (sparsity, proximity,
closeness, diversity, oracle score, trust score, completeness), not chapter 08's
faithfulness metric families. This is the same object gap decision 42 handles for
paper 21, one class over, and chapter 12 carries it in the prose the same way.

## Paper 25: study design, every parameter

Datasets, table 1 page 4, all three from the UCI Machine Learning Repository,
all tabular:

| Dataset | Instances | Features | Classes | F1 score | Test instances | Valid CFs |
|---|---|---|---|---|---|---|
| Mushroom (MUS) | 8124 | 22 | 2 | 1.00 | 1625 | 755 |
| Obesity Levels (OBE) | 2111 | 16 | 7 | 0.95 | 423 | 211 |
| Heart Disease (HRT) | 303 | 13 | 2 | 0.85 | 60 | 25 |

Dataset selection criteria, section 3.1 p. 4, verbatim, because chapter 12
states them: `Our inclusion criteria for dataset selection were: (1)
classification problems with intuitive features and labels supporting intuitive
counterfactual reasoning, (2) sufficient dataset size to train stable models and
produce meaningful CFs, and (3) relevance to real-world tabular decision-making
scenarios.` Footnote 4 on the same page gives the example: the Mushroom dataset
has features such as `cap color: green` and `odor: fishy`, understood without
domain expertise.

Pipeline, section 3.1 pages 4-5:

- Categorical features one-hot encoded, continuous features min-max scaled to
  $[-1,1]$. XGBoost selected as base model, `F1 scores >= 0.85 across datasets`.
  80:20 train-test split.
- CFs generated for all test-set instances with `Counterfactuals Guided by
  Prototypes`, in the open-source Python library `Alibi Explain`.
- A CF counts as valid if the model's prediction on the generated instance has
  flipped to the target class.

Sampling, section 3.2 page 5: k-means clustering on the vectors of the seven
metrics, proportional allocation to cluster sizes with at least one explanation
per cluster, uniform random draw within each cluster. **85 CFs selected: MUS 30,
OBE 30, HRT 25.**

User study, sections 3.3 and 3.5, pages 5-7:

- Run on **Prolific**. Participants introduced to CFs with an example from the
  simplified German Credit Risk dataset. Each explanation shown as a table
  comparing the original instance with the CF, changed features highlighted, plus
  a brief textual description.
- 85 CFs organised into **20 batches of 12 explanations each**, four per dataset;
  each participant assigned one batch. Dataset order randomised, same-dataset
  explanations consecutive.
- Five rating dimensions, each a question on a **4-point Likert scale**
  (1 = Definitely Yes, 4 = Definitely No, plus `I don't know`): **Perceived
  Accuracy** (`Is the class predicted by the model accurate?`),
  **Understandability** (`Is the provided explanation understandable?`),
  **Plausibility** (`Is the provided explanation plausible?`), **Sufficiency of
  Detail** (`Has the provided explanation sufficient detail?`), **User
  Satisfaction** (`Is the provided explanation satisfying?`).
- **One participant failed the attention checks and those judgments were
  discarded. Final analysed sample: 167 participants.** Compensation GBP 2.75,
  median completion time 15 minutes, set to match the German minimum wage at the
  time of collection, EUR 12.82/hour. Ages 20 to 72, M = 40.85, SD = 13.05.
  **77.8% held a higher education degree.** Self-reported ML experience averaged
  2.67, SD = 0.93, on a 1-4 scale.
- **2004 individual ratings collected**, a mean of **23.58** complete rating sets
  per explanation, SD = 2.57.
- Inter-rater reliability by ICC(2,1) and ICC(2,k): individual-level agreement
  low, aggregated ratings `higher but still modest`. No ICC value is printed.
- Internal consistency across the five dimensions **high, Cronbach's alpha =
  0.88**; PCA gives clear unidimensionality, **first component explains 74.1% of
  the variance**. The five are therefore averaged into a single **Combined
  Quality Score (CQS)**.

Power analysis, section 3.4 page 6, which is the reason the chapter can say what
the study was and was not built to see:

- Significance level alpha = 0.05. Per-dataset samples (n = 25/30 explanations)
  give **80% power to detect large effects, r >= 0.50**.
- For the regression with seven predictors, n = 25/30 gives 80% power to detect
  **$R^2$ >= 0.40**; detecting $R^2$ = 0.30 would need n about 42 and
  $R^2$ = 0.15 would need n about 89 explanations per dataset.
- The authors' own reading: `metrics only weakly correlated with user perception
  (r < 0.30) are arguably of limited practical utility. Our study is thus
  well-powered to detect practically significant effects, while acknowledging
  that detecting small or medium-sized effects would require larger samples.`

Table 2, page 7, mean ratings per dataset. Recorded in full because the chapter
prints the `All` row:

| | Acc. | Und. | Plaus. | Suff. | Sat. | CQS |
|---|---|---|---|---|---|---|
| MUS | 2.22+-0.23 | 1.83+-0.16 | 2.08+-0.26 | 2.08+-0.23 | 2.08+-0.20 | 2.06+-0.17 |
| HRT | 2.25+-0.27 | 1.95+-0.19 | 2.24+-0.23 | 2.20+-0.23 | 2.29+-0.24 | 2.19+-0.20 |
| OBE | 2.14+-0.30 | 1.85+-0.27 | 2.16+-0.33 | 2.10+-0.25 | 2.19+-0.33 | 2.09+-0.27 |
| All | 2.20+-0.27 | 1.87+-0.22 | 2.15+-0.28 | 2.12+-0.24 | 2.18+-0.28 | 2.10+-0.22 |

Note the scale direction: 1 is the most positive answer, so a mean near 2.1 sits
between `Definitely Yes` and `Probably Yes`, and a *lower* number is a better
rating. The paper never states this reminder next to table 2; the book states it
where it prints the row, because a reader who assumes higher-is-better reads the
table backwards.

## Paper 25: the seven metrics, as the paper defines them

Section 3.6, pages 7-9. Each has a formula in the paper; the book states none of
them as formulas, on chapter 10's practice, and describes each in one sentence.

| Metric | What it computes | Direction |
|---|---|---|
| Sparsity | count of features that differ between $x$ and the CF $x'$ | lower means fewer features changed |
| Proximity | $\ell_p$ distance between $x$ and $x'$, with $p = 1$ | lower means closer to the original |
| Closeness | mean distance from $x'$ to its $k$ nearest neighbours in the training set, $p = 1$, $k = 5$ | lower means closer to observed data |
| Diversity | mean pairwise $1 - \mathrm{NMI}$ over the changed features, for CFs with at least two changed features | higher means the changed features are more independent |
| Oracle Score | product of the target-class probabilities from the base model (XGBoost) and an oracle model (Random Forest) | higher means stronger cross-model agreement |
| Trust Score | ratio of the distance to the nearest other class over the distance to the predicted class, KD-tree per class, $p = 1$, $k = 3$ | higher means $x'$ sits closer to its predicted class |
| Completeness | share of the model's top-$k$ SHAP importance mass carried by the features the CF changed, $k = 5$ | higher means the CF moves features the model finds important |

**Completeness is computed with SHAP**, which is chapter 04's method. That is
the one place in this chapter where a metric of paper 25's set is built out of a
Part II attribution method, and it is worth the chapter naming, because it makes
one of the seven automated numbers a function of an attribution whose own
faithfulness Part IV has spent five chapters questioning.

## Paper 25: results, every printed number

Section 4.1, page 9, correlations. Pearson correlations between the seven
metrics and the five rating dimensions plus the CQS, computed separately per
dataset; figure 1 on page 10 is the three heatmaps, significance at $p < 0.05$
marked with an asterisk.

| Statement | Value | Anchor |
|---|---|---|
| Only `trust score` significantly associated with CQS when aggregating across all explanations | r = 0.307, p = 0.004 | p. 9 |
| All other metrics, aggregated | negligible, abs(r) < 0.1 | p. 9 |
| MUS: sparsity, diversity, proximity, closeness against sufficiency of detail, satisfaction and CQS | r = -0.38 to -0.64 | pp. 9-10 |
| OBE: diversity, trust score, completeness against plausibility, satisfaction and CQS | r = 0.37 to 0.52 | p. 10 |
| HRT | uniformly weak, non-significant, mixed directions | p. 10 |
| Mean cross-dataset standard deviation of correlation coefficients | 0.31 | p. 10 |

The paper's own reading of the MUS and OBE split, verbatim: MUS suggests `that
users in this domain prefer CFs involving fewer and smaller changes`, OBE
indicates `a preference for more comprehensive or information-rich explanations
in this domain`. The OBE quantifier is the paper's own: `results for the OBE
dataset (Figure 1 (b)) show mostly positive correlations`, so the chapter's
`phần lớn` is the source's word and not the book's. **The two datasets point in
opposite directions on the same metrics**, and that, not the size of any single
correlation, is the finding the chapter argues from.

The paper's own summary sentence, p. 10, immediately after the 0.31, verbatim:
`No single metric, nor any consistent metric combination, reliably proxies human
judgments across domains. These results indicate that relationships between
automated CF metrics and human perception are highly dataset-specific rather
than universal.`

And the characterisation the chapter attributes to it, from the abstract, p. 1,
verbatim: `increasing the number of metrics used in predictive models does not
lead to reliable improvements, indicating structural limitations in how current
metrics capture criteria relevant for humans.` Section 4.3, p. 12, states the
same in its own words: `current automated CF metrics, whether considered
individually or in combination, cannot serve as reliable proxies for human
evaluation of explanation quality.`

Section 4.2, pages 10-12, predictive modelling. Exhaustive powerset over all
**127 non-empty subsets** of the seven metrics; five model classes (linear
regression, kNN, Random Forest, XGBoost, GAMs) across three datasets and six
targets (five dimensions plus CQS); performance is 5-fold cross-validated $R^2$,
so a negative value means the model does worse than predicting the mean.

| Model class | Mean $R^2$ | Anchor |
|---|---|---|
| Linear regression | -1.253 | p. 11 |
| XGBoost | -1.874 | p. 11 |
| kNN | -0.887 | p. 11 |
| Random Forest, best overall | -0.474 | p. 11 |
| GAMs | no value; `frequently fail to converge` | p. 11 |

The representative case in figures 2 and 3, HRT predicting user satisfaction:

- All linear models negative, M = -0.972 (figure 2a's own legend reads
  `Mean=-0.972`).
- Random Forest achieves positive $R^2$ in **95 of 127** metric combinations,
  range -0.209 to 0.331, M = 0.067 (figure 2b's legend reads `Mean=0.067`).
- Figure 3a, linear regression: $R^2$ strictly negative at every complexity
  level; improves slightly up to four metrics, then deteriorates sharply.
- Figure 3b, Random Forest: mean $R^2$ positive but below 0.1 at every
  complexity level; best models peak at three and four metrics, **maximum
  $R^2$ = 0.33 for three used metrics**, then decline monotonically.
- The paper's summary, p. 12: `even for non-linear models, increasing the number
  of metrics beyond a certain value (approximately 3-4) does not improve, but
  degrades performance.`

## Paper 25: what it says about feature attribution, second-hand

Twice, in the introduction (p. 2) and in related work (p. 3), paper 25 reports a
result about **feature attribution** faithfulness metrics that the book has not
read directly. Verbatim, p. 2:

> The M4 benchmark demonstrated that widely used faithfulness metrics for
> feature attribution methods correlate only weakly with one another and can
> produce contradictory method rankings [11].

And p. 3:

> The M4 benchmark showed that widely used faithfulness metrics for feature
> attribution methods often correlate weakly and can lead to inconsistent
> rankings [11].

Reference 11 is `Li, X., Du, M., Chen, J., Chai, Y., Lakkaraju, H., Xiong, H.:
M4: a unified XAI benchmark for faithfulness evaluation of feature attribution
methods across metrics, modalities and models. In: NeurIPS (2023)`.

**The book has not read M4 and adds no bib key for it** (decision 45's
precedent, as chapter 09 did for Lanham and Chen and chapter 10 for Webster and
Nauta). Chapter 12 attributes the claim through paper 25 and says so.

Why it matters, and the boundary that has to hold: this is an *inter-metric
agreement* result on the exact object chapter 08 covers, feature-attribution
faithfulness metrics. Chapter 09 reported the same shape of test on
chain-of-thought metrics and section 9.7 blocked the transfer of the AUROC
numbers. M4 does not cross that boundary either, because agreement is not the
ground-truth comparison: metrics that disagree cannot all be right, but metrics
that agree need not be right. So the correct statement, and the one chapter 12
makes, is that the *agreement* question has now been asked of feature attribution
metrics and answered the same way it was for chain-of-thought metrics, while the
*ground truth* question still has not been asked of them. Chapter 09's open
statement is unchanged.

## Paper 25: limitation and future-work statements, for chapter 18

Fourth of the seven Part IV chapters logged. Section 5, page 13, under the
heading `Limitations`:

1. **Scope.** Constrained in number of datasets, participants, metrics, and the
   single CF generation method used.
2. **Power.** `increasing the number of annotators and including additional
   datasets could enable the detection of small or medium-sized effects that our
   current sample size is not powered to identify.`
3. **One generation method.** Everything rests on Counterfactuals Guided by
   Prototypes; other generators might behave differently.
4. **No domain-knowledge assessment.** Demographics and self-reported ML
   experience were collected, but nothing task-specific; varying background
   knowledge may still influence how participants evaluate CFs.
5. **Lay participants only.** A general online pool via Prolific, so the results
   reflect lay user perception and `the extent to which results generalize to
   domain experts remains an open question`.

Future work, same page: automated proxy metrics `grounded in human-centered
theory and validated against user perception`; more studies across tasks,
modalities and explanation types; and the actionability of CFs as a factor
current metrics do not capture.

The blocking limitation, in one line: **the study shows that the current metrics
are not proxies for human judgment, and cannot say what a metric that were one
would look like.**

## The crossing between the four logged papers

Chapter 10's note recorded the first crossing, papers 21 and 22 naming the same
blocking limitation from opposite directions. This session adds two more, both
of them the book's own reading and marked as such wherever the prose uses them.

1. **Nauta et al. (2023), `From anecdotal evidence to quantitative evaluation
   methods`, ACM Computing Surveys 55(13s), is cited by three of the four
   papers**, for three different things: paper 22 adapts its structure for the
   evaluation-property table of chapter 10's section 10.6 (paper 22's ref 65,
   confirmed in that paper's bibliography on this session's extraction), paper 24
   cites it for the 300-paper finding above (ref 18), and paper 25 cites it in
   related work (ref 16). The book has not read it and adds no key for it; the
   observation is that the one shared reference across the critique core is a
   review of *how XAI is evaluated*, which is exactly the instrument question.
2. **Paper 24 and paper 25 are the two halves of one statement.** Paper 24
   measures that the human check is almost never run. Paper 25 runs it, on one
   family of explanations, and finds the automated numbers do not track it. Taken
   together: the field's automated metrics have not been checked against people,
   and where they have been, they did not agree. Neither paper states the joint
   claim; the chapter does, marked as the book's.

## What chapter 12 must not say

Written down because each of these is a sentence that would be easy to write and
wrong.

- **Not** `fewer than 1% of XAI papers validate faithfulness`. Paper 24 counts
  human validation of explainability claims, and the word faithfulness does not
  occur in it. The count is on the plausibility side of chapter 01's split.
- **Not** `the human study route is the escape from the metric problem`. A human
  rating answers whether an explanation is understood and believed, which is not
  whether it reflects the model. Chapter 16 takes up the escape routes; chapter
  12's job is to establish what the human check can and cannot settle.
- **Not** `automated metrics were shown to be wrong`. Paper 25 shows they do not
  track human perception on three tabular datasets with one CF generator. Two of
  those datasets even disagree with each other on the direction of the effect.
- **Not** `paper 25 measured faithfulness metrics`. It measured counterfactual
  quality metrics. The M4 statement about faithfulness metrics is second-hand and
  is attributed through paper 25.
- **Not** a percentage where the paper's own two percentages disagree. Print
  `128 trong 237`.
