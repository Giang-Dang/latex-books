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
with the tone-mark table, Gloss against appendix B). Next action: draft
chapter 01.

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

3. **LIME: mô hình thay thế cục bộ** - LIME's full mechanics (sampling, kernel, sparse linear fit) and the free parameters nobody validates. Paper 09.
4. **SHAP và giá trị Shapley** - Shapley axioms, KernelSHAP and TreeSHAP, the feature-independence assumption, the statistical grounding SHAP later acquired. Papers 10, 19.
5. **Attribution theo gradient: Integrated Gradients và Grad-CAM** - IG's axioms and path integral, the baseline as an unvalidated setting, Grad-CAM for CNNs. Papers 11, 12.

### Phần III - Lý thuyết attribution

6. **Attribution từ nguyên lý đầu** - what attribution can even mean, rebuilt without reference to any one method; the assumptions Part II's methods share. Paper 17.
7. **Một khung hợp nhất cho attribution** - one formalism across feature attribution, data attribution and mechanistic interpretability; the field map before the critique. Papers 18, 20.

### Phần IV - Phê phán độ trung thực

8. **Đo độ trung thực: các họ chỉ số** - the faithfulness metric families and the assumption each smuggles in; a metric is an instrument, and instruments need validation. Setup of paper 21; papers 14, 20.
9. **Chỉ số trung thực không đo độ trung thực** - the anchor paper read closely: constructed ground truth via known-mechanism tasks, metrics near chance. Paper 21 (arXiv 2605.25052).
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
| 01 | not-started | |
| 02 | not-started | |
| 03 | not-started | First Part II chapter; its session settles the unified notation question (open item on appendix A). |
| 04 | not-started | |
| 05 | not-started | |
| 06 | not-started | Orientation note dead; draft from the PDF (decision 13). |
| 07 | not-started | Paper 20's orientation note dead; draft from the PDF. |
| 08 | not-started | Likely the chapter that first prints a paper-reported number and crosses the research/ cliff (decision 20). |
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
- **Research:** research/ starts empty on purpose (decision 19), so the
  Numbers and Verbatim checks stay dormant. The promise: the session that
  first prints a paper-reported number creates that chapter's note under
  research/, per decision 20, and from that moment every decimal in the book
  traces; the crossing session retro-sweeps earlier chapters. One note per
  chapter thereafter; a claim checked against a PDF and found false is
  recorded in the note too, so the next session does not re-derive it.
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

- **No dedicated CoT-faithfulness paper in the corpus.** Chapter 17
  currently rests on papers 06, 08 and 16 plus the transfer of the Part IV
  critique. Unblocked by a decision-log row before outlining chapter 17:
  either extend the corpus (add the paper to refs.bib and appendix D, read
  the PDF) or scope the chapter to the transfer argument alone.
- **Seven orientation notes are dead locally** (papers 02, 07, 17, 20, 26,
  30, 31). Costs nothing to correctness - notes are never citable - but
  slows drafting of chapters 02, 06, 07, 13 and 15. Unblocked if
  `computer-science-news` restores them; otherwise those chapters draft from
  the PDFs alone and this item closes when the last of them is drafted.
- **The limitation-statement log for chapter 18.** Each Part IV drafting
  session (chapters 08-14) records every limitation and future-work statement
  of its papers in that chapter's research note once notes exist, or in the
  chapter folder's scope comment until then; chapter 18 is the intersection
  of that log. Unblocked chapter by chapter as Part IV drafts.
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
