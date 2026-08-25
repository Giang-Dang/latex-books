# Chapter 09 - the anchor paper read closely

Date: 2026-08-25. Second note in this folder. Chapter 08 crossed the cliff
(decisions 35 to 37) while printing no decimal of its own; **chapter 09 is the
chapter that prints them**, so this note is where every number on its pages has
to be findable.

The whole of arXiv:2605.25052v1 was read for this chapter: main text pages 1-9
and appendices A through G, pages 18-31. Chapter 08's note
`ch08-cac-ho-chi-so.md` read the same PDF for a different purpose and its
records are not repeated here except where this session corrected one.

## Source pin

| Key | arXiv | Revision read | Pages read | Date |
|---|---|---|---|---|
| `p21metrics` | 2605.25052 | v1, the only revision | 1-9 and 18-31 | 2026-05-24 |

Re-verified on the arXiv abstract page this session: title *Faithfulness
Metrics Don't Measure Faithfulness: A Meta-Evaluation with Ground Truth*,
authors Yoav Gur-Arieh, Ana Marasovic and Mor Geva, submitted 24 May 2026,
submission history showing v1 and nothing after it. The PDF's own stamp reads
`arXiv:2605.25052v1 [cs.CL] 24 May 2026`. Preprint; no venue named.

Read from
`F:\repo\thesis-xai-faithfulness\3-tier-b-critique-core\21_xai-eval_faithfulness-metrics-dont-measure-faithfulness_2026.pdf`.
No orientation note was used for any claim here (decision 13); the note for
paper 21 is one of the dead ones anyway.

## A correction to chapter 08's note

`ch08-cac-ho-chi-so.md` records the LM Judge skyline row of figure 2a as
`0.87 +- 0.02` at step level and `0.82 +- 0.04` at CoT level. **Both margins are
wrong.** Figure 2a on page 7 prints `0.87 ± 0.01` and `0.82 ± 0.02`; the
`± 0.02 / ± 0.04` pair belongs to the row below it, LM Judge (generic), which
reads `0.68 ± 0.02` and `0.67 ± 0.04`. The skyline's margins had been copied up
one row. Chapter 08 prints no decimal so nothing shipped wrong, and the note has
been corrected in place this session. Recorded here because the same table is
transcribed again below and a reader comparing the two notes would otherwise
find a contradiction with no resolution.

## Notation decision this chapter forces

Every decimal below is written with a **period**, and chapter 09's prose prints
them that way too. This is not a style preference. The Numbers check matches
`\d+\.\d+`, so a Vietnamese decimal comma would make every score on the page
invisible to the gate: the check would report clean because it never looked,
which is the exact failure mode the SPEC's `==> policy:` line exists to prevent.
Writing 0.70 also matches the string a reader will search for in the PDF. See
the SPEC decision log.

## Section 2: the definitions the paper rewrites

Quoted exactly. The paper renumbers faithfulness for the CoT setting before it
measures anything, and chapter 09 states both definitions.

- **Definition 1 (CoT Step Faithfulness), p. 3:** \enquote{A CoT step is
  faithful iff it accurately describes a process that took place at some point
  in the model.}
- **Definition 2 (CoT Faithfulness), p. 4:** \enquote{A CoT is faithful iff (1)
  it contains a complete reasoning path the model followed to reach its answer,
  and (2) it contains no unfaithful steps.}

Why the definition had to be rewritten at all, p. 3: the most widely adopted
definition, Jacovi and Goldberg's, is that a faithful explanation
\enquote{accurately represents the reasoning process behind the model's
prediction}, and it \enquote{was designed for methods whose purpose is to
generate a coherent and self-contained explanation of a model's behavior, such
as attention maps and saliency scores}. Contemporary reasoning traces are not
that: they \enquote{can contain many steps not directly linked to the model's
prediction, or even irrelevant to it}.

**This sentence is load-bearing for chapter 09 and worth flagging: the paper
itself names attention maps and saliency scores as what the old definition was
built for.** That is Part II's object. The paper is explicit that it is moving
away from it.

Two readings, p. 3, with the paper's choice and its three reasons:

- *mechanistic reading*: a step is faithful if it accurately describes the
  underlying process that led to the information it produces. This is the one
  adopted.
- *phenomenological reading*: the step would be faithful unless the model
  \enquote{knowingly and deceptively lied}. Rejected because it is
  \enquote{close to unfalsifiable: any statement we know to be false could be
  excused as genuinely believed by the model}; because \enquote{from a safety
  perspective, a false description of the model's internal processes, however
  sincerely believed, is still dangerous and betrays user trust}; and because
  the choice \enquote{parallels the standard in cognitive psychology, where
  false explanations are considered unfaithful to the actual reasoning process
  even when sincerely believed}.

Why a CoT-level definition is needed on top of the step-level one, p. 4, in the
paper's own count of two: \enquote{There are two reasons to need such a
definition. First, step-level labels alone are insufficient: a CoT in which
every step is individually faithful can still misrepresent the model's
reasoning}, the example being a model that follows a hint without mentioning
it; \enquote{Second, the question we ultimately care about - can this model's
reasoning be trusted? - is a CoT-level question.}

Scope limit the paper sets on its own definition, p. 4: bare assertions like
\enquote{Da Vinci painted Starry Night} fall outside its scope, and inert steps
like \enquote{Hmm.} or \enquote{Hold on.} \enquote{introduce no information and
are evaluable for neither}. Also, a step need not describe a computation
executed during its own generation, only \enquote{any computation that took
place at some point in the model}.

Section 2.3 separates faithfulness from two things conflated with it.
Plausibility concerns whether a CoT describes a process the model
\enquote{could have} used; the paper repeats that a convincing post-hoc
rationalization is \enquote{by definition highly plausible}. Importance concerns
whether a step \enquote{causally influenced the model's answer}, and the paper
states the two directions of the gap: a step may faithfully describe a process
that occurred without being causally important (a dead-end exploration), and a
step containing a fabricated justification that the model later conditions on is
causally important but still unfaithful. Conflating them
\enquote{risks treating dead-end explorations as unfaithful, and fabricated
justifications as faithful, inverting the distinction faithfulness evaluation
aims to capture}.

## Section 3: how the ground truth is constructed

The move that answers chapter 08's circularity. Ground truth is not measured
inside the model; it is forced by task design, so that a given output could only
have been produced by a computation that is known in advance.

**Outright setting.** Tasks whose correct answer entails specific intermediate
computations, called *bottleneck steps*: \enquote{intermediate computations that
are necessary for arriving at the correct answer}. Appendix A.1, p. 18: ten
procedurally constructed task types spanning \enquote{arithmetic, number theory,
cryptography, text processing, scientific reasoning, graph traversal, and
logical reasoning}. Table 2, p. 19, names them: `nested_mod`, `collatz`,
`digit_square`, `prime_chain`, `stoichiometry`, `cipher`, `paragraph_analysis`,
`text_extraction`, `tournament`, `graph_traversal`. Parameters and phrasings are
generated procedurally \enquote{to preclude the model from having previously
seen the task}, and answer spaces are \enquote{large enough to make guessing
implausible}. The tasks were constructed by the authors.

What counts as a bottleneck step in two of those tasks, quoted from the same
page because the chapter names both: \enquote{For `collatz`, for instance, the
bottleneck steps are calculating the successive values produced by iterating the
rule (e.g. \enquote{22 -> 11 -> 34 -> 17 -> 52 -> ...}), while for
`graph_traversal` they are the per-edge transition and state-update events.}
The paper also states outright that not every step needs identifying:
\enquote{we do not need to identify every step required to complete each task,
only bottleneck steps that inform our ground-truth labels.}

Validation of the outright setting, p. 5 and appendix A.1 p. 19: the models are
prefilled with an empty CoT and forced to answer directly; over **100** randomly
generated tasks for each of the **10** models they succeed only **1.5%** of the
time.

**Diversionary setting.** A question is paired with a hint pointing to a
*random wrong answer*. If the model answers according to the hint, the hint is
the only reason it could have. A step verbalizing the reliance is faithful; one
attributing the answer to some other source (\enquote{I saw in a history book
that Da Vinci painted Starry Night}) is *misattribution* and unfaithful; a CoT
omitting the hint entirely is unfaithful because it lacks the complete path.
Questions are drawn from Humanity's Last Exam, SimpleQA and DDXPlus, chosen for
being open-ended with large answer spaces rather than multiple choice. The wrong
answers are generated by Gemini 3 Flash, prompted to adopt a different persona
per instance sampled from PersonaHub. Six hint formats, table 3 p. 20:
`sycophancy`, `validator`, `metadata`, `error_message`, `security_audit`,
`unauthorized_access`; one sampled per instance. Hints come in *direct* and
*indirect* variants, the indirect ones being small evaluable expressions such as
\enquote{the answer is len('Lorem ipsum dolor sit amet') + 5}, which
\enquote{introduce additional bottleneck steps that the model must verbalize for
the CoT to count as faithful}.

Two validations of the diversionary setting, appendix A.2, p. 20. A manual pass
over a sample of **100** generated hints found all **100** wrong, not easily
guessable, and plausible. And across **100** questions per model for all **10**
models, the models produce the planted wrong answer without the hint
**0.9%** of the time.

## Section 4: BonaFide

**Models**, appendix B p. 20-21: ten open-weight models from four families,
spanning **4B** to **70B** parameters. Olmo-3-7B-Think, Olmo-3-7B-Instruct,
Olmo-3.1-32B-Think, Olmo-3.1-32B-Instruct, Qwen3-4B-Thinking-2507,
Qwen3-4B-Instruct-2507, Qwen3-30B-A3B-Thinking-2507, Qwen3-30B-A3B-Instruct-2507,
Llama-3.3-70B-Instruct, DeepSeek-R1-Distill-Llama-70B. Footnote 1, p. 6, on why
open weights only: \enquote{most metrics require access to model internals,
while the rest require editing the model's reasoning. The former is impossible
with closed models}.

**Pipeline.** Each CoT is split into sentence-level steps and passed through a
multi-track extraction pipeline, one track per step type, each track running a
two-phase retrieval judge then validation judge. The design
\enquote{prioritizes precision over recall; since these labels serve as ground
truth, false positives are far more costly than missed labels}. Retrieval judge
Gemini 3 Flash, validation judge Gemini 3 Pro, total cost about **$2,100**
(p. 7). Bottleneck steps additionally use an entailment judge, T5 fine-tuned on
the TRUE dataset, taking the top **10** highest-scoring candidate steps per
ground-truth step (appendix C.1, p. 22).

The two judge roles are ranked by the paper itself, appendix C.1 p. 21:
\enquote{we rely on a weaker LLM judge for retrieval, and a stronger LLM judge
for validation}, which is what licenses the chapter to call them weaker and
stronger rather than just naming the two models.

**Six step types**, p. 6, with the setting each belongs to stated there. In the
diversionary setting: (1) hint acknowledgment, \enquote{where the model
acknowledges the existence of the hint}; (2) faithful commitment, \enquote{where
the model commits to answering according to the hint}; (3) misattribution,
\enquote{where the model attributes hint-derived information to a source other
than the hint}. In the outright setting: (4) bottleneck execution, \enquote{where
the model verbalizes a required intermediate computation}. \enquote{In both
settings}: (5) tool call, \enquote{where the model claims to use external tools
that were not available to it (and are therefore unfaithful)}; and (6) inert
steps, \enquote{which do not describe an evaluable internal process and are
therefore not candidates for faithfulness evaluation}. At step level, faithful
commitment and bottleneck execution are labeled faithful; misattribution and
tool call are labeled unfaithful.

**Pipeline precision**, p. 7 and appendix C.2, p. 22-23: six annotators evaluated
**88** labels, split evenly between faithful and unfaithful; a single step was
marked incorrect, giving precision **98.9%**, 95% CI **[96.6%, 100%]**.
Inter-annotator agreement **96.6%**, Gwet's AC1 **0.976**. Gwet's AC1 rather than
Cohen's or Fleiss's kappa because the marginal distribution collapses onto a
single class under this skew and kappa is then \enquote{paradoxically deflated
despite high raw agreement}. A second manual pass over **50** unfaithful CoTs
flagged for a missing ground-truth step found all **50** correctly classified.

**Composition**, p. 7: BonaFide holds **3,066** CoTs, roughly **4M** tokens,
across **10** models and **13** tasks. **1,946** step-level labels, **51%**
faithful and **49%** unfaithful; **1,120** CoT-level labels, **15%** faithful and
**85%** unfaithful. Step-label breakdown, table 10 p. 28: misattribution **901**,
bottleneck execution **573**, faithful commitment **428**, tool call **44**.
The unfiltered pool released alongside holds **19,459** labels over **9,302**
unique chains: **7,109** faithful steps, **5,707** unfaithful steps, **168**
faithful CoTs, **6,475** unfaithful CoTs.

## Section 5: the eight metrics and the results

The eight, with the paper's four tags. IMP importance-based: Adding Mistakes,
Early Answering, Filler Tokens, SCM. SEM semantic-utility: Paraphrasing,
Simulatability. PAR parameter-based: FUR. ATT attribution-based: CC-SHAP. The
paper attributes Early Answering, Adding Mistakes, Filler Tokens and Paraphrasing
to Lanham et al.; SCM to reference [48]; FUR to Tutek et al.; CC-SHAP to
Parcalabescu and Frank; Simulatability to [10, 60]. **The paper prints no formula
for any of the eight**; all are described procedurally, which chapter 08 already
recorded and this session re-confirmed across appendix D.

### What each metric actually does, appendix D.1, pp. 24-25

Recorded because appendix B of the book gives each of these a one-line
description and those lines need an anchor. All procedural; still no formulas.

- **Early Answering** \enquote{truncates the CoT at successive prefixes and, for
  each, measures how often the model still arrives at the full-CoT answer, with
  the score given by the area over the resulting curve}.
- **Adding Mistakes** \enquote{analogously injects a mistake at sampled step
  positions, generated via Gemini 3 Flash, regenerates the rest of the CoT from
  each, and reports the area over the answer-preservation curve}.
- **Filler Tokens** \enquote{replaces the entire CoT with an uninformative
  sequence of repeated tokens (e.g., dots), sweeping over a range of lengths,
  and reports answer preservation across them}. Note the length detail: the
  sweep is over a *range* of lengths at CoT level, and only the step-level
  adaptation splices \enquote{filler tokens of matching length in place of just
  that step}. A book line saying \enquote{same length} states the step-level
  adaptation as though it were the metric.
- **SCM** \enquote{applies causal mediation analysis to the triple of question,
  CoT, and answer, independently corrupting each and isolating the indirect
  effect that flows through the CoT}. Originally a dataset-level metric, adapted
  here to per-instance.
- **FUR**, \enquote{short for Faithfulness via Unlearning Reasoning steps},
  \enquote{performs a localized unlearning update that suppresses the
  information conveyed by that step from the model's weights, then re-runs the
  model on the original input to measure the change in the answer distribution}.
- **CC-SHAP** \enquote{computes two SHAP-based contribution distributions over
  the input tokens, one for generating the answer and one for generating the
  CoT, and scores faithfulness by the similarity between them}.
- **Simulatability** \enquote{provides the CoT as additional context to a weaker
  simulator model and tests whether the simulator can reproduce the original
  model's answer}.
- **Paraphrasing** \enquote{paraphrases progressively longer prefixes of the CoT
  while preserving their semantic content, re-runs the model from each
  paraphrased prefix, and checks whether the final answer is preserved}.

FUR expands, p. 24, as \enquote{Faithfulness via Unlearning Reasoning steps}.
**No expansion of SCM appears anywhere in the paper**, so the book gives it none,
on the ERASER precedent already written into appendix C's header comment.

Two reference rows, p. 7-8. Random assigns labels at chance. LM Judge (generic)
is an LLM prompted as a generic CoT monitor without the paper's definitions;
LM Judge with the paper's definitions is reported as a **skyline, not a competing
method**, because \enquote{our dataset was constructed using LM-based pipelines
that operate on the same data, an LM judge has access to the same signal used to
produce the ground-truth labels}.

### AUROC, figure 2a, p. 7

Caption: \enquote{AUROC ± 95% DeLong margin per metric}. An em dash in the
paper's table means that variant was not run at that level. Transcribed exactly,
and this table is the one chapter 09 prints.

| Tag | Metric | Step | CoT |
|---|---|---|---|
| IMP | Adding Mistakes | 0.51 ± 0.02 | 0.51 ± 0.04 |
| IMP | Early Answering | 0.51 ± 0.01 | 0.45 ± 0.03 |
| IMP | Filler Tokens | 0.59 ± 0.01 | 0.50 ± 0.02 |
| IMP | SCM | not run | 0.38 ± 0.03 |
| SEM | Paraphrasing | not run | 0.61 ± 0.03 |
| SEM | Simulatability | not run | 0.50 ± 0.01 |
| PAR | FUR | 0.52 ± 0.02 | not run |
| ATT | CC-SHAP | 0.41 ± 0.03 | 0.70 ± 0.04 |
| SKY | LM Judge | 0.87 ± 0.01 | 0.82 ± 0.02 |
| BASE | Random | 0.5 ± 0 | 0.5 ± 0 |
| BASE | LM Judge (generic) | 0.68 ± 0.02 | 0.67 ± 0.04 |

The two best figures are bolded in the paper: Filler Tokens **0.59** at step
level and CC-SHAP **0.70** at CoT level. Surrounding text, p. 8:
\enquote{The strongest performer at the CoT level is CC-SHAP (0.70), while at the
step level it is Filler Tokens (0.59). Notably, even these relative successes do
not transfer across settings: CC-SHAP drops to below random at the step level,
and Filler Tokens is near chance at the CoT level.}

The number that carries the chapter's title, from the abstract p. 1:
\enquote{The best metric reaches only 0.70 AUROC at the CoT level while another
reaches 0.59 at the step level, with neither transferring across settings, while
entailing prohibitively high computational cost.}

### Prediction skew, cost, agreement, length

- Skew, abstract p. 1-2 and figure 3 p. 8, on a label-balanced subset with 0.5 as
  the threshold: importance-based metrics predict unfaithful for **90%** to
  **96%** of instances at CoT level; semantic-utility metrics predict faithful
  for **94%** to **96%**.
- Cost, p. 2 and figure 2b p. 7: CC-SHAP requires up to **10^3** seconds per
  instance. A CoT-level FUR variant was **not run at all**, at an estimated
  \enquote{up to 10^5 seconds per CoT (over an entire day)} (p. 25).
- Inter-metric agreement, figure 7 p. 28, Cohen's kappa. Most near 0; at CoT
  level the highest is **0.35** between Adding Mistakes and Early Answering; at
  step level the highest is **0.12**, between Early Answering and Filler Tokens.
  Text p. 28: agreement \enquote{caps at 0.35, showing that they measure
  different properties}.
- Length, figure 3 right panel p. 8: most importance-based metrics lose accuracy
  as CoTs get longer. Per-dataset skew against length, appendix figures 5 and 6,
  \enquote{show no consistent trend, leaving this an open question} (p. 9).

### The paper's own diagnosis, and the evidence under it

Two conjectured factors for the unfaithful bias of importance-based metrics,
p. 8-9. First, \enquote{they conflate importance with faithfulness, potentially
labeling as unfaithful a faithful step that is not critical for the final
answer}. Second, \enquote{since they perturb individual steps and measure the
effect on the answer, their signal might weaken as CoTs grow longer and any
single step constitutes a smaller fraction of the context}.

The direction that second factor points in is the paper's claim too, p. 8, and
the chapter leans on it: \enquote{Both effects are compounded by the trend
toward longer CoTs in modern reasoning LLMs, underscoring the need for
faithfulness metrics that are not only more accurate but also more efficient.}
Do not confuse this with the separate open question recorded below: that one is
about whether the *skew* moves with CoT length within the benchmark
(appendix figures 5 and 6, \enquote{no consistent trend}), not about whether
CoTs are getting longer over time.

The evidence offered for the first, **table 5 p. 25**, step-level skew on
faithful steps only, split by task setting. Lower is better here: these are all
faithful steps, so an unfaithful prediction is an error. In the outright setting
faithful steps are also causally necessary, so a metric that conflates the two
should do better there. Four of the five move that way, but only two move far
enough to mean anything: Filler Tokens by 35 points and Adding Mistakes by 19,
against 5 for FUR and 1 for Early Answering. CC-SHAP moves 40 points the other
way. So the table supports the conjecture for two metrics, is near-silent for
two, and contradicts it for one, which is why both the paper and the chapter
present it as a conjecture with partial evidence rather than a result. An
earlier draft of this line said \enquote{three of the five} and did not
separate the two negligible deltas from the two real ones.

| Tag | Metric | Outright | Diversionary | Delta |
|---|---|---|---|---|
| IMP | Adding Mistakes | .70 ± .04 | .89 ± .03 | -.19 |
| IMP | Early Answering | .95 ± .02 | .96 ± .02 | -.01 |
| IMP | Filler Tokens | .62 ± .04 | .97 ± .01 | -.35 |
| PAR | FUR | .72 ± .04 | .77 ± .04 | -.05 |
| ATT | CC-SHAP | .91 ± .02 | .51 ± .04 | +.40 |

Table 6, p. 26, step-level skew on a label-balanced sample split by model type,
which is the evidence for the length and reasoning-model claim: Adding Mistakes
.74 ± .03 non-reasoning against .87 ± .02 reasoning (+.13); Early Answering
.95 ± .01 against .98 ± .01 (+.03); Filler Tokens .89 ± .02 against .89 ± .02
(+.01); FUR .66 ± .03 against .87 ± .02 (+.21); CC-SHAP .69 ± .03 against
.62 ± .03 (-.06).

Semantic-utility metrics get the opposite diagnosis, p. 9: \enquote{even
unfaithful CoTs typically contain enough verbalized reasoning to convey the
answer. A plausible-sounding but fabricated justification will still allow a
weaker model to reproduce the answer or yield the same answer after
paraphrasing.}

**Omission against commission**, appendix E p. 27 and appendix F p. 29. Of the
unfaithful CoTs, **48.2%** fail by omission only (no complete reasoning path),
**37.2%** by commission only (an unfaithful step present), and **14.6%** by both.
Figure 9 right panel, p. 30, splits it: non-reasoning models **292** (**59.1%**)
omission only, **94** (**19.0%**) commission only, **108** (**21.9%**) both;
reasoning models **167** (**36.5%**) omission only, **260** (**56.8%**) commission
only, **31** (**6.8%**) both.

### Implementation validation, table 4 p. 25

The paper's own check that its reimplementations reproduce published values.
Reference against reproduced, with the paper's stated difference in percentage
points: Early Answering **27%** against **26.5%** (-0.5); Filler Tokens **27%**
against **26.0%** (-1.0); Adding Mistakes **18%** against **27.1%** (+9.1);
Paraphrasing **71%** against **75.4%** (+4.4); CC-SHAP **13%** against **11.0%**
(-2.0). The paper explains the Adding Mistakes gap as an implementation
difference rather than an error: the reference reimplementation
\enquote{uses a fundamentally different procedure (single-word antonym
substitution rather than sentence-level mistake injection followed by
continuation, as in the original formulation), so the +9.1pp gap reflects an
implementation difference rather than a discrepancy in our code}. CC-SHAP was
validated at **0.11** against the paper's reference value of **0.13**.

Hardware, appendix G p. 29: \enquote{All experiments were run on an Nvidia H100
node, or an AMD MI325X node.}

### Relation to prior findings, p. 9

Four results, two confirmations and two divergences, all worth the chapter's
space because they are what a meta-evaluation is for.

- Confirms that importance-based metrics systematically overestimate
  unfaithfulness.
- Replicates that metric performance \enquote{does not scale clearly with model
  size}.
- Diverges on which metrics work: \enquote{While prior benchmarks have reported
  stronger performance from importance-based metrics, we find them to be among
  the weakest, with attribution-based CC-SHAP standing out as the strongest
  CoT-level metric.}
- Diverges on task difficulty: it does **not** find faithfulness detection harder
  in knowledge-intensive domains, contrary to Shen et al. And on Chen et al.'s
  report that reasoning models and longer CoTs are more faithful, it finds this
  \enquote{holds only for omission-type unfaithfulness, such as failing to
  mention a hint, which is simply overtaken by commission-type unfaithfulness,
  such as misattribution}.

## Limitations and future work

Paper 21's limitation set is already logged in `ch08-cac-ho-chi-so.md` under the
SPEC's chapter 18 open item, verified against p. 9 of the same PDF, and is not
duplicated here. Two items this session adds to that log, both from the
appendices rather than the limitations paragraph:

- The CoT-level FUR variant was omitted for cost, so the benchmark reports no
  number at all for one metric-level pair it set out to cover (p. 25).
- The LM Judge skyline is not a competing method and cannot be read as one, by
  the authors' own argument that it shares the signal that produced the labels
  (p. 8). A reader who takes 0.87 as evidence that LLM judges solve the problem
  is reading against the paper.

## Verified negatives

Kept so no later session re-checks them.

- **The paper prints no formula for any of the eight metrics.** Re-confirmed
  across appendix D.1-D.2, pp. 24-26, which is where a formula would be if there
  were one. A draft stating one \enquote{from} this paper would be inventing it.
- **SCM is never expanded** anywhere in the 31 pages.
- The paper does not evaluate any feature-attribution faithfulness metric. Chapter
  08's note establishes this by full-text search for deletion, insertion,
  comprehensiveness, sufficiency, ROAR, sensitivity-n, infidelity and
  monotonicity; this session's full read of the appendices found no such metric
  there either. CC-SHAP uses SHAP as an instrument, over input tokens, but scores
  a CoT rather than scoring an attribution.

## AUROC, and why appendix C may expand it

Appendix C's header rule is that an expansion is verified against a source, not
remembered, which is why ERASER sits in appendix B instead. AUROC clears that
bar by a different route than paper 21, which uses the abbreviation without ever
expanding it. The confidence intervals in figure 2a are DeLong intervals, and
the paper's reference [59] for them is DeLong, DeLong and Clarke-Pearson,
\enquote{Comparing the areas under two or more correlated receiver operating
characteristic curves: a nonparametric approach}, *Biometrics* 44:837-845, 1988 -
verified this session, and the source of the expansion *area under the receiver
operating characteristic curve*. That paper is not added to `refs.bib`: the book
cites nothing to it, and a source read only to pin one expansion does not belong
in a bibliography, on the precedent chapter 08's note set for the two robustness
papers.

## Methodology note

The PDF was read page-by-page as rendered images rather than through text
extraction, so every number above was read off the typeset table it appears in.
That is the right way round for this paper, whose results live almost entirely in
figures and tables, and it is how the skyline transcription error in chapter 08's
note was caught: extraction had put a row boundary in the wrong place, and the
rendered table shows the alignment directly.
