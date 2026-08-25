# Chapter 10 - the LIME variant survey read closely

Date: 2026-08-25. Third note in this folder, one per chapter from chapter 08 on
(decision 35). Chapter 10 prints counts and one percentage taken from a survey
that ran no experiment of its own, so the job of this note is to say for every
printed number where in the PDF it comes from and, just as important, what the
survey never says.

## Source pin

| Key | arXiv | Revision read | Pages read | Submitted |
|---|---|---|---|---|
| `p22whichlime` | 2503.24365 | v1, the only revision | 1-18 in full; 19-25 are the bibliography, scanned only | 2025-03-31 |

Read from
`F:\repo\thesis-xai-faithfulness\3-tier-b-critique-core\22_xai-eval_which-lime-should-i-trust_2025.pdf`.
The PDF's own stamp reads `arXiv:2503.24365v1 [cs.LG] 31 Mar 2025`.

Verified this session on the arXiv abstract page and through the arXiv API:
the submission history lists **v1 and nothing after it**, submitted
31 Mar 2025 17:44:39 UTC.

Two metadata facts the refs.bib entry did not have, both from the arXiv record:

- The exact title is `Which LIME should I trust? Concepts, Challenges, and
  Solutions` - lowercase *should* and lowercase *trust*. The seeded refs.bib
  entry had capitalised both, and the entry was corrected this session.
- The arXiv Comments field reads, verbatim: `Accepted at the 3rd World
  Conference on eXplainable Artificial Intelligence (XAI 2025)`. There is no
  `journal-ref`, so arXiv records the acceptance but not a proceedings entry;
  the book cites the arXiv version and says so in the note field. No publisher
  DOI was checked and none is claimed.

Authors in order: Patrick Knab, Sascha Marton, Udo Schlegel, Christian Bartelt.
Affiliations from page 1: TU Clausthal, University of Mannheim,
Ludwig-Maximilians-Universitaet Muenchen, and the Munich Center for Machine
Learning.

No orientation note was used for anything here (decision 13). The corpus README
names no note for paper 22 either way.

## What kind of paper this is, and what that forbids

**The survey runs no experiment.** There is no results section, no experimental
setup, no re-implementation, no benchmark and no dataset of its own. Its three
tables are classifications of other people's published work: table 1 places each
technique against an issue and a pipeline substep, table 2 places each technique
against a modality and a domain, table 3 lists evaluation properties adopted from
a prior framework. Every claim about LIME's behaviour in it is a claim it
attributes to a cited paper.

That settles what chapter 10 may say. The chapter may report the survey's
classification and its counts. It may **not** present LIME's instability as a
result this paper measured, because this paper measured nothing. Where the
prose needs the instability claim itself, it is attributed through the survey's
own statement and its citation list, on chapter 09's precedent for Lanham,
Tutek, Parcalabescu, Shen and Chen (decision 45).

## Claims of absence, verified by full-text search

Searched the extracted text of the whole PDF, and separately of pages 1-18,
which is the body without the bibliography.

- **`faithful` and `faithfulness` occur zero times in the body.** In the whole
  PDF the string occurs exactly once, on page 24, inside the title of
  reference 90, `Sokol, K., Flach, P.: Limetree: Consistent and faithful
  multi-class explanations (2024)`. So the survey never uses the word in its own
  prose.
- **`ground truth` occurs zero times**, in the body and in the bibliography.
- None of chapter 08's metric names occurs anywhere: `comprehensiveness`,
  `Sensitivity-n`, `infidelity`, `ROAR` all return zero. `deletion` and
  `insertion` occur only in ordinary senses, never as the names of the curves.
- The words the survey uses in that place instead are `fidelity`, six times in
  the body, and `Correctness`, once, as the name of the first property of
  table 3.

This is the same class of finding as chapter 08's record that paper 20 defines
no faithfulness metric, and it is recorded for the same reason: so that no later
chapter re-reads paper 22 looking for a faithfulness result that is not in it.

## Table 1, page 10: the count the chapter argues from

Table 1 is captioned `LIME Techniques Categorization` and lists every technique
the survey covers, each with its issue letters and check marks in four pipeline
columns.

**The table has 48 rows, that is 48 techniques.** Counted twice: by hand from the
rendered page, then by extracting page 10 with `pdftotext -layout` and parsing
each row's issue letters with a script. Both give 48 and the same tallies.

Reproduce with, from any directory:

```
pdftotext -layout -f 10 -l 10 22_xai-eval_which-lime-should-i-trust_2025.pdf t1.txt
```

then count the lines matching a technique name followed by a bracketed
reference number and one or more of the letters L, F, I, S, E.

How many techniques carry each issue letter. A technique carrying two letters is
counted under both, which is why the column sums to more than 48:

| Issue | Letter | Techniques |
|---|---|---|
| Fidelity | F | 23 |
| Stability | S | 20 |
| Interpretability | I | 13 |
| Locality | L | 11 |
| Efficiency | E | 3 |
| | | **70 assignments over 48 techniques** |

How many issues each technique carries:

| Issues carried | Techniques |
|---|---|
| one | 27 |
| two | 20 |
| three | 1 |

The one three-issue technique is B-LIME, marked S, F, I. The full breakdown by
combination, which is what the script returns: F alone 8, I alone 7, S alone 5,
L alone 4, E alone 3, then S+F 10, L+F 4, S+I 3, L+I 2, S+L 1, S+F+I 1.
Those add to 48 and their letters add to 70.

One derived count the chapter prints, from that same breakdown. **Techniques
carrying F or S or both: 32 of 48, exactly two thirds.** By inclusion and
exclusion, 23 plus 20 minus the 11 that carry both, where the 11 are the 10
marked S+F plus the one marked S+F+I. By direct addition of the combinations
that contain F or S it is the same number: 8 + 4 + 10 + 1 + 5 + 3 + 1 = 32. The
16 that carry neither are the 7 marked I alone, the 4 marked L alone, the 3
marked E alone and the 2 marked L+I.

The check-mark columns of table 1 are **not** transcribed here and no count
taken from them is printed in the chapter. The check-mark glyph carries no
Unicode mapping in this PDF, so `pdftotext` drops it and leaves the cell empty,
which makes an empty cell and a check mark indistinguishable in the extracted
text; the rendered page can be read by eye but not reliably enough to print a
number from. If a later chapter wants those counts it has to read them off the
page deliberately and record how.

## The five issues, page 8 and page 9

The survey's own wording, quoted, because chapter 10 restates each in Vietnamese
and the restatement has to be checkable against this.

- **Locality Issue (L)**, p. 8: the explanations \enquote{may not be
  sufficiently specific to the instance being explained if the perturbed data
  points used to create the surrogate model do not adequately represent the
  local decision boundary}. Cites [13, 31, 36, 81], four papers.
- **Fidelity Issue (F)**, p. 8: \enquote{The surrogate model used by LIME may
  not accurately capture the behavior of the original model, leading to
  explanations that do not fully reflect the original model's decision-making
  process.} Cites [12, 23, 63, 90, 99, 104], six papers. The paragraph goes on:
  \enquote{Fidelity and locality are closely linked}, and fidelity problems
  arise \enquote{not only from locality issues [...] but also from other
  factors, such as an overly simplistic surrogate model or inadequate feature
  representations}.
- **Interpretability Issue (I)**, p. 8: the explanation representation \enquote{may
  not represent the model's decision in a well-interpretable way by users or
  need adaptions due to varying modalities}. Cites [1, 6, 17, 34, 46], five
  papers.
- **Stability Issue (S)**, p. 8: explanations \enquote{can vary significantly due
  to minor changes in the input data, perturbation process, sampling, repeated
  runs, or the underlying model, resulting in inconsistent and unreliable
  outcomes. Such behavior undermines confidence in the XAI technique or the
  model to be explained, as the explainee does not know from which part the
  instability originates in case of doubt.} Cites [12, 33, 35, 59, 86, 94, 104],
  seven papers.
- **Efficiency Issue (E)**, p. 9: \enquote{The time required to generate
  explanations can be significant due to the steps involved in perturbation
  generation, obtaining model predictions, and fitting the surrogate model.}
  Cites [44, 82, 98], three papers.

And the sentence that keeps the five from being read as independent, p. 9:
\enquote{increasing locality can negatively impact efficiency, but decreasing
efficiency can positively affect stability}, and \enquote{many studies discussed
here do not focus solely on one issue but address several simultaneously}.

**A terminological note the chapter has to carry.** The survey's Fidelity Issue
is the surrogate failing to capture the model's behaviour, which is what this
book calls do trung thuc applied to the local surrogate. It is not the
counterfactual quantity `fidelity` that chapter 07 put in appendix B's
keep-in-English block and chapter 08 read closely. Two different things under one
English word, in two papers this book cites. Chapter 10 writes the survey's
category descriptively and names the collision once in the prose rather than
adding a second appendix B row that would map `fidelity` to a Vietnamese term
while the keep-block says to leave it in English.

## The four substeps, pages 5 and 9

Figure 2 on page 5 is captioned `Steps of LIME` and its four boxes are Feature
Generation, Sample Generation, Feature Attribution, Explanation Representation.
The caption's own gloss:

1. Feature generation: \enquote{Extract features (e.g., image segmentation).}
2. Sample generation: \enquote{Create perturbed samples around the instance.}
3. Feature attribution: \enquote{Train an interpretable model (e.g., linear) to
   approximate the complex model locally.}
4. Explanation representation: \enquote{Use the model's weights to represent
   feature importance.}

**The subgroups inside each step, and their counts.** The chapter prints these
counts, and one of them was wrong in the first draft, so here is the extraction
that settles them. The subgroup headings are set as run-in italics; recover them
with a grep for the heading pattern over the body text:

```
pdftotext -f 1 -l 18 22_xai-eval_which-lime-should-i-trust_2025.pdf body.txt
grep -oE "^(Segmentation|Clustering|Feature importance|Arbitrary|Selective|Approximation|Neighborhood|Distribution|Linear regression|Replacement of surrogate|Weighting|Training of surrogate|Expanded explanation|Interactive)[a-z -]*(-based)?:" body.txt
```

That returns fifteen headings in this order, which assign to the four steps as:

| Step | Subgroups | Count |
|---|---|---|
| 1, Feature Generation | Segmentation-based, Clustering-based, Feature importance-based, Arbitrary-based | **4** |
| 2, Sample Generation | Selective-based, Approximation-based, Neighborhood-based, Distribution-based, Arbitrary-based | **5** |
| 3, Feature Attribution | Linear regression modifications, Replacement of surrogate model, Weighting modification, Training of surrogate model | **4** |
| 4, Explanation Representation | Expanded explanation representation, Interactive explanation | **2** |

Note that **Arbitrary-based occurs twice**, once under step 1 and once under
step 2, which is what makes fifteen headings across four steps. The first draft
of the chapter said step 2 had four subgroups and it has five; the audit caught
it. `Arbitrary-based` is also not a descriptive name: under step 1 it holds
Anchors' rule generation and DIME's parallel two-modality generation, so
renaming the category after either member misdescribes it, and the chapter now
says the survey leaves the category unnamed and gives both examples.

Section 4.2 on page 9 repeats the split and states what the columns of table 1
mean: the covered works \enquote{adapt at one or multiple points of this
pipeline}, and the check marks indicate \enquote{modifications in the four main
components of LIME}.

This matches chapter 03's pipeline figure, which the book drew from paper 09
directly, so chapter 10 refers back to that figure rather than drawing the
pipeline a second time.

## Methodology, pages 4 and 5

- The review follows the structured process of Webster et al. [100] with the
  documentation approach of Brocke et al. [14].
- Search keywords beyond the original LIME publication: `'LIME issues'`,
  `'LIME improvements'`, `'LIME advancements'`.
- \enquote{Our initial review covered papers published between 2016 and 2025.}
- Non-peer-reviewed arXiv articles were included \enquote{provided they offered
  novel and pertinent contributions}.
- Footnote 5, p. 4, about the original LIME paper: \enquote{As of January 21st
  2025, the publication had been cited in 21,343 papers on ArXiv.} That is
  21 343 with a thousands separator; printed in the chapter as `21\,343` under
  decision 43, which keeps the thin space and does not import the English comma.
- p. 5, on coverage: \enquote{We acknowledge the possibility of overlooking
  papers that did not align with our selection criteria, given the challenge of
  reviewing over 20,000 works.} Printed as `20\,000`.

## The discussion, page 15, and the one percentage the chapter prints

Section 5.1 is where the survey turns on its own subject matter, and it is the
half of the paper the chapter's argument rests on.

- Opening: \enquote{Despite LIME's popularity, a best-practice standard for
  research and evaluation has not been established. This lack of standardized
  procedures hinders the scientific rigor and broader application of LIME-based
  techniques.}
- **Reproduction Issues**: \enquote{We observed a great lack of code
  availability (50%, see tool in Figure 1) that creates significant
  reproducibility issues, making verifying the authors' contributions
  difficult.} **The 50 percent is the one measured-sounding figure in the
  paper**, and the paper sources it to its own companion website rather than to
  a table. Two caveats the chapter states rather than hides. It is a count over
  the techniques the survey collected, not a survey of the field. And **the body
  never says whether the 50 percent is the share lacking code or the share
  having it**: the sentence reads as a lack "at the 50% level", which is how the
  chapter takes it, but the figure it points at is a screenshot of the website
  and cannot settle it here. The chapter quotes the paper's own phrasing and
  names the reading it uses, rather than asserting the count outright. If a
  later chapter needs this number, resolve it against the live website first.
- **Evaluation Practices**: \enquote{many papers begin their motivation by
  highlighting a known issue of LIME [...] and often compare their adapted
  version solely against the standard LIME version. However, this approach
  disregards other related works, a practice that undermines the quality of the
  research.} The works that do compare against prior variants \enquote{often
  compare against S-LIME [105] or BayLIME [104], as these provide code for
  reproducibility and thus enable comparisons.}
- \enquote{Another prevalent problem is the selection of evaluation metrics that
  confirm the stated contributions. This issue is universal within the XAI
  community and needs to be addressed.}
- On user studies: \enquote{there is no standard procedure, with varying sample
  sizes and differing tasks}.
- p. 15, on the modality table: \enquote{we cannot definitively assess the
  validity of the claimed universality for each approach, as not all methods
  have an available code.}

## Table 3, page 16: the evaluation properties

Captioned `LIME XAI Evaluation Metrics`, with \enquote{We adopt the structure of
[65]}, which is Nauta et al.; the paper says on p. 17 that it adapts that
structure \enquote{and add additional metrics found during the literature
review}.

**17 properties in three areas**, counted from the table:

- Content, 8: Correctness, Completeness, Consistency, Continuity, Contrastivity,
  Covariate complexity, Efficiency, Scalability.
- Presentation, 5: Compactness, Composition, Confidence, Applicability, Modality
  Flexibility.
- User, 4: Context, Coherence, Controllability, Complexity.

The first row is the one the chapter uses. **Correctness** is described as
\enquote{Reflects how accurately the explanation represents the underlying
model's decision-making process}, which is this book's definition 1.2 of do trung
thuc under a third name, in a paper that never writes the word. Consistency and
Continuity between them are the stability property split in two: Consistency
\enquote{Evaluates how stable the explanation is across multiple similar
instances}, Continuity \enquote{Assesses the degree of similarity between
explanations for similar instances}.

The table supplies descriptions and no formulas, no thresholds and no procedure
for computing any property. Chapter 10 therefore states none on its behalf, the
same rule chapter 09 followed for paper 21's eight metrics.

## Research opportunities, pages 17 and 18

Four, in the paper's order and its own headings:

1. **Automatic LIME Selection.** Existing selection aids [38, 43, 92, 102] and
   the automated approach of [18] are \enquote{limited to the techniques within
   the original framework, overlooking subsequent improvements and adaptations}.
   The survey's answer is its own overview webpage.
2. **Evaluation of LIME Techniques.** \enquote{While a broad spectrum of suitable
   and well-established metrics already exists, their application is inconsistent
   across the community}, and \enquote{developing a tailored evaluation framework
   specifically for LIME would be beneficial in assessing whether the identified
   issues are effectively mitigated}, drawing on existing XAI evaluation
   frameworks [5, 39, 88].
3. **Foundation Model Integration.** Putting a large language model into LIME's
   feature-generation and sample-generation stages, which \enquote{could soften
   LIME's strict locality, transitioning it toward a hybrid local-global
   explanation}.
4. **Focus on Explainee.** \enquote{this point is not a call for a specific new
   research direction but a recommendation for how future research should be
   structured.}

Opportunity 2 is the one chapter 10 argues with, and the argument is the book's
own rather than the paper's: the framework it proposes would be assembled out of
the metric families chapter 08 catalogued, and chapter 09 showed that the one
family ever tested against constructed ground truth scored near chance. The
survey does not make that connection and does not cite paper 21; it could not,
since paper 21 is a year later. **Nothing in this note licenses attributing that
argument to the survey.**

## Limitation and future-work log, for chapter 18

Required of every Part IV drafting session by the SPEC's open item. Paper 22's
statements, as the paper words them:

- No best-practice standard for LIME research and evaluation exists (5.1,
  opening).
- Code availability is 50 percent among the collected techniques, which blocks
  reproduction and blocks benchmarking against prior variants (5.1,
  Reproduction Issues).
- Papers commonly compare only against vanilla LIME, disregarding related work
  (5.1, Evaluation Practices).
- Evaluation metrics are selected so as to confirm the stated contribution;
  the paper calls this \enquote{universal within the XAI community} (5.1).
- User studies follow no standard procedure (5.1).
- Claimed universality of a method cannot be checked where there is no code
  (4.3, closing paragraph, p. 15).
- Coverage is incomplete by the authors' own admission, against a pool of over
  20 000 works (2, p. 5).
- Future work: automatic selection over the full variant set; a LIME-specific
  evaluation framework; foundation models inside feature and sample generation;
  and involving the explainee (5.2).

The intersection this feeds into chapter 18 is the one paper 21's log already
points at from a different direction: both papers name the absence of a
validated evaluation instrument as the blocking limitation, paper 21 by
measuring that the instruments fail and paper 22 by recording that no standard
for using them exists.

## Numbers this chapter prints, in one list

Every decimal, percentage and count on chapter 10's pages, with where it comes
from. Nothing else numeric is printed.

| Printed | Source in the PDF |
|---|---|
| 48 techniques | table 1, p. 10, rows counted twice as described above |
| 23, 20, 13, 11, 3 by issue | table 1's Issue column, tallied by script |
| 27 / 20 / 1 by number of issues carried | same tally |
| 21 techniques carrying two or more issues | same tally, 20 plus 1 |
| 32 of 48 carrying fidelity or stability, two thirds | same tally, derived above |
| 43 of the 70 assignments | 23 plus 20, same tally |
| 10 techniques marked both stability and fidelity | same tally |
| 5 issues | section 4.1, pp. 8-9 |
| 4 substeps | figure 2 caption, p. 5, and section 4.2, p. 9 |
| 50\% code availability | section 5.1, p. 15, quoted above |
| 21\,343 citations, 21 Jan 2025 | footnote 5, p. 4 |
| 20\,000 works | section 2, p. 5 |
| 2016 to 2025 | section 2, p. 4 |
| 17 properties, 8 / 5 / 4 | table 3, p. 16, counted |
| 4 / 5 / 4 / 2 subgroups per step | the heading extraction above |
| \enquote{chín năm kể từ bài báo gốc} | derived, not quoted: the original LIME paper is arXiv:1602.04938v1, submitted 16 Feb 2016, and this survey is 31 Mar 2025. Nine years and six weeks. Both dates verified on their arXiv abstract pages this session. |
| 6 papers cited for fidelity, 7 for stability, 5 for interpretability, 4 for locality, 3 for efficiency | the bracket lists in section 4.1, counted |

There is no decimal fraction anywhere in chapter 10; every number above is an
integer or a whole percentage. The chapter prints no AUROC, no score and no
measurement, because the survey reports none.
