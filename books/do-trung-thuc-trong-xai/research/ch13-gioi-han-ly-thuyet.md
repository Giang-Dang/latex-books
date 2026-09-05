# Chapter 13 - the algorithmic-information-theory ceiling read closely

Date: 2026-09-04. Sixth note in this folder, one per chapter from chapter 08 on
(decision 35). Chapter 13 reads one paper in full. It prints almost no decimals
of its own, because the paper reports no measurement of any kind: it proves
theorems and runs nothing. What this note therefore has to carry is different
from the earlier ones. It records (1) every numbered result the chapter cites by
number, because the Numbers check reads `2.23` and `3.15` as decimals; (2) the
verified absences the chapter's argument turns on, which are the strongest in
the book so far; (3) four places where the paper's own statement does not
support its own conclusion, two of which the chapter refuses to build on; and
(4) the paper's limitation and future-work statement for the chapter 18 log.

The single most important entry is under "Verified absences": **the word
`faithfulness` does not occur once in 65 pages.**

## Source pin

| Key | arXiv | Revision read | Pages read | Submitted |
|---|---|---|---|---|
| `p26limits` | 2504.20676 | **v2**, the latest of two | 1-55 body in full; 56-61 appendix (the proof of theorem 4.6) in full; 61-65 are the bibliography, scanned only | v1 2025-04-29 11:58:37 UTC; v2 2025-11-03 11:37:53 UTC |

Read from
`F:\repo\thesis-xai-faithfulness\3-tier-b-critique-core\26_xai-theory_limits-of-ai-explainability-ait_2025.pdf`.
The PDF's own stamp reads `arXiv:2504.20676v2 [cs.AI] 3 Nov 2025`, so the file
on disk is the current revision and no re-download was needed. 65 pages total:
body 1-55, appendix 56-61, references 61-65. Text extracted with
`pdftotext -layout`; every formula and every symbol quoted below was re-read
from the rendered page rather than from that extraction, because the math font
carries no ToUnicode map and the extraction silently drops every Greek letter.
That is worth recording as a trap: the extracted text of definition 2.12 reads
`f (k) = inf E(f, g)`, which looks like a definition of `f` and is in fact the
definition of the error function whose name is the dropped glyph.

Verified this session on the raw arXiv abstract page and through the arXiv API,
not through a summarising fetch:

- **Two revisions exist.** Submission history: `[v1] Tue, 29 Apr 2025 11:58:37
  UTC (33 KB)`, `[v2] Mon, 3 Nov 2025 11:37:53 UTC (42 KB)`. The API entry's
  `<id>` resolves to `http://arxiv.org/abs/2504.20676v2`. **This is the first
  corpus paper this book has read that has more than one revision**, so
  decision 15's "cited as the revision read" clause finally does work: the
  chapter cites v2 and refs.bib says so.
- Categories: primary `cs.AI`, cross-listed `cs.CY` and `cs.IT`. MSC 68Q30,
  68T01; ACM I.2.0, H.1.1, K.4.1. Licence CC BY 4.0.
- **`journal-ref`: absent. `Comments`: absent.** The abstract page shows only
  arXiv's own DataCite DOI, `10.48550/arXiv.2504.20676`, which is not a venue
  DOI; the Atom API entry carries no `<arxiv:doi>` element at all, which is a
  disagreement between the two arXiv surfaces worth knowing about but which
  changes nothing here.
- dblp's record for Shrisha Rao lists this paper only as a CoRR/arXiv entry with
  no venue tag, while other 2025 entries on the same page do carry venue tags
  when published. **Nothing anywhere says this paper has been accepted at a
  venue.** Same position as paper 23; the prose must not call it a conference or
  journal paper.
- Single author: Shrisha Rao.

**The seeded refs.bib entry needed one correction and one addition.** Author,
title, capitalisation, `eprint` and `eprinttype` all match the live record; the
`date` field said `2025` and stays `2025`, because v2 is November 2025. The
`note` field is rewritten from the seed string to record the v2 pin. Third time
a seeded entry has come through essentially clean, after chapter 12's two and
chapter 11's one.

No orientation note was used. The corpus README names one for paper 26 and it is
dead locally (decision 13 and the standing open item), so this chapter drafts
from the PDF alone, as chapters 06, 07 and 11 did.

## The TOC line is right, and it is also half the paper

The SPEC's initialized TOC line for chapter 13 reads:

> **Giới hạn lý thuyết của giải thích** - the algorithmic-information-theoretic
> ceiling on explainability, and what a bound does and does not say about
> practice. Paper 26.

The open item flagged this as one of the two lines that most read like a claim
inferred from a title, and asked for it to be checked against the abstract
before drafting. **Checked, and this time the line holds.** The paper does
formalise explainability through Kolmogorov complexity, does prove a ceiling,
and does devote a section to what the ceiling means in practice. This is the
first init-written line since decision 24 that survives contact with its paper,
which is worth recording as much as the five failures were.

What the line does *not* mention is that fifteen of the paper's 65 pages, section 4 (pp. 46-54)
plus the whole appendix (pp. 56-61), are about AI regulation: a feasibility
region, a trilemma, tiered and purpose-specific regulatory requirements, and a
reading of the EU AI Act, SR 11-7, the MAS FEAT principles and FDA guidance. The
abstract names this as one of the paper's headline contributions. The line
under-describes rather than over-promises, which is a new failure mode for these
lines and a much cheaper one.

## Verified absences

Full-text search of the extracted text of all 65 pages, case-insensitive,
counting every occurrence including the bibliography:

| String | Occurrences | Where |
|---|---|---|
| `faithful` | **0** | nowhere, in 65 pages |
| `ground truth` | **0** | nowhere |
| `saliency` | 0 | nowhere |
| `deletion` | 0 | nowhere |
| `insertion` | 0 | nowhere |
| `Shapley` | 0 | nowhere |
| `gradient` | 0 | nowhere |
| `dataset` | 0 | nowhere |
| `attribution` | **1** | **p. 2**, intro: "from feature attribution methods [8, 9] to prototype-based approaches [10] and counterfactual explanations [11]" |
| `LIME` | **1** | p. 39, end of the proof of theorem 3.15 |
| `SHAP` | **1** | p. 39, same sentence |
| `experiment` | 1 | p. 55, conclusion, as future work |
| `empiric` | 1 | p. 50, "an empirical claim about Nature" |
| `benchmark` | 1 | p. 3, naming someone else's InfoExplain benchmark |
| `metric` | 16 | every one either denotes an *error* metric of definition 2.10 or is part of `geometric` / `isoperimetric` / `parametric` |

Two absences that are not string counts and that the chapter also prints, checked
by reading rather than grepping. **The paper contains no figure and no results
table**: pages 1-61 were read and none of them carries either, `Figure` and
`Table` occur zero times in the extracted text, and the only tabular material
anywhere is the numbered display equations. **It uses no dataset**: `dataset`
occurs zero times and the one place data is mentioned at all is the conclusion's
proposal for future synthetic-data experiments (p. 55).

Two occurrences of `metric` are the reason the row above is worded as it is
rather than as a claim about strings. Page 8 carries "This metric is relevant
when..." twice, once for each of $\mathcal{E}_{D}$ and $\mathcal{E}_{\infty}$;
the word is bare there and refers back to "error metrics" a few lines up. A
first draft of section 13.1 claimed every occurrence sits *inside* the string
`error metric` or inside `geometric`/`isoperimetric`/`parametric`, which those
two falsify. The claim the chapter prints is the weaker and true one.

The `metric` row is the one to be careful with, and it is the reason the count
alone is not enough. Sixteen hits looks like a paper that discusses metrics. It
is not: the paper's "error metric $\mathcal{E}$" is the distance between $f$'s
output and $g$'s output, which is the book's `độ khớp` under decision 49, and
the word never once refers to an instrument for scoring an explanation. **No
faithfulness metric of chapter 08 appears in this paper under any name.**

The single sentence on p. 39 that names LIME and SHAP, quoted in full:

> This shows that the complexity of local explanations grows only
> logarithmically with the ratio of the Lipschitz constant and the error
> threshold, in contrast to growing exponentially with dimension for global
> explanations. This justifies why local explanation methods like LIME [9] and
> SHAP [8] can be more tractable than global ones.

That is the paper's entire contact with Part II of this book. Section 13.5 is
written around it.

## The object of the paper, stated before any result

Decision 54's rule. The paper's object is the **approximation error between a
model $f$ and an explanation function $g$, measured on outputs**, under a bound
on the description length of $g$. Definition 2.2: "An explanation for an AI
system $f$ is a function $g : \mathcal{X} \to \mathcal{Y}$ that approximates $f$
and is considered interpretable by humans according to some criterion."

Three consequences the chapter has to carry, none of which the paper states:

1. That error is `độ khớp`, not `độ trung thực`. Definition 1.2 of this book
   asks whether the explanation reflects the process by which the model reached
   its output; definition 2.10 of this paper asks how far $g(x)$ is from $f(x)$.
   Two explanations can have identical error and attribute the decision to
   different features.
2. An attribution vector is not a function $\mathcal{X} \to \mathcal{Y}$, so
   feature attribution scores do not fall under definition 2.2 as scores. They
   fall under it only through the surrogate reading: LIME's $g$ is exactly such
   a function, and SHAP's additive model is one too, by chapter 04's reading of
   paper 10. Grad-CAM's heatmap is not.
3. The paper measures nothing and never claims to. "Empirical validation of our
   theoretical predictions represents crucial future work" (p. 55).

## Numbered results cited by number

Every entry here appears somewhere in the chapter's prose, so every one of these
two-part numbers is recorded for the Numbers check. Page anchors are printed
page numbers, which coincide with PDF page numbers throughout this file.

| Number | Kind, title | Page | What it says |
|---|---|---|---|
| 2.1 | Definition, AI System | 5 | $f : \mathcal{X} \to \mathcal{Y}$ |
| 2.2 | Definition, Explanation | 5 | $g : \mathcal{X} \to \mathcal{Y}$ approximating $f$ and deemed interpretable |
| 2.3 | Definition, Kolmogorov Complexity | 5 | $K(g)$, shortest program on a universal Turing machine |
| 2.6 | Theorem, Invariance | 6 | $|K_{U_1}(g) - K_{U_2}(g)| \le c_{U_1,U_2}$ |
| 2.8 | Definition, Interpretability Class | 7 | $\mathcal{I}_k = \{g : K(g) \le k\}$ |
| 2.9 | Lemma, Size of Interpretability Class | 7 | $|\mathcal{I}_k| \le 2^{k+1} - 1$ |
| 2.10 | Definition, Approximation Error | 8 | $\mathcal{E}_D$ expected, $\mathcal{E}_\infty$ worst case |
| 2.11 | Proposition, Relationship Between Error Metrics | 8 | $\mathcal{E}_D \le \mathcal{E}_\infty$ |
| 2.12 | Definition, Explanation Error Function | 9 | $\varepsilon_f(k) = \inf_{g \in \mathcal{I}_k} \mathcal{E}(f,g)$ |
| 2.13 | Definition, Output Separation | 10 | $\sigma_f(\delta) = \inf_x \inf_{y \ne f(x)} d(f(x), y)$ |
| 2.14 | Definition, Non-Degenerate Function | 10 | $f$ is $\delta$-non-degenerate if $\sigma_f(\delta) > \delta$ |
| 2.16 | Definition, Explanation Complexity Function | 11 | $\kappa_f(\delta) = \min\{k : \exists g \in \mathcal{I}_k, \mathcal{E}(f,g) \le \delta\}$ |
| 2.17 | Theorem, Existence of Explanation Complexity | 11 | $\kappa_f(\delta) \le K(f)$ |
| 2.18 | Proposition, Monotonicity of Error Function | 11 | $\varepsilon_f(k)$ non-increasing in $k$ |
| 2.19 | Proposition, Monotonicity of Complexity Function | 12 | $\kappa_f(\delta)$ non-increasing in $\delta$ |
| 2.20 | Theorem, Duality of Explainability Measures | 12 | $\varepsilon_f(k) \le \delta \iff k \ge \kappa_f(\delta)$ |
| 2.21 | Lemma, Lower Bound on Explanation Error | 12 | $k < K(f) \Rightarrow \varepsilon_f(k) > 0$ |
| 2.22 | Theorem, Minimal Complexity for Perfect Explanation | 14 | $\kappa_f(0) = K(f)$ |
| 2.23 | Theorem, Complexity Gap | 15 | $K(g) < K(f) - c \Rightarrow \exists x, f(x) \ne g(x)$ |
| 2.24 | Theorem, Error-Complexity Trade-off | 15 | $\varepsilon_f(k) \ge \min_{x, y \ne f(x)} d(f(x), y)$ |
| 2.25 | Corollary, Error Bound for Non-Degenerate Functions | 16 | $f$ $\delta$-non-degenerate and $K(g) < K(f) - c$ $\Rightarrow$ $\mathcal{E}_\infty(f,g) > \delta$ |
| 2.27 | Definition, Compressibility | 16 | $f$ is $\alpha$-compressible if $\exists c, \forall \delta, \exists g$ with $K(g) \le c\delta^{-\alpha}$ and error $\le \delta$ |
| 2.29 | Theorem, Random Function Unexplainability | 17 | random Boolean $f$ on $\{0,1\}^n$, any $g$ with $K(g) \le (1-\epsilon)2^n$ fails on half the inputs |
| 2.31 | Theorem, Simple Function Explainability | 19 | $K(f) \le C \Rightarrow \varepsilon_f(C) = 0$ |
| 3.1 | Definition, Lipschitz Continuity | 20 | $|f(x)-f(y)| \le L\|x-y\|_2$ |
| 3.2 | Theorem, Explainability of Lipschitz Functions | 20 | $\kappa_f(\delta) = \mathcal{O}((L/\delta)^d \log(L/\delta))$ |
| 3.3 | Corollary, Dimension Dependence | 22 | the same bound, read as exponential in $d$ |
| 3.4 | Theorem, Lower Bound for Lipschitz Functions | 22 | $\exists f$ $L$-Lipschitz with $\mathcal{E}_\infty(f,g) = \Omega(L \cdot 2^{-k/d})$ for every $g$ with $K(g) \le k$ |
| 3.6 | Proposition, Smoothness of Explanation Error | 24 | $\varepsilon_f(k)$ falls without jumps |
| 3.7 | Proposition, Practical Complexity Measures | 25 | the five model-class encodings, see below |
| 3.8 | Corollary, Linear Model Explanations | 27 | **not used by the chapter, see "Four places the paper does not support itself"** |
| 3.9 | Corollary, Decision Tree Explanations | 28 | $\mathcal{E}_\infty(f,g) = \mathcal{O}(V(f) \cdot |T|^{-1/d})$ for bounded variation $V(f)$ |
| 3.10 | Theorem, Complexity-Error Trade-off for Neural Networks | 30 | $K(g) = \mathcal{O}((L/\delta)^d \log(L/\delta) + d \log d)$ |
| 3.11 | Theorem, Information-Theoretic Bound | 32 | error bounded below by an exponential in the mutual-information gap |
| 3.12 | Theorem, Rate-Distortion Interpretation | 35 | $\kappa_f(\delta) \ge R_f(\delta) - \mathcal{O}(1)$ |
| 3.13 | Definition, Local Explanation Error | 36 | $\varepsilon^{local}_f(k, x_0, r)$, sup over a ball |
| 3.14 | Lemma, Local-Global Explainability Gap | 36 | $\mathbb{E}_{x_0}[\varepsilon^{local}_f(k,x_0)] \le \varepsilon_f(k)$ |
| 3.15 | Theorem, Local Explanation Complexity | 37 | $\kappa^{local}_f = \mathcal{O}(1)$ if $\delta \ge Lr$, else $\mathcal{O}(d \log(Lr/\delta))$, **given oracle access to $f$** |
| 3.17 | Definition, Box-Counting Dimension | 40 | $\dim_{box}(S)$ |
| 3.18 | Theorem, Distribution-Aware Explainability | 40 | $\kappa^D_f(\delta) = \mathcal{O}((1/\delta)^{d_B} \log(1/\delta))$ for support of box dimension $d_B$ |
| 3.19 | Theorem, Practical Error-Complexity Trade-off | 43 | $\mathcal{E}(f,g) \ge \Omega(C_f^\alpha \cdot C_g^{-\beta})$ |
| 4.1 | Remark, Regulatory Feasibility Bound | 46 | a rule demanding $k$ and $\delta$ with $k < \kappa_f(\delta)$ is infeasible |
| 4.2 | Definition, Regulatory Feasibility Region | 46 | $R_f = \{(k,\delta) : k \ge \kappa_f(\delta)\}$ |
| 4.3 | Proposition, Regulatory Domain Coverage | 47 | the domain region is the intersection of the per-model regions |
| 4.4 | Remark, Regulatory Contradiction Analysis | 47 | three shapes of impossible rule |
| 4.5 | Definition, Feasible Regulatory Requirement | 49 | class, tolerable error, and $\kappa_{f,\mathcal{C}}(\delta) \le k_{max}$ |
| 4.6 | Theorem, Regulatory Impossibility Result | 49 | the trilemma; R1, R2, R3 pairwise satisfiable, not jointly, none implied by the other two |
| 4.7 | Proposition, Necessity of Non-Degeneracy | 50 | without non-degeneracy all three hold at once |
| 4.9 | Theorem, Tiered Regulatory Optimality | 51 | stricter error thresholds for higher-risk tiers |
| 4.10 | Definition, Purpose-Specific Explanation Requirements | 51 | per-purpose subspace, tolerance and class |

Section numbers referred to in the prose: 2.1, 2.2, 2.3, 3.1, 3.2, 3.3, 3.4,
3.5, 4.1, 4.2, 4.3. Three-part numbers (3.2.1 through 3.2.4) are skipped by the
Numbers check's own lookaround and are recorded here anyway.

### Proposition 3.7 verbatim, p. 25

The five encodings, quoted because section 13.4 tabulates them:

> 1. Linear models: $K(g) = O(n \log n)$ for $n$ features.
> 2. Decision trees: $K(g) = O(|T| \log |T|)$ for a tree with $|T|$ nodes.
> 3. Rule lists: $K(g) = O(r \cdot l \log(r \cdot l))$ for $r$ rules of average
>    length $l$.
> 4. Nearest-neighbor models: $K(g) = O(m \cdot d \log(m \cdot d))$ for $m$
>    stored examples in $d$ dimensions.
> 5. Neural networks: $K(g) = O(w \log p + b \log p + a)$ for a network with $w$
>    weights, $b$ biases, architecture description of length $a$, and precision
>    $p$ for parameter values.

The paper labels the argument a "Proof Sketch", not a proof. The chapter says so.

## Notation: what the book writes, and why

Six of the paper's symbols collide with symbols appendix A had already bound.
Resolved per decisions 29, 41 and 58.

| Paper | Book | Reason |
|---|---|---|
| $k$, complexity threshold | $b$ | $k$ is chapter 08's count of top-scoring elements kept or removed in the deletion family. Both are bare scalars with no distinguishing shape, so the collision is real. $b$ is free and is what the quantity is: a budget in bits. |
| $\mathcal{I}_k$, interpretability class | $\mathcal{G}_b$ | $\mathcal{I}$ is chapter 07's influence function. And appendix A already binds $\mathcal{G}$ to "the class of readable models used to approximate $f$", which is exactly this set; the paper's class is that class with a budget attached, so the book subscripts the symbol it has rather than importing a second one. Decision 58's $\varphi_{j\to i}$ move. |
| $D$, the input distribution | $\mathcal{D}$ | $D$ is LIME's distance function, appendix A. $\mathcal{D}$ matches chapter 07's $\mathcal{D}_{\mathrm{train}}$. |
| $d(y_1,y_2)$, output distance | $\rho(y_1,y_2)$ | The paper uses $d$ for the input dimension **and** for the output distance, on the same page. The book keeps $d$ for the dimension, which is what chapter 06 bound it to and what the paper means by it elsewhere. $\rho$ is free: the paper's own $\rho$-shaped letter for the failure rate in theorem 2.29 is $\varepsilon$, not $\rho$. |
| $\sigma_f(\delta)$, output separation | no symbol | Used twice in the paper and nowhere else. Decision 58: a symbol earns its place by being used more than once *and* by being shorter than what it stands for. Non-degeneracy is stated in words. This also removes a collision with LIME's kernel width $\sigma$. |
| $K(\cdot)$, Kolmogorov complexity | $K(\cdot)$, kept | Collides with LIME's $K$, the number of components kept, appendix A. Kept anyway and named once in the prose: $K$ is the field-wide notation for Kolmogorov complexity and renaming it would send a reader to any AIT text looking for a letter that is not there, and the two are separated by shape rather than by context. Kolmogorov complexity is *always* applied, $K(f)$, $K(g)$; LIME's $K$ is *always* bare. This is a third way of settling a symbol collision, after renaming (decisions 29, 41) and writing it out (decision 58). |

Symbols taken over unchanged because they are free in appendix A:
$\mathcal{X}$, $\mathcal{Y}$, $\varepsilon_f(b)$, $\kappa_f(\delta)$,
$\mathcal{E}_\infty$, $\mathcal{E}_{\mathcal{D}}$, $\delta$, $L$, $d_B$, $r$ for
a neighbourhood radius. **$r$ is a partial collision**: appendix A binds $r$ to
chapter 12's Pearson correlation coefficient. The two never appear on the same
page and the radius is always inside $B_r(x_0)$, so the book keeps both and the
appendix A row says so.

The paper's $k_{human}$ becomes $b_{\text{người}}$ and its $\delta_{neg}$ stays
a plain $\delta$, described in words as a threshold chosen small.

## Four places the paper does not support itself

**A fifth was found on 2026-09-05, in the proof of theorem 3.4 itself, and it
changes what entry 3 below concludes.** This note calls theorem 3.4 "a valid
lower bound" and builds on it in two places. The statement is fine; the paper's
proof of it is not, and once it is replaced the bounds in entry 3 turn out to
match after all, so the chapter's rebuttal of remark 3.5 was an overcorrection.
Both the defect and the replacement argument are in
`research/ch01-13-reading-flow.md`, and the decision log carries them as
decisions 66 and 62c. Read that file alongside entry 3 below.

Recorded so the next session does not re-derive them, and because decision 40
set the standard: a textbook that cites propositions by number cannot print one
that is false.

### 1. Corollary 3.8 reads a lower bound off an upper bound. The chapter does not use it.

Corollary 3.8, p. 27, claims that for an $L$-Lipschitz $f$ on $[0,1]^d$ and a
linear model $g$ with $n$ features, $\mathcal{E}_\infty(f,g) = \Omega(L \cdot
d^{1/2} \cdot n^{-1/d})$.

The proof's second step, quoted from p. 27:

> From Theorem 3.2, we know that achieving an error of $\delta$ requires
> complexity $\kappa_f(\delta) = O((L/\delta)^d \log(L/\delta))$. [...] With a
> linear model of complexity $K(g) = O(n \log n)$, this gives us: $n \log n
> \gtrsim (L/\delta)^d \log(L/\delta)$.

Theorem 3.2 states that $\kappa_f(\delta)$ is *at most* that quantity. Deriving
a floor on the error from a budget needs a lower bound on $\kappa_f$, and the
paper has only an upper one; the step silently treats the $\mathcal{O}$ as a
$\Theta$. The conclusion may still be true for linear surrogates, and almost
certainly is, but not by this route and not with this exponent: the error of the
best linear approximation to a fixed $f$ is a property of how far $f$ is from
linear, and does not fall as $n^{-1/d}$ when features are added.

**What the chapter does instead.** Theorem 3.4 is a valid lower bound, stated
existentially: for every $d$, $L$ and $b$ there exists an $L$-Lipschitz $f$ such
that every $g$ with $K(g) \le b$ has $\mathcal{E}_\infty(f,g) = \Omega(L \cdot
2^{-b/d})$. Combined with proposition 3.7's $K(g) = \mathcal{O}(n \log n)$ for a
linear model, that gives the worst-case statement about linear surrogates the
chapter wants, from results the paper does prove. The chapter names corollary
3.8, says the book does not build on it, and says why in one sentence.

### 2. Theorem 3.15 compares a relative complexity against an absolute one, and the LIME sentence rests on the comparison

Theorem 3.15's own statement, p. 37, defines $\kappa^{local}_f(\delta, x_0, N)$
as "the minimum description length of a program that, **given oracle access to
$f$**, computes a local approximation $g$ with error at most $\delta$ in the
neighborhood $N(x_0)$", and the proof of case 1 says it again: "Since we measure
relative complexity (description length given oracle access to $f$), the program
need only specify [...] The constant value $f(x_0)$ is obtained via oracle
access."

Every global bound in the paper - theorem 3.2, corollary 3.3, theorem 3.10,
theorem 3.18 - is an absolute description length, and the dominant term in each
is exactly the cost of encoding the function values that the local bound gets
free from the oracle. The proof of theorem 3.15 then closes with:

> Comparison with global complexity: For global explanations on $\mathcal{X}$,
> if $\mathcal{X}$ has diameter $D$, the complexity scales as
> $O((LD/\delta)^d d\log(LD/\delta))$, which is exponential in $d$. In contrast,
> the local complexity is only logarithmic in the ratio $Lr/\delta$,
> demonstrating that local explanations can be exponentially simpler than global
> ones.

and the paper's only sentence about LIME and SHAP, on p. 39, is the reading of
that comparison. This is not a false statement, and the book does not call it
one: it is a comparison between two quantities that are not measured the same
way, and the paper states the difference itself two pages earlier without
carrying it into the comparison. Section 13.5 says exactly that and no more.

A second, smaller gap in the same proof: case 2 constructs a covering with
$\mathcal{O}((Lr/\delta)^d)$ regions, computes $K(g) = \mathcal{O}((Lr/\delta)^d
\cdot d\log(Lr/\delta))$ at equation (113), and then asserts "we can improve this
bound" to $\mathcal{O}(d\log(Lr/\delta))$ by recursive subdivision, on the
grounds that "the depth of recursion is $\mathcal{O}(\log(Lr/\delta))$ and at
each level we need $\mathcal{O}(d)$ bits to specify the subdivision". Encoding
one path down a quadtree costs that; encoding the whole partition does not. The
theorem as stated is the improved bound.

### 3. Remark 3.5 claims the Lipschitz bounds match up to constants, and they do not

Found by the 2026-09-04 cold audit, which is the most valuable thing that audit
returned. Theorem 3.2 (p. 20) gives an upper bound
$\kappa_f(\delta) = \mathcal{O}\big((L/\delta)^d \log(L/\delta)\big)$, and its
proof charges for two things: the grid resolution, $\mathcal{O}(\log(L/\delta))$
bits, and **one encoded function value per cell**, $m^d$ of them at
$\mathcal{O}(\log(L/\delta))$ bits each. Theorem 3.4 (p. 22) gives a lower bound
$\mathcal{E}_{\infty}(f,g) = \Omega\big(L \cdot 2^{-k/d}\big)$ for every $g$ with
$K(g) \le k$. Remark 3.5 then asserts:

> This theorem establishes a worst-case lower bound: there exist $L$-Lipschitz
> functions whose complexity-error trade-off matches the upper bound in
> Theorem 3.2 up to constants.

**Write both in the same variable and they are nowhere near each other.** At
budget $k$, theorem 3.2's construction buys $m^d \approx k / \log(L/\delta)$
cells, so the achievable error is $\Theta(L \cdot k^{-1/d})$, falling
polynomially in $k$. Theorem 3.4 only forbids error below $\Omega(L \cdot
2^{-k/d})$, falling exponentially in $k$. Inverted, theorem 3.2 says
$\kappa_f(\delta)$ can be as large as $(L/\delta)^d \log(L/\delta)$ while theorem
3.4 only says it is at least $\Omega(d \log(L/\delta))$: exponential in $d$
against linear in $d$.

The step that produces the false claim is in proposition 3.6's proof, p. 24:

> With $N \le 2^k$ regions at complexity $k$, we get $\varepsilon_f(k) =
> \mathcal{O}(L \cdot 2^{-k/d})$.

That treats a $k$-bit budget as buying $2^k$ grid cells, which is exactly the
count theorem 3.2's own proof rejects, because it does not pay for the value
stored in each cell. The paper is internally inconsistent between p. 21 and
p. 24, and remark 3.5 rests on the p. 24 side.

**What this costs the chapter.** A first draft of section 13.4 printed "chặn
trên và chặn dưới vì thế khớp nhau tới hằng số: số mũ theo $d$ là bản chất của
bài toán chứ không phải của cách dựng", unattributed, and section 13.6 and the
tomtat repeated it. All three were corrected in that session: the chapter stated
both bounds in the budget variable, named remark 3.5 as the paper's claim,
declined it, and drew the narrower conclusion that the curse of dimensionality
here is a property of the grid construction rather than something proved
unavoidable. This is decision 62's class, and it is the third instance of it in
one paper after corollary 3.8 and theorem 3.15's comparison.

**Superseded 2026-09-05, and the correction is the interesting part.** The
critique of proposition 3.6's `N ~ 2^k` step above stands. The narrower
conclusion drawn from it does not. Theorem 3.4's own proof turned out to be
invalid too, and replacing it with a packing argument gives
`kappa_f(delta) = Omega((L/delta)^d)`, which matches theorem 3.2's upper bound in
the exponent. So the curse of dimensionality *is* intrinsic in the worst case,
remark 3.5's conclusion is right even though its route is not, and the chapter
now says so. **Having caught the paper printing an unsupported claim, that
session rejected the claim rather than only its derivation, and nothing in the
drafting or the audit caught the overcorrection because it read as caution.**
Full derivation in `research/ch01-13-reading-flow.md`; decisions 66 and 62c.

### 4. Lemma 2.21's second case assumes a hypothesis the lemma does not have

Lemma 2.21 is stated for $k < K(f)$. Case 2 of its proof, p. 13-14, concludes
with: "But this contradicts the assumption that $k < K(f) - c$ for a universal
constant $c$". The lemma has no $c$. Theorem 2.23 does, and the constant is real
and necessary there. Nothing downstream in the chapter rests on lemma 2.21 in
the expected-error case, so the chapter states the worst-case reading, which case
1 of the proof does establish cleanly. Recorded rather than printed.

## Smaller slips, recorded and not printed

None of these is load-bearing. They are here so the next session recognises them
as the paper's rather than as an error in the book's reading.

- The conclusion, p. 54, cites "the gap between local and global explainability
  (Theorem 3.14)" but 3.14 is a lemma; the theorem is 3.15. The same paragraph
  cites "the regulatory implications of our theoretical results (Theorem 4.1)"
  but 4.1 is a remark.
- The conclusion calls contribution (1) "a formal definition of explainability
  based on Kolmogorov complexity (Definition 2.2)"; the introduction, p. 2,
  calls it "A formal definition of explanation error (Definition 2.12)".
- The policy recommendations, p. 53, say "As suggested by Theorem 4.11"; 4.11 is
  a remark.
- Remark 2.15, p. 10, calls theorem 2.24 the "Error-Complexity Lower Bound";
  the theorem's own title is "Error-Complexity Trade-off".
- Definition 2.5, p. 6, refers to "Definition 2.3a", which does not exist.
- Proposition 2.19 is glossed on p. 12 as "In other words, longer explanations
  are not less accurate than shorter ones." The proposition says
  $\kappa_f(\delta)$ is non-increasing in $\delta$; the gloss restates
  proposition 2.18 instead, and loosely.
- Lemma 3.14 writes $\varepsilon^{local}_f(k, x_0)$ with two arguments where
  definition 3.13 defined three.
- Case 1 of theorem 3.15's proof writes "$\mathcal{O}(\log(1/\epsilon))$ bits
  for $\epsilon$-precision encoding", using $\epsilon$ for a coordinate
  precision on a page where $\varepsilon$ is the error function.

## Limitation and future-work log (chapter 18)

Paper 26's statement, quoted from the conclusion, p. 55. This is the sixth entry
in the log the chapter 18 open item describes, and the second from a paper that
is not a critique or a survey.

> Several important questions remain open for future research. These include
> investigating the computational complexity of finding optimal explanations,
> developing complexity measures that better align with human cognitive
> processes, extending our approach to more explicitly account for input
> distributions, incorporating causal and counterfactual notions of explanation,
> and exploring dynamic and interactive explanation models. Empirical validation
> of our theoretical predictions represents crucial future work. Initial
> experiments with synthetic data (e.g., fitting simple polynomial functions
> with decision trees of varying complexity) could validate our
> complexity-error trade-off bounds, while studies with real neural networks
> could test whether practical approximation schemes align with our theoretical
> predictions about explainability limits.

Two limitations the paper states inside the body rather than in that paragraph:

- p. 6 (first line of the page): "While Kolmogorov complexity is uncomputable in general, it serves as
  a theoretical foundation and can be approximated for practical model classes
  (Section 3.2)." The bounds are therefore not checkable on a given model and
  explanation; proposition 3.7 substitutes parameter counts for $K$, and calls
  its own argument a proof sketch.
- p. 50: "It may be noted that Theorem 4.6 is a conditional impossibility
  result: it demonstrates that *if* regulators impose certain combinations of
  requirements, *then* mathematical constraints make compliance impossible. The
  theorem does not claim that complex AI is necessary (which would be an
  empirical claim about Nature), nor does it prescribe which requirements should
  be relaxed."

**How this crosses the log.** Papers 21, 22 and 23 name the same blocking
limitation from three directions: measured to fail, recorded as having no
standard, named as the next step not taken. Papers 24 and 25 add the two halves
of the human check. Paper 26 is the first entry that does not name that
limitation at all, and it is the first whose own missing instrument is of a
different kind: it does not want a validated faithfulness metric, it wants a
computable stand-in for $K$ and one experiment. **That is worth recording as a
non-crossing.** The gap chapter 18 inherits is unchanged by this paper, and the
reason is exactly that the paper's object is `độ khớp`. What paper 26 does add
to the log is a bound on where any future instrument can land: whatever a
validated faithfulness metric turns out to measure, it cannot certify a
human-readable explanation of a complex model as having negligible output error,
because theorem 2.23 forbids that independently of any instrument.

## Claims checked against the PDF and found to be the book's own inference

Marked so the prose marks them too. None of these is in the paper.

1. That the paper's $\mathcal{E}$ is the book's `độ khớp` and not `độ trung
   thực`. The paper never uses either word. The identification is the book's,
   argued from definition 2.2 against definition 1.2.
2. That feature attribution scores fall outside definition 2.2 except through
   the surrogate reading. The paper's one mention of attribution, p. 3, is a
   list item in the introduction and it never returns to it.
3. That theorem 2.23 is the same argument as part 2 of the appendix proof of
   theorem 4.6. Verified by reading both: the appendix proof's steps 3 and 4 are
   theorem 2.23 plus definition 2.14 with $k_{human}$ substituted for $K(g)$.
   The paper does not say the two are the same argument; it cites 2.23 from the
   appendix, which is close, but the observation that the trilemma adds no
   mathematics to the ceiling is the book's.
4. That the ceiling is the first result in Part IV that needs no measuring
   instrument. The paper makes no claim about Part IV's subject.

## Numbers this chapter prints

Almost none, by the nature of the paper. The decimals that reach the page are
the numbered results in the table above, the arXiv identifier `2504.20676`
(covered by the single `Numbers.Allow` entry, decision 37), and nothing else. No
score, no proportion, no measurement: **paper 26 reports none.** The integers
that reach the page - 65 pages, one occurrence of `LIME`, zero occurrences of
`faithful`, five model classes in proposition 3.7, three requirements in theorem
4.6 - are counted above and are integers, which the Numbers check does not read.
