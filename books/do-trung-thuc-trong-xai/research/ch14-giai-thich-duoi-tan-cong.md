# Chapter 14 - explanations under attack, read closely

Date: 2026-09-05. Seventh note in this folder, one per chapter from chapter 08
on (decision 35), and the last of Part IV, which closes the limitation-statement
log the open items have been accumulating since chapter 08.

Chapter 14 is the first chapter in this book to read **three** corpus papers,
and the first to find that its three papers do not stand in the relation its
table-of-contents line asserts. It is also the second chapter to cite a paper
from outside the corpus (decision 34), and for the same reason: the object of
its first section is a construction that no corpus paper defines.

The single most important entry is under "Verified absences": **the word
`faithful` does not occur once in any of the three papers**, across 30 pages of
them. That is the strongest verified absence in the book, because it is not one
paper's silence but a whole tier of the reading ladder's.

## Source pins

| Key | arXiv | Revision read | Pages read | Submitted |
|---|---|---|---|---|
| `p27shlime` | 2508.11053 | **v1**, the only one | 1-7 in full (7 pages incl. references and appendix) | v1 2025-08-14 20:28:48 UTC |
| `p28shapattack` | 2601.10587 | **v3**, the latest of three | 1-15 in full; the file's own pages are numbered 51-65 as symposium proceedings | v1 2026-01-15 16:58:55 UTC; v2 2026-04-08 20:47:19 UTC; v3 2026-04-10 13:24:40 UTC |
| `p29causalshap` | 2509.00846 | **v1**, the only one | 1-8 in full; p. 8 right column is the bibliography, scanned only | v1 2025-08-31 13:31:34 UTC |
| `mfooling` (outside corpus) | 1911.02508 | **v2**, the latest of two | 1-7 in full | v1 2019-11-06 17:52:20 UTC; v2 2020-02-03 18:53:50 UTC |

The three corpus papers were read from
`F:\repo\thesis-xai-faithfulness\4-tier-c-robustness\`. The outside-corpus
paper was fetched from `https://arxiv.org/pdf/1911.02508v2` into the session
scratchpad and is not in the repo (decision 14).

Orientation notes exist locally for all three corpus papers
(`computer-science-news/xai/feature-attribution/2025-08-14-shlime-...md`,
`computer-science-news/computer-vision/2026-01-15-...md`,
`computer-science-news/xai/causal-interpretability/2025-08-31-...md`), so this
chapter is not blocked by the dead-notes open item. **None of them was read
or used.** Every claim below is from the PDF (decision 13).

Text extracted with `pdftotext -layout` for word counts and for prose
quotations. Every formula, every symbol and **every table cell** below was
re-read from the rendered page, per the trap chapter 13's session recorded.
That precaution earned its keep twice this session, in opposite directions:

- The extraction silently drops `≈` and `>` in paper 27, so the sentence that
  reads `(F1 ≈ 0.45)` on the page extracts as `(F1  0.45)`. A threshold with
  its relational operator dropped is a threshold that reads as an equality.
- Going the other way, a first pass read paper 29's Table III off a
  full-page render and transcribed Independent SHAP's colorectal AUROC as
  `0.6588` when the value is `0.5886`. Under the wrong digits the paper's own
  headline claim would have been false, and the chapter would have printed a
  finding that is not there. It was caught by cross-checking the extraction and
  settled by re-rendering that table alone at 300 dpi. **The rule this adds: a
  table cell is read from a crop at high resolution or from the extraction,
  never off a whole rendered page.**

### Metadata verified raw

Verified this session on the raw arXiv abstract pages and through the arXiv
API, not through a summarising fetch.

**Paper 27**, 2508.11053: one revision. `journal-ref` absent. `Comments`
present and reads `7 pages, 7 figures`, naming no venue. Only arXiv's own
DataCite DOI. Categories: primary `cs.LG`, cross-list `cs.CR`. So the chapter
cites the arXiv version and names no venue, on paper 23's precedent
(decision 57).
**The seeded refs.bib title was wrong in capitalisation**: it read
`Foiling Adversarial Attacks Fooling {SHAP} and {LIME}` where the source is
sentence case, `Foiling adversarial attacks fooling SHAP and LIME`. Corrected.
Author list matches exactly. One oddity, recorded and not printed: the
submission-history line reads `From: Sanjana Chauhan`, while the byline reads
`Sam Chauhan`. Nothing in the chapter depends on it.

**Paper 28**, 2601.10587: **three revisions**, and the file on disk carries the
stamp `arXiv:2601.10587v3 [cs.CV] 10 Apr 2026`, so v3 is what was read and v3
is what refs.bib says. This is the second corpus paper with more than one
revision, after paper 26, so decision 15's clause does work for the second
time. `journal-ref` absent. `Comments` present and reads
`10th bwHPC Symposium - September 25th & 26th, 2024`, which **does** name a
venue, and the paper's own running head reads `Proceedings of the 10th bwHPC
Symposium` with the pages numbered 51-65 within that volume. Two DOIs are
recorded: arXiv's own DataCite DOI, and a "Related DOI" with the `10.13140`
prefix, which is ResearchGate's registrar for self-archived documents and is
**not** a publisher DOI. The chapter cites the arXiv version on paper 22's
precedent (decision 48) and names the venue once, because the venue is a
high-performance-computing symposium rather than an XAI or a security one and
that is a fact about how the work was reviewed, not a disparagement.
**Two seeded refs.bib errors**: the title read `...Computer Vision Using SHAP
Values` where the source lowercases `using`; corrected. And arXiv records the
third author as `Roehrbein` where the seed and the paper's own byline both read
`Röhrbein`. **The byline wins**: the PDF prints `Florian Röhrbein` beside an
ORCID, and arXiv's is an ASCII transliteration of it. The seed stays as it is
and this note records the difference so the next session does not "fix" it back.
Symposium date (September 2024) precedes the arXiv posting (January 2026) by
well over a year; recorded, not printed.

**Paper 29**, 2509.00846: one revision. `journal-ref` absent. `Comments`
present and reads `Published in 2025 International Joint Conference on Neural
Networks (IJCNN). IEEE, 2025`, which names a venue. No IEEE DOI appears on the
arXiv record; none was invented. Categories: primary `cs.LG`, cross-list
`cs.AI` and `stat.ME`. **The seeded entry needed no correction at all**, title,
capitalisation and author list, the fourth time that has happened.

**`mfooling`**, 1911.02508: two revisions, v2 read. arXiv's own record has
**no `Comments` row and no `journal-ref`**, so arXiv itself says nothing about
where this paper was published. The PDF's own first page does: it carries the
ACM reference block `In Proceedings of the 2020 AAAI/ACM Conference on AI,
Ethics, and Society (AIES '20), February 7-8, 2020, New York, NY, USA` with
publisher DOI `10.1145/3375627.3375830`. This is decision 53's case exactly
(paper 24 had a publisher DOI printed on the paper and no arXiv `journal-ref`),
so the chapter cites the arXiv version at v2 and the venue printed on the paper
goes in the `note` field rather than into the prose.

### Why an eighth key outside the corpus

Decision 34 admitted seven `m`-prefixed keys to chapter 08 because no corpus
paper defines a faithfulness metric. Chapter 14 meets the same wall in a
sharper form. Paper 27 is a **replication of, and an extension to**, Slack et
al.'s scaffolding attack, and its own abstract says so: `Building on the work
of Slack et al. (2020), we investigate the susceptibility of LIME and SHAP to
biased models`. The attack is the object of sections 14.2 and 14.3, and no
corpus paper contains it - verified, see below. Reading a construction only
through a seven-page replication of it, when the construction is what two
sections argue from, is what decision 34 exists to prevent. One key,
`mfooling`, prefix `m` because a corpus key's number is a reading-ladder
position and this paper has none. Appendix D still lists exactly 32 papers and
does not list it; the reading ladder is unchanged.

## Verified absences

Counted on `pdftotext -layout` output of the full PDFs. Prose extraction is
unaffected by the math-font trap.

| String | Paper 27 | Paper 28 | Paper 29 |
|---|---|---|---|
| `faithful` (any case, any suffix) | **0** | **0** | **0** |
| `ground truth` | **0** | **0** | 7 |
| `attribution` | 3 | 1 | 27 |
| `deletion` | 0 | 0 | 0 |
| `insertion` | 0 | 0 | 5 |
| `comprehensiveness` | 0 | 0 | 0 |
| `sufficiency` | 0 | 0 | 0 |
| `ROAR` | 0 | 0 | 0 |
| `infidelity` | 0 | 0 | 0 |
| `causal` | 0 | 0 | 185 |
| `validat` | 2 | 0 | 4 |
| `metric` | 1 | 0 | 8 |

Readings that matter:

1. **`faithful` is absent from all three.** Chapter 13 recorded the strongest
   single absence in the book, 65 pages with no occurrence. This is stronger in
   a different way: an entire tier of the reading ladder, three papers by three
   unconnected groups on three continents, all writing about what explanations
   get wrong, and none of them reaching for the word. What they reach for
   instead is `bias concealment` (27), `misclassification` (28) and
   `misattributing` (29).
2. **Of chapter 08's metric families, only `insertion` appears anywhere**, and
   only in paper 29, where it is the instrument the repair is scored with.
   That matters to the chapter's argument, so its five occurrences were read
   individually: two in the abstract and contributions, one in the evaluation
   design, one in the experimental description, one in the conclusion. All five
   refer to the same use.
3. Paper 27's three `attribution` occurrences are: `additive feature
   attribution methods` (background), `crease attribution` (a line-broken
   fragment of SHAP's consistency property), and `the feature attribution by
   SHAP and LIME on the adversarial classifiers`. None is a definition.
4. Paper 28's single occurrence is `additive feature attribution method`, in
   its background section. **This paper uses SHAP throughout and names the
   field it belongs to once.**
5. Paper 29's 7 `ground truth` occurrences are all about synthetic reference
   values, never about explanation ground truth. Recorded below.

## Numbers this chapter prints

Every decimal that reaches a page of chapter 14, with its anchor and the
sentence it comes from. The Numbers check reads `\d+\.\d+`, so this list has to
be complete.

### From `mfooling` (Slack et al.), section 14.2

All from "Effectiveness of Adversarial Classifiers", p. 5, and Table 2, p. 6.

| Value | What it is | Anchor and quote |
|---|---|---|
| `0.42` | LIME coefficient of the uncorrelated feature after the attack | Table 2, p. 6. The same table gives race `-0.42` before and `0.0` after; the uncorrelated feature goes `0.0` to `0.42`. Caption: `Feature coefficients of LIME explanations for an instance from COMPAS, before and after an attack (ψ uses a single feature)` |
| `-0.42` | LIME coefficient of race before the attack | same table |

Percentages, which are integers and which the Numbers check does not read, but
which the chapter prints and which therefore belong here anyway:

- LIME, one uncorrelated feature: importance shifted to the uncorrelated
  feature in **100%** of held-out points for COMPAS and Communities & Crime,
  and to `Loan Rate % Income` in **91%** for German Credit. p. 5:
  `the adversarial classifier e successfully shifts the feature importance in
  LIME from the true informative feature ... to the uncorrelated feature in
  100% of held-out points for COMPAS ... and CC ..., and to the Loan % Income
  feature in 91% for German`.
- SHAP, one uncorrelated feature: **100%** for CC, **84%** for COMPAS,
  **85%** for German. p. 5.
- SHAP, two uncorrelated features: removing the bias from first place succeeds
  in only **67%** and **71%** of instances for COMPAS and CC. p. 5:
  `the adversarial classifier is less successful in removing the bias from 1st
  place in the ranking, succeeding in only 67% and 71% instances for COMPAS and
  CC respectively`.
- **The reason the paper gives for that**, quoted because the chapter uses it:
  `This is due to SHAP's local accuracy property that ensures that feature
  attributions must add up to the difference between a given prediction and the
  average prediction for the background distribution. This property will tend
  to distribute feature attributions across several features when it is not
  possible to identify a single most informative feature.`
- Fidelity of the adversarial classifier `e` with respect to the biased
  classifier `f`, i.e. the percentage of held-out instances where the two
  agree: LIME-targeted adversarial classifiers **100%** on all datasets;
  SHAP-targeted **75%** for CC, **80%** for German, **91%** for COMPAS. p. 5.
- Dataset sizes, Table 1, p. 4: COMPAS 6172 defendants, African-American
  **51.4%**, High Risk **81.4%**; Communities & Crime 1994 communities, Violent
  Crime Rate **50%**; German Credit 1000 applicants, Male **69%**, Good
  Customer **70%**. Communities & Crime's Caucasian percentage `ranges from
  2.68% to 99.63%`.
- **The PCA experiment, p. 3**, which sections 14.2 and 14.3 both rest on and
  which the first version of this note omitted. Slack et al. run it themselves,
  as their own motivation and not as a result quoted from elsewhere: `To better
  understand the nature of the synthetic data points generated via
  perturbations, we carried out the following experiment. First, we perturb
  input instances using the approach employed by LIME ... We then run principal
  component analysis (PCA) on the combined dataset containing original
  instances as well as the perturbed instances, and reduce the dimensionality
  to 2. As we can see from Figure 1, the synthetic data points generated from
  input perturbations are distributed significantly differently from the
  instances in the input data.` Paper 27 replicates the same figure (its own
  figure 1, p. 3), which is why the two look alike; the chapter attributes it
  to Slack et al. because that is whose experiment it is.
- **The subsection heading `Detecting OOD Samples`, p. 3**, a bold run-in
  heading in the `Proposed Framework` section. Recorded because the chapter's
  review question 8 sends the reader to it by name, which makes it a checkable
  identifier rather than a description.
- Implementation, p. 4: LIME perturbations are `random noise sampled from
  N(0,1)`; SHAP's background distribution is `cluster centers from kmeans with
  10 clusters`; the OOD classifier is `the standard sklearn implementation of a
  random forest with 100 tree estimators`. Train/test split 90/10.
- Hyperparameter robustness, p. 6: LIME kernel width varied `between 0.15√M to
  0.95√M (default kernel width is 0.75√M...)` and `the attacks remain equally
  effective`; l1 instead of l2 distance `does not impact the effectiveness`;
  SHAP with `5 and 15 clusters are also equally effective`; and
  `Using a background distribution of all zeroes for SHAP makes our attacks
  even more pronounced.`

**Decimals inside those: `0.15`, `0.95`, `0.75`, `2.68`, `99.63`, `51.4`,
`81.4`.** All recorded here.

### From paper 27, section 14.4

Paper 27 reports **no table**. Every quantitative claim in it is a threshold
read off a scatter plot. That is itself worth recording, and it is why the
chapter states these as the paper's readings of its own figures rather than as
measurements.

| Value | What it is | Anchor and quote |
|---|---|---|
| `0.45` | OOD-classifier F1 at which SHAP starts to be foolable | Extensions, p. 5: `SHAP is partially susceptible to attacks from less accurate OOD classifiers (F1 ≈ 0.45) but requires highly accurate classifiers for complete deception (F1 ≈ 0.7)` |
| `0.7` | OOD F1 up to which **LIME** stays resilient | same sentence, and **this row was wrong in the first version of this note**, which read it as the threshold for complete deception of SHAP. The sentence has no parenthetical after `complete deception`; the `(F1 ≈ 0.7)` that follows attaches to `LIME remains resilient until reaching higher accuracies`. The chapter's prose reads it correctly; only this row was wrong |
| `0.8` | OOD F1 beyond which LIME is `easily fooled` | same sentence, continuing: `while LIME remains resilient until reaching higher accuracies (F1 ≈ 0.7) but becomes easily fooled beyond that threshold (F1 > 0.8)` |
| `0.75` | OOD F1 above which the replication saw LIME's vulnerability rise sharply | Methodology/Results, p. 4: `the ability of the adversarial model to fool LIME sharply increased as the F1 score increased above 0.75` |
| `0.5` | OOD F1 around which SHAP's vulnerability begins, in the replication | same sentence: `while the ability of the model to fool SHAP increased comparatively gradually beginning around an F1 score of 0.5` |
| `0.8` | Explanation accuracy BASIC SHLIME is said to hold | Conclusions, p. 5-6: `BASIC SHLIME maintains strong explanation accuracy (consistently above 0.8) for a wider range of F1 scores (similar to LIME), only beginning to show significant degradation around F1 ≈ 0.75` |
| `0.75` | OOD F1 at which BASIC SHLIME is said to degrade | same sentence |

**The `≈` and `>` signs are on the rendered page and are dropped by
`pdftotext`.** Read from the page.

**Finding, and section 14.4 turns on it.** The same paper gives LIME's collapse
threshold three different values in two paragraphs: `F1 ≈ 0.7`, `F1 > 0.8` in
one sentence about the same event, and `above 0.75` in the replication
paragraph. It gives SHAP's onset as `F1 ≈ 0.45` and `around 0.5`. And it then
reports its own method degrading `around F1 ≈ 0.75` and calls that an
improvement. **0.75 lies inside the spread of the numbers the improvement is
measured against.** The chapter states this and does not accept the comparison.

**Second finding.** The abstract says `we assess multiple LIME-SHAP ensemble
configurations` and `Our results identify configurations that substantially
improve bias detection`, both plural. The body evaluates exactly one: `BASIC
SHLIME, an ensemble method that returns the LIME value multiplied by the SHAP
value for each feature` (p. 5). Full-text search for `SHLIME` returns no second
configuration anywhere; the other combining methods named (weighted average,
mixture of experts) are named as rejected or as future work. Verified by
listing every occurrence of `SHLIME`, `ensemble` and `configuration` in the
extraction.

**Third finding, and it is the paper's own claim about SHAP, not the book's.**
Justifying the product, p. 5: `SHAP values lie between 0 and 1, while LIME
values can be unbounded and negative`. That is wrong about SHAP and chapter 04
is where the book already says why: a Shapley value is signed, and local
accuracy makes the values sum to `f(x) − E[f(X)]` rather than bounding any one
of them to the unit interval. The paper's own background section, p. 2, states
local accuracy correctly two pages earlier. The chapter records the
contradiction and states what it costs the construction: a product of two
signed numbers has the sign of neither factor, so the combined score cannot
carry the direction of an attribution.

### From paper 28, section 14.5

Table 1, p. 62 of the proceedings numbering (p. 12 of the PDF), caption
`Misclassification Rate for Evasion Attack using FGSM by Kurakin et al. (2017)
and SHAP Attack`. Transcribed from a crop of the rendered page:

| Dataset | FGSM rate | FGSM ε | SHAP rate | SHAP ε | Model accuracy |
|---|---|---|---|---|---|
| Animal Faces | 52 % | 0.2 | 73 % | 50 | 99.5 % |
| Cats and Dogs Filtered | 98 % | 0.01 | 89 % | 80 | 98 % |
| MNIST | 34 % | 0.2 | 60 % | 1.5 | 99 % |
| Woman and Man Faces | 69 % | 0.2 | 98 % | 60 | 97 % |

**Decimals: `0.2`, `0.01`, `1.5`, `99.5`.** The rest are integer percentages.

Two of these rows are restated in the prose and both agree with the table:
p. 61, `The optimal ε ... is simulated as 0.2 for FGSM and 50 for SHAP attacks.
52 % misclassifications occur with FGSM and 73 % with SHAP attacks`; and
`Here ε is 60 for the SHAP attack and 0.2 for FGSM. The FGSM attack achieved a
misclassification rate of 69 % and SHAP attacks of 98 %`.

**Reading of the table the chapter prints.** The SHAP attack beats FGSM on
three datasets of four and loses on one, Cats and Dogs Filtered, 89 % against
98 %. The paper's own summary is not `always higher` but `SHAP-based attacks
consistently result in stable misclassification rates` (p. 63), against FGSM's
range of 34 % to 98 %, and the abstract's claim is narrower still: `more robust
in generating misclassifications particularly in gradient hiding scenarios`.
The chapter takes the narrow claim, which the table supports, and says so.

Other numbers from paper 28:

- Attack parameter guidance, p. 60: `ε ∈ [0,∞) stands for the intensity of the
  attack. In our investigations, ε = 1/(20σ_φ), with σ_φ as the standard
  deviation of φ, proved to be a good starting point.` And: `We recommend 2σ_φ
  for v as a first orientation. The parameter h ensures that only pixels with
  an increased absolute value are manipulated. Values between 0.2 and 0.3 are
  recommended.` **Decimals `0.2` and `0.3`.**
- The neutral zone, p. 56 and p. 57: `pixels with a value in the middle of the
  range (between 0-1) are more likely to have a SHAP value close to zero
  (according to Figure 2 at a pixel value of approximately 0.50)`, and for the
  overlaid version, `the neutral area is around 0.4`. For MNIST, p. 59: `the
  area with less influence on the model output is not close to 0.4 as in the
  two examples above, but rather lower, at around 0.3 or below`. **Decimals
  `0.50`, `0.4`, `0.3`.**
- Architectures, p. 58: Animal Faces `512x512` reduced to `64x64x3`, `3
  convolutional layers and a total of around 76k parameters`; Cats and Dogs
  Filtered `160x160x3` with `transfer learning with EfficientNetB7 ... with
  more than 66 million parameters`; MNIST `28x28x1` with `two convolutional
  layers followed by a dense layer with a total of 450k parameters`; Woman and
  Man Faces `64x64x3`, `3 convolutional layers and a total of around 76k
  parameters`.
- Confidence figures under the images of figure 7, p. 61, and figure 8, p. 62,
  are read off the image captions and **are not printed by the chapter.**

**Finding, and the chapter names it.** The prose on p. 60 says the attack
should move positive-φ pixels away from the high-influence edge regions **and
push negative-φ pixels out to the edges**: `moving away from the grey areas for
positive SHAP values and shifting the neration ones to the edges removes the
information the model needs for correct classification` (the typo `neration`
for `negative` is the paper's). Equation 5 does not do the second half. As
printed it reads

```
x' = x + ε · { −|φ|  if x ≥ 1−h ∧ V ;   |φ|  if x ≤ h ∧ V }
```

with `V` the condition `φ ≥ v ∨ φ ≤ −v` from equation 4. The branch is selected
by the **pixel value** `x` alone, and both branches move the pixel toward the
middle of the range. Nothing in equation 5 depends on the sign of `φ`; `|φ|`
discards it, and `V` is symmetric in it. So the equation implements one of the
two movements the prose describes. Recorded under decision 40's rule: the
chapter states what the paper wrote and what the equation does, and takes only
what the equation supports.

### From paper 29, section 14.6

Table I, p. 7, dataset summary. Integers: Lung Cancer Risk 4 features, 800
train, 200 test, regression, synthetic; Cardiovascular Risk 5 / 800 / 200 /
regression / synthetic; IBS 31 / 294 / 74 / classification / real-world;
Colorectal Cancer 21 / 18321 / 4580 / classification / real-world.

Data-generating equations, p. 7, printed by the chapter because the ground
truth is defined by them:

```
lung_cancer_risk = 2 · smoking + 1.2 · stress + ε_risk       (16)
drink_coffee     = 2 · smoking + stress + ε_coffee           (17)
bmi           = 0.4 · diet_score + 0.5 · sleep_duration + ε_bmi   (18)
mental_health = 1.5 · bmi + ε_health                          (19)
cv_risk       = 1.5 · bmi + ε_risk                            (20)
```

with `ε_risk ~ N(0,3)`, `ε_coffee ~ N(0,1)`, `ε_bmi ~ N(0,1)`,
`ε_health ~ N(0,1)`, `ε_risk ~ N(2,3)`; `stress` and `smoking` from `N(5,2)`;
`diet_score` from `U(1,10)`, `sleep_duration` from `N(8,4)`, `family_history`
from `N(4,2)`. **Decimals: `1.2`, `0.4`, `0.5`, `1.5`.**

**Table II, p. 7**, transcribed from a 300 dpi crop. Caption: `Comparison of
SHAP Methods on Synthetic Dataset 1 & 2. Bold values indicate the best
performance and underline values indicate second best.`

Lung Cancer block:

| Feature | Ground Truth | Causal SHAP | Independent SHAP | Kernel SHAP | On Manifold | Shapley Flow | ASV |
|---|---|---|---|---|---|---|---|
| Smoking | 5.2171 | 5.3462 | 3.9467 | 3.2405 | 2.0104 | 2.1600 | 5.9366 |
| Stress | 0.2507 | 0.2600 | 0.1031 | 0.3620 | 1.8759 | 0.2600 | 1.9125 |
| Drink Coffee | - | 0.0000 | 1.8163 | 1.9514 | 1.9798 | 0.0000 | -0.0805 |
| **RMSE** | - | **0.0167** | 1.6357 | 3.9193 | 12.9241 | 8.8037 | 3.2792 |

Cardiovascular Risk block:

| Feature | Ground Truth | Causal SHAP | Independent SHAP | Kernel SHAP | On Manifold | Shapley Flow | ASV |
|---|---|---|---|---|---|---|---|
| Diet Score | 0.5526 | 0.2397 | -0.5545 | -0.1910 | 1.3073 | 2.4000 | 0.0288 |
| Sleep Duration | 3.6362 | 2.2416 | 0.1123 | 0.3247 | 1.1862 | 3.9300 | 0.0401 |
| BMI | - | 3.6056 | 4.1359 | 4.2996 | 1.3811 | 3.0900 | 4.9054 |
| Mental Health | - | 0.0000 | 1.3065 | 1.7032 | 1.3838 | 0.0000 | 0.2841 |
| **RMSE** | - | **2.0422** | 13.6421 | 11.5176 | 6.5710 | 3.4993 | 13.2048 |

**Table III, p. 8**, insertion score. Footnotes: `All results are averaged over
5 runs with different random seeds` and `Bold values indicate the best
performance and underline values indicate second best for each dataset and
metric.`

| Method | IBS AUROC | IBS CE | IBS Brier | Colorectal AUROC | Colorectal CE | Colorectal Brier |
|---|---|---|---|---|---|---|
| Independent SHAP | 0.8527 ± 0.0326 | 0.4779 ± 0.0336 | 0.1517 ± 0.0136 | 0.5886 ± 0.0337 | 0.6893 ± 0.0175 | 0.2475 ± 0.0080 |
| Kernel SHAP | 0.8548 ± 0.0284 | 0.4674 ± 0.0360 | 0.1474 ± 0.0148 | 0.6263 ± 0.0149 | 0.6766 ± 0.0090 | 0.2410 ± 0.0040 |
| On Manifold | 0.8589 ± 0.0244 | **0.4644** ± 0.0311 | **0.1461** ± 0.0132 | 0.6243 ± 0.0132 | 0.6781 ± 0.0081 | 0.2416 ± 0.0035 |
| Shapley Flow | 0.8274 ± 0.0359 | 0.5233 ± 0.0434 | 0.1706 ± 0.0178 | 0.5868 ± 0.0262 | 0.6864 ± 0.0148 | 0.2463 ± 0.0069 |
| ASV | 0.8225 ± 0.0356 | 0.5327 ± 0.0414 | 0.1756 ± 0.0174 | 0.6177 ± 0.0170 | 0.6750 ± 0.0087 | 0.2406 ± 0.0039 |
| Causal SHAP | **0.8594** ± 0.0227 | 0.4645 ± 0.0314 | 0.1464 ± 0.0134 | **0.6271** ± 0.0190 | **0.6735** ± 0.0096 | **0.2397** ± 0.0044 |

The paper's summary of this table, p. 8, checks out cell by cell: `On IBS
dataset: Best AUROC (0.8594) and second-best Cross Entropy (0.4645) and Brier
scores (0.1464)`, and `On Colorectal Cancer dataset: Best performance across
all metrics (AUROC: 0.6271, Cross Entropy: 0.6735, Brier: 0.2397)`. **Both
hold.** This is the claim the misread digit would have made false; it is not
false.

Other paper 29 numbers:

- Monte Carlo sensitivity, p. 8: `AUROC is not sensitive to changes in M once
  it exceeds 64. (e.g., IBS dataset: M=32 yields AUROC=0.5678; M=64 yields
  AUROC=0.5680)`. **Decimals `0.5678`, `0.5680`. These two do not sit on the
  same scale as Table III's IBS AUROC of 0.8594 and the paper does not say
  what changed between them.** Recorded as an unexplained gap in the paper, on
  the precedent of chapter 09's note recording the 3,066-against-1,120 gap.
  The chapter does not print them and does not build on them.
- Timings, p. 8: `the Causal SHAP Value Computation, PC, and IDA take 366.13,
  0.26, and 1.56 seconds, respectively` for all IBS instances. **Decimals
  `366.13`, `0.26`, `1.56`.** Hardware: `AMD EPYC 7713`.

## The book's own arithmetic

Recorded here because the chapter prints its result, and because nothing in the
paper states it.

**Paper 29's Table II column headed `RMSE` is not a root-mean-square error. It
is the sum of squared deviations from the ground-truth column, over the
features that have a ground-truth value.** The Cardiovascular block reproduces
on all six methods and the Lung Cancer block on four of six.

Reproduced with `scratchpad/rmse_check.py`, which takes the transcribed cells
above and computes both readings:

| Block, method | Table's figure | Sum of squared deviations | RMSE over the same two features |
|---|---|---|---|
| Lung, Causal SHAP | 0.0167 | 0.016753 | 0.0915 |
| Lung, Independent SHAP | 1.6357 | 1.635702 | 0.9044 |
| Lung, Kernel SHAP | 3.9193 | 3.919335 | 1.3999 |
| Lung, On Manifold | 12.9241 | 12.924200 | 2.5421 |
| Lung, Shapley Flow | 8.8037 | **9.345947** | 2.1617 |
| Lung, ASV | 3.2792 | 3.279259 | 1.2805 |
| CV, Causal SHAP | 2.0422 | 2.042816 | 1.0106 |
| CV, Independent SHAP | 13.6421 | 13.643542 | 2.6119 |
| CV, Kernel SHAP | 11.5176 | 11.518973 | 2.3999 |
| CV, On Manifold | 6.5710 | 6.572072 | 1.8127 |
| CV, Shapley Flow | 3.4993 | 3.499205 | 1.3227 |
| CV, ASV | 13.2048 | 13.206302 | 2.5697 |

**Eleven of twelve reproduce**, every one of them to within the rounding that
four-decimal inputs allow once they are squared: the largest gap among the
eleven is 0.0015, on the cardiovascular block where the deviations are largest.
Two are exact at four places, Independent SHAP's `1.6357` and Kernel SHAP's
`3.9193`, and an agreement that close eleven times is not a coincidence.

**One cell does not reproduce: Shapley Flow on the lung block**, printed
`8.8037` against a computed `9.345947`. No reading tried accounts for it,
including treating the ground-truth-less `Drink Coffee` cell as a ground truth
of zero. Its Smoking cell was re-read at 200 dpi and is `2.1600`; had it been
`2.2500` the sum would be `8.80370`, exact to five places, so the likeliest
explanation is a slip in that row of the paper rather than a different formula.
**The chapter states one cell, does not guess at the cause, and does not build
on it.**

**The rankings are identical under both readings, in both blocks**, which the
script above checks explicitly rather than asserting: `RMSE = sqrt(SSE/2)` is
monotone, so the ordering cannot change. Causal SHAP is lowest on both datasets
either way. **Independent SHAP's underlined second place in the lung block is
also correct** (1.6357 < 3.2792 < 3.9193), so nothing in the table's own
markings is in doubt and the chapter withholds nothing.

### A transcription error that nearly shipped, and what caught it

The first version of this note recorded the lung block's **ASV / Stress** cell
as `0.2600`, which is the value in the neighbouring Shapley Flow column. The
page prints `1.9125`. On the wrong value ASV's reconstruction came out at
`0.5178` against a printed `3.2792`, so the note reported *two* irreproducible
cells instead of one, the chapter said "four of six" where the lung block
reproduces five of six, and it declined the table's second-best marking on the
grounds that the reading which supports it was in doubt. None of that was true.

**This is the same failure the preamble above already warned about, committed
after writing the warning.** The earlier instance was a misread digit inside a
cell; this one is a whole cell taken from the wrong column, which no digit-level
care would have caught. What caught it was the cold audit recomputing the column
from the page rather than from this note. The rule the preamble states is
therefore not enough on its own, and the stronger version is: **a reconstruction
that fails on some cells is evidence about the transcription before it is
evidence about the source.** An irreproducible cell is the first place to
re-read, not the first place to report.

**The one instance the chapter works out on the page**, so its two intermediate
decimals are recorded here. On the lung block, Independent SHAP scores smoking
`3.9467` and stress `0.1031` against ground truths of `5.2171` and `0.2507`.
The two deviations are therefore

```
3.9467 - 5.2171 = -1.2704
0.1031 - 0.2507 = -0.1476
```

and `(-1.2704)^2 + (-0.1476)^2 = 1.61391 + 0.02179 = 1.63570`, which is the
`1.6357` the table prints. The root-mean-square error over the same two
features is `sqrt(1.6357/2) = 0.9044`, which matches no cell in the table.
Both `1.2704` and `0.1476` are the book's own subtraction from the transcribed
cells above, not values the paper prints.

Table II carries no footnote about averaging over runs, unlike Table III, so
the reconstruction is against the printed cells and nothing else.

**What this does and does not cost the paper.** The two readings are monotone
in one another, `RMSE = sqrt(SSE/2)`, so every ranking in Table II is identical
under both, and Causal SHAP is lowest on both datasets either way. **The label
is wrong and the conclusion drawn from the column stands.** That is decision
62c's rule applied on purpose: a wrong derivation licenses rejecting the
derivation, not the conclusion.

## Claims checked against the PDFs and found not to hold

Recorded so the chapter states them once and so no later session re-derives
them.

1. **Paper 27's abstract promises `configurations`, plural; the body has one.**
   Verified by exhaustive search, above.
2. **Paper 27's `SHAP values lie between 0 and 1`** contradicts local accuracy
   as its own background section states it two pages earlier, and is false.
3. **Paper 27 gives LIME's threshold three values and SHAP's two**, above.
4. **Paper 28's equation 5 does not implement the second half of the movement
   its prose describes**, above.
5. **Paper 29's Theorem V.2 does not prove the property it is presented as
   establishing.** The paper states missingness, in Section V, as `Any instance
   missing a feature-value should assign a zero attribution value to that
   missing feature`. Theorem V.2 states and proves something else: `Let
   G = (V,E) be the causal graph and i be a feature. If i ∉ V or i has no path
   to the target variable in G, then φ_i^c = 0.` Absence from the causal graph
   is not absence of a feature value. The proof is correct for what it states.
   The chapter states both and does not claim the axiom is recovered.
6. **Paper 29's extension of consistency to the normalised values is asserted
   and is false.** After proving Theorem V.3 for `φ^c`, p. 6: `Note that
   although Theorems V.2 and V.3 are shown with respect to φ_i^c, it is easy to
   see that they hold for φ_i^n as well.` Equation 11 normalises by a factor
   that depends on the model, `(f(x) − E[f(X)]) / Σ_j φ_j^c`. Consistency is a
   statement across **two** models `f` and `f'`, so the two sides are scaled by
   two different factors, and `φ_i^c(f') ≥ φ_i^c(f)` does not give
   `φ_i^n(f') ≥ φ_i^n(f)`. The extension holds for Theorem V.2, whose
   conclusion is zero and survives any positive scaling; it does not hold for
   V.3. **This is the price of the normalisation that buys Theorem V.1**, and
   Theorem V.1 is true by construction rather than earned: its proof is one
   line of cancellation. Decision 62's class, and the chapter declines the
   extension on the record while keeping V.1 and V.2.

## The book's own inferences

Marked here so the prose marks them too. None is a claim any of the four papers
makes.

1. **That the scaffolding setup is a constructed faithfulness ground truth for
   feature attribution.** Slack et al. build `f` to use the protected attribute
   and nothing else, so on the data distribution the correct top-ranked feature
   for `e` is known in advance by construction. The paper calls the measured
   quantity `% of data points for which race is the most important feature` and
   never calls it ground truth or faithfulness. The identification with section
   9.7's first crossing item is the book's.
2. **That the attack exploits chapter 08's first free choice.** The
   perturbation distribution is the free choice chapter 08 isolates, and the
   attack is a construction that makes the model's behaviour differ between
   that distribution and the data distribution. Neither paper frames it that
   way; both frame it as an OOD problem.
3. **That paper 28's attack success is evidence about attribution quality at
   all.** The paper is about attack success, not about SHAP. The observation
   that a SHAP-guided attack outperforming a gradient-guided one is a statement
   about what SHAP recovered is the book's, and the chapter also states the
   limit on it: it is evidence about `mức quan trọng`, the causal-influence
   property chapter 09 holds apart from `độ trung thực`, and treating it as
   evidence for the second is the conflation the anchor diagnoses.
4. **That paper 29 evaluates a repair with an instrument Part IV has just
   finished calling unvalidated.** The paper calls the insertion score `a
   standard metric used for feature attribution evaluation` and cites RISE for
   it. That it is chapter 08's insertion family, and that chapter 09 is why
   `standard` is not the same as `validated`, is the book's.
5. **That the three papers do not stand in the relation the SPEC's TOC line
   asserts.** See below.
6. **That paper 27's improvement claim is not separable from its own scatter.**
   The book's, from the numbers in the table above.

## The TOC line, re-checked before drafting

The open item decision 56 opened asks for every remaining init-written TOC line
to be re-checked against its papers' abstracts before drafting, in both
directions. Chapter 14's line reads:

> **Giải thích dưới tấn công** - adversarial fooling of explanations, SHAP as
> an attack surface, causal structure as a partial repair. Papers 27, 28, 29.

Checked against all three abstracts and then against the full papers. **It
fails, and it fails in a way none of the previous five did.**

- Clause 1, `adversarial fooling of explanations`: **paper 27 replicates it and
  no corpus paper contains it.** Paper 27's own abstract is explicit that it is
  building on Slack et al.; its contribution is a testing framework and an
  ensemble defence. So the clause names the subject of an outside-corpus paper.
- Clause 2, `SHAP as an attack surface`: papers 27 and 28 both fit the words
  and they fit them in **opposite directions**. In 27 SHAP is the thing
  attacked; in 28 SHAP is the thing that does the attacking, against an image
  classifier, benchmarked against FGSM. `Attack surface` is the first sense
  only. One clause, two non-interchangeable relations.
- Clause 3, `causal structure as a partial repair`: **holds for paper 29**,
  which is the only clause of the three that survives contact. `Partial` is the
  book's word and is fair: the abstract says Causal SHAP `reduces attribution
  scores for features that are merely correlated`, not that it eliminates the
  problem.
- What the line does not name: **paper 29 has no adversary in it anywhere.**
  `attack`, `adversarial` and `robustness` do not describe it; its weakness is
  a statistical one that shows up under ordinary use. A chapter titled
  `Giải thích dưới tấn công` that contains it has to say so rather than let the
  title carry the claim.

**This is the sixth TOC finding and a new failure mode.** Decisions 24, 28, 47
and 56 are lines that promise more than the paper contains; decision 59 is a
line that promises less. This line's clauses are each defensible about some
paper; what it gets wrong is the **relation between them**, by presenting three
papers as three stages of one story - the attack, its surface, the repair -
when two of them point in opposite directions and the third is not in that
story at all. Nothing in a drafting session contradicts a line like that
either, because each clause checks out on its own; what has to be checked is
whether the papers stand in the relation the line implies.

## Limitation and future-work log for chapter 18

The last three entries of the Part IV log. With these, **all seven Part IV
chapters are logged and the open item closes.**

**Paper 27**, Future Work, p. 6, three statements:

1. `The natural path to take after this research would be to create a proper
   OOD classifier for our potential SHLIME models. While our results using both
   the LIME and SHAP OOD classifiers are promising, the strength of our results
   is limited by the inability to truly compare its robustness on a fair scale
   in comparison to LIME and SHAP individually.` **The paper's own statement
   that the comparison its conclusion rests on was not a fair one.**
2. `the focus of this research was mainly on the robustness of our SHLIME
   implementation, specifically to these kinds of adversarial attack. However,
   it is also important to consider how well it performs in its intended
   interpretability task compared to LIME and SHAP. In future research, it
   would be useful to see how SHLIME performs in comparison to both LIME and
   SHAP on a wide array of datasets.` **The missing instrument again, named
   from inside a defence paper**: the authors say they never measured whether
   their explanation explains anything.
3. Alternative combination methods, naming mixture of experts.

**Paper 28**, Conclusion, p. 63-64, two statements:

1. `Future research should focus on improving the defence mechanisms of
   computer vision models to mitigate the risks posed by these attacks. A
   development towards better generalized models would be desirable, where the
   influence of individual pixels is more balanced across the image and the
   classification relies less on individual pixels.`
2. `SHAP attacks not only require access to the model but also the availability
   of sufficient inference data for the calculation of the SHAP values.
   Depending on the resolution of the images and the number of classes, high
   computing resources may also be required due to the high computational
   complexity.`

**Neither names a missing faithfulness instrument.** Like paper 26, this is a
non-crossing, and for a related reason: the paper's object is attack success,
which its own model measures directly.

**Paper 29**, Conclusion and Future Work, p. 8, four statements: `(1) address
cases with hidden variables using the FCI algorithm for causal graph
estimation; (2) Explore Greedy Equivalence Search (GES) when the PC algorithm
becomes computationally expensive as number of features scale; (3) Enhance our
framework to handle causal structure uncertainty by aggregating multiple
possible causal graphs. (4) Develop more efficient approximation algorithms for
high-dimensional datasets with complex feature dependency structures.` Plus the
stated assumption they sit on: `We chose the PC algorithm due to its widespread
use, under the assumption that no hidden variables influence the dataset.`

**Also a non-crossing, and this one is the sharpest of the three.** Every item
is about improving the causal-discovery half. **Not one is about how you would
know the resulting attributions are right.** The paper validates against
synthetic ground truth and the insertion score and lists no future work on
either, which means the instrument question does not appear in its limitation
statement at all - not as a gap it names, and not as a gap it fills.

**Where the Part IV log now stands, for chapter 18.** Seven chapters, and the
statements fall into two groups rather than one. Papers 21, 22, 23, 24 and 25
name the same blocking limitation from five directions: measured to fail,
recorded as having no standard, named as the next step not taken, counted as
almost never run, and run once with the answer not tracking. Papers 26, 28 and
29 do not name it, and the three non-crossings do not have the same shape
either: paper 26 wants a computable stand-in for an uncomputable quantity,
paper 28 wants better-generalising models, paper 29 wants better causal
discovery. **Paper 27 is the only one of the three robustness papers that
crosses, and it crosses at the strongest point in the log**, because it is a
paper proposing an explanation method that says in its own future work that it
did not measure whether the method explains. That is paper 23's crossing
(the missing instrument named from inside a methods paper) for the second time,
and this time from inside a paper whose whole purpose is to repair
explanations.

## What the chapter takes and what it leaves

Left, on the record:

- Paper 28's figures 7 and 8 confidence percentages, read off image labels
  rather than a table.
- Paper 29's `M=32`/`M=64` AUROC figures, for the unexplained-scale reason
  above.
- Paper 29's Table II second-best markings in the lung block, for the
  two-cell reason above.
- The whole of Slack et al.'s related-work section, and paper 28's survey of
  white-box attack methods (Szegedy, DeepFool, ADef, Papernot). Named through
  the paper that names them, on decision 45's precedent, where they are named
  at all.
- Paper 29's figures 6 and 7 beeswarm plots: nothing in the chapter rests on
  the individual dot positions.
