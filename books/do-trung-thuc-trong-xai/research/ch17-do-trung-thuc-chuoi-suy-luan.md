# Chapter 17 - the faithfulness of chuỗi suy luận

Date: 2026-09-06. Tenth chapter note in this folder, one per chapter from
chapter 08 on (decision 35), and the third outside Part IV.

**One new corpus paper, paper 16, and one key from outside the corpus.** The
chapter also re-reads papers 06, 08 and 21, each of which an earlier chapter read
for a different question, which is chapter 16's method used a second time
(decision 82). The re-reading earned its keep here too: the single sharpest
finding in the chapter is a sentence in paper 08's figure 27, on p. 76 of a
103-page survey that chapter 02 read for its section 3 alone.

**The chapter's own claim, and it is the book's:** the Part IV critique was not
transferred to chuỗi suy luận. It started there. Section 9.7 already says so on
the page, in the book's own words, and no session had read that sentence as a
statement about the direction of the transfer.

## Source pins

| Key | arXiv | Revision read | Pages | First read by | Status of the record |
|---|---|---|---|---|---|
| `p06cot` | 2201.11903 | v6, the latest of six | 43 | chapter 02 | re-verified; no correction |
| `p08periodic` | 2606.11470 | **v1, and v2 now exists** | 103 | chapter 02 | see the note below |
| `p16llmxai` | 2504.00125 | v1, the only one | 18 | **this chapter** | seeded entry needed no correction |
| `p21metrics` | 2605.25052 | v1, the only one | 31 | chapters 08, 09, 16 | re-verified; no correction |
| `mcotfaith` | 2307.13702 | v1, the only one | - | **this chapter, from outside the corpus** | new entry |

Records were verified twice this session, against `https://arxiv.org/abs/<ID>`
and against `http://export.arxiv.org/api/query?id_list=<ID>`. **The API answered
this time**, which is the first session since chapter 14 where it did; chapters
15 and 16 both had to fall back to the abstract pages alone. Both sources agree
on every field recorded here.

### Paper 08 has a v2 the book has not read, and the book cites v1

This is the first time in the book that a cited revision is no longer the latest,
so it is recorded in full rather than in passing.

- v1: Tue, 9 Jun 2026 21:59:37 UTC, 3,775 KB.
- v2: Mon, 10 Aug 2026 19:13:02 UTC, 2,562 KB.

The PDF in `F:\repo\thesis-xai-faithfulness` carries the stamp
`arXiv:2606.11470v1 [cs.CL] 9 Jun 2026`, so it is v1. Chapter 02 read v1, cited
v1, and refs.bib says v1. Chapter 17 reads the same file, so it also cites v1,
and the chapter names no claim as the paper's current position.

The v2 file is **1,213 KB smaller than v1**, which is a large enough change that
nothing in v1 should be assumed to survive into it. Whether the three passages
this chapter quotes are still there in v2 is unknown and is not asserted either
way. The open item in SPEC.md carries this.

arXiv's own title for it is longer than the short name the book has been using:
**The Periodic Table of LLM Reasoning: A Structured Survey of Reasoning
Paradigms, Methods, and Failure Modes**. Appendix D and refs.bib carry the short
form; that is a display choice, and the full title is recorded here so a later
session does not read the short form as the paper's own.

### Paper 16's Comments field names an intended venue, not an accepted one

`Comments:` reads, verbatim:

> This manuscript is intended for submission to ACM Transactions on Intelligent
> Systems and Technology

There is no `journal-ref`. The only DOI is arXiv's own `10.48550/arXiv.2504.00125`,
issued via DataCite, not a publisher DOI.

The PDF's own running head reads `ACM Transactions on Intelligent Systems and
Technology, March 2025, USA` on every page, and the ACM reference-format block
on p. 1 reads `In . ACM, New York, NY, USA, 18 pages.` with the venue slot left
empty. So the running head states a venue the paper has not reached.

**This is a new case beside decision 48.** Papers 22, 25 and 32 record acceptance
in `Comments` and are cited as the arXiv version anyway; papers 27 and 31 have no
`Comments` row at all; paper 16 has a `Comments` row that names a venue as an
*intention*. The chapter cites the arXiv version and names no venue, which is the
same outcome by a different route, and refs.bib's `note` records the wording so a
later session does not read the running head as a venue.

The seeded refs.bib title, `{LLM}s for Explainable {AI}: A Comprehensive Survey`,
matches arXiv exactly. **That is the eighth seeded entry to need no correction.**

### The new outside-corpus key, and why it is forced

`mcotfaith` = arXiv:2307.13702, Lanham et al., *Measuring Faithfulness in
Chain-of-Thought Reasoning*. v1 is the only revision, submitted Mon, 17 Jul 2023
01:08:39 UTC. No `journal-ref` and **no `Comments` row at all**, which is paper
27's and paper 31's case. Primary category cs.AI, also cs.CL and cs.LG. Prefix
`m` because a corpus key's number is a reading-ladder position and this paper has
none; appendix D still lists exactly the 32 corpus papers.

Decision 76's trigger fires exactly: **paper 16 cites this paper in Table 1 as a
source for the claim that chain-of-thought is an intrinsic interpretability
technique, and the chapter cannot judge that citation without reading it.**

Abstract, verbatim from the arXiv abstract page, the two sentences the chapter
uses:

> As models become larger and more capable, they produce less faithful reasoning
> on most tasks we study.

> Overall, our results suggest that CoT can be faithful if the circumstances such
> as the model size and task are carefully chosen.

**Both halves matter and the chapter prints both.** The first is a measured
finding that runs against the claim paper 16 cites the work for. The second stops
the book from over-reading the first: Lanham et al. do not conclude that chains
of thought are unfaithful, they conclude that faithfulness is contingent on model
size and task. A method whose interpretability is contingent on the model it runs
in is not a method that makes models interpretable by design, which is the
narrower and correct thing to say, and it is what the chapter says.

The four perturbation constructions are named in that paper's figure 1 legend,
verbatim: `Early Answering: Truncate the original CoT before answering.`,
`Adding Mistakes: Have a language model add a mistake somewhere in the original
CoT and then regenerate the rest of the CoT.`, `Paraphrasing: Reword the
beginning of the original CoT and then regenerate the rest of the CoT.`,
`Filler Tokens: Replace the CoT with ellipses.` The chapter does not print these:
chapter 09 already describes all eight of paper 21's metrics from paper 21's own
appendix D.1, and this note records the four names only so that a later session
knows where they come from.

### Two papers deliberately not cited

**Turpin et al., arXiv:2305.04388**, the biasing-feature construction. Paper 21
attributes the whole family in its section 6 and the chapter attributes through
it on decision 45's precedent:

> Several works have used misleading hints or biases embedded in prompts to study
> CoT faithfulness [7, 8, 34, 43, 49, 51, 61]. They have shown that models
> frequently follow hints while omitting any mention of them in their CoTs,
> providing evidence of systematic unfaithfulness.

Paper 08 also states the finding and cites Turpin for it, p. 8. Two corpus papers
state it, and no section of the chapter has to judge a claim *about* Turpin's
paper, so decision 76's trigger does not fire and no key is added.

**Koo et al.**, paper 16's reference [76], *Benchmarking Cognitive Biases in
Large Language Models as Evaluators*, the source of every number in paper 16's
figure 4. The chapter says what paper 16 says about it and what paper 16's own
figure shows, and makes no claim about what Koo et al. measured or concluded.
That restraint is deliberate: the chapter's claim is about how paper 16 presents
its only numbers, which is checkable inside paper 16, and a claim about the
source's content would need the source. Recorded so a later session does not read
the omission as an oversight.

## Paper 06 - what the founding paper claimed, and what it declined

Read from the PDF, `arXiv:2201.11903v6 [cs.CL] 10 Jan 2023`. Body pp. 1-10,
appendices A through E to p. 43; the bibliography was scanned only.

### Word counts, whitespace-normalised and de-hyphenated across line breaks

Measured 2026-09-06 with a script that joins hyphenated line breaks, collapses
all whitespace to single spaces, and matches case-insensitively.

| String | Occurrences in paper 06 | Where |
|---|---|---|
| `faithful` (any form) | **2** | both are `faithfulness`; see below |
| `unfaithful` | **0** | - |
| `chain of thought` | 113 | throughout |
| `chain-of-thought` | 85 | throughout |

The two occurrences of `faithfulness` are:

1. p. 16, in a parenthesised list of emergent abilities: \enquote{the success of
   chain-of-thought reasoning as a result of model scale is a complicated
   phenomena that likely involves a variety of emergent abilities (semantic
   understanding, symbol mapping, staying on topic, arithmetic ability,
   faithfulness, etc)}. The sense is not definition 1.2's; it names an ability
   the model is said to have, not a relation between an explanation and a
   computation.
2. In the bibliography, inside the title of Maynez et al. 2020, *On faithfulness
   and factuality in abstractive summarization*.

**So the paper that introduced chain-of-thought prompting never once uses the
word for the property this book is about.** That is the strongest verified
absence a founding paper has given the book, and it is a different kind from
chapter 14's and chapter 16's: those were papers that were silent about a
property someone else attributed to their object; this is a paper that is silent
about a property later attributed to the thing it introduced.

### The four attractive properties, section 1, p. 3

The list of four is the paper's own. Property 2, verbatim, parenthesis included:

> Second, a chain of thought provides an interpretable window into the behavior
> of the model, suggesting how it might have arrived at a particular answer and
> providing opportunities to debug where the reasoning path went wrong (although
> fully characterizing a model's computations that support an answer remains an
> open question).

Two hedges in one sentence, and both are load-bearing: `might have`, and the
parenthesis. The chapter prints the sentence whole rather than the clause,
because the clause without the parenthesis is exactly the reading the chapter
says the field took.

### The paper declines to call a chain of thought a solution or an explanation

p. 3, verbatim:

> The chain of thought in this case resembles a solution and can interpreted as
> one, but we still opt to call it a chain of thought to better capture the idea
> that it mimics a step-by-step thought process for arriving at the answer

`can interpreted` is the paper's own typo and is quoted as printed. The verb the
paper chooses for the relation is **`mimics`**.

### Interpretability is a side effect, appendix C.2, p. 24

The sentence the chapter turns on, verbatim:

> And while NLE aims mostly to improve neural network interpretability
> (Rajagopal et al., 2021), the goal of chain-of-thought prompting is to allow
> models to decompose multi-hop reasoning tasks into multiple steps --
> interpretability is just a side effect.

The context matters and the chapter gives it: the sentence is drawn in the course
of separating chain-of-thought prompting from the natural-language-explanation
literature, and the separation the paper draws is that an NLE comes after the
prediction while a chain of thought comes before it. So the sentence is not an
aside about interpretability; it is the paper stating what its own contribution
is for.

### The limitations paragraph, section 6, p. 9

Four limitations. The first and the third are the ones the chapter uses,
verbatim:

> As for limitations, we first qualify that although chain of thought emulates
> the thought processes of human reasoners, this does not answer whether the
> neural network is actually "reasoning," which we leave as an open question.

> Third, there is no guarantee of correct reasoning paths, which can lead to both
> correct and incorrect answers

Chapter 02 already cites the third of these, in section 2.5. The first has not
been printed in the book before.

## Paper 16 - the survey, read in full

`arXiv:2504.00125v1`, 18 pages, read in full from the PDF. Body pp. 1-14,
references pp. 14-18. Tables 1, 2 and 3 and figures 2 and 4 were re-read from
rendered pages as images rather than from the extraction, on the open item's
standing instruction, and that is how three of the findings below were caught:
the extraction of Table 1 interleaves its three columns and assigns the source
lists to the wrong rows.

### Structure, from the rendered pages

| Page | Contents |
|---|---|
| 1-2 | abstract, introduction, section 2 background |
| 3-4 | section 3, explainability techniques; figure 2 on p. 4 |
| 5-6 | section 4, evaluating LLM-generated explanations; Table 1 on p. 6 |
| 7-9 | section 5, benchmark datasets; Table 2 on p. 8; Table 3 on p. 9 |
| 10-11 | section 6, applications; section 7, challenges; figure 3 on p. 11 |
| 12-13 | section 8, saliency; section 9, future directions; figures 4 and 5 on p. 13 |
| 14-18 | references |

### Word counts, same method as above

| String | Occurrences | Note |
|---|---|---|
| `faithful` (any form) | 13 | of which `faithfulness` 7 |
| `unfaithful` | **0** | - |
| `interpretab` | 41 | - |
| `ground truth` | 3 | - |
| `Lanham` | **1** | the bibliography entry only |
| `Jacovi` | 1 | the bibliography entry only |

**`unfaithful` occurs zero times.** A survey that names faithfulness as its
quantitative evaluation criterion never once writes the word for the case where
the criterion fails.

### Chain-of-thought is filed under intrinsic interpretability, section 3.2, p. 4

The three categories are the survey's, section 3, p. 3:

> Techniques for explainability in AI systems using Large Language Models (LLMs)
> are categorized into 1) post-hoc explanations, 2) intrinsic interpretability,
> and 3) human-centered explanations [150].

Figure 2 on p. 4 gives intrinsic interpretability the gloss `Design LLMs to be
inherently interpretable` and gives it two examples, `Transparent model
architecture` and `Attention-based interpretability`. **Chain-of-thought is not
in figure 2**; it enters the category in the body, p. 4:

> A notable technique in this category is Chain of Thought (CoT) reasoning [38],
> which breaks down complex problems into smaller, manageable steps, allowing
> models to follow a logical progression toward conclusions.

Reference [38] is **not** paper 06. It is Chu et al. 2023, *A survey of chain of
thought reasoning: Advances, frontiers and future*, arXiv:2309.15402, a survey.
Paper 06 **is** in paper 16's bibliography, cited as `Chain-of-Thought Prompting
Elicits Reasoning in Large Language Models`, so the survey has the founding paper
on its shelf and files chain-of-thought under a category the founding paper's own
appendix C.2 declines.

### Table 1's intrinsic-interpretability row, p. 6, read from the rendered page

| Column | Contents, verbatim |
|---|---|
| Topic | `Intrinsic interpretability` |
| Key Points | `Chain of thought reasoning, guided templates for logical progression` |
| Sources | `[38], [138], [57], [82], [148], [133]` |

**`[82]` is Lanham et al., *Measuring faithfulness in chain-of-thought
reasoning*.** A full-text search of the PDF finds `[82]` **exactly twice**: in
this table cell, and in the bibliography entry itself. It appears nowhere in the
body of the survey.

So the one work in paper 16's bibliography that measured whether chains of
thought are faithful is cited once, as a supporting source for the claim that
chains of thought make a model interpretable by design, and its finding is never
stated. What that work found is under `mcotfaith` above.

`[57]` in the same cell is Golovneva et al. 2022, *Roscoe: A suite of metrics for
scoring step-by-step reasoning*, which is also an evaluation paper rather than a
technique. The chapter names `[82]` and stops there, because Lanham et al. is the
one whose finding runs the other way and the one the chapter reads.

### Where the survey puts faithfulness, section 4, pp. 5-6

The split, p. 5:

> Evaluation can be divided into two categories: 1) qualitative and 2)
> quantitative evaluation as shown in Table 2.

Faithfulness and plausibility are the two quantitative criteria. The definition,
p. 6, verbatim:

> Faithfulness is the degree of accuracy with which an explanation represents the
> model's actual decision-making process [70]. A faithful explanation should
> align with at least the following: 1) internal logic and cause-and-effect
> relationship established by the model; 2) how the model has been designed and
> the data the model has been trained on; and 3) whether the decision of the
> model is reproducible using features represented in the explanation.

Reference [70] is Kadir, Mosavi and Sonntag 2023, *Evaluation Metrics for XAI: A
Review, Taxonomy, and Practical Applications*.

The first clause matches definition 1.2. **The second does not**: alignment with
how a model was designed and what it was trained on is a relation between an
explanation and the training setup, and table 1.1 has no row for it. The third is
a reproducibility condition on the explanation's feature set, which is the
sufficiency shape of section 8.4 rather than a definition. The chapter reads all
three against table 1.1 and says which row each lands on, and that the second
lands on none.

### Table 2, p. 8, read from the rendered page

| Category | Metric | Description | Example |
|---|---|---|---|
| Qualitative | `Comprehensibility and human understanding [86, 126]` | `Ease of understanding and clarity in delivering the model's reasoning to humans` | sentiment-analysis phrases |
| Qualitative | `Controllability [31, 36]` | `Interactivity and adjustability of explanations, enabling users to provide feedback to refine explanations` | users highlighting unclear parts |
| Quantitative | `Faithfulness [23]` | `Accuracy in representing the model's internal decision-making process, including causal relationships and alignment with training data` | `A medical diagnosis system showing specific patient features and their weights that informed the decision` |
| Quantitative | `Plausibility [64, 105]` | `Logical coherence and domain consistency, ensuring alignment with established knowledge` | `A climate prediction model providing explanations consistent with meteorological principles` |

Two things follow and the chapter prints both.

**First, the quantitative row has nothing quantitative in it.** No metric, no
formula, no threshold, no score, and no procedure. Its Example column describes a
picture of a system rather than a number. Across the whole of paper 16 there is
no way to compute the quantity the table calls faithfulness, and the survey never
says there is not one.

**Second, `[64]` is Jacovi and Goldberg 2020**, *Towards faithfully interpretable
NLP systems: How should we define and evaluate faithfulness?*, and Table 2 files
it under **Plausibility**. That is the paper paper 21 calls the source of the most
widely adopted definition of faithfulness, and the paper chapter 01's definition
1.2 traces back to.

**The charge is stated narrowly and this is deliberate.** The body of paper 16
uses `[64]` correctly once, p. 6: \enquote{Some researchers argue that
explanations that look understandable to humans might not be accurate or true to
the model's actual logic [64].} That sentence is the faithfulness/plausibility
distinction and it is attributed right. The defect is in the table, where the row
labels do not match the body's own use, and the chapter says exactly that rather
than accusing the survey of misreading its source. Decision 62c's rule applied on
purpose: a wrong table licenses rejecting the table.

### Figure 4, p. 13, read from the rendered page

The survey's only measurement. Legend reads `Salience Large` and `Salience
Small`; the caption and prose read `Saliency`. Caption: `Saliency Comparison of
Models by [76]`.

| Model, as the figure labels it | Salience Large | Salience Small |
|---|---|---|
| ChatGPT (175B) | 0.84 | 0.56 |
| Llamav2 (70B) | 0.75 | 0.53 |
| Cohere (54B) | 0.71 | 0.56 |
| Vicuna (13B) | 0.57 | 0.51 |
| Mistral (7B) | 0.68 | 0.50 |
| **Olmo (7B)** | 0.45 | 0.29 |

All twelve values are printed beside the bars in the figure and were read from
the rendered page, not from the extraction.

**Two defects, both checkable inside paper 16.**

1. **The prose names a model the figure does not.** Section 8, p. 12, reads
   \enquote{OLMO (1B) [58] has the lowest saliency scores (0.45 for large inputs
   and 0.29 for small inputs)}, and the figure labels that row `Olmo (7B)`. The
   two numbers match; the parameter count does not. OLMo was released at both 1B
   and 7B, so neither label is impossible on its own and the paper does not say
   which was run.
2. **The size story breaks at one row and the prose does not say so.** The prose
   groups `VICUNA (13B)` and `MISTRAL (7B)` as models that \enquote{display lower
   saliency values} against ChatGPT, Llamav2 and Cohere, and concludes that
   \enquote{the disparity among models emphasizes the importance of size,
   architecture, and training strategies in saliency performance}. Mistral at 7B
   scores 0.68, above Vicuna at 13B on 0.57, and 0.03 below Cohere at 54B on
   0.71. So the ranking is not monotone in parameter count and the single
   inversion is between the two models the prose puts in the same group.

The chapter prints the table and both defects. It does **not** say what the
numbers measure beyond what paper 16 says, which is
\enquote{the parts of a generated explanation, such as certain words and phrases
that are most aligned with the ground truth [33]}: that is an agreement with a
reference text, so it is a `tính hợp lý` quantity by table 1.1's rows, and the
chapter says so as its own reading and marks it.

### What the survey's challenges section does not contain

Section 7, pp. 10-12, lists five challenges: sensitive data, societal diversity
and norms, multi-source data, complexity of the AI model, and bias and fairness
within LLMs. **None of the five is that nobody can check whether an
LLM-generated explanation is faithful**, and the survey's own faithfulness row
has no metric behind it. Recorded as an absence in the same sense chapter 08's
note records paper 20's.

## Paper 08 - the 2026 survey, re-read for one question

`arXiv:2606.11470v1`, 103 pages. Chapter 02 read section 3 for the
reasoning-as-behaviour framing. This session re-read pp. 2, 8, 15 and 76 and
searched the whole extraction.

### Word counts, same method

| String | Occurrences | Note |
|---|---|---|
| `faithful` (any form) | 17 | of which `faithfulness` 7, `unfaithful` 1 |
| `ground truth` | 1 | - |
| `Turpin` | 2 | body citation and bibliography |
| `interpretab` | 32 | - |

### The doubt, stated three times

Introduction, p. 2, verbatim:

> Although techniques such as chain-of-thought prompting Wang et al. (2023)
> expose intermediate reasoning traces Wei et al. (2022b), it remains doubtful
> whether these traces faithfully reflect the underlying computational processes
> Lyu et al. (2023) or merely plausible post hoc rationalizations.

Section 3 on CoT, p. 8, verbatim:

> Despite these advantages, CoT reasoning does not guarantee the correctness or
> faithfulness of the generated reasoning process. The model continues to operate
> through probabilistic next-token generation, and intermediate reasoning traces
> may contain inconsistencies, hallucinated justifications, or post hoc
> rationalizations Lyu et al. (2023); Turpin et al. (2023). Nevertheless, the
> stepwise structure improves interpretability and provides opportunities for
> local verification and error analysis compared to direct-answer prompting.

The last sentence is the one the chapter has to handle honestly: the survey
states the doubt and then keeps the interpretability claim in the same paragraph,
without saying what the claim rests on once the doubt is granted.

Practical guidelines list, p. 15, fourth bullet, verbatim:

> Longer reasoning chains can improve performance, but increased verbosity alone
> does not guarantee faithful or correct reasoning.

### Figure 27, p. 76, and the finding the chapter turns on

Read from the rendered page. The figure is a waterline diagram: `Accuracy` above
the line as `WHAT BENCHMARKS MEASURE`, six properties below it. The faithfulness
entry, verbatim from the right-hand panel:

> **Faithfulness** - Does the chain-of-thought actually cause the answer, or is
> it post-hoc decoration?

with the instrument row beneath it, verbatim:

> trace perturbation - counterfactual CoT - causal mediation

and the same property is glossed inside the diagram itself as `does the trace
cause the answer?`.

**That definition is `mức quan trọng`, not `độ trung thực`.** Paper 21 section
2.3 separates the two explicitly and gives both directions of the gap: a step can
describe a computation that happened without being causally important for the
answer, and a fabricated justification the model later conditions on is causally
important and unfaithful. So a 2026 survey defines faithfulness, in a figure
whose whole point is that benchmarks measure the wrong thing, as the property
paper 21's central diagnosis says gets conflated with it.

This is the conflation chapter 09 named the terminology for. Decision 45's
`mức quan trọng`/`độ trung thực` split was settled because the anchor's diagnosis
is that the two get conflated; this is that conflation found in a survey's own
definition rather than inside a metric.

Two of the three instruments the figure names, trace perturbation and
counterfactual CoT, are the perturbation family. Paper 21 measured that family
and found it among the weakest; see the next section.

The `PRACTICAL HEURISTIC` box at the foot of the same figure, verbatim first
sentence:

> If a paper reports only accuracy, treat any claim about "reasoning" as
> preliminary.

### One artifact recorded and deliberately not printed

Figure 27's caption, p. 76, reads in full:

> Accuracy is the tip; faithfulness, robustness, calibration, generalization,
> efficiency, and safety sit below the waterline. Addresses your paper's
> recurring point that benchmarks overstate progress.

The second sentence addresses someone in the second person and refers to
\enquote{your paper}, which is not this paper. The heuristic box beneath it ends
\enquote{almost every failure mode in Teaching 4 is invisible from accuracy
alone}, and `Teaching 4` names nothing in the survey.

**The chapter does not print either.** Both are editorial residue rather than
claims, and neither changes anything the survey asserts. The rule the book has
been following without stating it: a source defect is named on the page when the
chapter's argument touches it, which is what decisions 40, 62, 62c, 73 and 77 all
did, and is left in the note when naming it would only embarrass the source. The
one consequence that does reach the page is that the chapter quotes only the
first sentence of the heuristic box, because the second has a dangling reference.

## Paper 21 - re-read for what a chain of thought is

`arXiv:2605.25052v1`. Chapters 08, 09 and 16 read this paper. Chapter 09 holds
the construction, the eight metrics and every AUROC in
`ch09-bai-bao-neo.md`, and **chapter 17 restates none of them**; it points at
chapter 09 and reads three passages for a question chapter 09 did not ask.

### The object moved once already, section 2.1, p. 3

Verbatim:

> This definition was designed for methods whose purpose is to generate a
> coherent and self-contained explanation of a model's behavior, such as
> attention maps and saliency scores [28, 29], or the original few-shot linear
> CoTs of Wei et al. [1]. The CoTs of contemporary reasoning models, however, are
> extended verbalizations the model emits over the course of solving a task.
> These verbalizations can contain many steps not directly linked to the model's
> prediction, or even irrelevant to it.

This is the answer to the question chapter 16 hands chapter 17. Paper 21 puts
paper 06's chains **inside** the class Jacovi and Goldberg's definition was built
for, and says the chains of today's reasoning models are not in that class. So
the thing being compared against the behaviour changed identity between 2022 and
2026, and no chapter of this book had noticed that until now.

### The proposal to abandon the book's subject, section 2.1 p. 3 and section 6 p. 9

p. 3, verbatim:

> others deem the definition unactionable, proposing to abandon faithfulness in
> favor of monitorability [33, 34].

p. 9, verbatim:

> A related line of work frames CoT-based safety through monitorability, the task
> of automatically predicting properties of a model's behavior from its outputs
> [5, 33, 34]. These works argue that faithfulness is operationally hard to
> measure and instead test whether monitors can identify specific behaviors from
> model outputs. BONAFIDE demonstrates that evaluating faithfulness can be
> tractable, opening an avenue for improving monitorability.

References [33] and [34] are Baker et al., *Chain of thought monitorability: A
new and fragile opportunity for AI safety*, 2025, and Guan et al., *Monitoring
monitorability*, 2025, arXiv:2512.18311. The book reads neither; the chapter
attributes the position through paper 21 on decision 45's precedent and says the
position is reported rather than assessed. **Chapter 18 inherits it**, because a
live proposal to replace the book's subject with a different one is a fact about
the shape of the gap, and it is the first the book has met.

### Definitions 1 and 2, section 2.2, pp. 3-4

Both are printed in chapter 09 and are not reprinted here. What chapter 17 uses
is the clause of definition 2 that chapter 09 states and does not work through:

> Definition 2 (CoT Faithfulness). A CoT is faithful iff (1) it contains a
> complete reasoning path the model followed to reach its answer, and (2) it
> contains no unfaithful steps.

and the reason the paper gives for needing clause (1), p. 4, verbatim:

> a CoT in which every step is individually faithful can still misrepresent the
> model's reasoning. For instance, if a model follows a hint without mentioning
> it, each step could be faithful on its own, while the CoT as a whole conceals
> the actual reasoning process.

**Step-level faithfulness does not compose into chain-level faithfulness**, and
that is what section 17.6 computes on the running example.

### Importance is not faithfulness, section 2.3, p. 4

Verbatim, the two directions:

> the model may have decided to follow the hint in its first forward pass and
> only verbalized that decision in a later step, or briefly considered Van Gogh
> before settling on a different answer. Those steps faithfully describe
> processes that occurred, but are not causally important for the answer.
> Conversely, a step containing a fabricated justification that the model later
> conditions on would be causally important but still unfaithful.

and the paper's own attribution of the perturbation family, same section:

> the perturbation-based metrics of Lanham et al. [10] measure whether CoT steps
> are causally important for the model's answer

So paper 21 says in one sentence what the chapter needs about `mcotfaith`: those
metrics measure importance. Together with paper 08's figure 27, which defines
faithfulness as importance, and paper 16's table, which files the standard
definitional source under plausibility, the chapter has three sources placing the
same word on three different relations of table 1.1.

### Where paper 21's results already are

`ch09-bai-bao-neo.md` holds every AUROC, the prediction-skew figures, the
agreement statistics and the cost column. Chapter 17 prints **no number from
paper 21**. Section 17.6 refers to chapter 09 for all of them.

## The book's own worked example, section 17.6

Computed by hand this session on the function chapters 01 to 08 use,
$f(x_1,x_2) = x_1 + 2x_2 + x_1x_2$ on binary features:

| $x_1$ | $x_2$ | $x_1$ | $2x_2$ | $x_1x_2$ | $f$ |
|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 |
| 1 | 0 | 1 | 0 | 0 | 1 |
| 0 | 1 | 0 | 2 | 0 | 2 |
| 1 | 1 | 1 | 2 | 1 | 4 |

Chapter 16 already uses the thresholds 1 and 4, which give the OR and the AND of
the two features.

The example the chapter builds on it is **the book's own illustration of paper
21's definitions 1 and 2**, marked as such on the page, and not a BonaFide row.
Its shape: a chain over the input $(1,1)$ whose three steps are
\enquote{$x_1$ is 1, so add 1}, \enquote{$x_2$ is 1, so add 2}, \enquote{both are
1, so add the interaction, 1}, and which concludes 4. Every step describes a
computation the function requires for that input, so every step is faithful under
definition 1 as long as the computation happened. The chain is nonetheless
unfaithful under definition 2 whenever the answer came from somewhere else, for
instance from having been told it, because clause (1) asks for the path the model
**followed**, and a path that was not followed is not made complete by being
correct.

The example is arithmetic the reader can check in four lines, and it separates
the two clauses of definition 2 without any of paper 21's machinery. The second
half of the section uses the same chain for the importance gap: the third step is
what makes the answer 4 rather than 3, so it is important, and a step reading
\enquote{4 is even} would be faithful if that check occurred and important for
nothing.

**This is the running example's fourth Part V appearance** after sections 15.2,
16.3 and question 1 of chapter 16.

## Numbers this chapter prints, and where each comes from

Every decimal in the chapter is from paper 16's figure 4, p. 13, read from the
rendered page, and all twelve are in the table above. Nothing else in the chapter
is a decimal. The integers it prints are counts recorded in this note: 2 and 0
for paper 06, 0 and 1 for paper 16, 5, 4 and 3 for structure.

Under decision 43 they are printed with a period.

## Verified negatives

- `unfaithful` occurs zero times in paper 16.
- `faithful` occurs twice in paper 06, neither in definition 1.2's sense, and
  `unfaithful` zero times.
- `[82]` occurs exactly twice in paper 16, once in Table 1 and once in the
  bibliography, and never in the body.
- Paper 16's section 7 lists five challenges and none of them is the absence of a
  way to check faithfulness.
- Paper 16 contains no metric, formula, threshold or procedure for the quantity
  its Table 2 calls faithfulness.

## Limitation and future-work statements

Part IV's log closed at chapter 14, so this is not an entry in it. Recorded
anyway because chapter 18 takes the intersection and two of these are new.

- **Paper 16, section 9**: three future directions, automating human feedback,
  integrating visual and text explanations, and cross-disciplinary research. None
  of the three is an instrument. Section 9.3 gives a reason worth keeping: it
  says agreement on \enquote{shared design principles or explainability
  evaluation standards} is hard because \enquote{the number of publications in
  XAI is growing so quickly that researchers struggle to keep up with studies in
  their field}. That is the nearest thing in the whole corpus to the research
  metagame chapter 11's initialized TOC line promised and paper 23 did not
  contain (decision 56), and it is one sentence in a survey rather than a
  measurement.
- **Paper 08**: figure 27 is itself a statement of what is not measured, and the
  practical heuristic is its prescription. It names three instrument families for
  faithfulness and validates none.
- **Paper 21**: recorded in `ch08-cac-ho-chi-so.md`. The monitorability passage
  above is the part chapter 18 needs and chapter 09 did not record.

## The 2026-09-06 cold audit

One `chapter-auditor` with no drafting context. **Six of its findings were
factual and four of those changed what the chapter asserts**, so they are
recorded here rather than only in the SPEC.

### The two that mattered most, and both were the session's own over-reach

**1. Paper 16 cites Jacovi and Goldberg twice in its body, not once.** The draft
said the body used the reference correctly once, on p. 6, and that the table's
plausibility row was therefore an isolated slip. It is not. The second body
citation, p. 7, sits inside the paragraph defining plausibility and sources the
climate-model example for it. So the table row agrees with the body's second use,
and the charge as drafted was too generous to itself: it presented a defect in a
table where the survey is in fact consistent. **The corrected statement, which is
narrower than a charge and harder than a remark about a table**: across the whole
survey the canonical faithfulness reference appears only on the plausibility
side, except for the single sentence that draws the boundary between the two
criteria. Section 17.4 now says exactly that.

**2. All three of paper 08's named instrument families were measured by paper 21,
not two.** The draft said two of figure 27's three, trace perturbation and
counterfactual CoT, are what paper 21's eight metrics rest on. Two errors in one
sentence. The eight metrics span four categories and only four of them intervene
on the chain, so "tám chỉ số" was wrong; and SCM, one of those four, applies
causal mediation analysis, which is figure 27's **third** family, so "two of
three" was wrong in the direction that weakened the finding. Section 9.5 says
both things on the page and the drafting session did not re-read it. **The
corrected claim is stronger**: a 2026 survey names three instrument families for
a property it cannot measure, and all three had already been measured and none
had held up.

### Four more factual corrections

3. The chapter called Lanham et al. \enquote{the fourth paper outside the
   corpus}. By papers it is the tenth; by occasions it is the fourth, after
   chapter 08's seven keys, chapter 14's one and chapter 15's one. Section 17.3
   now counts occasions and names the three earlier ones.
4. Paper 06's appendix C.2 says natural-language explanations are produced
   \enquote{either simultaneously to or after the final prediction}, and the
   draft dropped \enquote{simultaneously}. That clause is load-bearing here,
   because section 17.1's second consequence is built on the explanation and the
   answer arriving together. Restored, and section 17.2 now says why it matters.
5. The same section's footnote transcribed the C.2 sentence with ` -- ` where the
   page sets an em dash with no spaces on either side. Two defects in one: the
   transcription was not verbatim, and `--` typesets an en dash, which this book
   bans. **The Dashes check cannot see it**, because the character families mask
   `\enquote{}` spans before they run. The footnote now quotes the two clauses
   separately and says in words how the source joins them.
6. Paper 16's table 2 has four columns, not three; the draft forgot the metric-name
   column.

### One finding rejected on the record

**The auditor reported the chapter's six `quote` environments and five
`\footnote`s as the first of their kind in the book, and called for a decision
row on the precedent of decisions 44 and 63.** Half of that is wrong. Footnotes
are used in chapters 01, 02, 08 and 09, across five section files, so they set no
precedent. The `quote` environment **is** a first, and it needs no decision row
either, because the SPEC's Sources rule already licenses one: \enquote{long
normative passages via a quote environment with the citation on the introducing
sentence}. What the finding did expose is the second half of that rule being
broken, since every `~\autocite` sat at the end of its block; all six were moved
onto the introducing sentence.

### What was already fixed before the auditor read

Recorded because a reader of the audit would otherwise count them as misses.
Decisions 83 to 87, the Status paragraph, and the App A, B, C and D progress rows
all landed while the audit was running, and the auditor read the SPEC before
them. Paper 08's practical-guidelines anchor had already moved from p. 14 to
p. 15 for the same reason.

### The comprehension findings, which were the expensive ones

Thirteen, and the pattern in them is worth more than the list. **The chapter had
leaked its own SPEC into its prose.** One paragraph of section 17.7 enumerated
the four ways a table-of-contents line had failed in this book, counted the legs
of a re-check, and added a fifth; none of that exists on any printed page, so the
reader had no antecedent for any of it. Cut. The same leak in smaller form
produced \enquote{dòng mục lục} four times, where the reader sees only a chapter
title, and an index entry pointing at the book's own drafting machinery. The
chapter now attributes the framing it argues with to the word `chuyển` in section
1.5's thesis and section 16.7's hand-off, which the reader has met.

Two more were self-contradictions the session introduced. The chapter opener said
the four papers give four ways of *not* answering the question, three sentences
before section 17.7 says the anchor answers it. And section 17.1 described
section 9.2 as naming two of the anchor's three items, which was true until this
same session corrected section 9.2 to name all three. **A session that has just
corrected a passage is the session most likely to still be describing the old
one.**

The rest: section 8.2's three free choices belong to the measurement loop and not
to the explanation, so section 17.1 now names LIME's seven, IG's baseline and
SHAP's background distribution instead; the sweep over \enquote{fourteen
chapters} and the figure's own label both excluded nothing, though chapters 09
and 15 do not fit the left column, and the figure now says \enquote{các phương
pháp của Phần~II}; \enquote{bốn ô} of the importance-against-faithfulness grid
had only three worked and the fourth is now worked; section 9.7's three crossing
items were miscounted as a method and two diagnoses; \enquote{ba khảo sát} was
two; the two Lanham quotations sat back to back against house style and now have
a sentence between them; and section 17.4 closed by saying the next survey names
the missing instrument correctly, which is what section 17.5 spends its last
third denying.

### Voice

Five, all confirmed against chapter 16's prose: a verbless punchline with a
rule-of-three (\enquote{Không phải mô tả, không phải phản ánh, không phải ghi
lại.}), a second verbless fragment (\enquote{Ba điều về bảng ấy.}), the doubled
\enquote{thứ thứ} construction that chapter 16's own audit had already removed
once, an announcing paragraph opening section 17.6, and an opener lifted almost
word for word from chapter 16's section 7. Review question 1 also presupposed
that one of the four consequences makes checking *easier*, when the chapter
writes all four as making it harder, so a reader answering honestly had nothing
to hand back; it now asks for the argument in the other direction and allows the
answer that there is none.

## How page anchors in this note are numbered

Checked per paper rather than assumed, because two of the four number their
pages differently from the way an extraction reads them.

- **Papers 06, 08 and 21 print page numbers and they equal the PDF page index**,
  verified by reading the footer off the rendered page for pp. 3, 9, 16 and 24 of
  paper 06 and pp. 2, 8, 15 and 76 of paper 08. So every anchor to those three is
  both a printed page and a PDF page.
- **Paper 16 prints no page numbers at all**, on any page, which is normal for an
  `acmart` preprint with no venue. Every `trang N` the chapter gives for paper 16
  is therefore a **PDF page index**, and a reader following it counts pages from
  the title page. Recorded because the chapter cites five of them and nothing on
  the page says which numbering it means.

## Methodology note

Extraction with `pdftotext -layout`. **Every table, every figure and every
number in this note was re-read from a rendered page image**, on the standing
instruction the open items carry, and that is how the Table 1 row assignment, the
`Olmo (7B)` label and the twelve saliency values were established: the
`-layout` extraction of paper 16's Table 1 interleaves the three columns and
attaches each source list to the row below its own, which would have put `[82]`
on the `Evaluation of explanation` row and destroyed the chapter's central
finding.

**Three page anchors in this note were wrong in its first form and were corrected
before the cold audit ran**, by re-deriving each from the PDF page rather than
from the extraction's line order: paper 06's four attractive properties and its
`mimics` sentence are on p. 3, not p. 2, and appendix C.2 is on p. 24, not p. 32.
Paper 06 numbers its printed pages the same as its PDF pages, which is what makes
the check a one-line one. One of the three had reached the chapter, in section
17.2's \enquote{Ở trang 2}, and is fixed. That is decision 73's second-half rule
arriving from the other direction: there the note was wrong and the page was
right, here the note was wrong about *where* the page is, and both are caught by
going back to the page.

Word counts were made with a script that joins hyphenated line breaks, collapses
whitespace and matches case-insensitively, which is chapter 16's normalisation
rule applied from the start rather than after an audit caught a wrapped
occurrence.
