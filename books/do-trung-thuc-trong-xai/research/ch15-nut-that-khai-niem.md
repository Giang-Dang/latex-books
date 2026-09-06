# Chapter 15 - concept bottleneck models and leakage

Date: 2026-09-06. Eighth chapter note in this folder, one per chapter from
chapter 08 on (decision 35), and the first outside Part IV.

Chapter 15 reads three papers again, like chapter 14, but the three stand in a
relation the chapter 14 session did not meet: **one of them states a fourth
paper's finding backwards, and the chapter cannot say so without reading that
fourth paper.** That is why this chapter cites a third key from outside the
corpus.

The single most important entry is not a defect but the opposite. Paper 30
proposes two metrics and then **validates them against a criterion it did not
choose**, which is the thing Part IV spent seven chapters saying the
faithfulness literature has never done. What makes it possible is that in a
concept bottleneck model the ground truth arrives with the dataset: the concepts
are annotated. The chapter's job is to say that plainly and then say exactly how
far it carries.

## Source pins

| Key | arXiv | Revision read | Pages read | Submission history |
|---|---|---|---|---|
| `p30leakage` | 2504.14094 | **v3**, the latest of three | 1-25 in full (body plus appendix A); 26-39 are further appendix figures and the bibliography, scanned only | v1 Fri, 18 Apr 2025 22:21:06 UTC; v2 Mon, 19 May 2025 14:09:26 UTC; v3 Tue, 24 Mar 2026 09:58:24 UTC |
| `p31cbmrisks` | 2506.04237 | **v1**, the only one | 1-10 in full (pages 7-10 are the bibliography, scanned only) | v1 Sun, 25 May 2025 03:53:26 UTC |
| `p32cbmsae` | 2512.10805 | **v2**, the later of two | 1-9 body in full, plus appendix sections A and B on pages 9-10; 11-15 are further qualitative figures and were scanned only | v1 Thu, 11 Dec 2025 16:48:07 UTC; v2 Mon, 30 Mar 2026 18:43:32 UTC |
| `mclm` (outside corpus) | 2106.13314 | **v1**, the only one | 1-13 in full | v1 Thu, 24 Jun 2021 21:00:28 UTC |

The three corpus papers were read from
`F:\repo\thesis-xai-faithfulness\5-tier-d-concept-bottleneck\`. The
outside-corpus paper was fetched from `https://arxiv.org/pdf/2106.13314` into
the session scratchpad and is not in the repo (decision 14).

**Paper 30 is the third corpus paper with more than one revision** and the
second with three, after paper 28. **Paper 32 is the fourth**, with two. So
decision 15's "cited as the revision read" clause does work twice more in this
chapter, and both files' own stamps were checked against the abstract page
rather than trusted.

### A deviation in how the records were verified

Every chapter since 11 has re-verified its records **twice**, raw against both
the arXiv abstract page and the arXiv API. This session could not do the second.
`export.arxiv.org/api/query` returned `HTTP 429 Rate exceeded` to every request,
with and without a custom User-Agent, over both `https` and `http`, and over
several minutes; a later retry from the orchestrator returned an empty body.
**So all four records below come from the abstract pages alone**, fetched with
`curl` on 2026-09-06 and read raw:

```
curl -s https://arxiv.org/abs/2504.14094
curl -s https://arxiv.org/abs/2506.04237
curl -s https://arxiv.org/abs/2512.10805
curl -s https://arxiv.org/abs/2106.13314
```

The submission histories, the `Comments` fields and the absence of
`journal-ref` in all four were each read off those pages directly, not off a
summary of them. A later session that wants the second source should re-run the
API query; nothing below is expected to change.

### The records themselves

- **Paper 30.** No `journal-ref`. `Comments: 39 pages, 25 figures`, which names
  no venue. No publisher DOI, only the auto-issued
  `https://doi.org/10.48550/arXiv.2504.14094`. Primary category `cs.LG`,
  cross-listed `cs.AI` and `stat.ML`. So the chapter cites the arXiv version and
  names no venue, on paper 23's precedent.
- **Paper 31.** No `journal-ref`, and **no `Comments` row at all**, which is
  paper 27's case: arXiv says nothing about where it was published. Primary
  `cs.LG`, cross-listed `cs.AI`. Cited as the arXiv version, no venue named.
- **Paper 32.** No `journal-ref`, but `Comments: CVPR 2026`. That is decision
  48's case exactly, the same as papers 22, 25, 28 and 29: an acceptance
  recorded in `Comments` and nowhere else. Cited as the arXiv version at v2,
  and the venue lives in the refs.bib `note` field. Primary `cs.LG`,
  cross-listed `cs.CV`.
- **Paper `mclm`.** Single revision. Its own first page carries no venue block.

### Titles, checked character by character against the abstract pages

- Paper 30: `Leakage and Interpretability in Concept-Based Models`. Capital `B`
  in `Based`.
- Paper 31: `A Comprehensive Survey on the Risks and Limitations of
  Concept-based Models`. **Lower-case `b`** in `Concept-based`, unlike paper 30.
  Two papers a year apart on the same subject capitalise the same compound
  differently, and the seeded refs.bib entries already had both right; neither
  needed correcting, which is the fifth and sixth time a seeded entry has
  survived.
- Paper 32: `Interpretable and Steerable Concept Bottleneck Sparse
  Autoencoders`.

No author name differs between the arXiv record and the PDF byline in any of
the four, so there is no repeat of paper 28's `Roehrbein` / `Röhrbein` split.

## Extraction traps met this session

Text was extracted with `pdftotext -layout` for prose and word counts. **Every
number, every symbol and every table cell printed in the chapter was re-read
from the rendered page as an image**, per the trap chapter 13's session
recorded. That precaution mattered three times here:

- Paper 30's math font drops Greek letters silently, exactly as paper 26's did.
  The concept-supervision weight is `λ` on the page and extracts as nothing at
  all, so the sentence defining joint training reads `argmin [ Lc(g(x), c) +
  Ly(f (g(x)), y)]` with the weight simply gone, and the dataset families
  `TabularToy(δ)`, `dSprites(γ)` and `3dshapes(γ)` extract as `TabularToy()`,
  `dSprites()` and `3dshapes()`. Pages 4, 12 and 13 were re-read as images.
- Paper 30's tables 1, 2 and 3 extract with their rows and columns interleaved:
  Table 2's eight dataset labels and its twenty-four values come out in
  different orders and two rows arrive with no values beside them. Every cell
  quoted below was read from the render of pages 11, 13 and 15.
- Paper 31's tables 1 and 3 lose their tick and cross glyphs entirely, so the
  extraction of Table 1 shows ten model names and six column headings with no
  content between them. Page 5 was re-read as an image and the ten rows counted
  there.

Renders used `pdftoppm -png -r 150` (paper 30 pages 4, 12, 13; paper 32 page 7)
and `-r 130` / `-r 140` for the rest.

## Verified absences

- **`faithful` occurs zero times in the body of all three corpus papers.**
  `grep -ic faithful` returns 0 for papers 30 and 32 and 1 for paper 31, and the
  single hit in paper 31 is line 547 of the extraction, inside a bibliography
  entry: Stefano Teso, *Toward faithful explanatory active learning*. So no
  occurrence in any body text.

  This is the second chapter running to find the word absent from all of its
  papers. Chapter 14's was tier C of the reading ladder; this is tier D. Two
  whole tiers, six papers, seven groups of authors, and none of them reaches for
  the word.
- Papers 30 and 32 both measure something and neither calls it faithfulness.
  Paper 30's word for what leakage destroys is `interpretability`; paper 32's
  two words are `interpretability` and `steerability`.

## Paper 30 - every number the chapter prints

All from the rendered pages, not the extraction.

### Table 1, page 11: two models with the same scores and different leakage

The chapter prints the first pair only. Columns are concept accuracy, concept
F1, concept AUC, task accuracy, task F1, task AUC, and the intervention score
`Sint`, which the caption marks with a downward arrow, meaning lower is better.

| Dataset | Model | c_acc | c_F1 | c_AUC | y_acc | y_F1 | y_AUC | Sint |
|---|---|---|---|---|---|---|---|---|
| TabularToy(0.25) | Soft CBM λ = 5 | 0.993 | 0.992 | 0.992 | 0.990 | 0.990 | 0.990 | 0.000 |
| TabularToy(0.25) | Logit CBM λ = 5 | 0.995 | 0.995 | 0.995 | 0.991 | 0.991 | 0.991 | 0.301 |
| dSprites(0) | Logit CBM λ = 5 | 0.993 | 0.993 | 0.993 | 0.965 | 0.976 | 0.698 | 0.000 |
| dSprites(0) | Logit CBM λ = 0.5 | 0.992 | 0.992 | 0.992 | 0.965 | 0.975 | 0.689 | 0.139 |
| 3dshapes(0) | Soft CBM λ = 0.1 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 0.201 | 0.000 |
| 3dshapes(0) | Soft CBM λ = 0.01 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 0.207 | 0.674 |

The chapter uses the TabularToy pair: **six evaluation scores that agree to
within 0.005, and an intervention score of 0.000 against 0.301.** The
3dshapes pair is stronger still on the intervention score, 0.000 against 0.674
with all six scores at 1.000, but its task AUC of 0.201 sits beside a task
accuracy of 1.000, which the paper never explains, so the chapter does not
build on that row. **Recorded here so a later session does not re-derive it.**

### Table 2, page 13: the validation, printed in the chapter as table 15.1

Pearson `r` and its `p`-value for each of CTL, ICL and OIS against `Sint`.

| Dataset | CTL r | CTL p | ICL r | ICL p | OIS r | OIS p |
|---|---|---|---|---|---|---|
| TT(0.25) | 0.75 | 3.4e-3 | 0.69 | 1.4e-2 | 0.49 | 1.2e-1 |
| dS(0) | 0.83 | 1.1e-3 | 0.68 | 1.5e-2 | 0.70 | 1.1e-2 |
| 3ds(0) | 0.84 | 4.2e-5 | 0.86 | 2.4e-5 | 0.82 | 2.0e-4 |
| TT(0.75) | 0.54 | 4.9e-2 | 0.51 | 1.1e-1 | 0.27 | 4.1e-1 |
| dS(4) | 0.67 | 1.9e-2 | 0.48 | 1.2e-1 | 0.55 | 7.4e-2 |
| 3ds(5) | 0.79 | 3.9e-4 | 0.69 | 3.5e-2 | 0.70 | 6.5e-3 |
| CUB | 0.72 | 9.0e-3 | 0.67 | 2.1e-2 | 0.44 | 1.1e-1 |
| HAM10K | 0.49 | 1.8e-2 | 0.41 | 5.4e-2 | -0.06 | 7.7e-1 |

Boldface in the source marks the largest `r` in each row: CTL in seven rows,
ICL in the 3ds(0) row.

How the correlations were produced, from page 12: each score was evaluated 5
times per model, 10,000 Monte-Carlo samples were drawn from the resulting
distributions assuming normality, a Pearson `r` was computed per sample against
`Sint`, and the samples were pooled with Rubin's rule.

### The book's own arithmetic on Table 2 (defect 1)

Page 12 states: \enquote{The proposed CTL and ICL scores strongly correlate with
intervention performance, they systematically outperform OIS across all
datasets}.

Checked cell by cell against the table above.

- **CTL beats OIS on all eight**: 0.75 > 0.49, 0.83 > 0.70, 0.84 > 0.82,
  0.54 > 0.27, 0.67 > 0.55, 0.79 > 0.70, 0.72 > 0.44, 0.49 > -0.06. The claim
  holds for CTL without exception.
- **ICL loses to OIS on three of eight**: dS(0) 0.68 against 0.70, dS(4) 0.48
  against 0.55, 3ds(5) 0.69 against 0.70. It loses on the `p`-values in the
  same three rows too, 1.5e-2 against 1.1e-2, 1.2e-1 against 7.4e-2, and
  3.5e-2 against 6.5e-3, so the claim fails on either reading of
  \enquote{outperform}.

So the sentence is true of CTL and false of ICL, and the paper's own following
sentences already say the weaker thing correctly: \enquote{CTL generally appears
as the prominent form of leakage over ICL. Its correlation with intervention
performance is typically stronger than ICL, and is, moreover, significant in all
datasets.} That last clause checks out: CTL's eight `p`-values are 3.4e-3,
1.1e-3, 4.2e-5, 4.9e-2, 1.9e-2, 3.9e-4, 9.0e-3 and 1.8e-2, all below 0.05,
with TT(0.75) the closest call at 4.9e-2.

The chapter names the overstatement, keeps CTL's version of the claim, and
does not use ICL as evidence that the framework beats OIS. Nothing else in the
chapter's argument depends on it.

### Table 3, page 15: incomplete concept sets

Baseline task accuracies of a final head trained on the ground-truth concepts,
with 95% confidence intervals over 5-fold training.

| Dataset | complete | incomplete | well-specified | misspecified |
|---|---|---|---|---|
| TabularToy(0.25) | 1.000 ± 0.000 | 0.786 ± 0.000 | 1.000 ± 0.000 | 0.687 ± 0.000 |
| dSprites(0) | 1.000 ± 0.000 | 0.749 ± 0.004 | 1.000 ± 0.000 | 0.807 ± 0.000 |
| 3dshapes(0) | 1.000 ± 0.000 | 0.655 ± 0.002 | 1.000 ± 0.000 | 0.859 ± 0.008 |
| CUB | 1.000 ± 0.000 | 0.836 ± 0.012 | 1.000 ± 0.000 | not run |
| HAM10K | 0.999 ± 0.001 | 0.840 ± 0.009 | 0.999 ± 0.001 | not run |

The source prints an en-dash in the two `misspecified` cells for CUB and
HAM10K, and never says what it means. The chapter prints only the CUB pair,
1.000 against 0.836, and writes it in prose rather than as a table, so the
book's own rule about a blank cell having to say why in words does not arise.

### Counts and statements

- **14/15 model classes** trained on incomplete concept sets showed more
  leakage under the Leakage Criterion (page 15).
- **7/9 model classes** with a misspecified linear head showed more leakage
  (page 16).
- Interconcept correlations of magnitude comparable to concepts-task leakage
  were seen on **4 out of 8 datasets** (page 13).
- CUB: **11,788 images, 112 binary attributes, 200 species** (page 25).
- HAM10K: **6,498 images, 18 morphological concepts**, benign against malignant
  (page 25).
- The OIS trains **k(k-1)** auxiliary networks, typically 2-layer perceptrons
  (page 7).
- Mutual information and entropy are estimated with the
  **Kraskov-Stoegbauer-Grassberger estimator**, based on k-nearest-neighbour
  statistics (page 10). The extraction mangles the second author's name to
  `St?ogbauer`; the rendered page reads `Stögbauer`.
- CEMs trained on CUB with **up to 90% of the annotated concepts removed** keep
  essentially the same task accuracy as models trained on all of them (page 18,
  attributed there to Espinosa Zarlenga et al. 2022, appendix 8).
- Intervention performance is a measure of leakage \enquote{with perfect
  specificity ... but with poor sensitivity} (page 9), and in CEMs it is
  \enquote{not a measure of leakage} at all, with more-leaking models sometimes
  intervening better (page 8, pointing at its appendix G).

### Statements the chapter makes from the body text, with their anchors

These carry no decimal, so the Numbers check never asked for them; the cold
audit did, and it was right to. Each was read from the page and each is
load-bearing somewhere in the chapter.

- **The activation-distribution reading, page 5-6, figure 2 and the paragraphs
  around it.** Three models on the two-concept OR task: a hard CBM and two soft
  CBMs at intermediate (λ = 1) and low (λ = 0.01) supervision. \enquote{Neglecting
  the peak close to 0.5 ... the concept distribution in the hard CBM is very
  close to the binary ground-truth distribution for concept 1. In the soft CBM
  with λ = 1 additional structure is learnt based on the value of the other
  concept and of the class label, while for λ = 0.01 the concept itself is a very
  strong predictor of the value of both the class label and the other concept. In
  particular, the distribution is more similar to the ground-truth binary task
  distribution than to the concept distribution.} Section 15.2 paraphrases the
  last sentence and does not print the two λ values.
- **The OIS construction, page 7.** k(k-1) auxiliary networks, typically 2-layer
  perceptrons; the impurity matrix has entries `Pi_ij = AUC(psi_ij(chat_i), c_j)`;
  the score is `(2/k) * || Pi(chat,c) - Pi(c,c) ||_F`, the Frobenius norm of the
  difference, normalised so `0 <= OIS <= 1`.
- **The two OIS defects, page 7-8, stated as a numbered list.** (1) \enquote{its
  value is typically non-vanishing and relatively high for hard CBMs, indicating
  bias and a lack of sensitivity}; (2) \enquote{due to the intrinsic stochasticity
  in its definition which involves training neural networks, it is extremely
  variable when repeatedly evaluated for a given model at test time. The
  resulting broad confidence intervals typically prevent drawing any
  statistically significant conclusion when comparing models with different
  amounts of leakage}.
- **NIS, page 8.** The Niche Impurity Score captures information about concept
  `j` stored jointly in a subset of learnt representations not containing `j`,
  i.e. higher-order rather than pairwise. \enquote{the NIS is generally
  non-vanishing and very high for hard CBMs, and moreover it appears to be
  anticorrelated with intervention performance and leakage, casting doubt on its
  suitability as a measure of leakage.}
- **The hard-CBM result, page 12, which is the chapter's second validation
  argument.** \enquote{Figure 5 shows the leakage scores for hard models trained
  on a number of datasets in both low and high regimes of ground-truth
  interconcept MI ... In all cases, the CTL and ICL scores do not deviate
  significantly from zero, regardless of the interconcept MI. In contrast, the
  OIS is non-vanishing in all cases ... the estimated OIS for hard CBMs are
  comparable to those of the models shown in Figure 4, which exhibit a
  significant amount of leakage. Thus, in these cases OIS does not distinguish
  interpretable from uninterpretable concept-based models.} Figure 5's own
  legend lists the eight datasets, which is where the count of eight comes from.
- **The λ ceiling, page 14.** \enquote{At higher values (here, λ >= 10), models
  focus excessively on concept learning, and the task objective may be poorly
  learnt.} Section 15.5 prints `10` and nothing else from this sentence.
- **The over-expressive-encoding statements, page 14.** \enquote{raising λ is
  less effective at decreasing leakage when concepts representations are more
  expressive, as in the logit models, and furthermore the minimal attainable
  leakage is significantly higher for such models over soft CBMs} and
  \enquote{models with low λ generally have a comparable level of high leakage
  regardless of the concept encoding}. **Note what is not there**: the paper
  never states that logit models leak more than soft ones at a matched λ. A
  first draft of section 15.5 asserted that; it was cut and replaced by the
  Table 1 pair, which is one matched-λ instance on one dataset.
- **The CEM architecture, page 5.** A pair of vectors `(chat_i^+, chat_i^-)` in
  `R^{2d}` per input and concept; the pair predicts the activation `chat_i` as a
  soft probability; the weighted vector is
  `chat_i^w = chat_i * chat_i^+ + (1 - chat_i) * chat_i^-`, concatenated before
  the final head. Interventions work by modifying `chat_i` and thereby selecting
  one of the two vectors. Trained end to end, with each activation set to its
  ground-truth value with probability `p_int` in (0,1). \enquote{While Espinosa
  Zarlenga et al. (2022) present CEMs as interpretable models that resolve the
  accuracy-interpretability trade-off, we argue that they are still affected by
  this trade-off: indeed, they favour accuracy over interpretability.}
- **CEM's task accuracy, page 16.** \enquote{CEMs ... are widely recognized for
  achieving higher task accuracy than CBMs, particularly when the concept set is
  incomplete, and can often approach the performance of end-to-end models without
  concept supervision.}
- **Alignment leakage, page 22.** \enquote{While in models trained on dSprites(0),
  3dshapes(0) and HAM10K it does not appear, we find significantly non-zero
  scores for models trained on TabularToy(0.25) and CUB (Figure 14). Alignment
  leakage is stronger in models at high values of λ and p_int.} **Four datasets
  are named and the split is three-absent against two-present, not two against
  two**: dSprites(0), 3dshapes(0) and HAM10K are the absences and TabularToy(0.25)
  and CUB the presences, five datasets in all. A first draft of section 15.5 said
  \enquote{four datasets, absent in two and clearly present in two}; that is
  wrong on both counts and is corrected to follow this sentence.
- **Paper 32's two steering variants, page 7.** Unit Vector: the selected neuron
  is set to `alpha = 50` and every other neuron to 0. White Image: the selected
  neuron is set to the same `alpha = 50` while the others keep the values the
  model predicts for an empty white image. Both appear as separate columns in
  tables 1 and 2, which is where the chapter's \enquote{four metrics} come from:
  CLIP-Dissect and monosemanticity on the interpretability side, Unit-Vec and
  White Image on the steerability side.

### The scores themselves

For concept `k`, with `H` the entropy and `I` the mutual information, all
estimated on the test set:

```
CTL_k = max{ 0, I(chat_k, y)/H(y) - I(c_k, y)/H(y) }            (paper eq. 6)
ICL_kl = max{ 0, I(chat_k, chat_l)/sqrt(H(chat_k) H(chat_l))
                 - I(c_k, c_l)/sqrt(H(c_k) H(c_l)) }             (paper eq. 8)
```

Both are averaged over concepts (eq. 7 and 9) and both lie in [0, 1] by the
normalisation. `ICL_kk = 0` because `I(z,z) = H(z)`. The Leakage Criterion,
page 10: model A has more leakage than B if both scores are higher in A with
high statistical confidence, or if one is higher and the other is statistically
compatible between the two.

`Sint`, paper equation 5, page 9. **Read this one off the rendered page and not
off the extraction, because the two terms differ only by a star and the
extraction drops it**, so equation 5 comes out as `yacc(k) - yacc(k)`. On the
page it is

```
Sint = y_acc^(k) - y*_acc^(k)
```

where the **starred** term is the model under evaluation, \enquote{the task
accuracy after all the k concepts have been intervened on}, and the
**unstarred** term is \enquote{the reference accuracy of the final head when
separately trained on the ground-truth concepts ... the maximal task accuracy
attainable by the final head}. So it is **reference minus intervened**, not the
other way round: the paper says it \enquote{quantifies the further decrease in
task accuracy caused by leakage accounting for final head misspecification},
Table 1's header marks it with a downward arrow, and the leaking model of that
table scores 0.301 rather than -0.301. It is 0 for a successfully trained hard
model by construction and independent of the intervention policy.

**A first draft of section 15.3 had the subtraction the other way round**, which
would have made every printed value negative, and the cold audit caught it. The
paper's own choice of which term wears the star is the opposite of the usual
convention, which is how the slip happened; the chapter now defines the score in
words, naming which term is the baseline, and takes no symbol for it at all.

## The book's own worked example (section 15.2)

**These four numbers are the book's arithmetic, not the paper's.** They are
computed on the book's running function under an assumption the book states on
the page, and no number like them appears in paper 30.

The running function of chapters 01 to 08 is `f(x1,x2) = x1 + 2 x2 + x1 x2` on
two on/off features. Thresholded at 1 it becomes the OR of its two features:

| (x1,x2) | f | f >= 1 |
|---|---|---|
| (0,0) | 0 | no |
| (1,0) | 1 | yes |
| (0,1) | 2 | yes |
| (1,1) | 4 | yes |

Paper 30's own illustrative task, page 5, is that same function: \enquote{models
must learn two binary concepts c1, c2 and the binary task is to predict the
function y = c1 OR c2}. Appendix A.1, page 24, gives it as a two-concept
reduction of TabularToy with `y = 1(c1 + c2 >= 1)`.

Take the two concepts independent and each equally likely, which is the book's
own assumption and is stated as such on the page; TabularToy's concepts are
correlated through the parameter δ and are not independent.

- `P(y=1) = 3/4`, so `H(y) = -(3/4) log2(3/4) - (1/4) log2(1/4)`. With
  `log2 3 = 1.5849625`, this is `0.75 * 0.4150375 + 0.25 * 2 = 0.3112781 +
  0.5 = 0.8112781` bits. **Printed as 0.811.**
- `H(y | c1 = 1) = 0` because y is then 1 with certainty, and
  `H(y | c1 = 0) = H(c2) = 1` bit, so `H(y | c1) = 0.5`. Hence
  `I(c1, y) = 0.8112781 - 0.5 = 0.3112781` bits. **Printed as 0.311.**
- Normalised: `I(c1,y)/H(y) = 0.3112781 / 0.8112781 = 0.3836904`.
  **Printed as 0.384.**
- A learnt activation that had become a perfect predictor of the label would
  give `I(chat_1, y) = H(y)` and a normalised value of 1, so
  `CTL_1 = 1 - 0.3836904 = 0.6163096`. **Printed as 0.616.**

So on this task `CTL_1` runs over the interval from 0 to 0.616: zero for a hard
CBM whose activation reproduces the concept, and 0.616 at the other end, where
the activation has stopped being about the concept and become a copy of the
label. Under the same assumption `I(c1, c2) = 0` and `H(c1) = H(c2) = 1`, so the
ground-truth interconcept term is zero and **any** learnt dependence between the
two activations is interconcept leakage.

Reproduce with: `python -c "from math import log2; h=-0.75*log2(0.75)-0.25*log2(0.25); print(h, h-0.5, (h-0.5)/h, 1-(h-0.5)/h)"`.

## Paper 31 - every number the chapter prints

- **Five limitations** of supervised concept learning (section 4): concept
  leakage, limited semantic understanding, the strict concept independence
  assumption, fragility to perturbations, unbalanced interventions.
- **Four limitations** of unsupervised concept learning (section 5): learned
  spurious correlations, ambiguous concept interpretations, inconsistent concept
  fidelity, high performance-interpretability trade-offs.
- Table 1, page 5, read from the render: **ten architectures against six
  properties.** Counted tick by tick from the image:

  | Architecture | Leakage | Generative | Structuring | Intervention | Semantic | Robustness | ticks |
  |---|---|---|---|---|---|---|---|
  | CBMs [Koh et al. 2020] | x | x | x | x | x | x | 0 |
  | UnsupCBM [Sawada and Nakamura 2022b] | x | x | x | ✓ | x | x | 1 |
  | CEM [Zarlenga et al. 2022] | x | x | x | ✓ | x | ✓ | 2 |
  | GlanceNets [Marconato et al. 2022] | ✓ | ✓ | x | x | ✓ | x | 3 |
  | ProbCBM [Kim et al. 2023] | x | x | x | ✓ | ✓ | x | 2 |
  | CEM (Energy) [Xu et al. 2024] | x | ✓ | x | x | ✓ | x | 2 |
  | InstCEM [Espinosa Zarlenga et al. 2024] | ✓ | x | x | ✓ | ✓ | ✓ | 4 |
  | CoLiDR [Sinha et al. 2024a] | ✓ | ✓ | x | x | ✓ | x | 3 |
  | Editable CBM [Hu et al. 2024] | x | x | x | ✓ | x | x | 1 |
  | SupCBM [Sun et al. 2024] | ✓ | x | ✓ | ✓ | x | x | 3 |

  The three facts the chapter takes from it: **the best row has four of six**
  (InstCEM); **the concept-structuring column has exactly one tick in ten
  rows** (SupCBM), which is what the Table 2 caption independently says, that
  \enquote{there has not been a systematic analysis of the inter concept
  structuring vulnerability}; and **the original CBM of Koh et al. has none of
  the six.** The table's own caption states the first: \enquote{Note that none
  of the architectures satisfy all the 6 vulnerabilities}.
- Table 2, page 5: five vulnerability studies in the supervised setting, of
  which the mitigation column marks four as having an effective mitigation and
  four as not. Counted from the render: crosses against Margeloiu et al. 2021,
  Raman et al. 2024a, Shin et al. 2023 and one unlabelled row; ticks against
  Sawada and Nakamura 2022b, Sinha et al. 2023, Sheth et al. 2022, Steinmann et
  al. 2023 and Chauhan et al. 2023. **The chapter does not print these counts**,
  because the row grouping in the render is ambiguous about which study each
  mark belongs to. Recorded so a later session does not try again without
  reading the source LaTeX.

## Paper 32 - every number the chapter prints

Setup, from pages 3 to 4: a Matryoshka Batch Top-k SAE with **65,536 neurons**
and an **expansion factor of 64**, trained on **layer 22** of
**CLIP-ViT-L/14-336** using **ImageNet-1k**. Interpretability is CLIP-Dissect's
own similarity score against the **Broden** concept set of **1,197** concepts;
steerability forces one neuron to **α = 50**, runs the result through LLaVA on a
white image with the prompt \enquote{What is shown in this image? Use exactly
one word!}, and takes the cosine similarity between the steered word and the
neuron's CLIP-Dissect concept in a sentence-transformer space.

### The four quadrants, page 4

| Group | share | count |
|---|---|---|
| low interpretability, low steerability | 36.26% | 23,763 |
| high interpretability, low steerability | 19.87% | 13,022 |
| low interpretability, high steerability | 25.03% | 16,403 |
| high interpretability, high steerability | 18.84% | 12,348 |

Checked by the book: the four counts sum to 23,763 + 13,022 + 16,403 + 12,348 =
**65,536**, exactly the dictionary size, and each share reproduces its count to
two decimals (23,763 / 65,536 = 0.362594; 13,022 / 65,536 = 0.198700;
16,403 / 65,536 = 0.250290; 12,348 / 65,536 = 0.188416). The abstract's
\enquote{only about 19% of SAE neurons exhibit both high interpretability and
steerability} is the 18.84% row. **This one is clean.**

One figure in the chapter is the book's addition rather than the paper's: the
two mixed quadrants together are 19.87 + 25.03 = **44.90** percent, which the
chapter prints to say that nearly half the dictionary has exactly one of the two
properties. The paper never adds those two rows.

### Concept coverage, page 4

| Concept set | covered | of | share |
|---|---|---|---|
| Broden | 1,153 | 1,197 | 96.3% |
| VLG-CBM | 3,445 | 4,729 | 72.8% |
| DECIDER | 4,333 | 7,827 | 55.3% |
| 3k common English words | 1,857 | 3,000 | 61.9% |
| 20k common English words | 5,596 | 20,000 | 28.0% |

Also clean: 1153/1197 = 96.32%, 3445/4729 = 72.85%, 4333/7827 = 55.36%,
1857/3000 = 61.90%, 5596/20000 = 27.98%. The paper's summary that the SAE
\enquote{fails to capture 27-45% of ImageNet-related concepts from the VLG-CBM
and DECIDER sets} is the complement of the second and third rows, 27.2% and
44.7%.

### Table 1, page 7, read from the render

All four metrics in the 0-1 range, higher better. CD is the CLIP-Dissect score,
MS the monosemanticity score.

| Downstream task | Steered model | Method | CD | MS | Unit-Vec | White Image |
|---|---|---|---|---|---|---|
| image+text to text | LLaVA-1.5-7B (CLIP-ViT-L + Vicuna-7B) | SAE | 0.154 | 0.517 | 0.198 | 0.203 |
| image+text to text | LLaVA-1.5-7B | CB-SAE | 0.244 | 0.556 | 0.261 | 0.250 |
| image+text to text | LLaVA-MORE (DINOv2-L + Gemma2-9B) | SAE | 0.194 | 0.553 | 0.179 | 0.177 |
| image+text to text | LLaVA-MORE | CB-SAE | 0.291 | 0.598 | 0.192 | 0.189 |
| image to image | UnCLIP (CLIP-ViT-L + SD-2.1) | SAE | 0.058 | 0.540 | 0.642 | 0.654 |
| image to image | UnCLIP | CB-SAE | 0.092 | 0.594 | 0.659 | 0.664 |

Table 2, same page, cross-checks against it: the `All SAE neurons` row is
0.154 / 0.198 / 0.203 and the `All CB-SAE neurons` row is 0.244 / 0.261 /
0.250, both identical to the LLaVA-1.5-7B rows above. The other three rows of
Table 2 are discarded SAE neurons 0.084 / 0.144 / 0.162, retained SAE neurons
0.238 / 0.263 / 0.252, and CB neurons 0.323 / 0.231 / 0.219. **The chapter
prints the CB-neuron row against the retained-SAE row**, because the reversal
between them is the section's point: the CB neurons are the most interpretable
set and not the most steerable one.

### The book's own arithmetic on Table 1 (defect 2)

Section 6.2 reports six percentage gains of CB-SAE over the SAE baseline. Each
is a relative gain per metric. Recomputed from the table above:

| Claim in the paper | metric 1 | metric 2 | mean | sum |
|---|---|---|---|---|
| interpretability, CLIP+Vicuna, `+33.0%` | CD (0.244-0.154)/0.154 = 58.44% | MS (0.556-0.517)/0.517 = 7.54% | **32.99%** | 65.98% |
| steerability, CLIP+Vicuna, `+27.5%` | UV (0.261-0.198)/0.198 = 31.82% | WI (0.250-0.203)/0.203 = 23.15% | **27.48%** | 54.97% |
| interpretability, DINOv2+Gemma, `+29.0%` | CD (0.291-0.194)/0.194 = 50.00% | MS (0.598-0.553)/0.553 = 8.14% | **29.07%** | 58.14% |
| steerability, DINOv2+Gemma, `+14.0%` | UV (0.192-0.179)/0.179 = 7.26% | WI (0.189-0.177)/0.177 = 6.78% | 7.02% | **14.04%** |
| interpretability, UnCLIP, `+34.3%` | CD (0.092-0.058)/0.058 = 58.62% | MS (0.594-0.540)/0.540 = 10.00% | **34.31%** | 68.62% |
| steerability, UnCLIP, `+2.1%` | UV (0.659-0.642)/0.642 = 2.65% | WI (0.664-0.654)/0.654 = 1.53% | **2.09%** | 4.18% |

**Five of the six are the mean of the two metrics, and the fourth is their sum.**
The paper labels all six `avg.`. The correct figure under the rule the other
five follow is **+7.0%**, not +14.0%.

The abstract's two headline numbers are the means of the three per-model
figures:

- interpretability: (33.0 + 29.0 + 34.3) / 3 = 32.10, printed as **+32.1%**,
  and correct.
- steerability: (27.5 + 14.0 + 2.1) / 3 = 14.53, printed as **+14.5%**.
  Substituting the corrected 7.0 gives (27.5 + 7.0 + 2.1) / 3 = **12.2%**.

So the abstract's steerability headline is high by about a fifth of itself. The
chapter prints the corrected figure with the reconstruction beside it, and keeps
every ranking, because the sign of every comparison is unchanged: CB-SAE still
beats the baseline on all four metrics of all three models.

### Other statements

- The CB-SAE retains **30k** SAE neurons after pruning and uses a top-k
  activation with **k = 5**, on the VLG-CBM ImageNet concept set (page 7).
- The steerability loss ablation improves steerability by **2.9%** (page 7).
- Limitations and future work, appendix A **page 9** (this line read page 10
  until chapter 16's session re-read the render; the source-pin row above is
  right and this citation was off by one), quoted in full because the
  chapter uses both halves: \enquote{We acknowledge that the efficacy of our
  approach depends on the reliability of CLIP-Dissect in assigning accurate
  neuron-level concepts}, and the future work is extending the hybrid to other
  unsupervised discovery methods such as transcoders. It also asks whether
  feature-splitting in LLM SAEs is connected to the limited concept coverage it
  measures.

## The fourth paper, and why the chapter cites it (defect 3 and defect 4)

Papers 30 and 31 both cite Mahinpei, Clark, Lage, Doshi-Velez and Pan,
*Promises and Pitfalls of Black-Box Concept Learning Models*, arXiv:2106.13314,
and paper 31 states its finding in the wrong direction. What follows is the
whole check, including one charge against paper 30 that the audit made the
session withdraw.

- **Paper 31, section 4.1**: \enquote{They also found that hard concept
  representations (fixing the labels to binary values) cause significantly more
  leakage as compared to soft representations where the values are not binary.}
- **Paper 30, page 5**: \enquote{By definition no leakage can be present in hard
  CBMs, since concept learning is independent of task learning, and concepts are
  converted to binary values before being passed to the final head, preventing
  leaked information}, with Koh et al. 2020, Kazhdan et al. 2021 and Margeloiu
  et al. 2021 cited on page 12 for the same statement; Mahinpei et al. is cited
  alongside them on page 5 among the works that establish leakage.

Read from the source PDF, `pdftotext -layout` and confirmed against the page:

- **Mahinpei et al., appendix C**: \enquote{As more random concepts are added,
  the predictiveness of the hard concept representations increases, notably
  indicating that even hard concepts representations can encode more information
  than we intend. The predictiveness of the soft concept representations
  increases even more so - these soft representations always perform better than
  the hard representations when used in the downstream task.}
- **Mahinpei et al., section 4, paragraph \enquote{Soft Versus Hard Concept
  Representations}**: \enquote{Since all of the pathologies that we observe
  arise from the flexibility of soft concept representations, one might be
  tempted to propose always using hard concept representations (one-hot
  encodings). However, in Appendix Section C, we observe that (when the data
  manifold is low-dimensional, as in MNIST) even a modest number of semantically
  meaningless random hard concepts can capture more information about the data
  distribution than we might expect. This indicates that information leakage may
  always be an issue with black-box CLMs, regardless of the form of concept
  representation.}
- Section 3's own title is \enquote{Extraneous Information Leakage in Soft
  Concept Representations}, and section 3 shows the leakage under **sequential**
  training as well as joint: \enquote{We show that, surprisingly, the soft
  concept representations of these CLMs nonetheless encode much more information
  than the concepts themselves, even when the concepts are irrelevant for the
  downstream task.}

**Defect 3, paper 31's sentence is backwards.** Its source says soft
representations always perform better than hard ones on the downstream task,
which is the direction of more leakage in soft, and section 3's title says the
same. Nothing in the source says hard leaks more than soft. This is the only
misreport in the pair, and it is flat.

**Paper 30 is NOT guilty of the mirror-image defect, and a first draft of
section 15.4 said it was.** The draft claimed paper 30 cited Mahinpei et al. in
support of \enquote{by definition no leakage can be present in hard CBMs}, which
would have made it a wrong citation for a claim whose source concludes the
opposite. The cold audit flagged the attribution as unsure and rechecking the
rendered pages shows the draft was wrong:

- Page 5 cites Mahinpei et al. **for the existence of leakage in general**, in
  the list \enquote{information leakage occurs (Kazhdan et al., 2021; Margeloiu
  et al., 2021; Mahinpei et al., 2021; Havasi et al., 2022; Lockhart et al.,
  2022; Ragkousis and Parbhoo, 2024)}.
- The hard-CBM sentence on page 5 carries a different citation and attaches it
  to the *soft* half: \enquote{Soft CBMs with lower concept supervision are
  instead more prone to leakage ... (see Koh et al., 2020; Kazhdan et al., 2021,
  and our results in Section 7)}.
- The same claim on page 12 reads \enquote{By construction hard CBMs have
  vanishing leakage (Koh et al., 2020; Kazhdan et al., 2021; Margeloiu et al.,
  2021)}. **Mahinpei et al. is not among the three.**

So paper 30 attributes nothing to that source that the source does not say, and
the charge is withdrawn from the chapter, from the decision log and from this
note. **Recording it here rather than deleting it, because the mistake is the
exact one decision 62c names: a session that has just found one error is at its
least suspicious of the next thing that looks like the same error.** The first
finding, paper 31's inversion, was real, and it made a second, symmetrical
finding feel likely enough to write down without rechecking the citation list.

**What survives, and it is the useful half.** Paper 30's \enquote{by definition}
is honest inside its own framework, because its score measures the excess over
the ground-truth mutual information of a fixed annotated concept set and
independent training plus binarisation forces the learnt activation to reproduce
the annotation. Mahinpei et al.'s conclusion, that leakage \enquote{may always be
an issue ... regardless of the form of concept representation}, is about a
different quantity: they add random concepts and ask what the set as a whole
carries about the data distribution, which paper 30's excess neither asks nor
answers. Section 15.4 states that difference and states that the two do not
contradict each other. The reason the chapter still needs the outside key is
paper 31's inversion, which cannot be adjudicated without reading the source.

The consequence for the chapter's argument: **paper 30's second robustness
argument is a consistency check against its own definition rather than a
validation.** Its three arguments are that the scores are sensitive where
evaluation scores are not, that they vanish on hard CBMs, and that they
correlate with the intervention score. The middle one tests the scores against a
class of model the paper has already declared leak-free by definition, so a
score reporting anything but zero there would be failing the definition, not the
world. Only the third is a validation against something the paper did not
choose. **This reading does not depend on the withdrawn charge**: it follows from
the word \enquote{definition} in the paper's own sentence.

`mclm` is the third key from outside the corpus, after decision 34's seven
metric keys and decision 71's `mfooling`, and it widens the trigger a third
time: the book reads a paper outside the corpus when **a corpus paper makes a
claim about it that the chapter has to adjudicate**, and it cannot be adjudicated
from the citing paper. Appendix D still lists exactly 32 papers and does not
list it.

## Claims checked and found true, recorded so nobody re-checks

- Paper 30's `CTL` and `ICL` both lie in [0,1]: yes, by the normalisation in
  equations 6 and 8 plus the `max{0, .}`.
- Paper 32's Table 2 aggregate rows are consistent with a plain per-neuron mean
  over the retained SAE and CB sets. Solving the three weighted means for the
  number of CB neurons gives roughly 1,900 to 2,300 in the three columns, which
  is consistent to within the rounding that three-decimal inputs allow. **The
  paper never states the number of CB neurons**, and the chapter does not print
  this estimate, because the slack is wide enough that the estimate would be
  the book's guess rather than its arithmetic.

  **Pinned by chapter 16's session, 2026-09-06, and the estimate above holds.**
  Table 3 on page 11 states the CB-SAE dictionary sizes directly, in the
  denominators of its dead-neuron column: 32,167, 32,162 and 32,169 for the
  Top-k, Batch Top-k and Matryoshka variants. Page 7 gives the retained SAE
  count as 30k, so the Matryoshka variant of the main paper has 32,169 - 30,000
  = 2,169 CB neurons, inside the 1,900 to 2,300 above. It is still the book's
  arithmetic on an input the paper rounded to `30k`, so it is still not printed;
  what changes is that it is no longer an open question.
- Paper 30's page 8 says the misclassification-style claim about CEMs points at
  its appendix G, which pages 26-39 do contain; the appendix was scanned, not
  read, and the chapter takes the claim from the body sentence that states it.

## Limitation and future-work statements

The chapter 18 log closed at chapter 14 and covers Part IV only, so these are
recorded for the chapter itself rather than added to that log.

- **Paper 30, section 9**: the design guidance ends on a refusal rather than a
  fix. \enquote{If additional annotated concepts are not available, one should
  thus conclude that the task is not amenable to a concept-based approach given
  the dataset at hand.} It also records that \enquote{a general framework to
  interpret unknown concepts and safely include them in the concept refinement
  process is still missing}, and that leakage \enquote{is often unavoidable in
  soft CBMs}.
- **Paper 31, section 6**: three future directions, all about building better
  models rather than about measuring them: LLM and VLM based concept discovery,
  privacy attacks on concept-based models, and better architectures. It names no
  missing measurement.
- **Paper 32, appendix A**: the two quoted above. Its dependence on CLIP-Dissect
  is the one that matters for this chapter, because CLIP-Dissect is also what
  supplies the concept label that the steerability score is scored against, so a
  single tool sits on both sides of the comparison. **The paper does not say
  this and the chapter does**, marked as the book's reading.

## The table-of-contents re-check (decision 74)

The open item decision 56 opened requires the remaining init-written TOC lines
to be checked three ways against their papers' abstracts before drafting: does
the line promise more than the papers contain, does it promise less, and where
it names several papers, do they stand in the relation it implies. Chapter 15's
line was named there as the one that most reads like a claim inferred from a
title.

The line: \enquote{Mô hình nút thắt khái niệm và rò rỉ - concept bottleneck
models, concept leakage as the CBM analogue of unfaithfulness, CBMs meet sparse
autoencoders. Papers 30, 31, 32.}

- **More than the papers contain: yes, in the middle clause, and it is the
  book's own claim rather than an error.** No paper of the chapter says leakage
  is the bottleneck analogue of unfaithfulness, and `faithful` occurs in none of
  their bodies. The claim is defensible and the chapter makes it, in section
  15.2, marked as the book's and with the limit stated: what leakage measures is
  how much a displayed concept hides, and it is defined relative to an annotated
  concept set, so it is not definition 1.2 with the words changed.
- **Less than the papers contain: yes, and this is the failure that matters.**
  The line names leakage and says nothing about the measurement of it, which is
  paper 30's actual contribution and the thing that makes the chapter worth its
  place in Part V: an information-theoretic instrument validated against a
  criterion its authors did not choose. That is decision 59's failure mode a
  second time.
- **The relation between the three: holds, loosely.** Paper 31 does stand above
  paper 30 as the field's catalogue, and paper 32 does bring the bottleneck
  together with sparse autoencoders. What the line's phrasing hides is that
  paper 32 measures no leakage at all and never uses the word, so the arc is not
  \enquote{CBM, its leakage, then CBM plus SAE} but two papers on one paradigm
  and one on another.

The corrected line is recorded in the SPEC and in the chapter folder's scope
comment.

## Terminology settled this session

- `rò rỉ` for leakage, `rò rỉ khái niệm-nhiệm vụ` for concepts-task leakage,
  `rò rỉ liên khái niệm` for interconcept leakage, `rò rỉ căn chỉnh` for
  alignment leakage.
- `bộ mã hóa khái niệm` for the concept encoder and `đầu phân loại` for the
  final head. Paper 30 writes them `g` and `f`, both of which appendix A has
  already bound to something else, so the book names them in words and gives
  neither a symbol (decision 58).
- `mô hình cứng`, `mô hình mềm`, `mô hình logit` for hard, soft and logit CBMs.
  Each names a pair of choices, a training strategy and an encoding, not just a
  number type.
- `điểm số can thiệp` for the intervention score. No symbol, decision 58 again:
  paper 30 writes `Sint` and `S` is chapter 04's coalition.
- `khả năng điều khiển` for steerability, held apart from `mức quan trọng`,
  which chapter 09 settled for the causal-influence property. Steerability is
  measured by forcing a neuron and reading the output, so it is a way of
  measuring the property rather than a second property.
- CTL, ICL, OIS, NIS, CLIP-Dissect, CB-SAE, SAE, Broden, CUB, HAM10K,
  TabularToy, dSprites, 3dshapes, LLaVA, UnCLIP, CLIP, VLG-CBM, DECIDER,
  Matryoshka Batch Top-k, transcoder stay English, on the reasoning chapter 08
  gave for its own metric names.
- Symbols added: `c_k` and `chat_k` as extension rows under chapter 07's `c_k`,
  `\mathcal{C}` for the annotated concept set, `H` for entropy, `I(.,.)` for
  mutual information, and `\beta` for the concept-supervision weight the paper
  writes `λ`.
- `I(.,.)` is the **third** symbol collision the book settles by shape, after
  `K` (decision 61) and `\varepsilon` (decision 72). Chapter 08's `I` is a bare
  perturbation in the definition of infidelity and never takes an argument;
  mutual information always takes two. And `I` for mutual information is
  standard across all of information theory, so renaming it would send a reader
  to any text on the subject looking for a letter that is not there. Both of
  decision 72's conditions are met.
