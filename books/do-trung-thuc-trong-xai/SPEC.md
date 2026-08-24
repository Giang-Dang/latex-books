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
with the tone-mark table, Gloss against appendix B). Chapters 01 through 05,
chapter 07 and chapter 08 are reviewed; chapter 06 is drafted and awaits its
audit, which is the last thing standing between Part III and done. Chapter 08's
session built the whole book on a host TeX distribution: 96 pages, no overfull
boxes, no undefined references, prose gate clean, and the rendered chapter pages
inspected before review.

Two things changed at the book level in chapter 08's session, both in the
decision log. The anchor paper turned out to meta-evaluate chain-of-thought
faithfulness rather than feature-attribution faithfulness (decision 33), which
resolves one open item and opens another about where chapter 09 belongs. And
the book crossed the research/ cliff (decisions 35 to 37): `research/` now holds
one note, so every decimal printed anywhere in the manuscript must trace to it.

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
| 23 | Chapter 02 source pins and terminology | Chapter 02 reads arXiv:1706.03762v7, 2005.14165v4, 2203.02155v1, 2201.11903v6 and 2606.11470v2; each pin and the claim class read are recorded in refs.bib. It prints no measurement, so research/ remains empty under decision 19. Its settled Vietnamese terms are the Chapter 02 block in appendix B; transformer remains English. |
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
9. **Chỉ số trung thực không đo độ trung thực** - the anchor paper read closely: constructed ground truth via known-mechanism tasks, metrics near chance. Its object is the faithfulness of chuỗi suy luận, not of feature attribution (decision 33), and the chapter has to carry that difference rather than let a reader assume the results land on Part II's methods. Paper 21 (arXiv 2605.25052).
10. **LIME nào đáng tin?** - LIME's instability as a concrete unfaithfulness case study; the variant zoo. Paper 22.
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
| 01 | reviewed | Audited against arXiv:1606.03490v3, 1702.08608v2 and 2601.00428v2; the audit finding was fixed. Voice revision 2026-08-24 for cohesion per tone-giao-trinh (decision 22); that session also cleared the pending build: latexmk exits 0 (65 pages) and the full gate is clean. |
| 02 | reviewed | Audited against the five pinned foundation papers in refs.bib. Audit fixes: named the Part II forward reference, made the LLM index entry a plain entry, and recorded transformer in appendix B. Full LuaLaTeX build clean (67 pages); mechanical prose gate clean. |
| 03 | reviewed | Audited against arXiv:1602.04938v3; audit fixes unified the hàm nhân terminology and corrected the TOC scope. The unified notation is seeded in appendix A and Chapter 03 terms in appendix B. Full LuaLaTeX build is clean (69 pages), the full prose gate is clean, and the rendered Chapter 3 pages were inspected. |
| 04 | reviewed | Audited against arXiv:1705.07874v2 and 2602.10532v1. Audit fixes added section transitions, corrected a cross-reference tie, and settled the three translated SHAP axioms in appendix B. Full LuaLaTeX build clean (71 pages); mechanical prose gate clean; the rendered chapter pages were inspected. |
| 05 | reviewed | Drafted and audited 2026-08-24 from arXiv:1703.01365v2 and arXiv:1610.02391v4. Seven sections plus summary and questions; one TikZ mechanism diagram. The chapter defines sensitivity, implementation invariance, Integrated Gradients, completeness, baseline selection, and Grad-CAM, then carries the baseline and representation-choice question into chapter 06. No paper-reported decimal is printed, so research/ remains empty under decision 19. Full LuaLaTeX build clean (75 pages); mechanical prose gate clean; rendered chapter pages inspected. |
| 06 | drafted | Read arXiv:2505.24729v1 directly because its orientation note is unavailable. Seven sections plus summary and questions; one TikZ diagram. It separates attribution constraints from the choice of measure, recovers conditional, independent and partial-dependence forms, and carries the question of validating the chosen measure into chapters 07 and 08. No paper-reported decimal is printed, so research/ remains empty under decision 19. Prose gate is clean; the full LuaLaTeX build it was waiting on ran clean in chapter 07's session. |
| 07 | reviewed | Drafted and audited 2026-08-24 from arXiv:2501.18887v3 and arXiv:2505.07005v1, both read as PDFs. Seven sections plus summary and questions; one TikZ diagram; one numbered definition and two equations. It states the attribution function over a chosen set of aspects, walks data and component attribution through the same three techniques Part II used, gives the local function approximation framework its equation, then sets attribution on the survey's range and stage axes. It closes on the shared evaluation vocabulary, fidelity, inverse fidelity and sparsity, which chapter 08 takes up. No paper-reported decimal is printed, so research/ remains empty under decision 19. Full LuaLaTeX build clean (87 pages, no overfull boxes); mechanical prose gate clean; the rendered chapter pages were inspected. |
| 08 | reviewed | Drafted and audited 2026-08-24. Seven sections plus summary and questions; one TikZ diagram; one numbered definition and one equation. It places every faithfulness metric in Doshi-Velez and Kim's functionally-grounded tier, reduces the whole literature to one counterfactual loop with three free choices, then walks four families through it: deletion and insertion with comprehensiveness and sufficiency, ROAR and the out-of-distribution objection, Sensitivity-n and infidelity, and the randomization tests that are necessary conditions rather than metrics. It closes on paper 21's four-category grouping and its stated diagnosis, naming in the prose that the paper's object is chuỗi suy luận (decision 33). Cites seven papers from outside the corpus (decision 34); no corpus paper defines a metric. Crossed the research/ cliff (decisions 35 to 37) while printing no decimal of its own. Full LuaLaTeX build clean (96 pages, no overfull boxes, no undefined references); mechanical prose gate clean; the rendered chapter pages were inspected. |
| 09 | not-started | The anchor chapter. |
| 10 | not-started | |
| 11 | not-started | |
| 12 | not-started | |
| 13 | not-started | Orientation note dead; draft from the PDF. |
| 14 | not-started | |
| 15 | not-started | Both CBM orientation notes dead; draft from the PDFs. |
| 16 | not-started | Re-uses papers 21, 24, 18, 32; no new corpus paper. |
| 17 | not-started | Blocked on the CoT-corpus open item before outlining. |
| 18 | not-started | Needs the limitation-statement log the open items describe. |
| App A | not-started | Stub with a placeholder paragraph; seeded by chapter 03's session. |
| App B | not-started | Skeleton with the keep-in-English block heading in place so the Gloss check binds; per-chapter blocks land with their chapters. |
| App C | drafted | Ten abbreviations seeded at init; grows with the chapters. |
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
  section's conclusion, and within a paragraph consecutive sentences connect
  through a relation word, an explicit antecedent, or topic repetition - never
  bare juxtaposition. One name per concept, book-wide; the settled ledger so
  far: "lời giải thích" (the artifact; "giải thích" only as the act),
  "phương pháp hậu nghiệm" (never "mô hình hậu nghiệm"), "cách đánh giá" (the
  Doshi-Velez and Kim taxonomy; never "tầng" or "phép thử"). A chapter that
  settles a new term appends it here in the same session. Chapter 02 adds
  "mô hình ngôn ngữ lớn", "cơ chế chú ý", "tiền huấn luyện", "lời nhắc",
  "học tăng cường từ phản hồi của con người" and "chuỗi suy luận"; transformer
  stays English. Chapter 07 adds "hàm attribution", "attribution dữ liệu",
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
  so the audit step carries it.
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
- **Chapter apparatus:** every chapter closes with the `tomtat` box (3-6
  bullets restating the chapter's claims and definitions, nothing new) then
  `\cauhoi` with numbered questions in a `cauhoids` list; in Parts II-V at
  least one question per chapter directs the reader into a primary paper by
  name with `~\autocite`. Chapters in Parts II-IV also end their body with a
  short section naming what the chapter's papers left unsolved - the hinge to
  the next chapter.
- **Companion code:** none. There is no repo, no verify command, no tag
  convention, and the book says nothing that would need one.
- **Research:** the cliff is crossed. `research/` holds one note from chapter
  08 (decision 35), so the Numbers and Verbatim checks are live over the whole
  manuscript: every decimal printed anywhere must appear in some note here.
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
- **Where the anchor chapter belongs, now that its object is known.** Decision 8
  put paper 21 at chapter 09 so it would land right after the metric families,
  and decision 33 shows its evidence is CoT evidence while chapters 10 to 14
  critique attribution. Three ways out, none taken yet: leave 09 where it is and
  have it carry the difference explicitly (what chapter 08's closing section
  already sets up, and the cheapest); move the close reading to Part V beside
  chapter 17 and leave chapter 09 as the argument without the benchmark; or
  split it, the methodology at 09 and the CoT results at 17. This is a
  book-spine call for the author. Chapter 08 ships correctly under all three,
  so nothing is blocked on it, but chapter 09 is.
- **Six orientation notes are dead locally** (papers 02, 07, 20, 26, 30,
  31). Costs nothing to correctness - notes are never citable - but slows
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
  does not have to re-derive it. Unblocked chapter by chapter as Part IV drafts.
- **`Listings.MaxLineLength` unset.** Unblocked the day the book admits its
  first minted or verbatim environment: measure on a built page (decision 21)
  and set it in the same session.
- **`Gloss.Exempt` is empty.** Grows one measured term at a time as the gate
  finds ordinary-Vietnamese collisions. "chuỗi" is the likely first, and it
  collides with the subtitle's "chuỗi suy luận" - settle which side owns it
  when appendix B gains its first rows.
- **Whether appendix A (notation) must precede Part II.** LIME, SHAP and IG
  notations conflict. Chapter 03's drafting session decides the unified
  notation and seeds appendix A, or records that chapters carry their papers'
  own notation with a mapping.
