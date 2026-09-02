# Chapter 11 - the metagame paper read closely

Date: 2026-09-02. Fifth note in this folder, one per chapter from chapter 08 on
(decision 35). Chapter 11 reads one paper in full, prints an analytic table of
fractions and a small number of decimals from two results tables, and rests its
whole argument on what the paper says it did **not** measure. This note records
every printed figure with its page anchor, and records the paper's own
limitation statement verbatim because chapter 18 inherits it.

The single most important entry in this note is the first one under
"The TOC line was wrong": the chapter the SPEC promised and the paper on disk
are about different things.

## Source pin

| Key | arXiv | Revision read | Pages read | Submitted |
|---|---|---|---|---|
| `p23metagame` | 2605.06295 | v1, the only revision | 1-9 body in full; 15-32 appendices A-E in full; 10-14 are the bibliography and the appendix contents page, scanned only | 2026-05-07 13:59:26 UTC |

Read from
`F:\repo\thesis-xai-faithfulness\3-tier-b-critique-core\23_xai-eval_attributions-all-the-way-down-metagame_2026.pdf`.
The PDF's own stamp reads `arXiv:2605.06295v1 [cs.LG] 7 May 2026`. Total 32
pages: body 1-9, acknowledgements and references 10-13, appendix contents page
14, appendix A 15-16, appendix B 17-22, appendix C 23-25, appendix D 26-28,
appendix E 29-32.

Verified this session on the raw arXiv abstract page and through the arXiv API,
not through a summarising fetch:

- **v1 is the only revision**, published and updated timestamps identical
  (`2026-05-07T13:59:26Z`), submission history lists no `[v2]`.
- Categories: primary `cs.LG`, cross-listed `cs.AI` and `stat.ML`.
- **`journal-ref`: absent. `Comments`: absent. Publisher DOI: absent** (arXiv's
  own DataCite DOI `10.48550/arXiv.2605.06295` exists, which is not a venue
  DOI). Page 1's footer reads only `Preprint.`
- **Nothing anywhere says this paper has been accepted at a venue.** Papers 22
  and 25 both recorded acceptance in the arXiv Comments field; this one records
  nothing. The prose must not call it a conference paper.

Authors in order: Hubert Baniecki, Przemyslaw Biecek, Fabian Fumagalli.
Affiliations from page 1: University of Warsaw and the Centre for Credible AI
at Warsaw University of Technology (Baniecki, Biecek); Bielefeld University and
LMU Munich, MCML (Fumagalli).

**The seeded refs.bib entry needed no correction.** Author list, title with its
exact capitalisation and question mark, year, eprint and eprinttype all match
the live arXiv record. This is the second time that has happened, after chapter
12's two entries; only the `note` field changed this session. Code repository
printed on page 1: `https://github.com/credibleai/metagame`. The book does not
fetch or run it, so nothing here rests on it.

No orientation note was used (decision 13). The corpus README names none for
paper 23.

## The TOC line was wrong, and not by a little

The SPEC's initialized TOC line for chapter 11 read:

> **Attribution suốt đường xuống** - the research metagame: benchmark churn,
> metric proliferation, the incentives behind yet another unvalidated metric.
> Paper 23.

**Paper 23 contains none of that.** It is a methods paper. It introduces a
construction it calls the METAGAME, a cooperative game whose value function is a
first-order attribution method, and computes Shapley values on that game to
obtain what it calls *meta-attributions*. It proves two theorems, runs three
experiments, and says nothing at all about benchmark churn, metric
proliferation, or research incentives.

Verified by full-text search of the extracted PDF text:

| String | Occurrences in the whole PDF |
|---|---|
| `incentive` | 0 |
| `churn` | 0 |
| `proliferation` | 0 |
| `metric proliferation` | 0 |
| `publication` | 0 |
| `reviewer`, `peer review` | 0 |

The word `metagame` in the title is the paper's name for a game-theoretic
object, not a word about the sociology of the field. The paper says so itself,
in Related Work on p. 8: "While METAGAME shares a naming affinity with the
meta-evaluation problem (Hedstrom et al., 2023), which quantifies attribution
quality, our framework focuses on second-order interaction effects."

That sentence is the anchor for the correction. The init TOC line read the
title as a claim about research incentives and about meta-evaluation; the
authors explicitly separate their object from both.

This is the fifth init-written TOC line to over-promise (decisions 24, 28, 47
and 51's rejected item are the earlier ones), and it is the first where the
promised subject is not in the paper *at all* rather than merely weaker than
promised. Decision 47's rule, that a TOC line naming a *result* is the one to
re-check first, does not cover this case: this line names a *topic*, and it was
inferred from a title. New rule proposed to the SPEC: re-check a TOC line
against the paper's abstract before drafting whenever the line's subject was
plausibly readable off the title alone.

## What the paper actually is

**Object.** Second-order interaction effects between features or tokens, for an
arbitrary first-order attribution method. Not faithfulness. Stated on the
object-gap discipline decision 54 set, this is the fourth instance in Part IV:
the paper's object is one level above the chapter 08 metric families rather
than beside them.

**The construction** (p. 4-5). For a first-order attribution method
phi_i(f, x), define the meta-attribution phi_{j->i}(f, x) as the influence of
feature j on the attribution of feature i, by fixing x_i, treating phi_i as the
value function of a cooperative game over the remaining d-1 features, and
taking the Shapley value of j in that game. Definition 2, p. 5:

    phi_{j->i}(f,x) := sum over S subset of [d]\{i,j} of
        1 / ((d-1) * binom(d-2, |S|)) *
        [ phi_i(S union {i,j}; f,x) - phi_i(S union {i}; f,x) ]

The pure individual effect is the boundary value
phi_{i->i}(f,x) := phi_i({i}; f, x), that is, the attribution of i when only i
is present.

**Definition 1, hierarchical efficiency** (p. 4): an interaction
phi_{j->i} is hierarchically efficient with respect to phi_i(f,x) if
phi_i(f,x) = sum over j in [d] of phi_{j->i}(f,x). Read plainly: the first-order
attribution is recovered exactly as its pure individual effect plus its
interactions with the other features. This is a completeness axiom applied one
level up; the book has met the same shape as tinh day du in chapter 05 and as
do chinh xac cuc bo in chapter 04.

**Theorem 1** (p. 4, proof in B.2, pp. 20-22): existing interaction indices are
already hierarchically efficient. Shapley interactions decompose the Shapley
value, SOP decomposes integrated gradients, and serial methods decompose their
own first-order attributions with phi_{j->i} := psi_{i,j}.

**Theorem 2** (p. 5, proof in B.4, p. 22): the Meta-Shapley value and Meta-IG
are directional variants of STII and of SOP:
psi^STII_{i,j} = phi^{Meta-SV}_{j->i} + phi^{Meta-SV}_{i->j}, and
psi^SOP_{i,j} = phi^{Meta-IG}_{j->i} + phi^{Meta-IG}_{i->j}.

STII is the Shapley-Taylor interaction index (Sundararajan et al., 2020), SOP
is Sum of Power (Lundstrom and Razaviyayn, 2023). Both expansions are printed in
the paper (p. 3), so both may go to appendix C under decision 46.

**Serial attribution**, the thing the title is about (p. 3): "Serial
attributions construct interactions by recursively applying a first-order
method to its own output: psi_{i,j}(f,x) := phi_j(phi_i(f, . ), x). Notable
examples include integrated Hessians psi^IH (IH, Janizek et al., 2021) and the
serial Shapley value psi^SV (Lundstrom and Razaviyayn, 2023). However, serial
methods inherently fail to cleanly separate pure individual effects from
interaction effects." The paper attributes the *explaining explanations* idea to
Janizek et al. (2021), cited on p. 1.

**synergy and antisynergy** (p. 1 and D.1 p. 27). The paper names both on p. 1
("omitting higher-order dynamics encoded by the model, such as synergies and
antisynergies") and defines only the second, in D.1: the Meta-AttnLRP score
"down-ranks pairs whose individual attributions cancel additively -
antisynergies - because this is precisely the regime in which a first-order
method is blind". **There is no definition of synergy anywhere in the paper.**
A first draft of section 11.1 supplied one ("stronger together than the sum of
the parts"), which is the standard reading but is not in the source; the
sentence now names both and glosses only the one the paper glosses.

## The analytic example, and the fractions chapter 11 prints

This is the one place in the book so far where a ground truth for an attribution
exists, and it exists because the function was chosen so that it would.

**Setup** (Table 1 caption p. 4; derivations in B.1, pp. 17-19):
f(x) = x_1 + I where I := x_1 * x_2^2, with a standard zero baseline
b = (0,0). Table 1's caption states the criterion the paper judges against,
verbatim: "Unlike serial approaches, meta-attributions perfectly isolate the
individual effect x1 (phi_{i->i}) and the interaction I (phi_{j->i})."
The example paragraph on p. 3 states it as a faithfulness criterion, verbatim:
"As illustrated in Table 1 for f(x) = x1 + x1x2^2, a faithful method must
isolate the individual effect of x1 from the interaction x1x2^2. However, both,
the serial Shapley value and integrated Hessians fail to do this, leaking
interaction terms into the individual components."
And p. 3 again, under the heading *Limited flexibility and separation leakage*:
"Faithfully separating pure individual effects from joint interactions remains a
non-trivial challenge. Serial methods inherently fail to do this, leaking
interaction terms into the individual diagonal components."

**The correct answer, and why it is known.** Under the paper's own definition of
the pure individual effect as phi_i({i}; f, x) with a zero baseline,
phi_{1->1} = f(x_1, 0) - f(0,0) = x_1 and phi_{2->2} = f(0, x_2) - f(0,0) = 0.
So the answer is forced by the choice of function and of baseline, not observed
inside a model. Same method as chapter 09's constructed ground truth, one object
over, and with the same limit: it holds for a two-variable polynomial with a
stated masking convention, not for the transformer of section 4.1.

**Table 1 of the paper, transcribed** (p. 4). Columns as the paper groups them:
Individual (phi_{1->1}, phi_{2->2}), Interaction (phi_{2->1}, phi_{1->2}),
First-order (phi_1, phi_2), Sum. Every entry is a fraction of I or of x_1, not
a decimal.

| Type | Method | phi_{1->1} | phi_{2->2} | phi_{2->1} | phi_{1->2} | phi_1 | phi_2 | Sum |
|---|---|---|---|---|---|---|---|---|
| Serial | SV (psi^SV) | x1 + 1/4 I | 1/4 I | 1/4 I | 1/4 I | x1 + 1/2 I | 1/2 I | x1 + I |
| Serial | IH (psi^IH) | x1 + 1/9 I | 4/9 I | 2/9 I | 2/9 I | x1 + 1/3 I | 2/3 I | x1 + I |
| Set-based | Moebius (m) | x1 | 0 | I (undirected, one cell) | | x1 | 0 | x1 |
| Set-based | Shapley (psi^STII) | x1 | 0 | I (undirected, one cell) | | x1 + 1/2 I | 1/2 I | x1 + I |
| Set-based | SOP (psi^SOP) | x1 | 0 | I (undirected, one cell) | | x1 + 1/3 I | 2/3 I | x1 + I |
| Directional | Meta-GxI | x1 | 0 | I | 2I | x1 + I | 2I | x1 + 3I |
| Directional | Meta-IG | x1 | 0 | 1/3 I | 2/3 I | x1 + 1/3 I | 2/3 I | x1 + I |
| Directional | Meta-SV | x1 | 0 | 1/2 I | 1/2 I | x1 + 1/2 I | 1/2 I | x1 + I |

The set-based rows put a single undirected value I in the interaction group,
because a set-based index scores the unordered pair {1,2} and has no separate
entry for 2->1 and 1->2. That is the collapse of direction the paper objects to,
and it is visible in the table as a merged cell rather than as a number.

Two entries in that table are worth naming in the prose because they are the
ones the argument turns on:

- **The serial Shapley value gives phi_{1->1} = x1 + 1/4 I.** The individual
  effect of x_1 should be x_1. A quarter of the interaction has been added to it.
- **Integrated Hessians give phi_{1->1} = x1 + 1/9 I and phi_{2->2} = 4/9 I.**
  The individual effect of x_2 should be 0. Four ninths of the interaction has
  been added to it.

Derivations checked against appendix B.1, pp. 17-19, which supplies the
first-order attributions the table is built on:
phi^{GxI}_1 = x1 + I, phi^{GxI}_2 = 2I;
phi^{IG}_1 = x1 + 1/3 I, phi^{IG}_2 = 2/3 I;
phi^{SV}_1 = x1 + 1/2 I, phi^{SV}_2 = 1/2 I;
Moebius coefficients m_{1} = x1, m_{2} = 0, m_{1,2} = I.
The row sums check out in every case: for IH, 1/9 + 2/9 = 1/3 and
2/9 + 4/9 = 2/3, matching phi^{IG}_1 and phi^{IG}_2.

**One error in the source, recorded so nobody re-derives it.** In B.1.1, p. 17,
the two lines for h_2 are both labelled psi^SV_{2,1}; the second is
psi^SV_{2,2}. Both equal 1/4 I, so no value in Table 1 is affected. Chapter 11
prints neither label, so nothing shipped needs the correction; it is here so a
later reader of B.1 does not think they have found a real discrepancy.

**Meta-GxI's sum is x1 + 3I, not x1 + I.** Gradient-times-input is not
efficient to begin with (phi^{GxI}_1 + phi^{GxI}_2 = x1 + 3I), so hierarchical
efficiency preserves a total that was already wrong. Hierarchical efficiency
constrains the decomposition of a first-order attribution; it says nothing about
whether that first-order attribution was right. Chapter 11 states this and it is
**the book's own reading**, not a claim the paper makes: the paper reports the
sum column without comment.

## What the paper measures, and against what

Three applications, section 4, pp. 6-8. None of the three is a faithfulness
measurement, and the grounds are worth recording separately because the chapter
argues from them.

**4.1, token interactions in language models** (p. 6-7; setup in D.1, pp. 26-27).
Eight Gemma 3 models: 1B, 4B, 12B and 27B parameters, in pre-trained and
instruction-tuned variants. Twenty-one prompts, listed in full on p. 26,
generating answers of up to 100 tokens. The metric is **Recall@K**, defined on
pp. 26-27: "Recall at K% measures how human-annotated token pairs rank against
the model's most important interactions." The annotations are the paper's own:
"We here denote the naturally occurring token interactions in bold" (p. 26),
each prompt containing 2-4 interacting token pairs (p. 7). K ranges over
[0%, 15%] of all d(d-1) directed off-diagonal entries. Figures 3 and 10 plot
Meta-AttnLRP above AttnLRP across all four model sizes.

  So the ground for 4.1 is a human judgement about which token pairs ought to
  interact. In chapter 01's split that is a **plausibility** standard, not a
  faithfulness standard. The paper does not claim otherwise; it never uses the
  word faithfulness for this experiment.

**4.2, vision-language encoders** (p. 7; setup in D.2, p. 27). The paper says
"five openly available vision-language encoders" and its list is: CLIP
ViT-B/16; SigLIP-2 ViT-L/16 and SigLIP-2 ViT-B/32; and two MetaCLIP-2
checkpoints, `metaclip-2-worldwide-huge-quickgelu` for the numerical
experiments and `metaclip-2-worldwide-huge-378` for the higher-resolution
illustrations. **That is one CLIP, two SigLIP-2 and two MetaCLIP-2**, and only
four of the five contribute numbers; a draft that wrote "CLIP, two SigLIP-2 and
MetaCLIP-2" named four while claiming five, and was corrected. The metric
is the **pointing interaction recognition metric** of Baniecki et al. (2025b),
run on the ImageNet-1k validation set: ten class labels (fish, koala, plane,
balloon, church, jeep, laptop, lemon, pizza, acorn), 50 images each, combined
into ten four-label pointing games, four scenarios per game by adding one token
at a time, 40 scenarios of 50 images.

  So the ground for 4.2 is the dataset's own labels for which objects are in the
  picture. It measures whether the interaction lands on the right object, not
  whether the model used it.

Table 2, p. 8, decimals as printed (all carry an interval of the form
`± .01` or `± .00`, and the paper prints them without a leading zero):

| Model | Method | 1 object | 2 | 3 | 4 |
|---|---|---|---|---|---|
| CLIP ViT-B/16 | Attention | .77 | .46 | .32 | .25 |
| CLIP ViT-B/16 | + METAGAME | .84 | .87 | .89 | .90 |
| CLIP ViT-B/16 | Grad-ECLIP | .71 | .43 | .31 | .25 |
| CLIP ViT-B/16 | + METAGAME | .76 | .79 | .82 | .84 |
| MetaCLIP-2 ViT-H/14 | Attention | .84 | .45 | .32 | .25 |
| MetaCLIP-2 ViT-H/14 | + METAGAME | .85 | .83 | .85 | .86 |

The pattern the chapter uses: the first-order methods collapse toward .25 as
objects are added and the METAGAME variants do not. **.25 with four objects is
the chance level of the pointing game**, which is the book's own reading of the
column and is marked as such in the prose; the paper does not name it.

MaskCLIP with MetaCLIP-2 is missing from Table 2 and the paper says why, in D.2
p. 27: MaskCLIP produces uninterpretable outputs for the 2B-parameter
MetaCLIP-2 encoder, so that combination was discarded from the reported results.
Recorded because a book that reports a results table should say when a cell was
removed on purpose.

**4.3, diffusion transformers** (p. 7-8; setup in D.3, pp. 27-28). FLUX.1
[schnell], evaluated as a zero-shot segmentation proxy on Pascal VOC (1,449
validation images: 927 with a single annotated concept, 522 with 2 to 5), MS
COCO (5,000 panoptically annotated, of which 4,660 eligible after restricting to
single-token thing classes: 1,638 with one and 3,022 with 2 to 14) and
ImageNet-Seg (4,276 binary masks, 3,535 kept, 53 classes).

  So the ground for 4.3 is a segmentation mask. It measures whether the concept
  attribution overlaps the right pixels.

Table 3, p. 8, decimals as printed, Acc/mIoU/mAP:

| Method | Pascal VOC single | Pascal VOC multiple | MS COCO single | MS COCO multiple |
|---|---|---|---|---|
| ConceptAttention | .832/.645/.878 | .612/.476/.622 | .852/.656/.899 | .572/.350/.423 |
| + METAGAME | .903/.768/.908 | .803/.553/.663 | .889/.720/.909 | .706/.390/.439 |

### The decimals chapter 11 actually prints, in the form it prints them

The paper drops the leading zero (`.77`); the book writes the leading zero, per
decision 43's period rule and the book's own house style. Both forms are listed
here so the Numbers check can see the printed string and a reader can find the
paper's string.

| Book prints | Paper prints | Where in the paper | What it is |
|---|---|---|---|
| 0.77 | .77 | Table 2, p. 8 | CLIP ViT-B/16, Attention, 1 object |
| 0.25 | .25 | Table 2, p. 8 | CLIP ViT-B/16, Attention, 4 objects; also the 4-object value of Grad-ECLIP, MaskCLIP and of two rows of Table 4 |
| 0.84 | .84 | Table 2, p. 8 | CLIP ViT-B/16, + METAGAME, 1 object; and MetaCLIP-2 ViT-H/14, Attention, 1 object (the same value twice, in two different rows) |
| 0.90 | .90 | Table 2, p. 8 | CLIP ViT-B/16, + METAGAME, 4 objects |
| 0.85 | .85 | Table 2, p. 8 | MetaCLIP-2 ViT-H/14, + METAGAME, 1 object |
| 0.86 | .86 | Table 2, p. 8 | MetaCLIP-2 ViT-H/14, + METAGAME, 4 objects |
| 0.832 | .832 | Table 3, p. 8 | ConceptAttention, Pascal VOC single concept, accuracy |
| 0.903 | .903 | Table 3, p. 8 | + METAGAME, Pascal VOC single concept, accuracy |

Every one of these carries an interval in the source of the form `± .01` or
`± .00` for Table 2; the chapter prints the point values only, because the
argument it makes from them is about the direction of the trend rather than
about the gap between two rows.

The integers the chapter prints, all from the same pages: 32 (total pages of the
paper), 12 (occurrences of `faithful`), 21 (prompts, p. 26), 100 (maximum output
tokens, p. 26), 8 (Gemma 3 models, p. 26), 1B/4B/12B/27B (model sizes, p. 26),
15 (percent, the top of the Recall@K range, p. 27), 10 and 50 and 4 (class
labels, images per label, and scenarios per pointing game, p. 27), 20 (the
`d < 20` bound of the limitation, p. 9), 15 (days of compute, p. 28), 48 (from
chapter 10, not this paper). Thousands are set with a thin space, so `1\,449`,
`5\,000`, `4\,660`, `4\,276` and `3\,535` (all p. 28), and 927, 522 and 3\,022
likewise.

**Compute** (D.4, p. 28, verbatim): "Experiments described in Section 4 were
computed on a cluster consisting of 2x AMD EPYC 9534 CPUs (128 cores), 1TB of
RAM, and 8x H100 (80GB) GPUs for about 15 days combined. We envision that
preliminary and failed experiments required another same amount of compute
resources."

## The limitation statement, verbatim

Part IV's limitation log (SPEC open item) takes this in full. Section 6,
p. 9, under the heading **Limitations**:

> Our theory is limited by assuming baseline masking/imputation - the most
> principled approach to removing tokens/features from machine learning model
> inputs.
> Empirically, while it is feasible to compute Shapley values exactly for games
> with d < 20, such as captions in vision-language encoders and concepts in
> diffusion transformers, one must rely on efficient algorithms to approximate
> them for larger games, such as language model prompts. We further acknowledge
> that our language model analysis is an illustrative application of a few
> exemplary prompts; rigorous method comparisons would also require faithfulness
> measurements (Achtibat et al., 2024), such as token-pair insertion/deletion
> curves (Baniecki et al., 2025b). Finally, quantifying higher-order effects
> inherently increases both computational cost and cognitive burden for the
> user.

Four statements, and the third is the one chapter 11 turns on. The authors say
plainly that a rigorous comparison of their method against the alternatives
would require a faithfulness measurement, that they did not make one, and which
instrument they would have used: token-pair insertion and deletion curves.
Insertion and deletion are two of the metrics chapter 08 walked through, and
chapter 08's conclusion about that whole family is that nothing has established
that they measure what they are named for.

**This is what makes the paper usable as evidence and it must be said in the
prose.** The gap is stated by the authors, not discovered by the book. The
chapter is not accusing anyone of hiding anything.

**Crossing with the other logs.** Papers 21 and 22 name the absence of a
validated evaluation instrument as the blocking limitation, one by measuring
that the instruments fail on its own object and one by recording that no
standard for using them exists (see `ch10-vuon-bien-the-lime.md`). Paper 23
names it a third way and from inside: as the step a methods paper would take
next and cannot take yet. Under section 9.7's three crossing items this settles
none of them; it is a fourth kind of evidence for the same absence rather than
a test of it.

**Broader impact**, same page, recorded because chapter 18 may want it: "We do
not anticipate any negative societal impacts from this work, as it focuses on
foundational interpretability techniques intended to improve our understanding
of transformers."

## Claims of absence, verified by full-text search

Method: `pdftotext -layout` over the whole 32-page PDF, then
`grep -oic` per string. Run this session. **Three of the counts written from
reading before the search was run were wrong, and are corrected here**; the
lesson is in the retro.

- `incentive`, `churn`, `proliferat`, `publicat`, `reviewer`, `peer review`:
  **zero occurrences each.** This is the search behind the TOC-line correction
  above. Nothing in this paper is about the sociology of research.
- `faithful` and its inflections occur **thirteen times**, not the four a first
  read suggested and not the twelve a `grep -c` reports. `grep -c` counts
  matching *lines*, and p. 20 carries two occurrences on one line; the count
  here is `grep -oi ... | wc -l`. The split matters:
  - **Six are the proper name of a method**, the *faithful Shapley interaction
    index* (FSII) of Tsai et al. (2023): p. 3, p. 12 (bibliography title),
    twice in appendix B.1/B.2 and twice on p. 20. Counted with
    `grep -oi "faithful shapley interaction\|Faith-Shap: The faithful"`. The
    word there is part of a name and says nothing about the property.
  - p. 3, "a faithful method must isolate the individual effect of x_1 from the
     interaction x_1 x_2^2" - the analytic criterion of Table 1.
  - p. 3, "Faithfully separating pure individual effects from joint interactions
     remains a non-trivial challenge."
  - p. 5, of AttnLRP: "While it has shown state-of-the-art faithfulness
     performance in language and vision tasks" - attributed to Achtibat et al.
     (2024), not measured here.
  - p. 7, "our proposed Meta-MaskSigLIP approach is the most faithful to
     interpret SigLIP-2" - said of the interaction recognition numbers of
     Table 2 and appendix Table 4, which are pointing-game scores.
  - p. 7, "Beyond faithfully attributing bi-token interactions".
  - p. 8, "The debate over whether attention faithfully explains transformers
     remains central" - about the attention literature, not about this method.
  - p. 9, in the Limitations quote above.

  Six plus seven is thirteen, which is the check on the split.

  So the paper uses the word freely and still reports **no faithfulness
  measurement of its own**: the two places it applies the word to its own
  results, p. 7 twice, are applying it to a pointing-game score, and the one
  place it says a faithfulness measurement is needed is the Limitations
  sentence saying one was not made.
- `ground truth` unhyphenated: **zero occurrences.** `ground-truth` occurs
  twice, both in D.3 on p. 28, and both mean the segmentation label of a pixel
  (`let y_p denote the ground-truth category at pixel p`). There is no ground
  truth for an attribution anywhere in the paper except the analytic example,
  which the paper never calls one.
- **`sensitivity-n`, `comprehensiveness`, `sufficiency`, `ROAR` and
  `infidelity` occur zero times.** `sanity` occurs twice, both inside
  bibliography titles (Adebayo et al. 2018; Binder et al. 2023) and never in the
  paper's own prose, where the corresponding phrase is "model randomization
  tests" (p. 8). Of chapter 08's metric families, only insertion and deletion
  are named in the paper's prose, and only once, in the Limitations sentence.
- `Hedstrom` occurs **twice**: p. 8 in the Related Work sentence separating this
  paper from the meta-evaluation problem, and p. 12 in the bibliography.

## One claim checked and dropped

Table 2 shows **five first-order rows** all scoring exactly `.25` in the
four-object column. Those five rows are **three distinct methods** across two
models: Attention, MaskCLIP and Grad-ECLIP on CLIP ViT-B/16, and Attention and
Grad-ECLIP on MetaCLIP-2 ViT-H/14. A draft of section 11.5 wrote "five
different first-order methods", which the cold audit caught and which was wrong
under any reading; the prose now says five rows of three methods. It is
tempting to go further and write that `.25` is the chance level of the pointing
interaction recognition metric, since five rows converging on one value is
suggestive.
**The book cannot support that and does not print it.** The metric is defined in
Baniecki et al. (2025b), which is outside the corpus and which this book has not
read; paper 23 does not state the metric's chance level anywhere. What the
chapter prints instead is the observed fact - the first-order scores fall toward
`.25` as objects are added while the METAGAME variants do not - with no claim
about what `.25` means. Recorded here so a later session does not re-derive the
temptation.

## Terminology settled this session

Vietnamese, added to appendix B's Chuong 11 block:
tuong tac bac hai (second-order interaction), attribution noi tang (serial
attribution), ro ri tuong tac (interaction leakage), hieu ung rieng (pure
individual effect), hieu ung tuong tac (interaction effect), tinh hieu qua phan
tang (hierarchical efficiency), tuong tac co huong (directional interaction),
chi so tuong tac (interaction index).

Kept in English, added to the keep-in-English block on the reasoning chapter 08
gave for its own metric names: metagame, meta-attribution, Meta-Shapley value,
Meta-IG, integrated Hessians, AttnLRP, Grad-ECLIP, ConceptAttention, Recall@K,
pointing game.

Appendix C gains STII and SOP, both expanded in the source (p. 3): STII =
Shapley-Taylor interaction index, SOP = Sum of Power. Under decision 46 an
abbreviation with no expansion in its own source gets none; both of these have
one, and the prose uses both more than once.

**Notation, checked against appendix A rather than copied from the paper.**
Paper 23 writes `phi_i(f,x)` for a first-order attribution, `phi_{j->i}(f,x)`
for the meta-attribution, and `psi_{i,j}(f,x)` for the serial attribution.
Appendix A already binds `$\varphi_j(x,f)$` to a first-order attribution
(chapter 06, definition 6.1) with the arguments in the other order, and already
binds `$\psi_i(x)$` to a data attribution (chapter 07). Two consequences,
both on decision 29's rule that the book keeps one name per concept:

- The book writes `$\varphi_i(x,f)$` and `$\varphi_{j\to i}(x,f)$`, keeping its
  own argument order. The arrow subscript extends the chapter 06 symbol rather
  than colliding with it, since a meta-attribution is built out of exactly that
  object. Appendix A gains one row for `$\varphi_{j\to i}(x,f)$`.
- **The book introduces no symbol for the serial attribution.** `$\psi$` is
  taken, and the serial form is clearer written out as the attribution operator
  applied to the attribution function, `$\varphi_j\bigl(x, \varphi_i(\cdot,f)\bigr)$`,
  which is literally what the construction is. No appendix A row is needed and
  chapter 11's prose says once that the paper writes `psi_{i,j}` here.

**`I` is taken, so the book writes `$T$`.** The paper writes `I := x_1 x_2^2`
for the interaction term of the analytic example. A first draft kept it and
recorded here that it was "local to one table and one section", which was wrong:
appendix A already binds `$I$` to the perturbation in chapter 08's definition of
infidelity, and `$\mathcal{I}$` separately to chapter 07's influence function.
Chapter 11 writes `$T$`, says once in section 11.2 that the paper writes `I` and
why the book does not, and appendix A carries the row. Checking a one-letter
symbol against appendix A costs one grep and this one would have shipped
otherwise.
