# Chapters 01-13 - the reading-flow revision

Date: 2026-09-05. Seventh note in this folder. Unlike the others it is not a
note for one chapter: it is the working record of a revision pass across
chapters 01 to 13, whose object is the reading path rather than a new paper. It
carries three kinds of entry.

1. **The worked examples the revision adds.** Chapters 01, 03, 04, 05 and 08 had
   no example a reader could compute end to end, and chapters 09, 11, 12 and 13
   had claims stated without the arithmetic under them. Every decimal those
   examples print is derived here, because the Numbers check reads each one and
   asks where it came from.
2. **One defect in paper 26 that the chapter 13 session did not catch**, in the
   proof of the theorem the chapter prints as theorem 13.4, together with the
   replacement argument the book gives instead.
3. **Two arithmetic defects in the book's own reading of paper 25** in chapter 12.

Numbers are recorded as computed. Where a value is exact it is given as a
fraction and the decimal the book prints beside it.

## How the examples were computed

Python 3.13 with `fractions.Fraction` for the exact linear algebra and `sympy`
1.13 for the symbolic Shapley values, run 2026-09-05. Exact rationals throughout;
no floating-point value is printed in the book that was not first obtained as a
fraction. These are hand-checkable illustrations, not runs of any XAI library -
no LIME, SHAP, or Captum implementation was invoked, and the book says so where
it prints them.

---

## E1. The example that runs through chapters 01, 03, 04, 05 and 08

The function is `f(x1,x2) = x1 + 2*x2 + x1*x2` on `{0,1}^2`, explained at
`x = (1,1)` against baseline `x0 = (0,0)`; masking a feature sets it to 0. The
four masks are the whole illustrative set, not a random sample.

| mask z | f(z) | squared distance to (1,1) | LIME weight |
|---|---:|---:|---:|
| (0,0) | 0 | 2 | 1/4 |
| (1,0) | 1 | 1 | 1/2 |
| (0,1) | 2 | 1 | 1/2 |
| (1,1) | 4 | 0 | 1 |

The weights are the exponential kernel `exp(-D^2/sigma^2)` with Euclidean `D`
and `sigma^2 = 1/ln 2`, which makes `exp(-2 ln 2) = 1/4` and `exp(-ln 2) = 1/2`.
That value of sigma is chosen so the weights come out as halves and quarters; it
is an illustrative configuration, not LIME's default, and the chapter says so.

### Chapter 03 - the weighted fit

Surrogate `g(z) = w1*z1 + w2*z2`, no intercept, matching the chapter's existing
pseudo-code. The mask (0,0) contributes nothing to either normal equation
because both regressors vanish there. Normal equations, multiplied through by 2:

```
3*w1 + 2*w2 = 9
2*w1 + 3*w2 = 10
```

Solution `w1 = 7/5 = 1.4`, `w2 = 12/5 = 2.4`. Then `g(1,1) = 19/5 = 3.8`, which
is **not** `f(1,1) = 4`: the local surrogate is not required to reproduce the
model at the point being explained, and this is the number that shows it.
Weighted sum of squared errors `= 1/5 = 0.2`.

Adding an intercept changes the solution, so the chapter must keep the
no-intercept form it already uses.

**The chapter 03 review question uses the same example with a narrower kernel.**
With `sigma^2 = 1/(2*ln 2)` the kernel becomes `4^(-D^2)`, so the four weights
are `1`, `1/4`, `1/4`, `1/16`. Normal equations, multiplied through by 4:

```
5*w1 + 4*w2 = 17
4*w1 + 5*w2 = 18
```

giving `w1 = 13/9` and `w2 = 22/9`, against `7/5` and `12/5` at the original
width. Both coefficients rise while `f` is unchanged, which is the point of the
question. Computed with exact rationals in the same session as the rest of E1.

### Chapter 04 - Shapley on the baseline game

`v({}) = 0`, `v({1}) = 1`, `v({2}) = 2`, `v({1,2}) = 4`.

```
phi_1 = (1/2)(1 - 0) + (1/2)(4 - 2) = 3/2
phi_2 = (1/2)(2 - 0) + (1/2)(4 - 1) = 5/2
phi_1 + phi_2 = 4 = f(1,1) - f(0,0)
```

This is the baseline (interventional) game, chosen and stated as such; it is not
conditional SHAP and the chapter must not let the two merge.

### Chapter 05 - Integrated Gradients

Straight path `(alpha, alpha)` from `(0,0)` to `(1,1)`. Gradient along it is
`(1 + alpha, 2 + alpha)`.

```
IG_1 = int_0^1 (1 + alpha) d(alpha) = 3/2
IG_2 = int_0^1 (2 + alpha) d(alpha) = 5/2
sum = 4, which equals f(x) - f(x0): completeness holds here.
```

The plain gradient at `x = (1,1)` is `(2, 3)`, summing to 5, which does **not**
equal the output difference 4. The two objects answer different questions; the
gradient is not miscomputed. IG coincides with the Shapley values of chapter 04
in this example - that is a property of this function with this path and this
baseline, not a general equivalence theorem, and the chapter says so.

### Chapter 08 - deletion curves

Rank feature 2 above feature 1, delete in rank order, record the output:
outputs `4, 1, 0`. The reverse order gives `4, 2, 0`. With the horizontal axis
the fraction of features deleted (`0, 1/2, 1`) and the trapezoid rule:

```
order (2 then 1):  (4+1)/2 * 1/2 + (1+0)/2 * 1/2 = 1.5
order (1 then 2):  (4+2)/2 * 1/2 + (2+0)/2 * 1/2 = 2.0
```

Raw AUC, not normalised by the original output. If the chapter chooses to
normalise it must divide explicitly and record the resulting values; the default
for this example is raw.

## E2. Two surrogates agreeing on the data support

`f(x1,x2) = x1`, data supported only where `x1 = x2`. Both `g1 = x1` and
`g2 = x2` fit perfectly on that support with different coefficients. Allowing an
intervention on `x2` independent of `x1` separates them. No decimals.

The example refutes exactly one inference: from "two explanations differ" to "at
least one fits the data badly". It does not license the opposite claim that both
are faithful under every intervention.

## E3. AUROC of 1 with every label wrong at threshold 0.5

| true label | score |
|---|---:|
| positive | 0.4 |
| positive | 0.3 |
| negative | 0.2 |
| negative | 0.1 |

Four positive-negative pairs, all four ranked correctly, no ties, so
`AUROC = 4/4 = 1`. A 0.5 threshold labels all four negative, giving 2 of 4
correct. Ranking and thresholding are different readings of the same scores.
Used only to separate the two notions; it does not touch any measured value from
paper 21.

## E4. One wrong point against average error

Domain `{a,b}`, `f(a) = 0`, `f(b) = 1`, `g(a) = g(b) = 0`,
`P(a) = 1 - epsilon`, `P(b) = epsilon`.

```
expected absolute error = (1-epsilon)*0 + epsilon*1 = epsilon
worst-case error        = max(0, 1) = 1
```

Taking epsilon as small as we like shows a large worst-case error does not force
a large average error. At `epsilon = 0` the expected error is 0 while the two
functions still differ at a point outside the support, which is why the
distribution has to be named whenever an expected error is quoted. No decimals.

## E5. Serial attribution and Meta-SV in chapter 11

Chapter 11's own function and baseline: `f = x1 + T` with `T = x1*x2^2`,
baseline at the origin, masking to 0. Symbolic Shapley, verified with sympy.

First-order values:

```
phi_1 = x1*(x2^2 + 2)/2 = x1 + T/2
phi_2 = x1*x2^2/2       = T/2
```

Applying Shapley a second time to `phi_1` treated as a function of the same two
features:

```
psi_1 = x1*(x2^2 + 4)/4 = x1 + T/4
psi_2 = x1*x2^2/4       = T/4
```

So `T/4` of the interaction has leaked into the second-level attribution of
feature 2, and that is the quantity the reader is asked to derive. At
`x = (1,1)`, `T = 1`, so `psi_1 = 5/4 = 1.25` and `psi_2 = 1/4 = 0.25`.

Meta-SV on the same function splits the effect differently: own effects `x1` and
`0`, and two interaction halves `T/2` and `T/2`, giving `1` and `0.5` at
`x = (1,1)`. The ground truth here is ground truth **by construction of the
example**, because the polynomial's own terms name the interaction; it is not a
measurement.

---

## Paper 26, theorem 3.4: the proof does not prove the statement

This is new. The chapter 13 session recorded three places where paper 26 does not
support itself, and the 2026-09-04 cold audit found a fourth (remark 3.5). None
of them looked at the proof of theorem 3.4 itself, which
`research/ch13-gioi-han-ly-thuyet.md` describes as "a valid lower bound". The
statement is defensible. **The paper's proof of it is not.**

Read from the rendered pages, not from `pdftotext`, for the reason the chapter 13
note records: pages 22, 23, 24 and 25 of
`26_xai-theory_limits-of-ai-explainability-ait_2025.pdf` (arXiv:2504.20676v2),
rendered at 130 dpi with `pdftoppm` on 2026-09-05.

### What the paper says

Theorem 3.4, p. 22, verbatim:

> **Theorem 3.4** (Lower Bound for Lipschitz Functions). *For any dimension*
> `d >= 1`, *Lipschitz constant* `L > 0`, *and complexity threshold* `k` in `N`,
> *there exists an L-Lipschitz continuous function* `f : [0,1]^d -> R` *such that
> for any explanation* `g` *with* `K(g) <= k`: `E_inf(f,g) = Omega(L * 2^(-k/d))`.

The proof, pp. 22-23, opens:

> By Lemma 2.9, any function `g` with `K(g) <= k` is one of at most `2^(k+1) - 1`
> possible functions. Such a function can partition `[0,1]^d` into at most
> `2^(k+1)` distinct regions (corresponding to different output values).

then applies pigeonhole to get a region of volume at least `2^-(k+1)`, the
isoperimetric inequality to get diameter at least `c_d * 2^(-(k+1)/d)`, and
builds `f` to vary by `L*D` across that region.

### Two independent defects

**1. The region count does not follow.** `2^(k+1)` counts the *functions* whose
Kolmogorov complexity is at most `k`. It says nothing about how many level sets
any one of them has. The identity `g(x) = x` has `K(g) = O(1)` and a continuum of
distinct output values on `[0,1]`; a budget of `k` bits does not make a function
piecewise constant with `2^(k+1)` pieces. The proof's later step, "since `g` must
assign a constant value to this entire region (by definition of a piecewise
function with `2^(k+1)` pieces)", inherits the same assumption. Note the same
`2^(k+1)` is used *correctly* elsewhere in the paper - in the random-Boolean
argument it bounds the number of candidate `g` in a union bound, which is what
Lemma 2.9 actually gives. The defect is the reuse of that count as a partition
count.

**2. The quantifier order is inverted.** The theorem asserts *there exists* `f`
such that *for all* `g` in the budget the error is large. The proof fixes `g`
first ("Now we construct function `f`"), then builds `f` from the region `g`
happens to induce and from that region's diameter `D`. That establishes
"for all `g` there exists `f`", which is weaker and does not give the theorem.

### The replacement the book gives

A packing argument, elementary and self-contained, using only the count that
Lemma 2.9 does supply. It is the same "there are too few short programs" idea the
chapter already uses in section 13.3, so it costs the reader no new machinery.

Fix `m`, and split `[0,1]^d` into `m^d` cells of side `1/m`. In each cell `c` put
a cone-shaped bump of height `h = L/(2m)`:

```
phi_c(x) = max(0, h - L * dist(x, centre of c))
```

Each bump is `L`-Lipschitz, and its support is the ball of radius `h/L = 1/(2m)`
about the cell centre, which fits inside the cell, so the supports are disjoint.
For every sign vector `s` in `{-1,+1}^(m^d)` set `f_s = sum_c s_c * phi_c`. Each
`f_s` is `L`-Lipschitz, and two of them that differ in cell `c` differ by `2h =
L/m` at that cell's centre, so

```
|| f_s - f_s' ||_inf >= L/m  whenever s != s'
```

There are `2^(m^d)` such functions. Now suppose every `L`-Lipschitz function were
approximable to within `delta` by some `g` with `K(g) <= k`. If one `g` served
both `f_s` and `f_s'`, then `|| f_s - f_s' ||_inf <= 2*delta`; so as long as
`2*delta < L/m`, distinct sign vectors need distinct `g`. Taking
`delta <= L/(3m)` gives an injection from `2^(m^d)` functions into at most
`2^(k+1)` programs, hence

```
m^d <= k + 1
```

Choosing `m = floor(L/(3*delta))` turns that into a statement about the budget:
some `L`-Lipschitz `f` has

```
kappa_f(delta) >= floor(L/(3*delta))^d - 1 = Omega((L/delta)^d)
```

equivalently, at budget `k` the best achievable worst-case error over the class is

```
Omega(L * k^(-1/d))
```

The quantifier order is now right: the counting shows directly that *some* `f` in
the packed family defeats *every* `g` in the budget.

### What this changes in the chapter, and in the decision log

The consequence is not cosmetic, and it runs against what section 13.4 currently
concludes.

- `Omega(L * k^(-1/d))` is a **stronger** bound than theorem 3.4's
  `Omega(L * 2^(-k/d))`, since `k^(-1/d)` is far larger than `2^(-k/d)`. So
  theorem 3.4 as *stated* is true - it follows from the packing bound - while
  being much weaker than what counting actually gives. The book keeps the
  statement and drops the paper's proof.
- Theorem 3.2's upper bound is
  `kappa_f(delta) = O((L/delta)^d * log(L/delta))`, i.e. error
  `O(L * k^(-1/d) * log^(1/d))` at budget `k`. Against the packing lower bound
  `Omega(L * k^(-1/d))`, **the two bounds match in the exponent**, and differ by
  a factor of `log^(1/d)`.
- Therefore the chapter's present conclusion - that the curse of dimensionality
  here "is a property of the grid construction and not something proved
  unavoidable" - is **wrong**, and so is the reading that the lower bound only
  demands `Omega(d log(L/delta))` bits. Counting demands `Omega((L/delta)^d)`
  bits. The exponential dependence on `d` is intrinsic to the problem.
- Remark 3.5's *conclusion* (that the bounds match, and that the exponential
  dependence cannot be avoided in general) is therefore essentially correct, up
  to a logarithmic factor rather than "up to constants". What is wrong is the
  route: it is read off theorem 3.4, which is far too weak to support it, and
  proposition 3.6's `N ~ 2^k` step is a genuine error, exactly as decision 62b
  records. **A right conclusion drawn from a wrong derivation is still a wrong
  derivation, and the book's own rebuttal of the conclusion was the overcorrection.**

Decision 62b stands as to proposition 3.6 and as to the draft having printed the
paper's claim unattributed. Its third clause - that the bounds are nowhere near
each other and that the curse is an artefact of the construction - is superseded
by a new decision row, with this derivation as its evidence.

Two things this does **not** license. It does not make corollary 3.8 valid;
decision 62's first instance is untouched, and the chapter still declines it. And
it does not turn the book into the paper's proofreader beyond what it prints: the
packing argument is given as the book's own reasoning, in a reading-critically
passage, not as something the paper contains.

---

## Chapter 12, paper 25: two defects in the book's own reading

Both are in the manuscript, not in the paper, and both were found by re-reading
the chapter against its own stated scale direction.

### 1. The correlation signs are glossed backwards

Section 12.5 states the scale explicitly: a four-point Likert item running from
1, "Definitely Yes", to 4, "Definitely No", and the chapter adds "1 is the most
positive answer, so smaller is better".

Section 12.6 then reports that on Mushroom, sparsity, diversity, proximity and
closeness correlate **negatively** with the detail, satisfaction and combined
scores, coefficients from -0.38 to -0.64, and glosses this as users preferring
explanations that change *fewer* features.

With 1 as the best score, a negative correlation means a *higher* metric value
goes with a *lower*, i.e. better, rating. The gloss states the opposite of what
the sign says. The positive-coefficient gloss for Obesity Levels has the mirror
image of the same error.

**Checked against the paper, 2026-09-05.** Pages 6, 7, 9 and 10 of
`25_xai-eval_counterfactual-metrics-vs-user-perception_2026.pdf`
(arXiv:2603.15607v1) rendered with `pdftoppm` at 150-300 dpi and read as images;
`pdftotext` was used only to find the pages, and it visibly corrupted the plus-
minus sign, which is why the numbers below were taken from the renders.

The result is worse than a book-side slip: **the paper contradicts itself.**

- Page 6, verbatim: "Participants rated each explanation along five dimensions by
  answering the corresponding question using a 4-point Likert scale
  (1=Definitely Yes, 4=Definitely No, plus I don't know)". So 1 is the favourable
  end and a lower number is a better rating.
- Page 10, verbatim, on Mushroom: "several metrics [...] are moderately to
  strongly negatively correlated with sufficiency of detail, satisfaction, and
  CQS (r = -0.38 to -0.64). This suggests that users in this domain prefer CFs
  involving fewer and smaller changes." Read against the page 6 coding, a
  negative `r` means a higher metric value goes with a *lower*, i.e. more
  favourable, rating: the opposite of "prefer fewer changes". The Obesity Levels
  gloss ("positively correlated [...] indicates a preference for more
  comprehensive or information-rich explanations") is wrong in the mirror way.
- **The paper never states a reverse-coding or scoring convention.** Searched for
  `revers`, `invert`, `recod`, `coding`, `flipped`, `sign convention`, `lower/
  higher value indicates`. The only "flipped" is about a counterfactual's
  predicted class. There is also no code or data availability statement, so the
  scoring actually used in the correlation cannot be checked outside the paper's
  own words.

So the two glosses only stand if the ratings were reverse-coded before
correlating, and nothing in the paper says they were. The chapter therefore
attributes both readings to the paper, states that they do not agree with the
paper's own stated scale, and records the direction of user preference as not
determined by what the paper prints. The book does not pick a coding.

What survives untouched is the section's actual conclusion. The sign *flip*
between datasets, and the 0.31 cross-dataset standard deviation built on it, are
invariant to the coding convention as long as one convention is used throughout,
so the argument the chapter runs on them is unaffected.

Correlation values re-read from figure 1, p. 10, and used to confirm the two
ranges the chapter prints. Mushroom, columns Acc./Und./Plaus./Suff./Sat./CQS:
sparsity `0.03, -0.20, -0.21, -0.62*, -0.47*, -0.38*`; diversity
`-0.16, -0.16, -0.20, -0.52*, -0.53*, -0.41*`; proximity same as sparsity;
closeness `-0.10, -0.21, -0.34*, -0.64*, -0.53*, -0.47*`. The chapter's "-0.38
to -0.64" is the range over the starred cells and is correct. Obesity Levels
gives diversity `0.37*` on CQS, Trust Score `0.52*` on satisfaction and
Completeness `0.38*` on CQS, so the chapter's "0.37 to 0.52" is correct.
Cross-dataset aggregate, p. 9: "Only trust score shows a statistically
significant association with the CQS [...] (r = 0.307, p = 0.004)". Confirmed.

### 2. "2.10 lies between the two most positive levels" is false on a 1-4 scale

Section 12.5 prints a mean combined score of 2.10 with standard deviation 0.22
and reads it as sitting between the two most positive response levels. On a
scale where 1 is best, 2.10 lies between levels 2 and 3. The two most positive
levels are 1 and 2. The number is the paper's; the reading is the book's, and it
is the reading that is wrong.

**Checked 2026-09-05.** Table 2, p. 7, "All" row, CQS column reads `2.10 ± 0.22`,
confirmed digit by digit from the render, so the value the chapter prints is
right. The paper offers no gloss on it anywhere: it is introduced only as the
dependent variable ("We therefore aggregate them into a single Combined Quality
Score (CQS) by averaging the five ratings per explanation, used in subsequent
analyses"), and neither the discussion (p. 12) nor the conclusion (p. 13) says
whether 2.10 counts as a favourable result. The chapter now states the value,
places it correctly between levels 2 and 3, and says the paper draws nothing
from it.

Sample structure, also confirmed from the renders: 167 participants after one
exclusion for failed attention checks (p. 6), 85 counterfactuals split 30 MUS /
30 OBE / 25 HRT (p. 5), 2004 individual ratings and "a mean of 23.58 (SD = 2.57)
complete rating sets per explanation" (p. 7). Every one of those figures in the
chapter is correct as printed.

---

## Status

Entries above are the derivations. Where an entry says a source still has to be
checked, it has not been checked yet at the time of writing and the manuscript
must not print a claim that depends on it until it has.
