# SPEC - Do trung thuc trong XAI

Source of truth for this book: decisions, approved TOC, and progress. Read it
fully before working on the book; update the progress table before finishing a
working session.

Title: **Độ trung thực trong XAI**
Subtitle: *Từ LIME đến chuỗi suy luận*
Author: Giang Dang
Language: Vietnamese

This SPEC and check-chapter.psd1 are written in English (decision 3): the
draft-chapter skill reads the slot labels, and the library's other SPECs are
English, so a mixed-language log would be the odd one out and harder to scan.

## Status

Initialized 2026-08-24. The skeleton builds clean: 18 chapter stubs in five
parts, four appendix stubs (appendix D, the corpus table, written in full),
refs.bib seeded with all 32 corpus papers, prose gate armed (Spelling en-US
with the tone-mark table, Gloss against appendix B). Chapters 01 through 05 and
chapters 07 through 10 are reviewed; chapter 06 is drafted and awaits its audit,
which is the last thing standing between Part III and done.

Two things changed at the book level in chapter 08's session, both in the
decision log. The anchor paper turned out to meta-evaluate chain-of-thought
faithfulness rather than feature-attribution faithfulness (decision 33), which
resolved one open item and opened another about where chapter 09 belongs. And
the book crossed the research/ cliff (decisions 35 to 37): `research/` holds a
note per chapter from 08 on, so every decimal printed anywhere in the manuscript
must trace to one.

Chapter 09's session settled the open item decision 33 opened: the anchor stays
at chapter 09 and carries its object difference in the prose (decision 42), so
the book spine is unchanged and chapter 17 gains a primary source. It is also
the first chapter to print a measurement, which is what finally exercised the
Numbers check the cliff armed, and which forced the period-decimal call in
decision 43.

Chapter 10's session, 2026-08-25, moved the book on three fronts. It corrected a
TOC line that had promised a case study its paper cannot supply (decision 47),
which is the fourth time an init-written line has over-promised and the point at
which the pattern is worth naming: a TOC line that names a *result* is the one to
re-check against the PDF first. It settled a word collision between two cited
papers rather than letting the glossary contradict itself (decision 49). And its
glossary sweep handed two terms back to the chapters that introduced them
(decision 50), which is decision 27's mechanism firing for the third time. Part
IV is now three chapters deep with four to go, and the 2026-08-25 build is 118
pages, no overfull boxes, no undefined references, prose gate clean, and the
rendered chapter pages inspected.

Chapter 12's session, 2026-09-02, drafted out of order: chapter 11 is still a
stub, so the Cohesion rule's second half could not be met and the chapter's
opener answers a closing paragraph that does not exist yet. That is recorded as
an open item below rather than waived, and chapter 11's session owns the
reconciliation. The session settled three things at book level. The object gap
decision 42 handled once is now a pattern with three instances and a rule
(decision 54), and one of its consequences is that section 9.7's third
crossing item, the inter-metric agreement test, turns out to have been run.
Two more word collisions were settled the opposite way from decision 49, and
the line between the two ways is now written down (decision 55). And the App B
and App C progress rows were found to be carrying stale counts, which is why
both now name the date they were counted and point at the gate's own printed
figure instead. The 2026-09-02 build is 140 pages, no overfull boxes, no
undefined references, `main.ilg` reporting 0 warnings, prose gate clean, and
the rendered chapter pages inspected.

Chapter 11's session, 2026-09-02, closed the debt chapter 12 had left and
opened a larger one. Its first finding was that the chapter the SPEC promised
does not exist: the initialized TOC line read paper 23's title as a claim about
research incentives, and the paper is a methods paper about second-order
interaction effects (decision 56). That is the fifth over-promising init line
and the first whose subject is absent from its paper entirely, which is why the
open items now carry a standing instruction to re-check the remaining lines
against their papers' abstracts before drafting. The chapter that replaced it
reads the paper as the regress its own title names and ends on the loop with no
elimination step, which is the paragraph chapter 12's opener was already written
against, so that open item closed with no edit to chapter 12 at all. Chapter
10's closing paragraph did need one, because it had promised a field-level
paper. Two smaller calls: the book now has a rule for when *not* to introduce a
symbol (decision 58), and paper 23's limitation statement gives the chapter 18
log its first instance of the missing instrument being named from inside a
methods paper. The 2026-09-02 build is 148 pages, no overfull boxes, no
undefined references, `main.ilg` reporting 0 warnings, prose gate clean, and the
rendered chapter pages inspected.

Chapter 13's session, 2026-09-04, is the first in this book to draft against a
paper that measures nothing, and most of what it settled follows from that. The
TOC line the open items flagged as most likely to be inferred from a title
**held**, the first init-written line to survive its paper since decision 24, and
the failure mode it did have is the opposite of the previous five: it named less
than the paper contains rather than more (decision 59). The object gap fires for
the fifth time and in a new form, because the gap is in the kind of claim rather
than in the family of explanation (decision 64); `faithful` occurs zero times in
the paper's 65 pages, which is the strongest verified absence the book has found.
Six of the paper's symbols collided with appendix A and one of them, `$K$`,
produced a third way to settle a symbol collision after renaming and writing out:
keep both names where the shapes never overlap and one name is standard outside
this book (decision 61). The session also extended decision 40 from a result with
wrong hypotheses to a result with a wrong derivation, and declines to build on
one of the paper's own corollaries on the record (decision 62). The 2026-09-04
build is 162 pages, no overfull boxes, no undefined references, `main.ilg`
reporting 0 warnings, prose gate clean, and the rendered chapter pages inspected.

A reading-flow pass over chapters 01 to 13, 2026-09-05, is the first session in
this book to revise the whole drafted span at once rather than draft one
chapter. It was asked for by a review that read the chapters as a student who
knows basic ML and no XAI, and its findings split three ways. Two were
contradictions the book had been carrying between chapters, and they produced
decisions 65 and 68: the same Vietnamese word naming two different relations,
and the same letter naming two different functions. One was a defect in a
source's proof that the chapter 13 session had not caught, decision 66, and
chasing it down turned up something worth more than the defect: **the book's own
rebuttal of that paper's claim was an overcorrection, and decision 62c records
that a broken derivation licenses rejecting the derivation and not the
conclusion.** The rest was reading path rather than correctness. Chapters 01 to
08 carried no example a reader could compute, so one function now runs through
five of them; four chapters reached for maths the book had not built, so each
now builds it just before it is needed; and chapter 01 states what it assumes
the reader knows. The dash-convention open item closed on the way past
(decision 67).

**Four cold auditors read the thirteen chapters in four groups, and the
session's own additions were where most of the findings landed.** That is worth
recording plainly, because the pass was a correction pass and it introduced
defects of exactly the kind it was correcting. Chapter 09's second worked
labelling case was built on a multiple-choice question, which is the one design
the diversionary setting excludes and which section 9.3 says so on the page.
Chapter 08's scoping of the measurement loop was made in section 8.2 and not
propagated, so four later passages went on asserting what 8.2 had just denied,
and three cells of the new table 8.1 were wrong about direction or return type.
The three-factor reading of the influence function in chapter 07 swapped loss
for prediction, curvature for steepness, and up-weighting for down-weighting.
The measure ladder in chapter 06 concluded countable additivity from a finite
cut. Chapter 13's packing bound, which is existential, was restated
universally two paragraphs after it was derived. Chapter 11's derivation
introduced a symbol that decision 58 had deliberately refused, and appendix A
had already bound to something else. All are fixed. **The general lesson, and
it is the same one decision 62c records at the level of argument: a session
that has just found an error is at its least suspicious of the fix.**

Three findings were checked and rejected. The Collatz framing of the first
labelling case is consistent with section 9.3's own description of bottleneck
steps, so it stays. `nhãn đúng` in section 8.6 refers to a dataset's correct
labels rather than to explanation ground truth, which is not what the Cohesion
ledger's rule is about. And the `đáp án đúng` slip reported in section 8.1 does
not appear in the file.

The 2026-09-05 build is 174 pages against the 162 of 2026-09-04,
no overfull boxes, no undefined references, prose gate clean, and the rendered
pages inspected. Those twelve pages are worked examples, four maths ladders and
three tables, added to chapters that were already drafted; they are the first
increase in this book that did not come from reading another paper, and the
length open item below should read them that way rather than as a sixth data
point about paper count.

The paper corpus lives outside this repo at `F:\repo\thesis-xai-faithfulness`
(32 arXiv PDFs in six tier folders; its README.md holds the reading ladder
and the per-paper rationale). Orientation notes for most papers live in
`F:\repo\computer-science-news\xai\`; they are drafting aids only and are
never citable (decision 13). Both paths are local working facts, not
dependencies of the built book.

## Decision log

Settled 2026-08-24 through a requirements interview at initialization. A
settled row is re-opened only by recording what changed and why, in the row.

| # | Question | Decision |
|---|----------|----------|
| 1 | Subject and thesis | XAI faithfulness: the argument that the field's faithfulness metrics are themselves unvalidated instruments, and the escape routes the critique literature points at - constructed ground truth, human studies, mechanistic interpretability, and the transfer of the whole question to chain-of-thought. Anchor paper: *Faithfulness Metrics Don't Measure Faithfulness*, arXiv 2605.25052 (paper 21 of the corpus). |
| 2 | Book type and voice | Graduate **textbook**. The Voice line below literally declares a textbook voice so the draft-chapter skill maps chapter prose to humanizer-vi's `tone-giao-trinh.md`. Third person for the subject matter; "ta"/"chúng ta" only in the expository sense, never authorial biography. |
| 3 | SPEC language | The book is Vietnamese; the SPEC and psd1 are English. Precedent: tu-rnn-den-transformer's decision 18, same reasoning. |
| 4 | Title | *Độ trung thực trong XAI*, subtitle *Từ LIME đến chuỗi suy luận*, author Giang Dang, folder `do-trung-thuc-trong-xai`. |
| 5 | Scope | The full arc of the six-tier reading ladder in `F:\repo\thesis-xai-faithfulness`: LLM foundations, classic methods, attribution theory, the critique core (papers 21-26), adversarial robustness, concept bottleneck models, plus the escape routes. All 32 corpus papers are load-bearing somewhere; appendix D maps each to its owning chapter. |
| 6 | Shape and length | 18 chapters in five parts, four appendices, 300-400 pages. Part IV (chapters 08-14) is the core and gets the pages. |
| 7 | Where LLM foundations go | One compressed chapter (02), not eight chapters and not an appendix: Part V depends on transformer, RLHF and CoT concepts, and a dependency chapters build on cannot live in an appendix. Deep background is delegated to the reading ladder via appendix D. |
| 8 | Where the anchor sits | Chapter 09, its own chapter, after chapter 08 has laid out the metric families it demolishes. The book's title claim is this chapter's claim. |
| 9 | Where CoT faithfulness sits | Chapter 17, penultimate, closing the loop with the subtitle. The corpus has no dedicated CoT-faithfulness paper; chapter 17 rests on papers 06, 08 and 16 plus the transfer of the Part IV critique - recorded as an open item to resolve before outlining it. |
| 10 | Closing chapter | Chapter 18 synthesizes the research gap as the intersection of the limitation and future-work statements of papers 21-26, which is the corpus README's own prescription. |
| 11 | Chapter apparatus | Every chapter closes with a `tomtat` box (tcolorbox, 3-6 bullets: the chapter's claims and definitions) then `\cauhoi` (starred heading *Câu hỏi ôn tập*) with numbered questions in a `cauhoids` list. In Parts II-V at least one question per chapter sends the reader into a primary paper, cited with `~\autocite`. |
| 12 | Companion code | None. Listings are limited to pseudo-code (`algpseudocode`, float renamed *Thuật toán*) and fragments quoted from cited papers; the prose frames every one as never having run. No minted load at init; admitting one is a new decision row plus decision 21's measurement. |
| 13 | Orientation notes | The `computer-science-news` notes are drafting orientation only and are never citable; every printed claim and number is verified against the actual PDF in `F:\repo\thesis-xai-faithfulness` before printing. Seven note paths the corpus README names are dead locally (papers 02, 07, 17, 20, 26, 30, 31); those chapters draft from the PDFs alone. |
| 14 | PDFs stay out of the repo | The remote is public and the PDFs are other people's papers; redistribution is not this repo's call. Corpus pinning lives in refs.bib and appendix D, not in committed PDFs. Same reasoning as tu-rnn-den-transformer's decision 22. |
| 15 | refs.bib seeding | All 32 papers at init, keys `pNNslug` (`p09lime`, `p21metrics`), reading-order-stable. Every entry carries `eprint`/`eprinttype=arxiv` and a `note` field ledger seeded as "Not yet read for this book; verify against the PDF before citing.", rewritten with the exact arXiv revision and what was read when a chapter first close-reads the paper. |
| 16 | Skeleton | All 18 chapter folders and four appendix stubs created at init with three-line `ch.tex` stubs (scope comment, `\chapter`, `\label`), per the tu-rnn-den-transformer init precedent, which the pre-commit build gate accepted then and accepts now. |
| 17 | Gloss regime | `\tn{vietnamese}{english}`; appendix B is the source of truth. A term the chapter owns is glossed once per section, a borrowed term once per chapter; a term whose obvious Vietnamese rendering is an ordinary word goes to the keep-in-English block; no gloss in headings. The tone mark sits on the first vowel of a vowel cluster (hóa, not hoá), enforced by `Spelling.Extra`. Adopted from tu-rnn-den-transformer's decisions 16, 21, 39, 40 and 41, which this book takes as a package rather than rediscovering. |
| 18 | Spelling variety | en-US for the English inside glosses and quotations, because the 32 corpus papers spell that way; a gloss in the wrong variety sends a reader searching the paper for a string it does not contain. |
| 19 | research/ starts empty | Deliberate: this book measures nothing, so every decimal it will print is paper-reported. The Numbers and Verbatim checks stay dormant until the first research note lands (see research/README.md for the cliff). The refs.bib note fields carry corpus pinning instead of a manifest note, precisely so the cliff stays uncrossed until decision 20 crosses it on purpose. |
| 20 | Paper-reported numbers | The session that first prints one (expected: chapter 08 or 09, the AUROC results of paper 21) creates that chapter's research note recording the number, the bib key, the arXiv ID and revision, the page/table/figure anchor in the PDF, and the surrounding quote - verified against the PDF, never against an orientation note. That arms the Numbers check for the whole book; the same session retro-sweeps any earlier decimals into notes. One note per chapter thereafter. |
| 21 | Listing measure | `Listings.MaxLineLength` stays 0 at init: the book admits no minted environments, so there is nothing to measure. The day one is admitted, the measure is established on a built page (expect about 73 columns at `\small` under the template geometry and fonts, but measured, not borrowed - tu-rnn-den-transformer's method) and set in the same session. |
| 22 | Chapter 01 voice review | A 2026-08-24 review found the drafted prose running at the humanizer's `chặt` economy with the connective tissue cut - juxtaposed clipped sentences, sections opening cold, English calques, synonym rotation - against the textbook voice decision 2 set. Fixed chapter-wide in the same session. The Cohesion writing rule below records the standard for later chapters, and humanizer-vi's tone-giao-trinh.md gained a Liên kết section plus three tells (vendored copy refreshed this session). Prose-only enforcement: the author declined a machine check, so no psd1 setting backs it. |
| 23 | Chapter 02 source pins and terminology | Chapter 02 reads arXiv:1706.03762v7, 2005.14165v4, 2203.02155v1, 2201.11903v6 and 2606.11470v1; each pin and the claim class read are recorded in refs.bib. It prints no measurement, so research/ remains empty under decision 19. Its settled Vietnamese terms are the Chapter 02 block in appendix B; transformer remains English. |
| 24 | Chapter 03 scope and notation | The initialized TOC said LIME's free parameters were unvalidated, but paper 09 documents the procedure rather than establishing that claim. Chapter 03 therefore states the parameters and their interpretive consequences, and the TOC and scope comment now say so. The session also settles the shared notation: x is the model-space input, x-prime the interpretable representation, z-prime a perturbed representation, z its reconstructed input, f the model, g the local surrogate, pi-x the locality kernel, and Z the sample set. |
| 25 | Chapter 04 sources and terminology | Chapter 04 reads arXiv:1705.07874v2 and arXiv:2602.10532v1. Its terms added to appendix B are giá trị Shapley, lời giải thích cộng tính, phân phối nền, hàm nhân Shapley, độ chính xác cục bộ, tính vắng mặt, and tính nhất quán; KernelSHAP and TreeSHAP stay in English. Appendix A now maps the shared notation to SHAP as well as LIME. |
| 26 | Chapter 06 source, scope and notation | Chapter 06 reads arXiv:2505.24729v1. It treats completeness, sensitivity and linearity as constraints, then develops the paper's indicator-function construction and its measure-theoretic form, without claiming that the construction picks an application-appropriate measure or proves faithfulness. The chapter prints no paper-reported decimal, so research/ remains empty under decision 19. It adds hàm chỉ báo and độ đo Borel hữu hạn có dấu to appendix B and $\varphi_j(x,f)$ with $\mu_{j,x}$ to appendix A. |
| 27 | Ownership of tính tuyến tính | Chapter 04 had introduced tính tuyến tính with SHAP's axioms but omitted it from appendix B. Chapter 06's glossary sweep exposed the omission. The term belongs to Chapter 04, where it is now glossed; Chapter 06 borrows it, so the full-book Gloss gate has one owner and both chapters meet their cadence. |
| 28 | Chapter 07 sources, scope and notation | Chapter 07 reads arXiv:2501.18887v3 and arXiv:2505.07005v1, both from the PDFs. Paper 18 is a position paper: it argues the unification rather than proving it, and the only formalism it supplies, local function approximation, covers feature attribution alone, with the extension to data and component attribution stated there as a hypothesis. The TOC line promised "one formalism across feature attribution, data attribution and mechanistic interpretability" and now says what the chapter delivers instead. The chapter prints no paper-reported decimal, so research/ remains empty under decision 19. It adds fourteen terms to appendix B (hàm attribution, attribution dữ liệu, attribution thành phần, diễn giải cơ chế, xấp xỉ tuyến tính, hàm ảnh hưởng, phân tích trung gian nhân quả, vá kích hoạt, vá theo đường, xấp xỉ hàm cục bộ, khả năng giải thích, siêu suy luận, hệ tự hành đáng tin cậy, ngẫu nhiên hóa miền), eight to the keep-in-English block (ground truth, leave-one-out, fidelity, inverse fidelity, sparsity, attribution patching, checkpoint, multi-armed bandit), and $\psi_i(x)$, $\gamma_k(x)$, $\mathcal{D}_{\mathrm{train}}$, $c_k$, $\mathcal{I}(x^{(i)},x)$, $\mathcal{N}_x$, $\xi$, $\mathcal{G}$, $\ell$ and $H_{\theta^{*}}$ to appendix A. |
| 29 | The local-neighbourhood symbol is $\mathcal{N}_x$, not $\mathcal{Z}$ | Paper 18 writes the local function approximation neighbourhood as $\mathcal{Z}$, but decision 24 already bound $\mathcal{Z}$ to LIME's sample set and the book keeps one name per concept for the whole book. Chapter 07 writes $\mathcal{N}_x$ and appendix A records the mapping, in the same place it records the paper's $\phi_i$, $\psi_j$, $\gamma_k$ index letters against the book's. |
| 30 | Appendix A is a longtable | Chapter 07's eight new notation rows pushed appendix A past a page, and a plain tabular cannot break: the build reported an overfull vbox of 269pt instead of a table continuing overleaf. Appendix B's keep-as-is block hit the same wall at 43 rows and was already a longtable. Appendix A now is one too, with a repeated header, and its meaning column widened from 3.2cm to 5.2cm because the new rows wrapped one word per line. |
| 31 | Glossary additions bind chapters already written | Adding chapter 07's terms to appendix B made three earlier passages owe a gloss they did not owe when they were written: xấp xỉ tuyến tính in chapter 05, and attribution dữ liệu with diễn giải cơ chế in chapter 06's closing forward reference. All three were glossed in the same session, on decision 27's precedent. A fourth Gloss finding was a false positive worth recording: chapter 06's figure caption read "cách diễn giải cơ chế của bài báo", where the words are ordinary prose and not the term, so that caption was reworded rather than glossed. Expect this every time a chapter names something an earlier chapter had used loosely. |
| 32 | Chapter 07's figure is the grid, not the paper's schematic | The first draft of `ch07-ba-doi-tuong` put three aspect boxes on the left, one techniques box in the middle and three score boxes on the right, which is the layout of paper 18's own figure 1, and the audit called it a lift. The Figures rule bans that outright. The figure is now a three-by-three grid, techniques by rows and aspects by columns, with one representative method per cell: it compresses the paper's eight-row classification table rather than restaging its picture, and it is the thing the surrounding prose actually argues from. General rule for later chapters: when a redrawn schematic ends up matching the source's own figure, redraw what the source tabulates instead. |
| 33 | The anchor paper's object is chain-of-thought, not feature attribution | Chapter 08's session read arXiv:2605.25052v1 in full and confirmed on arXiv that this is the only revision. Paper 21 meta-evaluates the faithfulness of **chuỗi suy luận**, not of feature attribution: deletion, insertion, comprehensiveness, sufficiency, ROAR, sensitivity-n, infidelity and monotonicity appear nowhere in its 31 pages, and its eight metrics (Adding Mistakes, Early Answering, Filler Tokens, SCM, FUR, CC-SHAP, Simulatability, Paraphrasing) are all CoT-specific. Decision 1 called it the anchor for a thesis about XAI faithfulness metrics and that is still right at the level of the argument, but the evidence it supplies is CoT evidence. Chapter 08 takes from it what does transfer, the four-category grouping by what a metric perturbs and the stated diagnosis of two of those categories, and says in the prose that the object differs. What this means for chapter 09's placement is an open item below, not a decision this session took. |
| 34 | Chapter 08 cites seven papers from outside the corpus | No corpus paper defines a faithfulness metric, and chapter 08 is the chapter about the metric families, so it could not be written from the corpus alone. Verified: paper 20 is the only corpus survey that could have supplied a taxonomy and the string "faithful" occurs zero times in its full text. Added to refs.bib under an `m` prefix rather than `pNN`, because a corpus key's number is a reading-ladder position and these have none: `mrise`, `meraser`, `mroar`, `msensn`, `minfid`, `mood`, `msanity`. Appendix D still lists exactly the 32 corpus papers and does not list these; the reading ladder is unchanged. Each `note` field records the revision read. This admits a second citation class to the book, so later chapters may do the same where the corpus genuinely cannot answer, and must record it the same way. |
| 35 | Chapter 08 crossed the research/ cliff, and chapter 08 prints no decimal | Decision 20 expected the crossing to come with the first printed paper-reported number. It came earlier and for a different reason: the session had paper 21's measurements and its full limitation set verified against the PDF, chapter 18's open item needs that log to live somewhere, and refs.bib note fields are too small for it. The note `research/ch08-cac-ho-chi-so.md` holds the sources, paper 21's AUROC table and the limitation log; **chapter 08's own prose prints no decimal**, and paper 21's numbers belong to chapter 09. Arming the check produced 38 findings and not one was a measurement, so both halves were fixed at the source rather than waived. |
| 36 | LaTeX column widths are not numbers, and moved out of scanned prose | 6 of those 38 findings were `p{5.2cm}`-style column widths in appendices A and D. A `Numbers.Allow` entry for them would have had to match bare decimals like `1.4`, which is exactly the shape of a score the check exists to catch. They are typographic settings rather than claims, so they moved into `\newcommand`s in preamble/macros.tex, which `Paths.Prose` does not scan, and the check keeps full strength on them. Appendix B's columns are whole centimetres, raise no finding, and stayed where they are. |
| 37 | arXiv identifiers get the one hole in the Numbers check | The other 32 findings were appendix D's arXiv identifiers, which cannot move out of the table. `Numbers.Allow = @('^\d{4}\.\d{4,5}$')`, anchored at both ends and fixed at four digits before the point. No score, proportion or AUROC this book will print has that shape, so the hole cannot swallow the numbers the check exists for. Widening it to `\d+\.\d+` would exempt every one of them and is the thing not to do. |
| 38 | `baseline` stays English | Appendix B's Chương 05 block settled `điểm nền` while `preamble/macros.tex` named baseline among the terms the book keeps in English, and the prose had already gone twenty bare English uses to four Vietnamese, including the section heading of 5.4 and a figure node. The 2026-08-24 chapter 01-06 audit forced the choice. `baseline` moves to appendix B's keep-in-English block, the four `\tn{điểm nền}{baseline}` calls in chapters 05, 06 and 07 are dropped, and `\index{điểm nền}` becomes `\index{baseline}` so the printed index stops carrying one concept under two headings. This reverses the appendix B row decision 25's session added; recording the reversal is what the decision log is for. |
| 39 | Chapter 05 sources, scope and notation | The row chapters 02, 03, 04, 06 and 07 each got and chapter 05 did not. Chapter 05 reads arXiv:1703.01365v2 and arXiv:1610.02391v4, both pinned in refs.bib. Its appendix B terms are độ nhạy, bất biến theo cài đặt, tính đầy đủ and bản đồ đặc trưng; Integrated Gradients and Grad-CAM stay English. It added `$x_0$`, `$A^k$`, `$\alpha_k^c$` and `$y^c$` to appendix A. The 2026-08-24 audit removed a `tích phân đường` row the chapter never used, and added `$Z$` for Grad-CAM's spatial-position count because a plain `$Z$` already sat in the appendix's SHAP column for a different object. |
| 40 | The completeness proposition states absolute continuity | Chapter 05's proposition rendered paper 11's footnote 1 faithfully: continuous, differentiable almost everywhere, partial derivatives integrable. That condition set does not support the theorem - the Cantor function satisfies all three on $[0,1]$ and gives a zero integral against an output difference of one. A textbook that promises to cite propositions by number cannot print one that is false, so the proposition now assumes the restriction of $F$ to the path is absolutely continuous, which is sufficient, alongside differentiability along the path; the re-audit caught a first attempt that claimed necessity too. The prose records both what the paper wrote and why locally Lipschitz models satisfy the stronger condition. General rule: where a source's stated hypotheses are too weak for its own result, state the correct ones and say what the source wrote. |
| 41 | The player set is $\mathcal{P}$, not $F$ | Chapter 04 wrote $F$ for the set of players in the cooperative game while appendix A had already given $F$ to the score function being attributed, which chapter 05 then used in that sense. The game now uses $\mathcal{P}$: $N$ was tried first and collided with LIME's sample count, which the re-audit caught. Appendix A carries rows for $\mathcal{P}$, $N$, $K$, $D$ and $h_x$. Same class as decision 29. |
| 42 | **The anchor chapter stays at chapter 09 and carries the object difference in its prose** | Settled by the author 2026-08-25, closing the open item decision 33 opened. Of the three ways out, this is the first: chapter 09 close-reads paper 21 where decision 8 put it, and section 9.7 exists to say plainly that the benchmark's object is chuỗi suy luận while chapters 10 to 14 critique attribution. What transfers is named there and is never a number: the method of constructing ground truth from task design, the two diagnoses restated at the level of structure, and the inter-metric agreement test. What does not transfer is every AUROC in the chapter. The chapter states, as the current state of the field rather than as a result, that the same question has not been asked of attribution metrics by experiment; chapter 18 inherits that as the gap. Nothing else in the book moves, which is why this option was the cheapest of the three. |
| 43 | Printed decimals use a period, not a comma | Chapter 09 is the first chapter to print a measurement, so it had to settle this. The reason is not typographic taste: the Numbers check matches `\d+\.\d+`, so a Vietnamese decimal comma would make every score on the page invisible to the gate and the run would report clean because it never looked. A period also matches the string a reader searches for in the PDF. The thousands separator goes the other way and stays a thin space (`3\,066`), because importing the English comma there would collide head-on with this rule; the 2026-08-25 audit proposed matching the paper's `3,066` and was overruled for exactly that reason. |
| 44 | The book may float a table, and its label class is `tab:` | Chapter 09 prints paper 21's AUROC results as `table`/`tabular` with booktabs, the first table float in a chapter of this book; appendices A, B and D had tables but no floats and no labels. A results table of eleven rows is not prose and not a figure, and the alternative, eleven scores read out in a paragraph, is unreadable. house-style's label list names `ch:`, `sec:`, `fig:` and `app:` only, so `tab:chNN-<slug>` is added here rather than left to drift. The em rules a source table uses for a cell with no run are spelled out as words instead, because `--` is banned in prose and a blank cell cannot say whether the variant was run and dropped or never run. |
| 45 | Chapter 09 sources, scope and terminology | Chapter 09 reads arXiv:2605.25052v1 in full, main text pages 1-9 and appendices A-G pages 18-31, from the PDF, with the revision re-verified on the arXiv abstract page. It cites no paper outside the corpus: where it names Lanham, Tutek, Parcalabescu, Shen or Chen it attributes through paper 21's own statements, cited to `p21metrics`, rather than adding bib keys for papers the book does not itself read. It adds thirteen terms to appendix B, ten metric and dataset names to the keep-in-English block, and AUROC and FUR to appendix C. It also corrected chapter 08's research note, which had recorded the LM Judge skyline margins as `± 0.02` and `± 0.04`, the row below it, against the paper's `± 0.01` and `± 0.02`; chapter 08 prints no decimal, so nothing shipped wrong. |
| 46 | An abbreviation with no expansion in its own source gets none | Chapter 09 needed AUROC, FUR and SCM. Paper 21 expands FUR and expands neither of the others. FUR and AUROC are in appendix C: AUROC because paper 21's confidence intervals are DeLong intervals and the DeLong paper it cites for them supplies "receiver operating characteristic", a chain recorded in the research note. **SCM is not**, because no source the book has read expands it, so it sits in appendix B's keep-in-English block as a bare metric name. This is chapter 08's ERASER rule applied a second time, and it is now general: an invented expansion is worse than no expansion, and appendix C's header comment carries both cases. |
| 47 | **Chapter 10's TOC line promised a case study its paper cannot supply** | The initialized TOC said chapter 10 would present LIME's instability as a concrete unfaithfulness case study. Paper 22 is a literature survey and it runs no experiment: no results section, no re-implementation, no benchmark, no dataset of its own, and its three tables classify other people's published work. It defines a Stability Issue as one of five categories and attributes it to seven cited papers rather than measuring it. The chapter therefore reports the classification and attributes every behavioural claim about LIME *through* the survey, on decision 45's precedent, and says so in the opener rather than letting a reader take the survey for a study. The TOC line now says what the chapter delivers. Same class as decisions 24 and 28; this is the fourth time a TOC line written at init has promised more than its paper contains, and the pattern is that a line naming a *result* is the one to re-check first. |
| 48 | Chapter 10 sources, scope and terminology | Chapter 10 reads arXiv:2503.24365v1, body pages 1-18 in full, from the PDF; pages 19-25 are the bibliography and were scanned only. The revision and metadata were re-verified on the arXiv abstract page and through the arXiv API: v1 is the only revision, and the arXiv Comments field records acceptance at the 3rd World Conference on eXplainable Artificial Intelligence (XAI 2025) with no `journal-ref`, so the book cites the arXiv version. The seeded refs.bib title had capitalised *Should* and *Trust*; the source title is lowercase and the entry is corrected. The chapter cites no paper outside the corpus: where it names Webster, Brocke or Nauta it attributes through paper 22's own statements, on decision 45's precedent. It adds four terms to appendix B (sinh đặc trưng, sinh mẫu, biểu diễn lời giải thích, phân đoạn) and six names to the keep-in-English block (S-LIME, BayLIME, B-LIME, Correctness, Consistency, Continuity), and it adds definition~10.1, tính ổn định. |
| 49 | The survey's *fidelity* is not the book's `fidelity`, and the book renames rather than collides | Paper 22's Fidelity Issue is the local surrogate failing to capture the model's behaviour, which is definition 1.2 applied to the surrogate. The book already keeps `fidelity` in English as the counterfactual quantity chapter 07 named and chapter 08 read closely. Two papers, one English word, two objects. Chapter 10 writes the survey's category as ordinary Vietnamese, độ khớp, names the collision once in the prose, and adds no appendix B row for it: a row mapping `fidelity` to a Vietnamese term while the keep-block says to leave it in English would make the glossary contradict itself and the Gloss check unreadable. Same class as decision 29, one layer up: there the collision was between two papers' symbols, here between two papers' words. |
| 50 | Two terms chapter 10 surfaced belong to earlier chapters | Adding chapter 10's block to appendix B made the Gloss check report `tính cục bộ` unglossed in chapters 03 and 04 and `tính ổn định` unglossed in chapter 08. Both are decision 27's case rather than chapter 10's: chapter 03 introduces locality in section 3.2 and chapter 08 introduces stability when it reads max-sensitivity, so the terms belong there and chapter 10 borrows them. Both moved to the owning chapter's block and are glossed at their first use. One of the four findings was a false positive of decision 31's kind: chapter 04 read \enquote{TreeSHAP chỉ làm phép tính cục bộ nhanh hơn}, where `tính` belongs to `phép tính` and the term is not there at all; that sentence was reworded rather than glossed. Chapter 03's \enquote{giữa các lần sinh mẫu} was reworded for the same reason, since the survey's substep name is chapter 10's and chapter 03's use was ordinary prose. |
| 51 | **Economy flexes with the difficulty of what is being explained; the opaque-prose pass of chapters 01 to 09** | A 2026-09-02 review read chapters 01 to 09 for passages a reader finishes without knowing what they said, as distinct from passages read wrongly, and found 44 of them, six at the level of a whole paragraph carrying a chapter's central construction. Every one was a compressed passage, in one of four shapes: a derivation skipping the step that defines its object (section 6.4's jump from atomic attributions to the measure), a technical result stated in one sentence with several unglossed terms (section 4.6's nuisance function and debiased estimator, section 7.6's reinforcement-learning direction), a paper's term or symbol used before its definition ($h_x$ inside theorem 4.1, "quy tắc hoàn thiện", "phản thực", "độ đo"), and a reference with no antecedent ("chữ thứ ba", "cắt cả hai chiều", "cách nhìn đó"). The author's ruling: economy is not a fixed dial per book. A passage explaining a hard definition or concept takes the room it needs, intermediate steps and a worked example included, while easy material stays at `vừa`; the Economy line above now says so, and `tone-giao-trinh.md` (vendored and global copies) carries the same sentence plus two new tells, a paper's term used as if familiar and a result compressed into one sentence. The fixes are prose-only, no psd1 setting, on decision 22's precedent. Sections 4.6, 6.3, 6.4, 6.7, 7.5, 7.6 and 9.5 roughly doubled in length by design; 9.5 now describes all eight metrics in one sentence each from paper 21's appendix D.1, which the research note already carried, because a results table for eight unnamed procedures was the largest single comprehension failure in the book. Two ledger slips in chapter 07 ("lớp" for a layer, "vectơ") were corrected in the same pass, and five colloquial spans in chapters 08 and 09 returned to the textbook register. Chapter 10, merged after the review was read, was not in scope and its prose was not reviewed; it received exactly one mechanical edit, a `\tn` gloss on "phản thực" in 10.2 that the Gloss check demanded once appendix B listed the term, and its references to definition 1.2 survive the rewording because the definition's content did not change. **A cold audit followed the pass**, one `chapter-auditor` per chapter for 04, 06, 07 and 09, briefed to report comprehension failures first. It caught the pass's own mechanical error (every progress-table note one row too high, fixed) and about forty prose findings, most of them acted on: theorem 6.2 restated so the remainder is the Taylor remainder's attribution, the figure of 6.4 redrawn to the four steps the prose narrates, the ReLU closed form and the center of mass stated in 6.6 so 6.7's projection has an antecedent, the Shapley kernel written out in 4.4 with its loss, the regression target and the $v(S)=f_x(z'_S)$ bridge added in 4.2, section 4.6 given $X$, $Y$, the marginal completion rule, both nuisances and the $n^{-1/4}$ payoff, the influence-function symbols read out in 7.3, attribution patching's mechanism in 7.4, the sampling forms of 7.5, omission and commission named once in 9.6, the eight-hint-format and semantic-utility misstatements in 9.3 and 9.5 corrected against the research note, "mô hình suy luận" defined at first use, "gán sai nguồn" restored, "nhãn đúng" and "đáp án đúng" returned to ground truth, `\tn` rows added for trần trên, precision, unlearning and recall, appendix A rows for $E$, $\theta^{*}$ and $\mathcal{L}$, and a stale scope comment in chapter 07 and the App A progress row's `$N$` corrected. Rejected on the record: chapter 06's TOC line as over-promising (the identification of SHAP's background distribution and IG's baseline with the measure choice is the chapter's argument in 6.5, not an analogy); "lớp hàm" as a ledger collision (the ledger separates a network layer from an output class, and a function class is standard mathematical Vietnamese that no reader confuses with either); chapter 04's seven "Vì vậy" and its `\index` range placement (connective frequency is not a comprehension defect, and chapter 03 uses the same word); the request to explain why the $p<2$ correction needs smoothness (would carry more of paper 19's section 3.2 than the chapter should); chapter 07's survey category names left unexplained (they are the survey's names and the sentence only maps them); paper 18's table-versus-sentence inconsistency on game-theoretic notions (the chapter follows table 1, and the inconsistency is the paper's, recorded here); and chapter 09's "độ phủ" (ordinary Vietnamese, no gloss). Chapter 06's "độ nhạy" was not renamed: paper 17's sensitivity is IG's second condition, so 6.2 now says which one it means instead of coining a third name. |
| 52 | Chapter 10's opaque-prose pass | The same review as decision 51, run on chapter 10 after PR 71 merged, on its own branch. Chapter 10 had been audited well and had no paragraph-level failure; the pass found thirteen sentence-level ones, all of decision 51's shapes: references with no antecedent ("ba nhóm kia" with five groups named, "Ba bảng ... dựng trên hai trục" when only table 1 is), terms used as familiar ("thứ tự bộ phận", "hệ lập trình logic quy nạp", "cấu trúc khuyến khích", "bộ đọc"), ledger slips ("mô hình khả diễn giải" for the surrogate, "thước đo" for what chapter 08 settled as "chỉ số", about a dozen times), and a caption that contradicted its figure. The cold audit (one `chapter-auditor`) found the caption contradiction and the "mũi tên đứt" in a question where the prose had just reserved "đứt" for another meaning, both certain and both fixed by making the return arrow of figure 10.1 solid, so that dotted means only "missing"; the tomtat's "phần lớn" where the body and the note say "nhiều"; four facts printed from the PDF that the research note had not recorded, now recorded there; and two of the book's own inferences stated as the survey's, now marked. Rejected: the fifteen subgroup labels left unexplained (the survey's names, by design, as decision 51 ruled for chapter 07) and "quy tiếp qua khảo sát" (rewritten anyway, as plain attribution). Chapter 10 keeps its reviewed status. |
| 53 | Chapter 12 sources, scope and terminology | Chapter 12 reads arXiv:2503.16507v1 and arXiv:2603.15607v1 in full from the PDFs; both are v1-only and both records were re-verified raw against the arXiv API and abstract pages. Neither seeded refs.bib entry needed a correction, which is the first time that has happened; only the `note` fields changed. Paper 24 has a publisher DOI printed on the paper (CHI EA '25, 10.1145/3706599.3719964) but no arXiv `journal-ref`, and paper 25 records acceptance at XAI 2026, the same series that accepted paper 22 a year earlier; both are cited as the arXiv version on decision 48's precedent. The chapter cites no paper outside the corpus: Miller, Wells and Bednarz, Nauta, Rudin and the M4 benchmark are all attributed *through* the paper that names them, on decision 45's precedent. It adds three terms to appendix B (cảm nhận của người dùng, thang Likert, lực kiểm định), eight to the keep-in-English block, and `$r$` and `$R^2$` to appendix A. It adds no abbreviation to appendix C, for the reason in that progress row. |
| 54 | **The object gap is now a book-wide pattern, and chapter 12 is its third instance** | Decision 42 settled how chapter 09 carries the difference between the anchor's object (chuỗi suy luận) and Part II's. Chapter 12 meets the same shape twice more. Paper 24's object is claims of human explainability, and the words `faithfulness`, `ground truth` and `attribution` occur zero times in it, so its 0.7 percent is a count on the plausibility side of the chapter 01 split and the chapter says so in its opener rather than at the end. Paper 25's object is counterfactual explanations, so its correlations and $R^2$ values say nothing about the chapter 08 metric families, and section 12.6 holds that line the way section 9.7 does. **What is new is what crosses.** Paper 25 reports, second-hand, that the M4 benchmark found the faithfulness metrics of feature attribution correlate only weakly with one another and can produce contradictory rankings. That is exactly the third of the three things section 9.7 said would cross the boundary, the inter-metric agreement test that needs no ground truth, and it has now been run and answered the same way. It is not the ground-truth comparison, because metrics that agree need not be right, so section 9.7's open statement is unchanged and chapter 18 still inherits it. The general rule for the rest of Part IV: state the object of every paper before its numbers, and when a result crosses, name which of section 9.7's three items it settles. |
| 55 | `sparsity` and `phản thực` each name two objects, and the book keeps the English name while renaming nothing | Decision 49 settled the `fidelity` collision between papers 07 and 22 by writing the survey's sense in Vietnamese. Chapter 12 hits the same class twice and settles it the other way, because here both senses are proper names of published quantities. Paper 25's `Sparsity` counts the features a counterfactual explanation changes; chapter 07's `sparsity` counts how many high-scoring elements are needed to reach fidelity. Its `Completeness` is a share of top-5 SHAP importance mass; chapter 05's `tính đầy đủ` is Integrated Gradients' axiom. And `phản thực` names the perturbation test from chapter 07 on, while a `lời giải thích phản thực` is an explanation in its own right, an object rather than an instrument. All three collisions are named once in the prose at the point of use, the English names stay English, and the `sparsity` keep-row in appendix B carries the note the way the `fidelity` row does. The rule this settles: rename when one of the two senses is ordinary Vietnamese (decision 49), and name the collision in place when both are proper names. |
| 56 | **Chapter 11's TOC line named a subject paper 23 does not contain, and the whole chapter changed** | The initialized line read "the research metagame: benchmark churn, metric proliferation, the incentives behind yet another unvalidated metric". Paper 23 is a methods paper: it introduces the METAGAME, a cooperative game whose value function is a first-order attribution method, and computes Shapley values on it to get meta-attributions. Verified by full-text search of the whole 32-page PDF: `incentive`, `churn`, `proliferat`, `publicat`, `reviewer` and `peer review` occur **zero times each**. The paper separates itself from the nearest thing to the promised subject in its own Related Work (p. 8): "While METAGAME shares a naming affinity with the meta-evaluation problem (Hedstrom et al., 2023), which quantifies attribution quality, our framework focuses on second-order interaction effects." This is the fifth init-written TOC line to over-promise, after decisions 24, 28 and 47, and it is the first where the promised subject is **absent rather than weaker than promised**: the line was inferred from the paper's title. Decision 47's rule, re-check a line that names a *result*, does not cover it, because this line names a *topic*. **The general rule this adds: re-check a TOC line against the paper's abstract before drafting whenever the line's subject could have been read off the title alone.** The remaining chapters this applies to are named in the open items. Chapter 10's closing paragraph had also been written against the old line, promising a paper that asks its question at the level of the whole field, so it was rewritten in the same session under the Cohesion rule's own escape clause. |
| 57 | Chapter 11 sources, scope and terminology | Chapter 11 reads arXiv:2605.06295v1, body pages 1-9 and appendices A-E pages 15-32, in full from the PDF; pages 10-14 are the bibliography and the appendix contents page and were scanned only. The revision and the record were re-verified raw against the arXiv abstract page and the arXiv API. **v1 is the only revision, and there is no `journal-ref`, no `Comments` field and no publisher DOI**; page 1 reads "Preprint.", so the chapter cites the arXiv version and never names a venue, which is a difference from papers 22 and 25 that both recorded acceptance in Comments. The seeded refs.bib entry needed no correction, the second time that has happened after chapter 12's two; only the `note` field changed. The chapter cites no paper outside the corpus: where it names Janizek, Sturmfels and Lee, Lundstrom and Razaviyayn, or Tsai, it attributes through paper 23's own statements on decision 45's precedent. It adds five terms to appendix B (tương tác bậc hai, attribution nối tầng, rò rỉ tương tác, hiệu ứng riêng, tính hiệu quả phân tầng) and nineteen names to the keep-in-English block, and it adds STII and SOP to appendix C, both expanded in the source on p. 3 and so admissible under decision 46. Two numbered definitions, one numbered theorem, one TikZ figure, and the book's second table float. **This is decision 54's object gap for the fourth time**: the paper's object is second-order interaction effects, stated in the opener before any number. Nothing in it crosses to section 9.7's three items, and that is worth recording as much as a crossing would be: the paper supplies a fourth kind of evidence for the same absence, from inside a methods paper, rather than a test of it. |
| 58 | Where the paper's symbol collides and the construction is clearer written out, the book introduces no symbol at all | Paper 23 writes `\psi_{i,j}` for the serial attribution. Appendix A had already bound `$\psi_i(x)$` to a data attribution in chapter 07, so decision 29's rule applies. Decisions 29 and 41 both resolved a collision by **renaming**; this one resolves it by **not naming**. The serial construction is written out as the attribution operator applied to the attribution function, `$\varphi_j(x, \varphi_i(\cdot,f))$`, which is literally what it is and reads better than any symbol would; the chapter says once in the prose that the paper writes `\psi_{i,j}` here. The meta-attribution does get a symbol, `$\varphi_{j\to i}(x,f)$`, and it is deliberately built on chapter 06's `$\varphi_j$` rather than held apart from it, because the object being differenced is exactly that attribution. Appendix A carries the row and records that the paper writes its two arguments the other way round. General rule: a symbol earns its place by being used more than once and by being shorter than what it stands for; where neither holds, writing the thing out avoids a collision instead of resolving one. **The same session hit the ordinary case as well and settled it the ordinary way.** Paper 23 writes `I` for the interaction term of its analytic example, and appendix A had already given `$I$` to the perturbation in chapter 08's definition of infidelity, with `$\mathcal{I}$` separately taken by chapter 07's influence. Chapter 11 writes `$T$`, names the substitution once in the prose where the function is introduced, and appendix A records the mapping, which is decisions 29 and 41 applied a third time. The lesson for later chapters is that the check is cheap and easy to skip: a single capital letter lifted from a source's table looks local, and appendix A is where to find out that it is not. |
| 59 | **Chapter 13's TOC line held, and the new failure mode is a line that under-describes** | The open item decision 56 opened asked for the remaining init-written TOC lines to be re-checked against their papers' abstracts before drafting, and named chapter 13's as one of the two that most read like a claim inferred from a title. Checked against arXiv:2504.20676v2 and **it holds**: the paper does formalize explainability through Kolmogorov complexity, does prove a ceiling, and does have a section on what the ceiling means in practice. This is the first init-written line since decision 24 to survive contact with its paper, which is worth recording as much as the five failures were. What it missed is the opposite of over-promising: roughly a third of the paper, section 4 plus the whole appendix, pages 45 to 61, is about AI regulation, and the abstract names that as one of three headline contributions. The line now says what the chapter delivers, including the trilemma. **General rule this adds: the re-check asked for by decision 56 is a two-way check.** A line can fail by naming more than the paper contains and it can fail by naming less, and the second kind is cheaper to fix but just as easy to miss, because nothing in the drafting session contradicts it. |
| 60 | Chapter 13 sources, scope and terminology | Chapter 13 reads arXiv:2504.20676**v2** in full from the PDF, pages 1--55 body and 56--61 appendix; pages 61--65 are the bibliography and were scanned only. **The first corpus paper this book has read with more than one revision**, so decision 15's "cited as the revision read" clause finally does work rather than resolving trivially: v1 is 2025-04-29, v2 is 2025-11-03, the book cites v2 and refs.bib says so. Verified raw against the arXiv abstract page and the arXiv API: no journal-ref, no Comments field, no venue-tagged dblp entry, so the chapter cites the arXiv version and names no venue, on paper 23's precedent. The seeded refs.bib entry needed no correction, the third time that has happened; only the `note` field and the `urldate` changed. The chapter cites no paper outside the corpus. It adds twelve terms to appendix B (lý thuyết thông tin thuật toán, độ phức tạp Kolmogorov, máy Turing phổ dụng, lớp khả diễn giải, hàm sai số giải thích, hàm độ phức tạp giải thích, không suy biến, biến phân bị chặn, số chiều đếm hộp, giả thuyết đa tạp, miền khả thi, bộ ba bất khả), gives `lời nguyền số chiều` to chapter 07 on decision 27's precedent a fifth time, and adds `Lipschitz` and `EU AI Act` to the keep-in-English block; `Lipschitz` had been used bare in chapters 05 and 06 since before the appendix listed it. It is the first chapter to use AIT, an abbreviation seeded at init that no chapter had used until now, so that appendix C row is finally earned rather than merely present. **It also removed a term it had added**: `sai số xấp xỉ` was in the chapter 13 block for one gate run, and the run showed chapter 05 using the same phrase for the error of a Riemann sum rather than for the distance between an explanation and a model. Two ordinary technical phrases, two objects, neither a proper name, so decision 55's test sends it neither way and the row was dropped instead. A term that is ordinary Vietnamese in both senses does not belong in the glossary at all. |
| 61 | **A symbol collision can also be settled by shape, which is the third way** | Six of paper 26's symbols collide with symbols appendix A had already bound, and five are settled the ways decisions 29, 41 and 58 already established. The complexity threshold `$k$` is renamed `$b$`, because chapter 08 owns `$k$` for the count of top-scoring elements in the deletion family and both are bare scalars. The interpretability class `$\mathcal{I}_k$` becomes `$\mathcal{G}_b$`, which is not a fresh name but decision 58's extension move: appendix A already binds `$\mathcal{G}$` to "the class of readable models used to approximate $f$", which is exactly this set, so the book subscripts the symbol it has. The input distribution `$D$` becomes `$\mathcal{D}$`, because `$D$` is LIME's distance function. The output distance `$d(y_1,y_2)$` becomes `$\rho$`, because the paper uses `$d$` for the input dimension **and** for the output distance on the same page and the book keeps `$d$` for the dimension. The output separation `$\sigma_f$` gets no symbol at all, decision 58's case exactly: used twice in the whole paper and not shorter than what it stands for, so non-degeneracy is stated in words. **`$K$` is the new case.** It collides with LIME's `$K$`, the number of components kept, and the book keeps both. Renaming Kolmogorov complexity would send a reader to any text on that subject looking for a letter that is not there, and the two senses are separated by shape rather than by context: Kolmogorov complexity is always applied, `$K(f)$`, `$K(g)$`, and LIME's `$K$` is always bare. The rule this adds: **shape is a legitimate third resolution, but only where the shapes never overlap and where one of the two names is standard outside this book.** Neither condition held in decisions 29, 41 or 58, which is why none of them took this way out. `$r$` is a fourth, weaker case recorded in its appendix A row: chapter 12's correlation coefficient against this chapter's neighbourhood radius, which is always written inside `$B_r(x_0)$`, and the two never share a page. |
| 62 | **Where a source's own derivation does not support its own statement, the book says so and builds on something else** | Decision 40 settled the case where a source's stated hypotheses are too weak for its own result: state the correct ones and say what the source wrote. Paper 26 supplies a different case. Its corollary 3.8, p. 27, claims a lower bound `$\Omega(L \cdot d^{1/2} \cdot n^{-1/d})$` on the error of a linear model with `$n$` features, and derives it by reading that floor off theorem 3.2's `$\mathcal{O}$` upper bound on `$\kappa_f$`, which is a step that needs a lower bound on `$\kappa_f$` the paper does not have. The conclusion is also wrong in form: the error of the best linear approximation to a fixed `$f$` is set by how far `$f$` is from linear and does not fall as `$n^{-1/d}$` when features are added. Section 13.4 names the corollary, states the step that does not follow in one sentence, and takes the statement the chapter needs from theorem 3.4 plus proposition 3.7 instead, both of which the paper does prove. **The general rule: decision 40 covers a result whose hypotheses are wrong, and this covers a result whose derivation is wrong; in both the book states what the source wrote and prints only what it can stand behind.** Two smaller instances in the same paper are recorded in the research note and not printed, because nothing in the chapter rests on them: lemma 2.21's expected-error case assumes a constant `$c$` the lemma does not have, and theorem 3.15's proof asserts a quadtree improvement whose count is the cost of one path down the tree rather than of the whole partition. The third instance **is** printed, in section 13.5, because the chapter's argument rests on it: theorem 3.15 measures a relative description length given oracle access to `$f$`, states that in its own statement, and then compares it against absolute global bounds, and the paper's only sentence about LIME and SHAP is the reading of that comparison. |
| 62b | **The 2026-09-04 cold audit found a third instance of decision 62 in the same paper, and it was the one the draft had swallowed** | Recorded as its own row because the catch is the most valuable thing an audit has returned in this book and the mechanism that produced the error is general. Paper 26's remark 3.5, p. 22, asserts that theorem 3.4's lower bound "matches the upper bound in Theorem 3.2 up to constants". It does not. Write both in the budget variable: theorem 3.2's construction buys $m^d \approx b / \log(L/\delta)$ grid cells for $b$ bits, because its own proof charges for one encoded function value per cell, so the achievable error falls as $L \cdot b^{-1/d}$; theorem 3.4 only forbids error below $L \cdot 2^{-b/d}$. Polynomial against exponential. Inverted, theorem 3.2 allows $\kappa_f(\delta)$ exponential in $d$ while theorem 3.4 proves only $\Omega(d \log(L/\delta))$, linear in $d$. The false step is in proposition 3.6's proof on p. 24, which treats $b$ bits as buying $2^b$ cells, contradicting p. 21's own count. **The draft printed the paper's claim unattributed, as the book's own, in section 13.4, and then leaned on it twice more in section 13.6 and the tomtat.** All three are corrected: the chapter now writes both bounds in the same variable, names remark 3.5 as the paper's claim, declines it, and draws the narrower conclusion that the curse of dimensionality here is a property of the grid construction rather than a proved property of the problem. **The general lesson, and it is about the drafting session rather than about the paper: decision 62's other two instances were caught while reading because the chapter had a use for them, and this one was not, because the chapter agreed with it.** A source's claim that the draft is happy to repeat is the one the draft does not check, which is the argument for the cold audit stated as a mechanism rather than as a rule. |
| 63 | The book's first `proof` environment, and the preamble had already provided for it | Chapter 13 prints the complexity gap theorem's proof in full, four lines, because the chapter's argument is that the proof is trivial and that this is what makes the result both unbeatable and nearly empty. No earlier chapter had used a proof environment, and none needed one: chapters 04 to 11 state results and cite them by number without proving them. `amsthm` was already loaded and `preamble/macros.tex` already carried a comment recording that babel's Vietnamese locale supplies `\proofname` as "Chứng minh", so the preamble anticipated this and no preamble change was needed. **The rule this settles: a proof is printed when the shape of the proof is itself the chapter's point, and otherwise the result is stated and cited.** Chapter 13 prints one proof and paraphrases the ideas of five others in prose, which is that rule applied. |
| 64 | **The object gap is a fifth instance, and this time the gap is in the kind of claim rather than in the family of explanation** | Decision 42 settled it once for the anchor, decision 54 made it a book-wide pattern with chapter 12's two papers as instances two and three, and decision 57 recorded chapter 11's paper as the fourth. Paper 26 is the fifth and it differs from all four. The earlier gaps were between one family of explanation and another: chuỗi suy luận against feature attribution, human-explainability claims against faithfulness, counterfactual explanations against attribution, second-order interaction effects against faithfulness. **Here the object is a different kind of statement.** The paper proves theorems and measures nothing, its error is the distance between two outputs, and `faithful` occurs zero times in 65 pages while `ground truth` occurs zero times, `attribution` once and `LIME` and `SHAP` once each. So what has to be carried into the prose is not "these numbers are about a different family" but "this is a bound rather than a measurement, and it bounds `độ khớp` rather than `độ trung thực`". Section 13.6 does that, and it also records the one thing that does cross: the ceiling constrains what any future validated instrument can be asked to certify, because theorem 13.4 says in advance that a readable explanation of a complex model does not agree with it. **The rule for the rest of Part IV and for Part V: state the kind of claim as well as the object, because a chapter can hand a reader a proof and a measurement in the same voice and they carry different weight.** |
| 65 | **`Độ khớp`, `độ trung thực`, `tính hợp lý` and `tính ổn định` are four relations and the book states them once, in a table** | Chapter 10 had said the survey's fidelity group *is* definition 1.2 applied to a local surrogate, while chapter 13 kept output error separate from definition 1.2. Both sentences were defensible on their own and they contradict each other, which is what a reader hits when the same Vietnamese word carries two relations. Settled by naming what each relation compares: `độ khớp` compares two outputs on a stated domain, `độ trung thực` compares an explanation with the behaviour's dependencies under a stated intervention set, `tính hợp lý` compares an explanation with a reader's judgement, `tính ổn định` compares two runs. Table 1.1 holds the four rows plus, for each, the inference it does not license; chapters 10 and 13 now cite that table instead of restating the relation. Decision 49 stands: it settled the *word*, and this row settles the *relation* the word names. |
| 66 | **A source's proof can fail while its statement holds, and the book then supplies a proof rather than dropping the result** | Decision 62 covers a source claim the book declines to build on. Paper 26's theorem 3.4 is a different case and needed its own rule. Its statement is fine; its proof, p. 22-23, counts the functions of complexity at most `k` by lemma 2.9 and then reuses that count as the number of value regions of one such function, which the identity map refutes, and it fixes `g` before constructing `f`, which inverts the theorem's quantifier order. The book keeps the statement, prints the two defects in the reading-critically passage, and proves the result with a packing argument over bump functions that uses only the count lemma 2.9 does supply. The rule: where a source's statement survives its broken proof and an elementary argument is available, the book gives the argument as its own and says so, rather than either repeating the proof or discarding a true result. Where no such argument is available, decision 62 applies instead and the book declines. Derivation in `research/ch01-13-reading-flow.md`. |
| 62c | **Decision 62b's third clause is superseded: the Lipschitz bounds do match, and the curse of dimensionality is intrinsic** | 62b concluded from the gap between `L*2^(-b/d)` and `L*b^(-1/d)` that remark 3.5 was wrong and that the exponential dependence on `d` was an artefact of the grid construction. The first half stands and the second does not. The packing argument of decision 66 gives `kappa_f(delta) = Omega((L/delta)^d)`, i.e. error `Omega(L*b^(-1/d))` at budget `b`, which matches theorem 3.2's upper bound in the exponent and differs from it by a logarithmic factor. So remark 3.5's conclusion is right and only its route is broken: it reads the conclusion off theorem 3.4, which is far too weak to carry it, and proposition 3.6's `N ~ 2^k` step remains a genuine error that the book still refuses. Sections 13.4, 13.6 and the tomtat are rewritten accordingly. **What this cost, and the lesson: the draft's overcorrection was as wrong as the claim it was correcting.** Having caught the paper printing an unsupported claim, the session rejected the claim itself rather than only its derivation, and no audit caught it because the rejection read as caution. A wrong derivation licenses rejecting the derivation, not the conclusion. |
| 67 | **The dash convention is settled: dotted means missing, dashed means a free choice, and an operation arrow is solid with a label** | The open item recorded the survey and left the call. Dotted already meant "missing" in chapters 10 to 13 and nothing else. Dashed meant "a free choice" in chapters 08 and 13 and "the integration step" in chapter 05, which predates both. Settled the way that leaves the convention with no exceptions: figure 5.1's integration arrow becomes a solid arrow carrying the label `phép lấy giới hạn`, and its caption names the label instead of the stroke. The two senses of dashed are gone rather than documented, so chapter 13's caption now cites a convention that genuinely holds book-wide. No machine check backs this, per decision 22 and the survey's own finding that every candidate check either fires on the deliberate cases or never fires at all. Inspecting the rendered page for this change also turned up a pre-existing collision in the same figure, the Integrated Gradients box overlapping the Grad-CAM row, which no gate can see and which the vertical separation now fixes. **Worth keeping as a habit: the figure whose caption you are editing is the figure to look at on the page.** |
| 68 | **Chapter 07's attribution function gets its own symbol** | The definition of the attribution function and the local-function-approximation surrogate both used `g`, and section 7.5 reconciled them by asserting they were "the same object". They are not: one maps the object set `E` to the reals, the other maps the input space to a prediction. The scores being the surrogate's coefficients is a relation that holds only when the interpretable class is linear. The attribution function becomes `\mathcal{A}_{f,x}`, with its domain written into the definition; `g` stays the surrogate; the relation is printed as an equation with its condition attached. Appendix A's row asserted the merge and is corrected. This reverses a call the appendix had recorded, which is what a decision row is for. |

## Version baseline

Verified 2026-08-24 from the init build's `build/main.log`; re-verify when
the TeX distribution updates.

| Component | Version | Status |
|---|---|---|
| LuaHBTeX | see init build log | verified at init: the skeleton builds clean |
| babel (Vietnamese via `\babelprovide[import, main]`) | see init build log | verified at init: Vietnamese chapter names and hyphenation active |
| fontspec + TeX Gyre Pagella/Heros/Cursor (loaded by filename) | see init build log | verified at init: full Vietnamese repertoire renders on the title page and part pages |
| biblatex + biber | see init build log | verified at init against the 32 seeded entries |
| csquotes, tcolorbox, algorithm/algpseudocode, imakeidx, hyperref | see init build log | verified at init: all load without warnings that matter |
| The 32-paper corpus | arXiv IDs fixed in refs.bib and appendix D, taken from `F:\repo\thesis-xai-faithfulness\download-pdfs.sh` | the exact arXiv revision (vN) is pinned in the refs.bib `note` field the first time a chapter close-reads that paper (decision 15); the PDFs live outside the repo (decision 14) |

The corpus is this book's dependency surface; there is no companion toolchain
to pin beyond TeX.

## Table of contents

Approved 2026-08-24. If drafting deviates from this list, update the list in
the same session. Chapter folders in chapters/ carry the same scope lines.
Paper numbers are reading-ladder positions (appendix D maps them to arXiv
IDs).

### Phần I - Nền tảng

1. **Giải thích mô hình để làm gì?** - the interpretability debate; the evaluation taxonomy; faithfulness vs plausibility defined; the book's thesis stated. Papers 13, 14, 15.
2. **Các mô hình cần được giải thích** - compressed LLM foundations: transformer, pretraining and prompting, RLHF, chain-of-thought as behavior. Papers 01, 03, 04, 06, 08.

### Phần II - Các phương pháp kinh điển

3. **LIME: mô hình thay thế cục bộ** - LIME's full mechanics (sampling, kernel, sparse linear fit) and the interpretive consequences of its free parameters. Paper 09.
4. **SHAP và giá trị Shapley** - Shapley axioms, KernelSHAP and TreeSHAP, the feature-independence assumption, the statistical grounding SHAP later acquired. Papers 10, 19.
5. **Attribution theo gradient: Integrated Gradients và Grad-CAM** - IG's axioms and path integral, the baseline as an unvalidated setting, Grad-CAM for CNNs. Papers 11, 12.

### Phần III - Lý thuyết attribution

6. **Attribution từ nguyên lý đầu** - what attribution can even mean, rebuilt without reference to any one method; the assumptions Part II's methods share. Paper 17.
7. **Một khung hợp nhất cho attribution** - the three attribution problems (feature, data, component) and the three techniques they share; the local function approximation framework, which unifies feature attribution alone; the field map before the critique. Papers 18, 20.

### Phần IV - Phê phán độ trung thực

8. **Đo độ trung thực: các họ chỉ số** - the faithfulness metric families and the assumption each smuggles in; one counterfactual loop with three free choices, then deletion and insertion, comprehensiveness and sufficiency, ROAR and the out-of-distribution objection, Sensitivity-n and infidelity, and the randomization tests that are necessary conditions rather than metrics. A metric is an instrument, and instruments need validation. Papers 14, 20, 21, plus the seven metric papers from outside the corpus (decision 34), which supply every metric definition because no corpus paper does.
9. **Chỉ số trung thực không đo độ trung thực** - the anchor paper read closely: constructed ground truth via known-mechanism tasks, metrics near chance. Its object is the faithfulness of chuỗi suy luận, not of feature attribution (decision 33), and the chapter carries that difference in section 9.7 rather than letting a reader assume the results land on Part II's methods (decision 42). Paper 21 (arXiv 2605.25052).
10. **LIME nào đáng tin?** - the variant zoo read from the field's own survey: five issue categories, four pipeline substeps, 48 techniques, two thirds of them aimed at the surrogate's fidelity or at stability, and the survey's own record that nothing ranks them. Paper 22 runs no experiment, so instability is reported as its classification rather than as a result it measured (decision 47). Paper 22.
11. **Attribution suốt đường xuống** - attribution applied to the output of an attribution. Paper 23 introduces the metagame and meta-attributions, diagnoses interaction leakage in serial methods on a two-variable function whose answer is known analytically, and proves that existing interaction indices already decompose attributions hierarchically. The chapter reads it as the regress its title names: hierarchical efficiency is a completeness axiom one level up and constrains nothing about the level below, the three experiments are grounded in human annotation and dataset labels rather than in faithfulness, and the paper's own limitation statement names the missing measurement and points it at deletion and insertion. **The initialized line promised the research metagame, benchmark churn and publication incentives, and the paper contains none of that (decision 56).** Paper 23.
12. **Con người vắng mặt** - the human check that functionally-grounded evaluation borrows its validity from, and how rarely it is run: a Scopus census finds 128 of 18,254 XAI papers validate with humans. Then the one study that ran the comparison, and found the automated metrics do not track what users perceive. Its object is counterfactual explanations rather than the chapter 08 metric families (decision 54), and the chapter carries that difference the way section 9.7 does. Paper 24's census counts validation of explainability claims and never writes "faithfulness", so its 0.7 percent is a count on the plausibility side of the chapter 01 split, not a count of faithfulness validation. Papers 24, 25.
13. **Giới hạn lý thuyết của giải thích** - the algorithmic-information-theoretic ceiling on explainability, and what a bound does and does not say about practice. Explainability formalized as a function approximating the model under a bit budget, the complexity gap theorem, how high the ceiling stands for random functions, Lipschitz functions and each interpretable model class, the intrinsic-dimension escape, the local-versus-global comparison that is the paper's only contact with Part II, and the regulatory trilemma read as that same theorem in policy language. Its object is the approximation error between the explanation's output and the model's, which is `độ khớp` and not `độ trung thực`; the word faithfulness does not occur once in the paper, so the chapter carries that difference the way section 9.7 does (decision 59). Paper 26.
14. **Giải thích dưới tấn công** - adversarial fooling of explanations, SHAP as an attack surface, causal structure as a partial repair. Papers 27, 28, 29.

### Phần V - Những lối thoát

15. **Mô hình nút thắt khái niệm và rò rỉ** - concept bottleneck models, concept leakage as the CBM analogue of unfaithfulness, CBMs meet sparse autoencoders. Papers 30, 31, 32.
16. **Ground truth dựng sẵn, human study, và mechanistic interpretability** - the three escape routes the critique points at, each with its cost. Papers 21, 24, 18, 32 re-used; no new corpus paper.
17. **Độ trung thực của chuỗi suy luận** - chain-of-thought as self-explanation; the Part IV critique transferred to LLMs explaining themselves. Papers 06, 08, 16. Open item: no dedicated CoT-faithfulness paper in the corpus.
18. **Khoảng trống nghiên cứu** - synthesis: the intersection of the limitation and future-work statements of papers 21-26; what a validated instrument would have to look like.

### Appendices

- A. **Bảng ký hiệu** - one notation for the whole book, mapped against what LIME, SHAP, IG and Grad-CAM each wrote. Seeded when chapter 03 settles the unified notation (open item).
- B. **Bảng thuật ngữ Việt-Anh** - the glossary, source of truth for `\tn` and the Gloss check; per-chapter blocks plus the keep-in-English block. Grows with the chapters.
- C. **Bảng chữ viết tắt** - abbreviations. Seeded at init; grows with the chapters.
- D. **Danh mục 32 bài báo và thang đọc** - the corpus: reading order, tier, arXiv ID, owning chapter. Written in full at init.

## Progress

Status values: not-started / outlined / drafted / reviewed / final.

| Chapter | Status | Notes |
|---------|--------|-------|
| Preface | not-started | Written last, after the chapters exist. |
| 01 | reviewed | Audited against arXiv:1606.03490v3, 1702.08608v2 and 2601.00428v2; the audit finding was fixed. Voice revision 2026-08-24 for cohesion per tone-giao-trinh (decision 22); that session also cleared the pending build: latexmk exits 0 (65 pages) and the full gate is clean. Chapter 01-06 audit 2026-08-24: three attributions to papers 13, 14 and 15 corrected against the PDFs, proxy and hộp đen glossed and added to appendix B, the two definition titles unnested, the figure caption cut to what the prose does not already say, and the chapter indexed for the terms it owns. Opaque-prose pass 2026-09-02 (decision 51): the two opening questions restated so each names its object; definition 1.2 rewritten with distinct nouns for the explanation's items and the input's features, plus a paragraph tying it to Jacovi and Goldberg through paper 21; the borrowing chain of figure 1.1 moved into the body; attribution explained in prose at first use with a pointer to definition 6.1; Billa named at the p15 citation; the specification-gap question given examples. Reading-flow pass 2026-09-05: the chapter opener gains a prerequisites paragraph and a reading-path paragraph naming where the three unfamiliar areas of maths get built and how the Đọc sâu passages are meant to be read; section 1.4 gains the intervention example on the book's running function and table 1.1, the four-relation table that decision 65 settles and that chapters 10 and 13 now cite. |
| 02 | reviewed | Audited against the five pinned foundation papers in refs.bib. Audit fixes: named the Part II forward reference, made the LLM index entry a plain entry, and recorded transformer in appendix B. Full LuaLaTeX build clean (67 pages); mechanical prose gate clean. Chapter 01-06 audit 2026-08-24: the 2606.11470 pin corrected to v1 against the PDF stamp, the chain-of-thought and reasoning-survey claims narrowed to what the papers state, the InstructGPT figure retitled because that pipeline produces an instruction-following model rather than a dialogue one, and prompt, RLHF, reward model and CoT each collapsed to one name. Opaque-prose pass 2026-09-02 (decision 51): next-token generation and the probability distribution named plainly; query, key and value given in English; the "gọi tên một vị trí" and "chịu trách nhiệm" sentences rewritten; the reasoning survey named (Anand et al.) and its list of conditions framed as what the book borrows. Reading-flow pass 2026-09-05: the opener now says which later chapters use which part of this one, because outside chapter 03 nothing referred back to it; section 2.1 gains table 2.1, mapping tabular, image and text tasks to the scalar output an attribution method actually explains and to the unit it intervenes on. |
| 03 | reviewed | Audited against arXiv:1602.04938v3; audit fixes unified the hàm nhân terminology and corrected the TOC scope. The unified notation is seeded in appendix A and Chapter 03 terms in appendix B. Full LuaLaTeX build is clean (69 pages), the full prose gate is clean, and the rendered Chapter 3 pages were inspected. Chapter 01-06 audit 2026-08-24: the opener no longer credits chapter 02 with a definition chapter 01 makes, the sample set now matches the algorithm and appendix A, the pseudo-code caption says which steps come from the paper's prose rather than its numbered algorithm, and five names for the interpretable representation collapsed to one. Opaque-prose pass 2026-09-02 (decision 51): the opener now repeats chapter 02's three closing questions; the x' sentence rewritten; section 3.5 states the proposition each free choice commits the user to and counts seven choices, the tomtat matched; LIME's own faithfulness named as độ khớp of g to f and distinguished from definition 1.2. Reading-flow pass 2026-09-05: section 3.4 gains the book's running example computed end to end, table 3.1 of the four masks and their kernel weights, the normal equations and the solution w1 = 7/5, w2 = 12/5, and the observation that the surrogate misses the model at the very point it explains. A new first review question redoes the fit at a narrower kernel width. |
| 04 | reviewed | Audited against arXiv:1705.07874v2 and 2602.10532v1. Audit fixes added section transitions, corrected a cross-reference tie, and settled the three translated SHAP axioms in appendix B. Full LuaLaTeX build clean (71 pages); mechanical prose gate clean; the rendered chapter pages were inspected. Chapter 01-06 audit 2026-08-24: the player set renamed to $\mathcal{P}$ (decision 41), the uniqueness result and the three properties numbered, consistency restated over two models as paper 10 has it, the TreeSHAP attribution corrected because paper 10 never names it, and the duplicated noun in 4.4 fixed. Opaque-prose pass 2026-09-02 (decision 51): the P sentence simplified; h_x and f_x introduced before definition 4.1 and consistency stated with them; quy tắc hoàn thiện defined in 4.3, glossed per section and added to appendix B; the Shapley kernel's infinite weights at the empty and full coalitions explained against paper 10's theorem 2; section 4.6 widened to three paragraphs (SHAP curve as nuisance function, why plug-in averaging fails, the debiased estimator, the smoothing for p below two) against paper 19, with hàm phụ and ước lượng khử chệch added to appendix B; "câu hỏi miền" and "tình huống hoàn thiện" rewritten. Cold audit 2026-09-02 (decision 51): the SHAP paper named and cited where $F$ is mentioned, players not features in 4.1, the $v(S)=f_x(z'_S)$ bridge added, phân phối nền separated from quy tắc hoàn thiện, the weighted least-squares loss and the Shapley kernel formula written out, "độ chính xác cục bộ" tied only to the full-coalition constraint, the regularizer named as KernelSHAP's third choice, the TreeSHAP non sequitur and the path-prefix sentence fixed, $X$ and $Y$ and the marginal rule introduced in 4.6 with both nuisances and the $n^{-1/4}$ payoff, the model-specific case separated in the closing paragraph, the figure caption cut to what the prose does not say, and the ledger slips (đặc trưng vắng mặt, phương pháp/mô hình cộng tính, Kernel SHAP spelling) corrected. Reading-flow pass 2026-09-05: section 4.1 gains the Shapley values of the running example from both orderings, with the coalition game written out and flagged as a choice; section 4.6 gains a two-point example showing a signed mean and an absolute mean disagreeing, placed before the semiparametric correction. |
| 05 | reviewed | Drafted and audited 2026-08-24 from arXiv:1703.01365v2 and arXiv:1610.02391v4. Seven sections plus summary and questions; one TikZ mechanism diagram. The chapter defines sensitivity, implementation invariance, Integrated Gradients, completeness, baseline selection, and Grad-CAM, then carries the baseline and representation-choice question into chapter 06. No paper-reported decimal is printed, so research/ remains empty under decision 19. Full LuaLaTeX build clean (75 pages); mechanical prose gate clean; rendered chapter pages inspected. Chapter 01-06 audit 2026-08-24: the completeness proposition restated under absolute continuity (decision 40), citations added to the two sections that carried none, the pre-softmax qualifier restored to $y^c$, baseline settled as English (decision 38), and tầng separated from lớp. Opaque-prose pass 2026-09-02 (decision 51): the unit problem stated; DeepLift and LRP named as paper 11's modified-backprop examples; the Cantor counterexample given its reason; the completeness-to-sensitivity step spelled out; phản thực glossed at first use, per section after, and added to appendix B; the Grad-CAM opener's antecedent supplied. Reading-flow pass 2026-09-05: section 5.3 computes Integrated Gradients on the running example before stating completeness, contrasts the result with the plain gradient at the point, and notes that agreeing with chapter 04's Shapley values here is a property of this function rather than a theorem. The Cantor counterexample moves into a Đọc sâu paragraph. Figure 5.1's integration arrow becomes solid with a label, which is decision 67. |
| 06 | drafted | Read arXiv:2505.24729v1 directly because its orientation note is unavailable. Seven sections plus summary and questions; one TikZ diagram. It separates attribution constraints from the choice of measure, recovers conditional, independent and partial-dependence forms, and carries the question of validating the chosen measure into chapters 07 and 08. No paper-reported decimal is printed, so research/ remains empty under decision 19. Prose gate is clean; the full LuaLaTeX build it was waiting on ran clean in chapter 07's session. Chapter 01-06 audit 2026-08-24: the ReLU closed form now carries the paper's positivity hypothesis, "high dimensional" scoped back to the Monte-Carlo branch, the paper's actual second limitation restored with the book's own point moved out of the citation's scope, the central definition and theorem numbered, and the figure redrawn to the book's idiom. Opaque-prose pass 2026-09-02 (decision 51): độ đo glossed at first use and added to appendix B with quy tắc nguyên tử; section 6.3 states R is a box and works paper 17's two-dimensional atomic rules; section 6.4 rewritten as the paper's four steps with the Riemann-sum equation, the two conditions for the limit, the Riesz direction and the two-dimensional measure; 6.5 names the three measures as paper 17's table 1 has them; positivity explained in 6.6; recall defined and the center-of-mass projection explained in 6.7; the "attribution nhỏ nhất" and "chuyển mâu thuẫn" sentences rewritten. Cold audit 2026-09-02 (decision 51), the first this chapter has had: theorem 6.2 restated (remainder as the attribution of the Taylor remainder, Lipschitz in the model argument, the bound's three factors), paper 17's sense of độ nhạy stated against chapter 05's, the two-dimensional rule presented as the paper's refinement with the general-$d$ form marked as the book's, the measure hypothesis in 6.4 stated as the paper's assumption rather than derived, "đủ đều" replaced by the Borel description, the figure redrawn to the four narrated steps, the ReLU closed form and center of mass stated in 6.6, recall's global and probability-measure setting and theorem 4.1's shape added in 6.7, "không làm được" softened to the paper's wording, 6.6's restatement of 6.5 cut, and the announcing sentence, "thế kẹt", "hiện ra trên trang" and "Trước hết" removed. Status stays drafted until the author's review. Reading-flow pass 2026-09-05: section 6.2 writes the Taylor expansion with a named expansion point and splits the linear part from the remainder before the theorem that bounds it; section 6.4 derives finite additivity from a single interval cut, so the signed Borel measure arrives as a consequence of linearity rather than as a hypothesis. |
| 07 | reviewed | Drafted and audited 2026-08-24 from arXiv:2501.18887v3 and arXiv:2505.07005v1, both read as PDFs. Seven sections plus summary and questions; one TikZ diagram; one numbered definition and two equations. It states the attribution function over a chosen set of aspects, walks data and component attribution through the same three techniques Part II used, gives the local function approximation framework its equation, then sets attribution on the survey's range and stage axes. It closes on the shared evaluation vocabulary, fidelity, inverse fidelity and sparsity, which chapter 08 takes up. No paper-reported decimal is printed, so research/ remains empty under decision 19. Full LuaLaTeX build clean (87 pages, no overfull boxes); mechanical prose gate clean; the rendered chapter pages were inspected. Opaque-prose pass 2026-09-02 (decision 51): "lớp" changed to "tầng" for a layer (twice) and "vectơ" to "vector" (twice) per the ledger; the eight-row remark and the TracIn duplicate claim explained; the gradient-matching loss described; the local-function-approximation conjecture restated as what g takes and approximates in each branch; the survey's meta-reasoning and reinforcement-learning directions rewritten to carry meaning without that background; "cắt cả hai chiều" and "mổ xẻ" replaced. Cold audit 2026-09-02 (decision 51): the stale scope comment replaced with the SPEC TOC line, "đáp án đúng" returned to ground truth, the influence-function symbols and the parameter-shift step read out with appendix A rows for $E$, $\theta^{*}$ and $\mathcal{L}$, the two remaining paths introduced without the dangling "hai điểm yếu", Datamodel's retraining stated, the TracIn reason marked as the book's, attribution patching's mechanism and the bandit's role given, the mask-or-noise forms of $\xi$ stated, the $g$ collision between definition 7.1 and equation 7.2 resolved in prose and in appendix A, the conjecture's elaboration marked as the book's, "may also" restored as "có thể", the perturbation-type remark widened to all three branches, "tầng" for a reasoning level changed to "mức", the wrong "mục trước" pointed at 7.1, the survey's RL direction rewritten around the reward, the "tức là" inference marked, sparsity no longer claimed as a chapter 08 family, the tomtat's "Bài báo" named, and four colloquial spans replaced. Reading-flow pass 2026-09-05: the attribution function becomes A_{f,x} with its domain written out and g stays the surrogate, which is decision 68 and which corrects an appendix A row; section 7.3 reads the influence function as three factors before printing the inverse-Hessian formula. |
| 08 | reviewed | Drafted and audited 2026-08-24. Seven sections plus summary and questions; one TikZ diagram; one numbered definition and one equation. It places every faithfulness metric in Doshi-Velez and Kim's functionally-grounded tier, reduces the whole literature to one counterfactual loop with three free choices, then walks four families through it: deletion and insertion with comprehensiveness and sufficiency, ROAR and the out-of-distribution objection, Sensitivity-n and infidelity, and the randomization tests that are necessary conditions rather than metrics. It closes on paper 21's four-category grouping and its stated diagnosis, naming in the prose that the paper's object is chuỗi suy luận (decision 33). Cites seven papers from outside the corpus (decision 34); no corpus paper defines a metric. Crossed the research/ cliff (decisions 35 to 37) while printing no decimal of its own. Full LuaLaTeX build clean (96 pages, no overfull boxes, no undefined references); mechanical prose gate clean; the rendered chapter pages were inspected. Opaque-prose pass 2026-09-02 (decision 51): the out-of-distribution argument of Hase et al. given its mechanism, marked as the book's reading; CC-SHAP's use of SHAP described in 8.7; phản thực and độ đo glossed once for this chapter; three colloquial spans returned to the textbook register. Reading-flow pass 2026-09-05: the common-loop claim is scoped to the two ranking families that actually run it, in the prose and in figure 8.1's caption, and table 8.1 puts all four families side by side with what each intervenes on, what it compares, which direction its raw score reads and what it returns. Section 8.3 computes two deletion curves and their areas on the running example. |
| 09 | reviewed | The anchor chapter, drafted and audited 2026-08-25 from arXiv:2605.25052v1 read in full (pages 1-9 and 18-31). Seven sections plus summary and questions; one TikZ diagram; the book's first table float (decision 44); two numbered definitions. It rebuilds the anchor's method (ground truth forced by task design rather than observed inside the model), its BonaFide benchmark, its AUROC results, and its two diagnoses, then spends section 9.7 on what crosses to feature attribution and what does not, under decision 42. **First chapter in the book to print a measurement**, so it created `research/ch09-bai-bao-neo.md` and settled decision 43; it also corrected the LM Judge skyline margins in chapter 08's note. Full LuaLaTeX build clean (112 pages, no overfull boxes, no undefined references); mechanical prose gate clean; the rendered chapter pages were inspected, which is how the figure's note-over-arrow collision was caught. The 2026-08-25 audit fixed a miscount of the prior-work comparisons, named Chen and Shen where the prose had left prior work anonymous, cut the paragraph narrating the book's own decimal notation to the reader, trimmed the figure caption to what the prose does not already say, added the FUR row the table-5 argument had skipped, and unified `kiểm định chỉ số` with chapter 08's index heading. Six audit findings were rejected on the record, five of them because the claim was in the paper and the research note was what lacked the anchor; the note now carries all five. Opaque-prose pass 2026-09-02 (decision 51): section 9.5 now describes all eight metrics in one sentence each from paper 21's appendix D.1 (research note updated); the three reference rows counted correctly; the two-phase pipeline said to be LLM judges; the "không thể đi tắt" condition named before use; the diagnosis test's missing step and the Chen correction's "lấn át" spelled out; saliency scores tied to the book's term; the closed-model footnote restructured; the 3,066 versus 1,120 gap noted as unexplained on p. 7 (research note); four colloquial spans replaced. Cold audit 2026-09-02 (decision 51): "mô hình suy luận" defined at first use and the verb-phrase homonym rewritten, the bare-assertion example added, the 88-label precision check reworded so the skew refers to the annotators' verdicts, precision kept in English against độ chính xác, the ten models pointed at 9.4, the Collatz chain quoted, the six hint formats separated from the direct/indirect split, the semantic-utility framing sentence corrected against the note, the 0.5 threshold restored, "Cùng bảng đó" fixed, omission and commission named once and used consistently with "gán sai nguồn", CC-SHAP no longer called the only metric above chance, "nhãn đúng" and "đáp án đúng" returned to ground truth in prose, tomtat and figure, trần trên glossed as skyline, two unsourced claims in 9.7 cut, the book's inference in 9.5 marked, the announcing close of 9.4 and the rhetorical close of 9.5 cut, and five colloquial spans replaced. The research note's "Two reference rows" heading corrected to three. Reading-flow pass 2026-09-05: section 9.4 gains two worked chain-of-thought labelling cases, one outright and one diversionary, marked as the book's own illustrations of the taxonomy rather than BonaFide rows, plus the chain-level aggregation rule; section 9.5 separates the labelling rate at threshold 0.5 from AUROC with a four-case example and returns the inter-metric agreement reading to the authors. |
| 10 | reviewed | Drafted and audited 2026-08-25 from arXiv:2503.24365v1, body pages 1-18 read in full from the PDF, with the revision and the arXiv Comments field re-verified on the abstract page and through the API. Seven sections plus summary and questions; one TikZ diagram; one numbered definition; no table float. It reads the variant survey as the field's own record of what happened to LIME: five issue categories, four pipeline substeps, 48 techniques of which 32 aim at the surrogate's fidelity or at stability, then the survey's discussion, where 50\% of the techniques have no code, most papers compare only against vanilla LIME, and evaluation metrics get chosen to confirm the contribution. Section 10.6 turns on a verified absence: `faithfulness` and `ground truth` occur zero times in the body, and the survey's `Correctness` property is definition 1.2 under a third name. **The TOC line was wrong and changed (decision 47)**: paper 22 runs no experiment, so instability is reported as its classification, not as a result it measured. Its glossary sweep moved `tính cục bộ` to chapter 03 and `tính ổn định` to chapter 08 (decision 50) and it declined to add an appendix B row that would have collided with `fidelity` (decision 49). Prints no decimal: every number in it is an integer or a whole percentage, all recorded in `research/ch10-vuon-bien-the-lime.md`. Full LuaLaTeX build clean (118 pages, no overfull boxes, no undefined references); mechanical prose gate clean; the rendered chapter pages were inspected. **The 2026-08-25 audit was the most productive this book has had and two of its findings were structural.** It caught that chapter 09's closing paragraph hands this chapter the instability case explicitly (\enquote{Chương 10 đọc trường hợp ấy trên chính LIME}) while the draft opened on chapter 09's middle and then disclaimed all measurement, so the hand-off was broken; the opener was rewritten to take the hand-off and to answer it with what the survey actually is. It also caught section 10.6 treating chapter 09's near-chance AUROCs as evidence against chapter 08's metric families, which is exactly the transfer decision 42 and section 9.7 exist to block; that passage now says the objection is that the metrics are unverified rather than that they are known broken, and names the boundary. Other fixes: the survey's sample-generation step has five subgroups and the draft said four; the fourth feature-generation subgroup is unnamed in the source and the draft had renamed it after one member; a citation was attributing to chapter 08's prose a zero-occurrence claim that lives only in decision 34; definition 10.1 carried a citation for a positive statement the survey only makes negatively; the survey's \enquote{or} had become \enquote{and} and its \enquote{many papers} had become \enquote{most}; the 50\% is now stated with the paper's own phrasing plus the note that the body never says whether it is the share lacking code or holding it; the figure's dashed \enquote{missing} boxes became dotted because chapter 08's figure already uses dashed for a free choice; and five announcing sentences, three punchline closes and two colloquial spans were cut for the textbook tone. Six findings were rejected: four were already fixed before the auditor read (the missing decision rows, the not-started progress row, the incomplete parameter mapping, the `\emph`/`\enquote` inconsistency), and two were judged wrong on the record, namely that `tính ổn định` should belong to chapter 10 rather than chapter 08 (decision 27 gives it to the chapter that introduced it, which is 08) and that `độ khớp` needs an appendix B row (decision 49 explains why it must not have one, though the `fidelity` keep-row was extended to carry the collision). Touched once by the 2026-09-02 pass (decision 51) only because appendix B gained "phản thực": the Gloss check then required one gloss in this chapter, added at its first use in 10.2; no prose reviewed or changed otherwise. Opaque-prose pass 2026-09-02 (decision 52): thirteen sentence-level passages rewritten ("bộ đọc", "cái được rà", "ba nhóm kia", "hạ hiệu năng", "thứ tự bộ phận", "cấu trúc khuyến khích", "chỗ hở" twice, and the ledger slips "mô hình khả diễn giải" and "thước đo"), then a cold audit: figure 10.1's return arrow made solid and its caption and question 4 corrected, "phần lớn" returned to "nhiều" in the tomtat, four PDF facts recorded in the research note, the seven-choice mapping and the nine-year inference marked as the book's, the survey's "one or multiple points" quoted in place of a count read off the check marks, citations added to the four uncited group paragraphs of 10.2, the announcing paragraph of 10.7 and the repeated opener of 10.1 cut, and "hé" replaced. **Chapter 11's session rewrote the closing paragraph of 10.7**, under the Cohesion rule's own escape clause: it had promised that chapter 11 would take up the question "với một bài báo đặt câu hỏi ở mức cả lĩnh vực", which paper 23 is not (decision 56). It now says the corpus has no such survey and that the question is taken up instead by close-reading one paper from a different branch. No other prose in the chapter changed. Reading-flow pass 2026-09-05: độ khớp is defined as output agreement on a stated domain and kept apart from definition 1.2 in sections 10.2, 10.4 and the tomtat, per decision 65; the inference from two differing runs to a wrong one is replaced in four places by what actually follows, with the two-surrogate example added in section 10.4; review question 2 rewritten, since it had asked the reader to prove the false claim. |
| 11 | drafted | Drafted and audited 2026-09-02 from arXiv:2605.06295v1, body pages 1-9 and appendices A-E pages 15-32 read in full from the PDF, with the revision and the record re-verified raw against the arXiv abstract page and the arXiv API. Seven sections plus summary and questions; one TikZ diagram; two numbered definitions, one numbered theorem, and the book's second table float. **The session's first finding was that the chapter the SPEC promised does not exist**: the initialized TOC line named the research metagame and publication incentives, and a full-text search of the PDF finds `incentive`, `churn`, `proliferat`, `publicat`, `reviewer` and `peer review` zero times each (decision 56). The chapter that replaces it reads paper 23 as the regress its title names. It takes the serial construction, the interaction leakage the paper diagnoses on a two-variable polynomial whose answer is forced by the function and the baseline, the metagame and meta-attribution, then hierarchical efficiency as a completeness axiom one level up, then the three experiments and what each is grounded in, and it lands on the paper's own limitation sentence: a rigorous comparison would need a faithfulness measurement, which the paper did not make and points at deletion and insertion. Prints eight decimals from tables 2 and 3, all traced in `research/ch11-attribution-suot-duong-xuong.md`, along with the analytic fractions of table 11.1 checked entry by entry against appendix B.1. Full LuaLaTeX build clean (148 pages, no overfull boxes, no undefined references, `build/main.ilg` 0 warnings); mechanical prose gate clean; the rendered chapter pages were inspected. Runs 10 printed pages, 81 to 90. **It also repaid chapter 12's opener debt and rewrote chapter 10's closing paragraph**, which had promised a field-level paper that paper 23 is not. **The 2026-09-02 cold audit was productive on all three lenses and two of its findings were structural.** It caught that section 11.7's last two paragraphs were doing chapter 12's opening work: chapter 12's opener answers the loop-with-no-elimination paragraph, and the draft had put a four-chapter recap and a re-derivation of the Doshi-Velez split after it, so chapter 12 would have re-derived what chapter 11 had just said; both were cut to two sentences. And it caught that the chapter's opener declared it was taking a route different from the one chapter 10 announces, which had become false when the same session rewrote chapter 10's closing paragraph, plus a near-verbatim restatement of two of its sentences. Other fixes: "năm phương pháp bậc nhất khác nhau" where table 2's five `0.25` rows are three methods over two models; the pure individual effect derived as a difference of model outputs rather than as the first-order attribution on a masked input, which coincide for this function but are not the same step; "công bố" for a paper whose page 1 reads "Preprint."; a forward count of object-gap instances that asked the reader to have already met chapter 12's two papers; one Vietnamese name serving both the Shapley-interaction family and STII specifically; Meta-Shapley value and Meta-SV used as two names in one section; `\varphi_i(S;x,f)` first appearing inside numbered definition 11.1 with no definition of coalition-restricted attribution; the Shapley weight called "đúng dạng" as equation 4.1 when the two are the same weight in factorial and binomial form; three first-order values attributed to columns table 11.1 does not print; the meta-evaluation gloss moved one level up from the paper's own "quantifies attribution quality"; a figure caption asserting one meaning for two different defects; four consecutive sections opening on the identical "mục trước để lại" template; four meta-announcements of what the prose was about to say; the three grounds stated three times; and two review questions whose answers were printed verbatim in the body. **Rejected on the record: one.** The auditor read the scope comment's paraphrase of the SPEC TOC line as a house-style violation, on chapter 07's precedent; chapters 10 and 12 both carry a paraphrase plus session-specific notes rather than the line verbatim, so the practice is the paraphrase and the comment was only extended to name the interaction-leakage half the line carries. Two further findings were already fixed before the auditor read the files (the five-encoder enumeration and the `$I$` collision) and are recorded above rather than as audit catches. Reading-flow pass 2026-09-05: section 11.2 derives the serial Shapley leak of T/4 and Meta-SV's split before the table that reports them, so the analytic fractions arrive as consequences of the definition; two notation-history passages compress to pointers at appendix A, which already carried both mappings. |
| 12 | drafted | Drafted and audited 2026-09-02 from arXiv:2503.16507v1 (body pages 1-6) and arXiv:2603.15607v1 (body pages 1-13), both read in full from the PDFs, with both revisions and both metadata records re-verified raw against the arXiv abstract pages and the arXiv API rather than through a summarising fetch. Seven sections plus summary and questions; one TikZ diagram; no numbered definition and no table float. It collects on the debt section 1.3 records: functionally-grounded evaluation is valid only where a more expensive evaluation has already checked the proxy, and paper 24's census shows that check is almost never run. Then section 12.5 reads the one study that ran it. **The first chapter in the book to read two papers of different shapes**, a seven-page literature census and a fifteen-page user study, which is why it runs 14 printed pages against the six-to-ten of Parts I and II. Prints many decimals, all traced in `research/ch12-con-nguoi-vang-mat.md`. Full LuaLaTeX build clean (140 pages, no overfull boxes, no undefined references, and `build/main.ilg` now reports 0 warnings); mechanical prose gate clean; the rendered chapter pages were inspected. The 2026-09-02 cold audit was productive on all four of its lenses. It caught an unclosed `\index{...\|(}` range that the build had reported only in `main.ilg`, which no check reads (retro proposal below); a `tomtat` of seven bullets against decision 11's three to six; "tỉ lệ ở mức hai so với mức bốn" where 237 is level three, which made the funnel unfollowable; a "tình huống thứ tư" in 12.4 that is the first of section 12.2's four; the false precedent that chapter 10 states no formula for the same reason this chapter does (chapter 10's source supplies none; this one supplies all seven); seven facts printed from the PDFs that the research note had not recorded, now recorded there; an orders-of-magnitude claim the book had computed loosely, now replaced by the three counts themselves; the CQS abbreviation introduced and never used again, so it left appendix C and the English name went to the keep-in-English block; and five compressed passages, of which the reliability-and-PCA paragraph that licenses the whole results section was rewritten from one paragraph into three under decision 51's economy rule, and the definitions of Diversity, Trust Score and Completeness were given the constants the research note holds. Rejected on the record: "phần lớn tương quan mang dấu dương" as an unsupported quantifier (the paper's own word is `mostly`, now quoted in the note) and the four model-class names left in Vietnamese (chapter 08's keep-English reasoning, recorded in the Cohesion rule below, is about proper names of published procedures, and a model class is not one; the book already writes hồi quy tuyến tính in Vietnamese, and XGBoost stays English because it names one implementation). Status stays drafted until the author's review. Reading-flow pass 2026-09-05: section 12.1 scopes what the human branch validates, since correlation with perception cannot validate a faithfulness claim; section 12.6 records that paper 25's own reading of its correlation signs contradicts the scale it states on page 6 and that no reverse coding is stated anywhere, so the preference-direction claim is withdrawn rather than recoded, while the sign-flip argument the section runs on is unaffected; section 12.5's reading of the 2.10 mean corrected. |
| 13 | drafted | Drafted and audited 2026-09-04 from arXiv:2504.20676v2, pages 1--55 body and 56--61 appendix read in full from the PDF; pages 61--65 are the bibliography and were scanned only. Orientation note dead, so drafted from the PDF alone. **The first corpus paper with more than one revision**, which is the first time decision 15's "cited as the revision read" clause has done any work: v1 is 2025-04-29, the book cites v2 of 2025-11-03. The revision and the record were re-verified raw against the arXiv abstract page and the arXiv API; no journal-ref, no Comments field, no venue-tagged dblp entry, so the chapter cites the arXiv version and names no venue. Seven sections plus summary and questions; one TikZ figure; three numbered definitions and three numbered theorems; the book's third table float; **the book's first `proof` environment** (decision 63). It formalizes an explanation as a function approximating the model inside a bit budget, proves the complexity gap theorem in four lines, measures how high the ceiling stands for random Boolean functions, Lipschitz functions and five interpretable model classes, reads the intrinsic-dimension escape, then spends section 13.5 on the paper's single sentence about LIME and SHAP and section 13.6 on what the ceiling does and does not settle. **The chapter prints no measurement, because the paper reports none**: every two-part number in it is a numbered result or a section of the source, all recorded in `research/ch13-gioi-han-ly-thuyet.md`. Full LuaLaTeX build clean (162 pages, no overfull boxes, no undefined references, `build/main.ilg` 0 warnings); mechanical prose gate clean; the rendered chapter pages were inspected, which is how figure 13.1's placement between theorem 13.4 and its proof was caught and fixed. Runs 13 printed pages, 105 to 117. Its TOC line was the first init-written line since decision 24 to survive its paper (decision 59), and it declines to build on one of the paper's own corollaries (decision 62). Status stays drafted until the author's review. Reading-flow pass 2026-09-05: theorem 13.4's proof is shown not to prove it and is replaced by a packing argument over bump functions (decision 66), which reverses what 13.4 and 13.6 concluded about the curse of dimensionality and supersedes part of decision 62b (decision 62c); section 13.2 gains the two-point example separating expected from worst-case error; the word-count forensics in 13.1 compress to the load-bearing absences; the tomtat's longest bullet splits and the questions gain a numeric check of the packing count. |
| 14 | not-started | |
| 15 | not-started | Both CBM orientation notes dead; draft from the PDFs. |
| 16 | not-started | Re-uses papers 21, 24, 18, 32; no new corpus paper. |
| 17 | not-started | Blocked on the CoT-corpus open item before outlining. |
| 18 | not-started | Needs the limitation-statement log the open items describe. |
| App A | drafted | Seeded by chapter 03, extended by chapters 04 through 07, and made a longtable by decision 30. The chapter 01-06 audit added rows for the feature count and for Grad-CAM's `$Z$`, renamed the player set to `$\mathcal{P}$` (decision 41), and put `hàm nhân` back in Vietnamese. The 2026-09-02 opaque-prose pass added rows for `$E$`, `$\theta^{*}$` and `$\mathcal{L}$`. Chapter 12 added `$r$` and `$R^2$`, the first two rows that belong to a statistical procedure rather than to an attribution method, so their four right-hand columns are empty like chapters 06 to 08's rows. Chapter 11 added one row, `$\varphi_{j\to i}(x,f)$`, placed directly under `$\varphi_j(x,f)$` because it extends that symbol rather than competing with it, and carrying the note that paper 23 writes its two arguments the other way round. It deliberately added no row for the serial attribution (decision 58). Chapter 13 added thirteen rows, the largest single addition this table has had, and four of them rename a symbol the source uses (decision 61): `$b$` for the bit budget the paper writes `$k$`, `$\mathcal{G}_b$` for the class it writes `$\mathcal{I}_k$`, `$\mathcal{D}$` for the distribution it writes `$D$`, and `$\rho$` for the output distance it writes `$d$`. It also added `$d$` itself, which chapter 06 had bound and never given a row, and extended chapter 12's `$r$` row to carry the neighbourhood radius. `$K(f)$` is the row to read before adding any symbol here, because it is the one collision the book settled by keeping both names. |
| App B | drafted | Nine per-chapter blocks plus the keep-in-English block, 69 terms under the Gloss check. The chapter 01-06 audit added ten terms the prose used but the appendix never listed, dropped an unused `tích phân đường` row, and moved `baseline` to the keep-in-English block under decision 38. Chapter 09 added its own block of thirteen, `mức quan trọng` to chapter 08's block, and ten metric and dataset names to the keep-in-English block, SCM among them with no expansion (decision 46). Chapter 10 added a block of four, six names to the keep-in-English block, and gave `tính cục bộ` to chapter 03 and `tính ổn định` to chapter 08 rather than claiming them (decision 50); it deliberately added no row for the survey's `fidelity` (decision 49). Chapter 12 added a block of three (cảm nhận của người dùng, thang Likert, lực kiểm định), gave `lời giải thích phản thực` to chapter 07 on decision 27's precedent a fourth time, extended the `sparsity` keep-row to carry its second collision (decision 55), and added eight keep-in-English rows: six of paper 25's metric names, `M4`, and `Combined Quality Score`. Chapter 11 added a block of five (tương tác bậc hai, attribution nối tầng, rò rỉ tương tác, hiệu ứng riêng, tính hiệu quả phân tầng) and nineteen keep-in-English rows: the paper's five coined names, three method names it attributes to others, STII and SOP pointing at appendix C, Recall@K, AttnLRP, and the four model families and four datasets the three experiments run on. **Counted from the gate's own policy line 2026-09-02, after chapter 11: twelve per-chapter blocks, 91 terms under the Gloss check.** The "75 terms" this row once claimed and the "86" that replaced it both went stale within a session, because a pass that adds terms without re-counting leaves the number behind; the `gloss=` figure on check-chapter.ps1's printed policy line is the authority, not this row, so re-read it rather than trusting the number here. Chapter 13 added a block of twelve and two keep-in-English rows (`Lipschitz`, which chapters 05 and 06 had been using bare since before this appendix listed it, and `EU AI Act`), and gave `lời nguyền số chiều` to chapter 07 on decision 27's precedent a fifth time. It also **removed a term it had just added**, `sai số xấp xỉ`, because the gate showed chapter 05 using the same phrase for the error of a Riemann sum: two ordinary technical phrases for two objects, which decision 55's test sends neither way, so the row goes rather than the collision being named (decision 60). **Counted from the gate's own policy line 2026-09-04, after chapter 13: thirteen per-chapter blocks, 104 terms under the Gloss check.** |
| App C | drafted | **Fifteen abbreviations, counted 2026-09-02**: ten seeded at init, plus Grad-CAM (used eighteen times, never expanded in the prose), RISE and ROAR from chapter 08, and AUROC and FUR from chapter 09. The "thirteen" this row previously claimed had missed RISE and ROAR. SCM is deliberately absent under decision 46. Chapter 12 added none and that is a decision rather than an omission: it introduced CQS for paper 25's Combined Quality Score, then never used the abbreviation again because the prose says "điểm gộp" throughout, so the row was removed and the English name went to appendix B's keep-in-English block instead. An abbreviation the book does not itself use does not belong in a table of the abbreviations the book uses. **Seventeen after chapter 11**, which added STII (Shapley-Taylor interaction index) and SOP (sum of power); both are expanded in paper 23 on p. 3 and both are used more than once in the prose, so both clear decision 46. **Chapter 13 added none and instead earned one that was already there.** AIT was seeded at init and no chapter had used the abbreviation in eleven chapters of prose, which under the rule this row states for CQS would have made it a candidate for removal. Chapter 13 introduces it at first use in section 13.1, expanded, and uses it three more times, so the row now describes an abbreviation the book actually uses. The lesson is that the CQS rule cuts both ways: an unused row is either removed or earned, and a session that touches the subject of a seeded abbreviation should decide which. Still seventeen, counted 2026-09-04. Grows with the chapters. |
| App D | drafted | Written in full at init: 32 rows, reading order, tier, arXiv ID, owning chapter. |

## Writing rules (book-specific)

Deviations from and additions to the library-wide defaults in AGENTS.md. The
machine-checkable half of these rules is check-chapter.psd1 in this folder;
keep the two in step.

- **Voice:** textbook (giáo trình). This word is load-bearing: the
  draft-chapter skill reads this line and resolves chapter prose to
  humanizer-vi's textbook tone profile, `tone-giao-trinh.md`. Third person
  for the subject matter; "ta"/"chúng ta" only in the expository sense ("ta
  xét...", "chúng ta chứng minh..."), never authorial biography. One name per
  concept for the whole book; definitions and theorems are numbered (one
  shared counter per chapter, set up in preamble/macros.tex) and cited by
  number. Steady cadence is correct in this tone; precision carries the
  complexity. Appendices take the appendix role, frontmatter the front-matter
  role, and the review questions the lab role.
- **Economy:** flexible by difficulty (decision 51). The baseline is `vừa`,
  as `tone-giao-trinh.md` sets it, and a passage explaining a hard definition
  or concept widens to `rộng`: intermediate steps written out, a worked
  example, a sentence on why the object is needed before what it is. Easy or
  familiar material stays at `vừa`. The four `chặt` tests still apply to every
  added sentence, so widening adds steps and examples, never restatement. A
  derivation shows every step and a step is not padding; what still gets cut
  is the prose around the material: the paragraph announcing a theorem, the
  paragraph summarizing what the section just proved. The 2026-09-02 review
  found the passages readers could not follow were all compressed ones: a
  derivation skipping the step that defines its object, a result stated in
  one sentence with four unglossed terms, a paper's term used before its
  definition, a reference with no antecedent. The remedy is room, not a
  tighter dial.
- **Language and spelling:** Vietnamese. The English inside glosses and
  quotations is en-US (decision 18); `Spelling.Preset = 'en-US'` in
  check-chapter.psd1, Exempt starts empty. The tone mark sits on the first
  vowel of a vowel cluster (hóa, not hoá), enforced by `Spelling.Extra`.
  Vietnamese diacritics are letters and legal everywhere; Unicode look-alikes
  of ASCII punctuation are banned (Characters stays at the library-default
  Punctuation mode). An English quotation is introduced or parenthesized,
  never a grammatical constituent of the Vietnamese sentence.
- **Humanizer skill:** humanizer-vi. Never the English humanizer: the book
  is Vietnamese and is judged against the Vietnamese tone profiles.
- **Cohesion:** every section opens with a sentence that ties to the previous
  section's conclusion, **and every chapter opens on the last paragraph of the
  chapter before it, not on that chapter's middle.** The second half of that
  rule was added after chapter 10's audit: chapter 09 ends by handing chapter 10
  a specific case to read, chapter 10's first draft picked up an earlier thread
  instead, and the promise chapter 09 had made to the reader went unanswered.
  The check is mechanical even though no script does it: before drafting, read
  the previous chapter's closing paragraph and make the opener answer it, or
  change that closing paragraph in the same session. Within a paragraph,
  consecutive sentences connect
  through a relation word, an explicit antecedent, or topic repetition - never
  bare juxtaposition. One name per concept, book-wide; the settled ledger so
  far: "lời giải thích" (the artifact; "giải thích" only as the act),
  "phương pháp hậu nghiệm" (never "mô hình hậu nghiệm"), "cách đánh giá" (the
  Doshi-Velez and Kim taxonomy; never "tầng" or "phép thử"). A chapter that
  settles a new term appends it here in the same session. Chapter 02 adds
  "mô hình ngôn ngữ lớn", "cơ chế chú ý", "tiền huấn luyện", "lời nhắc",
  "học tăng cường từ phản hồi của con người" and "chuỗi suy luận"; transformer
  stays English, and RLHF is introduced once in 2.4 then used as the
  abbreviation. Chapter 02 also settles "mô hình thưởng" (the model) against
  "tín hiệu thưởng" (the signal it emits), and "tự chú ý". Chapter 01 adds
  "đại lượng thay thế" and "hộp đen"; chapter 03 adds "biểu diễn có thể diễn
  giải", "phép nhiễu", "hàm nhân", "mẫu đã nhiễu" and "siêu tham số"; chapter
  04 adds "hàm nhân Shapley", "đặc trưng còn thiếu", "quy tắc hoàn thiện" and
  "phương trình" for every numbered equation reference; chapter 05 settles
  "tầng" for a network layer against "lớp" for an output class, and "bản đồ
  đặc trưng" against "bản đồ nhiệt"; chapter 06 adds "loại bỏ đặc trưng",
  "quy tắc nguyên tử" and "vector" (never "vectơ"). The 2026-09-02 pass
  (decision 51) added three terms the prose had been using unglossed: chapter
  05 owns "phản thực" (counterfactual), first used at the baseline section and
  glossed there; chapter 06 owns "độ đo" (measure, in the measure-theoretic
  sense, glossed as such at first use and kept apart from "phép đo", "dụng cụ
  đo" and "thang đo", which are about measuring); chapter 04 owns "quy tắc hoàn
  thiện" (completion rule, now defined in 4.3), "hàm phụ" (nuisance function)
  and "ước lượng khử chệch" (debiased estimator). "attribution" stays in the
  keep-in-English block and is explained in plain prose at its first use in
  chapter 01, pointing at definition 6.1, rather than glossed. Chapter 03 names
  what the LIME paper calls faithfulness as "độ khớp" of $g$ to $f$, the term
  decision 49 settled, and says in the prose that it is narrower than
  definition 1.2. baseline, embedding,
  checkpoint, few-shot, super-pixel, ground truth and partial dependence plot
  stay English. Chapter 07 adds "hàm attribution", "attribution dữ liệu",
  "attribution thành phần", "diễn giải cơ chế", "xấp xỉ tuyến tính", "hàm ảnh
  hưởng", "vá kích hoạt" and "xấp xỉ hàm cục bộ"; fidelity, inverse fidelity,
  sparsity, ground truth and leave-one-out stay English. Chapter 08 adds "chỉ
  số trung thực", "đầu vào ngoài phân phối", "phép thử ngẫu nhiên hóa" and
  "tính hữu dụng ngữ nghĩa"; the metric names themselves stay English
  (deletion, insertion, comprehensiveness, sufficiency, RISE, ERASER, ROAR,
  Sensitivity-n, infidelity, max-sensitivity, sanity check), because each is the
  proper name of one published procedure and a translated name would send a
  reader to the paper looking for a string it does not contain. **ground truth
  stays English everywhere**, including where the sentence would read naturally
  with a Vietnamese phrase: chapter 08's first draft slipped into "đáp án đúng"
  and "chuẩn độc lập" in six places while chapters 06 and 07 write "ground
  truth" and index it, and the audit caught it. One name per concept applies
  hardest to the concept the whole of Part IV turns on. Verbless punchline
  fragments are out, and a forward reference names its target explicitly
  (`Phần~II`, `chương~\ref{...}`), never "phần tiếp theo". Prose-only rule
  with no psd1 setting behind it (decision 22); the gate cannot see cohesion,
  so the audit step carries it. Chapter 09 adds "bước suy luận", "cách đọc cơ
  chế", "cách đọc hiện tượng", "bước trơ", "nhiệm vụ trực tiếp", "nhiệm vụ đánh
  lạc hướng", "bước nút thắt", "thực thi bước nút thắt", "thừa nhận gợi ý",
  "cam kết trung thực", "gán sai nguồn", "gọi công cụ" and "độ chệch dự đoán";
  the eight metric names, BonaFide and LM Judge stay English on the reasoning
  chapter 08 already gave for its own metric names. Chapter 09 also settles
  "mức quan trọng" for the causal-influence property, held apart from "độ trung
  thực" for the property this book is about, because the anchor's central
  diagnosis is that the two get conflated. That term belongs to chapter 08,
  which introduced it and had never glossed it; chapter 09's glossary sweep
  exposed the omission and chapter 08 now glosses it, on decision 27's
  precedent. Chapter 10 adds "sinh đặc trưng", "sinh mẫu", "biểu diễn lời giải
  thích" and "phân đoạn", the survey's four pipeline substeps. It settles "độ
  khớp" for the survey's Fidelity Issue, held apart from the English `fidelity`
  of chapter 07 and from "độ trung thực" (decision 49); "độ khớp" is ordinary
  Vietnamese here and deliberately gets no appendix B row, because a row for it
  would contradict the keep-in-English block. `tính cục bộ` belongs to chapter
  03 and `tính ổn định` to chapter 08, not to chapter 10, on decision 27's
  precedent a third time (decision 50). S-LIME, BayLIME, B-LIME, Correctness,
  Consistency and Continuity stay English on the reasoning chapter 08 gave for
  its own metric names. Chapter 12 adds "cảm nhận của người dùng" (user
  perception), "thang Likert" and "lực kiểm định" (statistical power). It gives
  "lời giải thích phản thực" to chapter 07, which introduced it in the survey's
  list of post-hoc families, on decision 27's precedent a fourth time; chapter
  12 borrows it. Paper 25's seven metric names stay English (Sparsity,
  Proximity, Closeness, Diversity, Oracle Score, Trust Score, Completeness), as
  do M4 and Combined Quality Score. Two of those names collide with terms the
  book had already bound and both collisions are named once in the prose rather
  than renamed, because both senses are proper names (decision 55): this
  `Sparsity` is not chapter 07's `sparsity`, and this `Completeness` is not
  chapter 05's "tính đầy đủ". The third collision is on "phản thực" itself,
  which from chapter 07 on names the perturbation test and in chapter 12 names
  a family of explanations. A model class keeps its ordinary Vietnamese name
  (hồi quy tuyến tính, rừng ngẫu nhiên, k láng giềng gần nhất, mô hình cộng
  tính tổng quát), because the keep-English rule is about proper names of
  published procedures; XGBoost stays English because it names one
  implementation rather than a class. Chapter 11 adds "tương tác bậc hai"
  (second-order interaction), "attribution nối tầng" (serial attribution), "rò
  rỉ tương tác" (interaction leakage), "hiệu ứng riêng" (pure individual
  effect) and "tính hiệu quả phân tầng" (hierarchical efficiency). It settles
  "hiệu ứng riêng" against "hiệu ứng tương tác" as the two halves of what a
  second-order method has to separate, and it holds "tính hiệu quả phân tầng"
  apart from chapter 05's "tính đầy đủ" and chapter 04's "độ chính xác cục bộ"
  by saying in the prose that the three are the same shape at three levels
  rather than three names for one thing. metagame, meta-attribution,
  Meta-Shapley value, Meta-IG, Meta-G$\times$I, serial Shapley value,
  integrated Hessians, STII, SOP, Recall@K and AttnLRP stay English on the
  reasoning chapter 08 gave for its own metric names, and so do the model and
  dataset names the experiments run on (Gemma 3, CLIP, SigLIP-2, MetaCLIP-2,
  ImageNet-1k, ImageNet-Seg, Pascal VOC, MS COCO). "tầng" carries a third sense
  in this chapter, a level of the explanation stack, alongside chapter 05's
  network layer; both are ordinary Vietnamese for a layer and the chapter's
  sense is fixed by figure 11.1, so no new term was coined.
- **Listings:** this book ships no code that runs, anywhere. Two listing
  forms only: (1) pseudo-code in `algpseudocode` (the `algorithm` float,
  renamed *Thuật toán* in preamble/macros.tex), which the prose always calls
  pseudo-code; (2) a fragment quoted from a cited paper, set as a displayed
  quotation with `~\autocite`, introduced explicitly as the paper's text.
  Nothing on any page may read as code that executed, because nothing did.
  No minted and no `\newminted` aliases; admitting either is a decision-log
  row and triggers decision 21's measurement.
- **Figures:** TikZ, sources in `figures/tikz/chNN-<slug>.tex` as bare
  tikzpicture environments; the figure environment, caption and label stay at
  the call site. Mono-safe: meaning carried by dash pattern, grey level and
  fill, never hue. Biased toward pipeline and mechanism diagrams (attribution
  flow, metric construction, the constructed-ground-truth setup); a redrawn
  schematic is always this book's own drawing citing the paper it explains,
  never a lift of a paper's figure.
- **Tables:** a results table a chapter argues from is a `table` float with
  `tabular` and booktabs, labelled `tab:chNN-<slug>` (decision 44). Reserve it
  for numbers the prose would otherwise read out one by one; a table is not a
  place to park material the chapter does not use. A cell with no value says in
  words why there is none, because `--` is banned in prose and a blank cell
  cannot distinguish "not run" from "run and omitted". Appendix tables stay as
  they are: no float, no label, and longtable wherever the block grows
  (decision 30).
- **Chapter apparatus:** every chapter closes with the `tomtat` box (3-6
  bullets restating the chapter's claims and definitions, nothing new) then
  `\cauhoi` with numbered questions in a `cauhoids` list; in Parts II-V at
  least one question per chapter directs the reader into a primary paper by
  name with `~\autocite`. Chapters in Parts II-IV also end their body with a
  short section naming what the chapter's papers left unsolved - the hinge to
  the next chapter.
- **Companion code:** none. There is no repo, no verify command, no tag
  convention, and the book says nothing that would need one.
- **Research:** the cliff is crossed. `research/` holds a note from chapters 08,
  09, 10, 11 and 12 (decision 35), so the Numbers and Verbatim checks are
  live over the whole manuscript: every decimal printed anywhere must appear in
  some note here. Decimals are printed with a period so that the check can see
  them at all (decision 43).
  Two things are not numbers and are handled at the source rather than waived.
  A LaTeX column width is a typographic setting and lives in
  preamble/macros.tex, which the gate does not scan (decision 36). An arXiv
  identifier is the single `Numbers.Allow` entry, `^\d{4}\.\d{4,5}$`, anchored
  so it cannot match a score or an AUROC (decision 37). Adding a second hole
  needs the same standard: a shape no printed measurement of this book can
  take.

  One note per chapter from here on, created by the session that drafts it,
  recording for every number the bib key, the arXiv ID and revision, the
  page or table anchor in the PDF, and the surrounding quote - verified against
  the PDF, never against an orientation note (decision 20). A claim checked
  against a PDF and found false is recorded in the note too, so the next
  session does not re-derive it, and so is a claim of absence: chapter 08's
  note records that paper 20 defines no faithfulness metric, which is why no
  later chapter has to re-read it looking for one. Decision 19's original plan,
  that research/ would stay empty because the book measures nothing, held for
  seven chapters and is superseded by decision 35.
- **Sources:** the 32 corpus papers are the citation backbone; keys
  `pNNslug`; `~\autocite{...}` always with the tilde; quotations via
  `\enquote{}`, long normative passages via a quote environment with the
  citation on the introducing sentence. The orientation notes in
  `computer-science-news` are never cited and never trusted for a printed
  claim (decision 13). A paper with more than one arXiv revision is cited as
  the revision read, recorded in the refs.bib note field (decision 15) - the
  2025-26 corpus papers are exactly the class where revisions move. Chapter
  references in prose are `chương~\ref{ch:...}`, never a literal number. The
  index is maintained while writing, not retrofitted.

## Open items

- **CLOSED by decision 33: the corpus does have a dedicated CoT-faithfulness
  paper, and it is the anchor.** Paper 21 meta-evaluates eight CoT faithfulness
  metrics against constructed ground truth. Chapter 17 no longer rests on the
  transfer argument alone; it has a primary source, and appendix D's owning-
  chapter column for paper 21 should gain 17 when chapter 17 is outlined.
- **CLOSED by decision 42: the anchor chapter stays at chapter 09.** The author
  settled it 2026-08-25, taking the first of the three options: chapter 09 close-
  reads paper 21 where it stands, and section 9.7 carries the object difference
  explicitly. Chapter 17 still gets the CoT-faithfulness chapter decision 9
  assigned it, now with paper 21 as a primary source rather than a transfer
  argument, and appendix D's owning-chapter column for paper 21 should gain 17
  when chapter 17 is outlined.
- **Six orientation notes are dead locally** (papers 02, 07, 20, 26, 30,
  31; decision 13 said seven, and paper 17 came off the list when chapter 06
  read it from the PDF). Costs nothing to correctness - notes are never citable - but slows
  drafting of chapters 02, 07, 13 and 15. Chapter 06 read paper 17 from its
  PDF, and chapter 07 read papers 18 and 20 the same way, so chapter 07 no
  longer depends on this item. **Chapter 13 read paper 26 from its PDF, so it no
  longer depends on it either, and chapter 15 is the last chapter that does.**
  This item is unblocked if
  `computer-science-news` restores them; otherwise those chapters draft from
  the PDFs alone and this item closes when the last of them is drafted.

  Chapter 13's session found a trap in reading a PDF directly that the earlier
  ones did not hit, and it is worth recording because it would have produced
  silent errors rather than obvious ones. Paper 26's math font carries no
  ToUnicode map, so `pdftotext` drops every Greek letter without warning: the
  extracted text of its definition 2.12 reads `f (k) = inf E(f, g)`, which looks
  like a definition of `f` and is in fact the definition of a function whose name
  is the dropped glyph. **Every symbol and every formula this chapter prints was
  re-read from the rendered page as an image rather than from the extraction**,
  and any later chapter reading a mathematical paper from its PDF should do the
  same. Prose extraction is unaffected and the word counts the chapter rests on
  were taken from it.
- **The limitation-statement log for chapter 18.** Each Part IV drafting
  session (chapters 08-14) records every limitation and future-work statement
  of its papers in that chapter's research note; chapter 18 is the intersection
  of that log. The "or in the chapter folder's scope comment until then" escape
  is spent: notes exist from chapter 08 on, so the note is the only place.
  Paper 21's log is recorded in `research/ch08-cac-ho-chi-so.md`, so chapter 09
  does not have to re-derive it. Paper 22's is in
  `research/ch10-vuon-bien-the-lime.md`, and papers 24 and 25 are in
  `research/ch12-con-nguoi-vang-mat.md`, and paper 23's is in
  `research/ch11-attribution-suot-duong-xuong.md`. **Five of the seven Part IV
  chapters are now logged**, leaving 13 and 14. The note for chapter 10 records the
  first crossing between two logs: papers 21 and 22 name the same blocking
  limitation, the absence of a validated evaluation instrument, from opposite
  directions, one by measuring that the instruments fail and one by recording
  that no standard for using them exists. Chapter 12 adds two more crossings.
  Papers 24 and 25 are the two halves of one statement that neither makes: the
  human check is almost never run, and where it was run the automated numbers
  did not track it. And Nauta et al. (2023), *From anecdotal evidence to
  quantitative evaluation methods*, is cited by three of the four logged papers
  for three different things, which makes the one shared reference across the
  critique core a review of how XAI is evaluated. The book has not read it and
  adds no key for it; if chapter 18 needs it as a source rather than as an
  observation, that is a reading decision for that session. Chapter 11 adds a
  crossing of a different kind. Paper 23's third limitation statement says a
  rigorous method comparison would need a faithfulness measurement and names
  deletion and insertion as the instrument it would use, which makes it the
  first paper in the log to name the missing instrument from *inside* a methods
  paper rather than from a critique or a survey. Papers 21, 22 and 23 now name
  the same blocking limitation from three directions: measured to fail, recorded
  as having no standard, and named as the next step not taken. **Paper 26's log
  is in `research/ch13-gioi-han-ly-thuyet.md`, so six of the seven Part IV
  chapters are now logged and only chapter 14 is left.** Paper 26 is the first
  entry that **does not cross**, and that is worth recording as much as a
  crossing: it never names the missing faithfulness instrument, because its
  object is `độ khớp`, and what it wants instead is a computable stand-in for
  Kolmogorov complexity and one experiment it names but did not run. Chapter 18
  takes the intersection of these statements, so a paper that intersects none of
  the others is a data point about the shape of the gap rather than a hole in the
  log. What paper 26 does add is a constraint on the answer: whatever a validated
  instrument turns out to measure, theorem 13.4 says in advance that it cannot be
  asked to certify agreement between a readable explanation and a complex model,
  so its job has to be describing where the two differ. Unblocked chapter
  by chapter as Part IV drafts.

- **The remaining init-written TOC lines have not been re-checked against their
  papers.** Decision 56 is the fifth over-promising line and the first whose
  subject was absent from the paper entirely, and the rule it adds is to
  re-check a line against the paper's abstract before drafting whenever the
  line's subject could have been read off the paper's title alone. That applied
  to chapters 13, 14, 15, 16 and 17. **Chapter 13's is checked and it held**
  (decision 59), which is the first init-written line since decision 24 to
  survive its paper, so the item is four chapters wide now: 14, 15, 16 and 17.
  Chapter 15's ("concept leakage as the CBM analogue of unfaithfulness") is the
  remaining one that most reads like a claim inferred from a title, so it is the
  next to check. **Chapter 13 also widened what the check is for.** Its line was
  not wrong, it was short: it named the ceiling and said nothing about the third
  of the paper that is about AI regulation, including one of the paper's three
  headline results. So the re-check is two-way, and the under-describing failure
  is the harder of the two to notice, because nothing in a drafting session
  contradicts a line that promises too little. This is cheap to discharge, one
  abstract per chapter before any drafting, and it closes when the last of those
  four is drafted.
- **CLOSED 2026-09-02 by chapter 11's session: chapter 12's opener is now
  answered, and it cost nothing.** The debt was that chapter 12 had been drafted
  first and its opener was written against a guess at what chapter 11 would end
  on: a loop with no elimination step, in which a method is proposed, compared
  against what exists on a metric its proposer chose, and published. Chapter 11
  took the first of the two ways out and ended on exactly that paragraph, so
  chapter 12 needed no edit at all. **The guess held for a reason worth keeping**:
  it was a guess about the *shape* of the argument rather than about the paper,
  and the shape survived the TOC line being wrong (decision 56) while everything
  else about chapter 11 changed. General rule this exposes: drafting Part IV out
  of order costs exactly one opener, which is cheap, but only if the debt is
  written down when it is incurred and only if the borrowed paragraph states a
  structure rather than a finding.
- **`Listings.MaxLineLength` unset.** Unblocked the day the book admits its
  first minted or verbatim environment: measure on a built page (decision 21)
  and set it in the same session.
- **Five chapter-owned terms sit in no appendix B block.** The 2026-08-24
  re-audit named "liên minh", "đóng góp biên", "trò chơi hợp tác" and "đường
  cong SHAP" in chapter 04 and "độ đo" in chapter 06: each is central, each is
  technical, and none is in the glossary, so the Gloss check cannot see them.
  Adding them was tried in that session and reverted: they appear in nearly
  every section of their chapters, so the once-per-section cadence would put
  about twenty parenthetical glosses on the page. Closing this means either
  accepting that cost, or adding them together with `Gloss.Exempt` entries and
  a SPEC rule saying which technical terms the cadence does not bind. "độ đo"
  is also the ordinary Vietnamese word for a measurement, so it is the first
  candidate the other open item on `Gloss.Exempt` anticipates.
- **CLOSED by decision 67: the dash convention is settled, and chapter 05 was
  the only exception.** Figure 5.1's integration arrow is now solid with the
  label `phép lấy giới hạn`, so dashed carries one sense book-wide and dotted
  carries one. The survey below stands as the evidence the call was made from,
  including its conclusion that no machine check should back it.

- **The dash convention is real for dotted and not settled for dashed.** Surveyed
  across all seven figures 2026-09-04, after chapter 13's audit found figure 13.1
  using dotted for three things while its caption named one. **Dotted means
  "missing" in four chapters and never anything else**: chapters 10, 11, 12 and
  13, each with a dotted node border and a dotted arrow carrying that one meaning
  in two shapes. **Dashed has two meanings.** Chapter 08 sets it for a free
  choice and chapter 13 follows; chapter 05, which predates both, uses it for the
  integration step. Chapter 13's caption is accurate as written, because it cites
  the convention *figure 8.1 sets* rather than claiming a book-wide one, but a
  reader meeting chapter 05 first has met the other sense already. Settling this
  means either rewording chapter 05's caption and figure to use another mark, or
  recording that dashed carries two senses and that the marks are far enough
  apart (an arrow against a box border) not to collide. **No machine check backs
  this and none should.** A check on "one pattern, one style" was proposed after
  chapter 13's audit and dropped once the survey ran: it fires on chapters 10, 11
  and 12, where two styles share a pattern deliberately, and the narrower version
  that avoids those never fires at all, not even on the figure 13.1 defect that
  prompted it. The defect is about what a mark refers to, which is decision 22's
  case: prose-only, and the audit carries it.
- **`Gloss.Exempt` is empty.** Grows one measured term at a time as the gate
  finds ordinary-Vietnamese collisions. "chuỗi" is the likely first, and it
  collides with the subtitle's "chuỗi suy luận" - settle which side owns it
  when appendix B gains its first rows.
- **The chapters are running six to ten typeset pages each.** Re-measured on the
  2026-08-25 chapter 10 build: chapters 01 through 10 start on printed pages 3,
  9, 15, 21, 27, 35, 39, 49, 57 and 67, and chapter 10 ends on page 74. Ten
  drafted chapters come to 72 pages against decision 6's 300-400 for eighteen.
  The Part IV trend decision 6 predicted now has three data points and it is not
  a trend: chapter 08 ran 8 pages, chapter 09 ran 10, chapter 10 runs 8, against
  six per chapter across Parts I and II. Extrapolating the core at nine pages
  and the rest at seven lands the book near 145 pages, well under half the
  target. Either the target or the density is wrong, and no audit has chosen:
  this closes with a decision-log row that revises decision 6 or that records
  why the current density is right. **Chapter 10 is the strongest evidence yet
  for the second reading and it points at a cause the earlier note missed.**
  Its length is set by how much its single paper actually contains, and paper 22
  is a survey with no experiment, so there is no results section to walk
  through. A book whose chapters are each one close reading will be as long as
  its papers are deep, and no drafting decision changes that. If the 300-400
  target is to be met, it has to be met by reading more papers per chapter or by
  adding chapters, not by writing the same chapters longer. Decide that before
  Part V rather than after.

  **Chapter 12 tests that prescription and it holds.** It is the first chapter
  to read two papers of different shapes rather than close-read one, and it runs
  14 printed pages, pages 83 to 96 of the 2026-09-02 build, against the 8 to 10
  of chapters 08 to 10. Nothing about it is padded: the audit cut two announcing
  paragraphs and widened five compressed passages, and the length came from the
  second paper. So the lever is real and it is the number of papers, not the
  word count. Two figures now bracket the choice: one paper per chapter lands
  the book near 145 pages, and chapter 12's rate over eighteen chapters would
  land it inside decision 6's 300-400. The decision that closes this item is
  therefore concrete: either revise decision 6 down to what one-paper chapters
  give, or assign a second paper to the chapters that can carry one and say
  which. That is an author call and no audit should make it.

  **Chapter 11 is a third data point and it lands between the two, which sharpens
  the prescription rather than confirming it.** It reads one paper, like chapters
  08 to 10, and runs 10 printed pages, 81 to 90, against their 8 to 10 and
  against chapter 12's 14. So the lever is not simply the number of papers.
  Paper 23 is one paper carrying a theory section, an analytic table and three
  experiments, and the chapter is as long as that content is deep, whereas paper
  22 is a survey with no experiment and gave the short chapter. The sharper
  statement: a chapter is as long as the *material* its papers contain, and
  "one paper" is not a length. Four Part IV chapters are now drafted at 8, 10,
  10 and 14 pages, which puts the core above the seven-page figure the earlier
  extrapolation used. The author call this item asks for is unchanged; the
  arithmetic under it should be redone from these four.

  **Chapter 13 is a fifth data point and it settles the sharpened statement.** It
  reads one paper, runs 13 printed pages, 105 to 117, and the paper it reads
  reports not a single measurement. So the length has nothing to do with results
  to walk through: it comes from a 55-page theory paper with three definitions,
  a dozen theorems and a section on regulation, and the chapter is as long as
  that material is deep. Five Part IV chapters now run 8, 10, 10, 14 and 13
  pages, averaging 11, against the six of Parts I and II. Redoing the
  arithmetic on that: eleven pages for the seven core chapters and seven for the
  other eleven lands the book near 175 pages including front and back matter,
  still under decision 6's 300 to 400. The prescription is unchanged and the
  choice is still the author's, but the gap is now smaller than the earlier
  extrapolation suggested and the lever is confirmed to be material rather than
  paper count.
