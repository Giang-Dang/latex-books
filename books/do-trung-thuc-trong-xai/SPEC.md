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
11. **Attribution suốt đường xuống** - the research metagame: benchmark churn, metric proliferation, the incentives behind yet another unvalidated metric. Paper 23.
12. **Con người vắng mặt** - fewer than 1 percent of XAI papers validate with humans; automated metrics vs what users actually perceive. Papers 24, 25.
13. **Giới hạn lý thuyết của giải thích** - the algorithmic-information-theoretic ceiling on explainability, and what a bound does and does not say about practice. Paper 26.
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
| 01 | reviewed | Audited against arXiv:1606.03490v3, 1702.08608v2 and 2601.00428v2; the audit finding was fixed. Voice revision 2026-08-24 for cohesion per tone-giao-trinh (decision 22); that session also cleared the pending build: latexmk exits 0 (65 pages) and the full gate is clean. Chapter 01-06 audit 2026-08-24: three attributions to papers 13, 14 and 15 corrected against the PDFs, proxy and hộp đen glossed and added to appendix B, the two definition titles unnested, the figure caption cut to what the prose does not already say, and the chapter indexed for the terms it owns. |
| 02 | reviewed | Audited against the five pinned foundation papers in refs.bib. Audit fixes: named the Part II forward reference, made the LLM index entry a plain entry, and recorded transformer in appendix B. Full LuaLaTeX build clean (67 pages); mechanical prose gate clean. Chapter 01-06 audit 2026-08-24: the 2606.11470 pin corrected to v1 against the PDF stamp, the chain-of-thought and reasoning-survey claims narrowed to what the papers state, the InstructGPT figure retitled because that pipeline produces an instruction-following model rather than a dialogue one, and prompt, RLHF, reward model and CoT each collapsed to one name. |
| 03 | reviewed | Audited against arXiv:1602.04938v3; audit fixes unified the hàm nhân terminology and corrected the TOC scope. The unified notation is seeded in appendix A and Chapter 03 terms in appendix B. Full LuaLaTeX build is clean (69 pages), the full prose gate is clean, and the rendered Chapter 3 pages were inspected. Chapter 01-06 audit 2026-08-24: the opener no longer credits chapter 02 with a definition chapter 01 makes, the sample set now matches the algorithm and appendix A, the pseudo-code caption says which steps come from the paper's prose rather than its numbered algorithm, and five names for the interpretable representation collapsed to one. |
| 04 | reviewed | Audited against arXiv:1705.07874v2 and 2602.10532v1. Audit fixes added section transitions, corrected a cross-reference tie, and settled the three translated SHAP axioms in appendix B. Full LuaLaTeX build clean (71 pages); mechanical prose gate clean; the rendered chapter pages were inspected. Chapter 01-06 audit 2026-08-24: the player set renamed to $\mathcal{P}$ (decision 41), the uniqueness result and the three properties numbered, consistency restated over two models as paper 10 has it, the TreeSHAP attribution corrected because paper 10 never names it, and the duplicated noun in 4.4 fixed. |
| 05 | reviewed | Drafted and audited 2026-08-24 from arXiv:1703.01365v2 and arXiv:1610.02391v4. Seven sections plus summary and questions; one TikZ mechanism diagram. The chapter defines sensitivity, implementation invariance, Integrated Gradients, completeness, baseline selection, and Grad-CAM, then carries the baseline and representation-choice question into chapter 06. No paper-reported decimal is printed, so research/ remains empty under decision 19. Full LuaLaTeX build clean (75 pages); mechanical prose gate clean; rendered chapter pages inspected. Chapter 01-06 audit 2026-08-24: the completeness proposition restated under absolute continuity (decision 40), citations added to the two sections that carried none, the pre-softmax qualifier restored to $y^c$, baseline settled as English (decision 38), and tầng separated from lớp. |
| 06 | drafted | Read arXiv:2505.24729v1 directly because its orientation note is unavailable. Seven sections plus summary and questions; one TikZ diagram. It separates attribution constraints from the choice of measure, recovers conditional, independent and partial-dependence forms, and carries the question of validating the chosen measure into chapters 07 and 08. No paper-reported decimal is printed, so research/ remains empty under decision 19. Prose gate is clean; the full LuaLaTeX build it was waiting on ran clean in chapter 07's session. Chapter 01-06 audit 2026-08-24: the ReLU closed form now carries the paper's positivity hypothesis, "high dimensional" scoped back to the Monte-Carlo branch, the paper's actual second limitation restored with the book's own point moved out of the citation's scope, the central definition and theorem numbered, and the figure redrawn to the book's idiom. |
| 07 | reviewed | Drafted and audited 2026-08-24 from arXiv:2501.18887v3 and arXiv:2505.07005v1, both read as PDFs. Seven sections plus summary and questions; one TikZ diagram; one numbered definition and two equations. It states the attribution function over a chosen set of aspects, walks data and component attribution through the same three techniques Part II used, gives the local function approximation framework its equation, then sets attribution on the survey's range and stage axes. It closes on the shared evaluation vocabulary, fidelity, inverse fidelity and sparsity, which chapter 08 takes up. No paper-reported decimal is printed, so research/ remains empty under decision 19. Full LuaLaTeX build clean (87 pages, no overfull boxes); mechanical prose gate clean; the rendered chapter pages were inspected. |
| 08 | reviewed | Drafted and audited 2026-08-24. Seven sections plus summary and questions; one TikZ diagram; one numbered definition and one equation. It places every faithfulness metric in Doshi-Velez and Kim's functionally-grounded tier, reduces the whole literature to one counterfactual loop with three free choices, then walks four families through it: deletion and insertion with comprehensiveness and sufficiency, ROAR and the out-of-distribution objection, Sensitivity-n and infidelity, and the randomization tests that are necessary conditions rather than metrics. It closes on paper 21's four-category grouping and its stated diagnosis, naming in the prose that the paper's object is chuỗi suy luận (decision 33). Cites seven papers from outside the corpus (decision 34); no corpus paper defines a metric. Crossed the research/ cliff (decisions 35 to 37) while printing no decimal of its own. Full LuaLaTeX build clean (96 pages, no overfull boxes, no undefined references); mechanical prose gate clean; the rendered chapter pages were inspected. |
| 09 | reviewed | The anchor chapter, drafted and audited 2026-08-25 from arXiv:2605.25052v1 read in full (pages 1-9 and 18-31). Seven sections plus summary and questions; one TikZ diagram; the book's first table float (decision 44); two numbered definitions. It rebuilds the anchor's method (ground truth forced by task design rather than observed inside the model), its BonaFide benchmark, its AUROC results, and its two diagnoses, then spends section 9.7 on what crosses to feature attribution and what does not, under decision 42. **First chapter in the book to print a measurement**, so it created `research/ch09-bai-bao-neo.md` and settled decision 43; it also corrected the LM Judge skyline margins in chapter 08's note. Full LuaLaTeX build clean (112 pages, no overfull boxes, no undefined references); mechanical prose gate clean; the rendered chapter pages were inspected, which is how the figure's note-over-arrow collision was caught. The 2026-08-25 audit fixed a miscount of the prior-work comparisons, named Chen and Shen where the prose had left prior work anonymous, cut the paragraph narrating the book's own decimal notation to the reader, trimmed the figure caption to what the prose does not already say, added the FUR row the table-5 argument had skipped, and unified `kiểm định chỉ số` with chapter 08's index heading. Six audit findings were rejected on the record, five of them because the claim was in the paper and the research note was what lacked the anchor; the note now carries all five. |
| 10 | reviewed | Drafted and audited 2026-08-25 from arXiv:2503.24365v1, body pages 1-18 read in full from the PDF, with the revision and the arXiv Comments field re-verified on the abstract page and through the API. Seven sections plus summary and questions; one TikZ diagram; one numbered definition; no table float. It reads the variant survey as the field's own record of what happened to LIME: five issue categories, four pipeline substeps, 48 techniques of which 32 aim at the surrogate's fidelity or at stability, then the survey's discussion, where 50\% of the techniques have no code, most papers compare only against vanilla LIME, and evaluation metrics get chosen to confirm the contribution. Section 10.6 turns on a verified absence: `faithfulness` and `ground truth` occur zero times in the body, and the survey's `Correctness` property is definition 1.2 under a third name. **The TOC line was wrong and changed (decision 47)**: paper 22 runs no experiment, so instability is reported as its classification, not as a result it measured. Its glossary sweep moved `tính cục bộ` to chapter 03 and `tính ổn định` to chapter 08 (decision 50) and it declined to add an appendix B row that would have collided with `fidelity` (decision 49). Prints no decimal: every number in it is an integer or a whole percentage, all recorded in `research/ch10-vuon-bien-the-lime.md`. Full LuaLaTeX build clean (118 pages, no overfull boxes, no undefined references); mechanical prose gate clean; the rendered chapter pages were inspected. **The 2026-08-25 audit was the most productive this book has had and two of its findings were structural.** It caught that chapter 09's closing paragraph hands this chapter the instability case explicitly (\enquote{Chương 10 đọc trường hợp ấy trên chính LIME}) while the draft opened on chapter 09's middle and then disclaimed all measurement, so the hand-off was broken; the opener was rewritten to take the hand-off and to answer it with what the survey actually is. It also caught section 10.6 treating chapter 09's near-chance AUROCs as evidence against chapter 08's metric families, which is exactly the transfer decision 42 and section 9.7 exist to block; that passage now says the objection is that the metrics are unverified rather than that they are known broken, and names the boundary. Other fixes: the survey's sample-generation step has five subgroups and the draft said four; the fourth feature-generation subgroup is unnamed in the source and the draft had renamed it after one member; a citation was attributing to chapter 08's prose a zero-occurrence claim that lives only in decision 34; definition 10.1 carried a citation for a positive statement the survey only makes negatively; the survey's \enquote{or} had become \enquote{and} and its \enquote{many papers} had become \enquote{most}; the 50\% is now stated with the paper's own phrasing plus the note that the body never says whether it is the share lacking code or holding it; the figure's dashed \enquote{missing} boxes became dotted because chapter 08's figure already uses dashed for a free choice; and five announcing sentences, three punchline closes and two colloquial spans were cut for the textbook tone. Six findings were rejected: four were already fixed before the auditor read (the missing decision rows, the not-started progress row, the incomplete parameter mapping, the `\emph`/`\enquote` inconsistency), and two were judged wrong on the record, namely that `tính ổn định` should belong to chapter 10 rather than chapter 08 (decision 27 gives it to the chapter that introduced it, which is 08) and that `độ khớp` needs an appendix B row (decision 49 explains why it must not have one, though the `fidelity` keep-row was extended to carry the collision). |
| 11 | not-started | |
| 12 | not-started | |
| 13 | not-started | Orientation note dead; draft from the PDF. |
| 14 | not-started | |
| 15 | not-started | Both CBM orientation notes dead; draft from the PDFs. |
| 16 | not-started | Re-uses papers 21, 24, 18, 32; no new corpus paper. |
| 17 | not-started | Blocked on the CoT-corpus open item before outlining. |
| 18 | not-started | Needs the limitation-statement log the open items describe. |
| App A | drafted | Seeded by chapter 03, extended by chapters 04 through 07, and made a longtable by decision 30. The chapter 01-06 audit added rows for the feature count and for Grad-CAM's `$Z$`, renamed the player set to `$N$`, and put `hàm nhân` back in Vietnamese. |
| App B | drafted | Nine per-chapter blocks plus the keep-in-English block, 69 terms under the Gloss check. The chapter 01-06 audit added ten terms the prose used but the appendix never listed, dropped an unused `tích phân đường` row, and moved `baseline` to the keep-in-English block under decision 38. Chapter 09 added its own block of thirteen, `mức quan trọng` to chapter 08's block, and ten metric and dataset names to the keep-in-English block, SCM among them with no expansion (decision 46). Chapter 10 added a block of four, six names to the keep-in-English block, and gave `tính cục bộ` to chapter 03 and `tính ổn định` to chapter 08 rather than claiming them (decision 50); it deliberately added no row for the survey's `fidelity` (decision 49). Now ten per-chapter blocks and 75 terms under the Gloss check. |
| App C | drafted | Thirteen abbreviations: ten seeded at init, plus Grad-CAM (used eighteen times, never expanded in the prose), and AUROC and FUR from chapter 09. SCM is deliberately absent under decision 46. Grows with the chapters. |
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
- **Economy:** vừa, as `tone-giao-trinh.md` sets it - the profile's own
  level, kept, not overridden. A derivation shows every step and a step is
  not padding; what still gets cut is the prose around the material: the
  paragraph announcing a theorem, the paragraph summarizing what the section
  just proved.
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
  "quy tắc nguyên tử" and "vector" (never "vectơ"). baseline, embedding,
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
  its own metric names.
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
  09 and 10 (decision 35), so the Numbers and Verbatim checks are
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
  longer depends on this item. This item is unblocked if
  `computer-science-news` restores them; otherwise those chapters draft from
  the PDFs alone and this item closes when the last of them is drafted.
- **The limitation-statement log for chapter 18.** Each Part IV drafting
  session (chapters 08-14) records every limitation and future-work statement
  of its papers in that chapter's research note; chapter 18 is the intersection
  of that log. The "or in the chapter folder's scope comment until then" escape
  is spent: notes exist from chapter 08 on, so the note is the only place.
  Paper 21's log is recorded in `research/ch08-cac-ho-chi-so.md`, so chapter 09
  does not have to re-derive it. Paper 22's is in
  `research/ch10-vuon-bien-the-lime.md`. Two of the seven Part IV chapters are
  now logged, and the note for chapter 10 records the first crossing between two
  logs: papers 21 and 22 name the same blocking limitation, the absence of a
  validated evaluation instrument, from opposite directions, one by measuring
  that the instruments fail and one by recording that no standard for using them
  exists. That crossing is chapter 18's first actual intersection rather than a
  single paper's list, so chapter 18 should start from it. Unblocked chapter by
  chapter as Part IV drafts.
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
