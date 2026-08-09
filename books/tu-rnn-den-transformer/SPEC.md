# SPEC - Tu RNN den Transformer

Source of truth for this book: decisions, approved TOC, and progress. Read it
fully before working on the book; update the progress table before finishing a
working session.

Title: **Từ RNN đến Transformer**
Subtitle: *Sáu bài báo gốc từ 1997 đến 2021, và những gì đến sau*
Author: Giang Dang
Language: Vietnamese

This SPEC is in English while the book is in Vietnamese. That is decision 18:
`draft-chapter` reads the slot labels below, the library's other SPEC is
English, and a decision log that mixes the two is harder to scan than one that
picks a side. Chapter titles are quoted in Vietnamese exactly as they are set.

## Status

Chapters 01, 02 and 03 drafted. Six appendices now: C was split out of B on
2026-08-09 (decision 28) and the old C, D and E became D, E and F.

Chapter 03 was drafted out of order, in a session that branched before chapters
01 and 02 landed on main. Nothing was lost, but the reconciliation cost real
time; decision 30 exists so the next session does not repeat it.

Next action: chapter 04, "Sửa bằng kiến trúc". It inherits a settled notation
(decision 25), a companion repo with tags through `ch03`, and the requirement in
decision 24 that its vocabulary stay inside software engineering, ML and
mathematics.

## Decision log

Settled 2026-08-09 through a three-round requirements interview. A settled row
is re-opened only by recording what changed and why, in the row.

| # | Question | Decision |
|---|----------|----------|
| 1 | Audience | Third and fourth year CS/AI undergraduates who have had a first machine learning course: backprop, multivariable calculus, linear algebra, some PyTorch or numpy. Chapter 01 is a self-service top-up for anyone thin on that, not a second course |
| 2 | Spine | Problem-driven. Chapters are named after the problem, not after the paper. Each one states what the previous work could not do, then opens the paper that fixed it, then names what that fix broke or left open. A paper is evidence, not a syllabus item |
| 3 | Mathematical depth | Full derivations in the running text, not in an appendix. The vanishing and exploding conditions, the derivative through the LSTM constant error carousel, the variance argument behind 1/sqrt(d_k), and the cost of self-attention are all worked where the reader meets them. A student who cannot differentiate the architecture cannot modify it, and modifying it is goal three |
| 4 | Code | A companion repo in PyTorch, built from scratch, tagged per chapter. Every listing in the book comes from it at that chapter's tag |
| 5 | Scope beyond the six papers | Extended to 2026 for real, not as an epilogue. Part VI is four chapters: FlashAttention, RoPE and long context, SSMs and Mamba, and deployment reality. Reason: a book that stops at ViT presents 2021's open problems as open, and several of them were closed years ago. Intermediate papers the spine needs (Cho 2014, Luong 2015, Gers 2000, layer norm, residual, BERT, GPT) get bridge boxes rather than chapters |
| 6 | Length | 330-380 pages, 16 chapters, 6 appendices after decision 28. Not the "small book" the request opened with; decisions 2, 3, 4 and 5 each cost pages and the author took all four |
| 7 | Numbers | Two kinds, kept visibly apart. Numbers a paper reported are cited. Numbers I measured go in a `measured` box and trace to a research note. Experiments are toy-scale on purpose (decision 13) |
| 8 | Exercises | Three tiers per chapter, one per goal: "Kiểm tra hiểu" (questions on the derivation and the figures), "Để tay vào" (code against a repo tag, checkable), "Đẩy xa hơn" (open questions, at least one of which is a real unsolved gap, and the book says so) |
| 9 | Tone | Chapter body takes the chapter role, end-of-chapter exercises the lab role, appendices the appendix role, `frontmatter/` the front matter role. Resolved through `humanizer-vi`: `tone-chuong-sach`, `tone-thuc-hanh`, `tone-phu-luc`, `tone-loi-noi-dau` |
| 10 | Pronouns | "tôi" for the author, "bạn" for the reader. One pair for the whole book, per humanizer-vi's third hard constraint. Never "chúng ta" for what one author did |
| 11 | Notation | One notation for the whole book, defined in chapter 01, with appendix A mapping it back to what each of the six papers wrote. The six conflict genuinely: LSTM's `c_t` is a cell state and Bahdanau's `c_i` is a context vector. Without one notation the book cannot set two papers' equations side by side, which is most of what it exists to do |
| 12 | Foundation chapter | Exactly one: notation, backprop in Jacobian form, BPTT, a three-step worked example, and finite-difference gradient checking. Not a course in deep learning |
| 13 | Hardware | Every experiment finishes on a CPU-only laptop in minutes. The GPU path is an optional override, never the default. Reason: the reader is a Vietnamese undergraduate, and an experiment that needs a card the reader does not have is a figure, not an experiment |
| 14 | Where the work happens | A dedicated worktree of `latex-books` on branch `book/tu-rnn-den-transformer`, at `F:/repo/latex-books-transformers`. Companion code is a second git repo, public on GitHub |
| 15 | Title | "Từ RNN đến Transformer", folder `tu-rnn-den-transformer`. The subtitle offered during the interview said "Mười ba năm kiến trúc chuỗi", which was written before decision 5 extended the book to 2026; corrected to "Sáu bài báo gốc từ 1997 đến 2021, và những gì đến sau" in the same session |
| 16 | Glossed terms | A term this book translates carries its English original in parentheses at **every** occurrence, not just the first, so that a reader opening at chapter 9 gets the same help as one who started at page 1. A term the book keeps in English takes no parentheses: "attention (attention)" helps nobody. Which terms fall on which side is settled once in appendix B |
| 17 | Spelling of the English glosses | en-US, matching how all six papers spell. `Spelling = @{ Enabled = $true; Preset = 'en-US' }` in `check-chapter.psd1`, so "(initialisation)" is a finding. A gloss in the wrong variety sends a student searching for a string that is not in the paper |
| 18 | Language of SPEC.md and check-chapter.psd1 | English. `draft-chapter` reads the slot labels, and the library's other SPEC is English |
| 19 | Companion repo environment | Conda, not venv and not bare pip. The repo ships `environment.yml` pinning the env name, the Python version and the PyTorch build; the verify script activates that env before it runs anything, so a clean run does not depend on whose machine it is. Appendix D teaches the conda path. Default install is CPU-only PyTorch per decision 13; the GPU path is a separate override file, never an edit to the main one |
| 20 | Crossing the research cliff now, deliberately | `research/` holds one note from the skeleton session, so the `number` and `verbatim` checks are armed from before the first sentence of prose exists. `research/README.md` warns that the transition should be met on purpose; the cheapest possible moment to meet it is when there is no prose to retrofit. Every decimal this book ever prints has therefore had to trace since page zero |
| 21 | Glosses are written through a macro | `\tn{vietnamese}{english}` in `preamble/macros.tex`, never by hand. It sets the parentheses once instead of 400 times, and it turns decision 16 from a discipline into something greppable later: a glossary term appearing in the prose outside `\tn` is a miss. See the open item on the gloss check |
| 22 | The six PDFs stay out of the repo | `latex-books` has a public GitHub remote, and "Long Short-Term Memory" is an MIT Press journal article; committing it would be redistribution rather than archiving. `research/2026-08-nguon-sau-bai-bao.md` records the folder, the arXiv version of each copy, and a SHA-256 per file instead, so a later session can tell whether it is reading the same bytes the citations were checked against. Do not add a `*.pdf` ignore rule inside the book folder: `figures/images/` may hold PDF artwork |
| 23 | Two language mappings in the preamble, and the load order they force | biblatex ships no `vietnamese.lbx` and csquotes ships no Vietnamese style, so both warn once Vietnamese is the main language. `\DeclareLanguageMapping{vietnamese}{english}` and `\DeclareQuoteAlias{english}{vietnamese}` fix them, and the second is correct rather than expedient: modern Vietnamese uses the same curly double quotes English does. This also pins the load order in `preamble/packages.tex` to minted, then csquotes, then biblatex, because fvextra (loaded by minted) wants csquotes after it and biblatex wants csquotes before it. Moving csquotes back up to the other packages reintroduces a warning on every run |
| 24 | Vocabulary stays inside the book's own fields | This is a software engineering and AI book, so its prose takes words from software engineering, machine learning and mathematics, and does not reach into an unrelated domain for a metaphor. Settled 2026-08-09 when the author rejected "triệu chứng" (symptom). The whole medical register went with it: chapter 02's title became "Hiện tượng", chapter 03's became "Phân tích", and "căn bệnh", "chẩn đoán" and "chữa" were rewritten wherever chapters 01 and 02 used them, folders and labels included. Carve-out: a vivid word that is established terminology in this literature stays, and the error-surface geometry of Pascanu et al., the wall and the valley, is the case that matters most. The test is whether a reader would meet the word in a paper, not whether it is vivid |
| 25 | The loss is `L`, and the state has two names | Chapter 01 was drafted with `L` for the cost and chapter 03 arrived using `\mathcal{E}`, which is what Pascanu writes. `L` wins, because one notation for the whole book beats matching any single paper, and chapter 03 was rewritten. Appendix A records that Pascanu writes `E`. Alongside it: `x_t` input, `a_t` pre-activation, `h_t = sigma(a_t)` hidden state. Two state variables rather than one, because Pascanu's recurrence *is* the book's pre-activation form: naming the argument of sigma in `h_t = sigma(W_hh h_{t-1} + ...)` as `a_t` turns their equation into this book's, symbol for symbol. That identity is what lets chapter 03 derive against the paper without a second notation, and chapter 01's code already used both names. Refines decision 11 |
| 26 | The companion repo is organized by topic from chapter 03 on | Chapters 01 and 02 put one module per chapter in `rnn_to_transformer_lab/`, each exposing a `verify()`. From chapter 03 the package is organized **by topic**, because chapter 04 replaces the recurrence but keeps the Jacobian machinery and a per-chapter module would mean copying it. What pins a chapter's state is its tag. The chapter 01 and 02 modules are left exactly as they are, since their tags are published; the repo README names the seam. Two things found while doing it: the chapter 01 and 02 code is numpy rather than the PyTorch decision 4 asked for, and `environment.yml` listed `cpuonly` but resolved to `pytorch==2.6.0=cuda126_mkl_...`, installing several gigabytes of CUDA on a machine the book promised would not need one. It went unnoticed because that code imports torch nowhere. Fixed by installing torch from the CPU wheel index |
| 27 | Per-experiment CPU time budget | 60 seconds per experiment and 600 seconds for a whole `verify.py` run, enforced by that script rather than written down as a note. Measured at tag `ch03`: 124 seconds in total, of which chapter 02's verify is 92 and the whole of chapter 03 is 32. Closes the open item that said budgets were unset |
| 28 | Abbreviations are their own appendix | The abbreviation table arrived as a section inside appendix B during chapter 01. Split out into appendix C on 2026-08-09 at the author's request, so that notation, glossary and abbreviations are three lookups rather than two; the old C, D and E shifted to D, E and F. Nothing referenced an appendix by letter, so the shift cost only file renames |
| 29 | Appendices are lookup only | Settled 2026-08-09 after the author cut three openers as redundant. An appendix carries entries, not argument: no scene-setting paragraph, no rationale section, no closing note about how the table is maintained, no transition between entries. Why a term was translated, why a symbol was chosen, and how a table grows all belong in this SPEC. A reader reaches an appendix from the index, reads one row, and leaves |
| 30 | Check `origin/main` before drafting, not after | Chapter 03 was drafted in a worktree branched before chapters 01 and 02 landed, so it rebuilt appendix A and appendix B from scratch, duplicated the abbreviation table, and used a loss symbol the book had already chosen. None of it was lost, but the merge cost more than the drafting. The rule: `git fetch origin && git log --oneline origin/main -- books/<name>` before the first file is written, and read the SPEC from `origin/main` rather than from the working tree. This book's SPEC and its appendices are shared state, and two sessions can be editing them at once |

## Version baseline

Verified 2026-08-09 by building this book. Re-verify before any chapter that
depends on a version.

| Component | Version |
|-----------|---------|
| LuaHBTeX | 1.24.0 (MiKTeX 25.12) |
| babel | 2025/12/11 v25.17; Vietnamese from `babel-vi.ini`, hyphenation from `hyph-vi.tex` |
| fontspec | 2025/09/29 v2.9g; TeX Gyre Pagella / Heros / Cursor, loaded by filename |
| minted | 2026/03/03 v3.8.0, with Pygments 2.19.2 |
| biblatex / biber | 3.21 / 2.21 |
| csquotes | 2026 |
| tcolorbox | 2025/11/28 |
| conda | 26.1.1 |
| The six source papers | Exact arXiv versions and SHA-256 in `research/2026-08-nguon-sau-bai-bao.md` |

## Table of contents

Approved 2026-08-09. If drafting deviates, update this list in the same
session. Chapter folders in `chapters/` carry the same scope lines as a comment
in their `ch.tex`.

Every chapter in parts II to VI closes with the same two things: the tier-three
exercises, and a section naming what the paper did not solve and what it
created. That section is the hinge to the next chapter and is not optional.

### Part I - Nền tảng

1. **Chuỗi, ký hiệu, và lan truyền ngược qua thời gian** - why sequence data
   differs; the book's notation; the plain RNN; BPTT derived in Jacobian form; a
   three-step worked example; finite-difference gradient checking

### Part II - Gradient không đi xa được

2. **Hiện tượng: vì sao huấn luyện RNN thất bại** - the adding problem and the
   copy task; gradient norm measured against temporal distance; bridge boxes for
   Hochreiter 1991 and Bengio 1994
3. **Phân tích: khi nào gradient tắt và khi nào nổ** (Pascanu, Mikolov, Bengio 2013) - the sufficient condition for
   vanishing through the largest singular value of `W_hh`, the necessary
   condition for exploding; the dynamical-systems view and the gradient cliff;
   the paper's two remedies, clipping and the norm-preserving regularizer, and
   why only one is still used; gap: it fixes training, not memory
4. **Sửa bằng kiến trúc** (Hochreiter, Schmidhuber 1997) - the constant error
   carousel and the derivative through it; input and output gates; the gradient
   truncation in the original; bridge boxes for the Gers 2000 forget gate,
   peepholes, and Cho's GRU; gap: still sequential, four times the parameters

### Part III - Ánh xạ chuỗi sang chuỗi

5. **Encoder-decoder** (Sutskever, Vinyals, Le 2014) - the fixed-length context
   vector; source reversal; beam search; ensembling; a bridge box for Cho 2014.
   Careful here: this paper's own abstract says its LSTM did **not** struggle on
   long sentences, and the length-degradation result belongs to Cho. See the
   research note
6. **Đồng chỉnh** (Bahdanau, Cho, Bengio 2015) - the bottleneck measured before
   it is fixed; additive attention; the derivation showing a direct gradient
   path from every source step to every target step; the BiRNN encoder; a
   measured Vietnamese-English alignment matrix; a bridge box for Luong 2015;
   gap: attention is still an accessory bolted onto an RNN

### Part IV - Bỏ hẳn recurrence

7. **Kiến trúc Transformer** (Vaswani et al. 2017) - scaled dot-product with the
   variance argument behind 1/sqrt(d_k); multi-head attention; sinusoidal
   positional encoding and its linear-shift property; residuals, layer norm, the
   position-wise FFN; masked decoder self-attention
8. **Chi phí, song song hoá, và cái giá phải trả** - the paper's complexity
   table, re-measured as FLOPs, memory and wall clock against `n` on a CPU;
   warmup, label smoothing and dropout as load-bearing rather than tricks;
   post-LN versus pre-LN; gap: quadratic, no inductive bias, data-hungry
9. **Tiền huấn luyện: BERT, GPT, và quy luật scaling** - the bridge chapter ViT
   cannot be understood without; encoder-only versus decoder-only; pretraining
   as the invention rather than the architecture; Kaplan 2020 and Hoffmann 2022

### Part V - Ra khỏi ngôn ngữ

10. **Bias quy nạp của CNN** - locality, translation equivariance, weight
    sharing; the pre-ViT attempts: local attention, Image Transformer, iGPT
11. **Ảnh là 16x16 chữ** (Dosovitskiy et al. 2021) - patch embedding, the `CLS`
    token, learned positional embeddings; the headline result is that it loses
    to ResNet on ImageNet-1k and wins after JFT-300M pretraining; a small ViT
    trained on CIFAR-10 to reproduce exactly the losing half; gap: data-hungry,
    quadratic in image size

### Part VI - Sau ViT, 2021 đến 2026

12. **Chi phí bậc hai** - FlashAttention v1, v2 and v3 as IO-aware exact
    attention rather than approximation; the sparse and linear attention lines,
    and why most did not survive contact with hardware
13. **Vị trí và ngữ cảnh dài** - why Vaswani's sinusoids do not extrapolate;
    RoPE, ALiBi, positional interpolation
14. **Recurrence quay lại** - S4, Mamba, linear attention, RWKV. The circle
    closes: what 2017 threw away came back in 2023 in a different shape
15. **Chạy được trong thực tế** - KV cache, MQA and GQA, quantization, MoE; the
    ViT descendants Swin, DeiT and ConvNeXt, and the awkward question of whether
    the Transformer won or the training recipe did
16. **Còn lại gì năm 2026** - the summary table: what gap each paper named, who
    closed it, what is left; and where an undergraduate could actually
    contribute

### Appendices

- A. **Bảng đối chiếu ký hiệu** - this book's notation against each of the six
  papers, so a reader opening a paper does not get lost
- B. **Bảng thuật ngữ Việt-Anh** - which terms are translated and which are kept
  in English. This is the source of truth for `\tn` and for decision 16
- C. **Bảng chữ viết tắt** - acronyms and their full forms, split out of B by
  decision 28
- D. **Các dẫn xuất dài** - the long manipulations the running text states the
  result of, cross-referenced from where they are used
- E. **Dựng môi trường bằng conda và chạy companion repo**
- F. **Cách đọc một bài báo machine learning**

## Progress

Status values: not-started / outlined / drafted / reviewed / final.

| Chapter | Status | Notes |
|---------|--------|-------|
| Preface | not-started | Write last. Stub in place so front matter pagination is right from the start; front matter role, so `tone-loi-noi-dau` |
| 01 | drafted | Companion repo `rnn-to-transformer-lab` tag `ch01`; notation in appendix A; glossary seeded in appendix B; research notes in `research/2026-08-09-*.md` |
| 02 | drafted | Adding problem + copy task experiments; gradient norm measured against temporal distance; bridge boxes for Hochreiter 1991 and Bengio 1994; refs.bib first entries; CPU budgets ~10 min for two tasks |
| 03 | drafted | Venue confirmed: ICML 2013, PMLR 28(3):1310-1318. Companion tag `ch03`. Corrects the paper's eigenvalue wording against its own singular-value proof |
| 04 | not-started | |
| 05 | not-started | Must verify the venue of the Sutskever paper; the PDF on file states none |
| 06 | not-started | |
| 07 | not-started | |
| 08 | not-started | |
| 09 | not-started | |
| 10 | not-started | |
| 11 | not-started | |
| 12 | not-started | Re-verify the 2021-2026 facts before drafting |
| 13 | not-started | Re-verify before drafting |
| 14 | not-started | Re-verify before drafting |
| 15 | not-started | Re-verify before drafting |
| 16 | not-started | Write after 12-15; it is their summary |
| App A | drafted | Notation cross-reference table populated with LSTM 1997, Pascanu 2013, Sutskever 2014, Bahdanau 2015, Vaswani 2017 |
| App B | drafted | Glossary seeded with 12 translated terms and 5 kept-English terms from chapter 01 |
| App C | drafted | Abbreviations, split out of B by decision 28 |
| App D | not-started | Long derivations. Grows as chapters push derivations out |
| App E | not-started | Conda environment. The repo it documents already exists |
| App F | not-started | |

## Writing rules (book-specific)

Library-wide defaults are in AGENTS.md; these are this book's additions. The
machine-checkable half is `check-chapter.psd1` in this folder.

- **Vocabulary** (decision 24): software engineering, machine learning and
  mathematics only. No metaphor borrowed from an unrelated field: nothing
  clinical, nothing military, nothing about journeys or winning. A vivid word
  that is established terminology in this literature stays, and the wall and
  the valley of the error surface are the case that matters most. The test is
  whether a reader would meet the word in a paper.
- **Appendices are lookup only** (decision 29): entries, not argument. No
  opening paragraph, no rationale section, no closing note about how the table
  is maintained. That reasoning lives here.
- **How often a gloss repeats:** once per section. Decision 16 originally said
  every occurrence, and chapter 03 is what showed the cost: it names the
  spectral radius sixteen times, and a parenthesis on each turns the page into a
  bilingual dictionary. Once per section still serves the reason decision 16
  gave, because a reader opening the book anywhere lands inside a section. After
  the gloss, carry the term as notation where there is one: `
ho(W_hh)` reads
  better than the words fifteen times over, and it is more precise.
- **Voice:** First-person practitioner, the AGENTS.md default, which takes the
  chapter role. In Vietnamese that is "tôi" for the author and "bạn" for the
  reader, one pair for the whole book (decision 10). The book teaches other
  people's papers, so "tôi" is the person who read them, ran the code and
  measured the numbers, never a co-author of the work. Opinions are allowed and
  have to be paid for on the spot with a measurement or a named source.
- **Language and spelling:** Vietnamese. The English inside a gloss is en-US, to
  match the six papers; `Spelling.Preset` is set to `en-US` in
  `check-chapter.psd1` and `Exempt` is empty. Vietnamese diacritics are letters
  and are legal everywhere; what is banned is Unicode look-alikes of ASCII
  punctuation, which is `Characters.Mode = 'Punctuation'`, the library default.
- **Humanizer skill:** `humanizer-vi`. Never the English `humanizer`.
- **Listings:** `minted` with the `python` lexer for code, `text` for captured
  console and training output, `console` for a shell session. Code comes from
  the companion repo at the chapter's tag and nowhere else. Algorithms that
  describe a mechanism rather than ship as code use `algpseudocode`, and the
  prose calls them pseudo-code so nothing pretends to be runnable that is not.
  No `\newminted` aliases are declared; if one is added, record it here.
- **Figures:** TikZ, sources in `figures/tikz/chNN-<slug>.tex` as a bare
  `tikzpicture`; the `figure` environment, caption and label stay at the call
  site. Beyond the template's `arrows.meta` and `positioning`, this book loads
  `calc`, `fit`, `matrix`, `backgrounds` and `decorations.pathreplacing`, for
  unrolled recurrent networks, stacked encoder-decoders and attention score
  matrices. Mono-safe: meaning carried by dash pattern, grey level and fill,
  never by hue.
- **Figures before prose where a picture is clearer.** When a concept can be
  shown (unrolled network, gradient flow, attention matrix), draw it rather than
  describe it in three paragraphs. A diagram replaces text; it is not decoration.
  This book ships at least one TikZ figure per chapter where the architecture or
  the data flow is load-bearing. Added 2026-08-09 during chapter 02 revision.
- **Abbreviations spelled out per chapter.** Every abbreviation (RNN, BPTT,
  LSTM, GRU, MSE, SGD, ReLU, and any other the book introduces later) is
  written in full at its first occurrence in each chapter, because a reader
  opening at chapter 9 gets the same help as one who started at page 1.
  Appendix C holds the master abbreviation table, split out of appendix B by
  decision 28. Added 2026-08-09.
- **Chapter apparatus:** every chapter closes with `\exercises` and its three
  tiers, `\tierunderstand`, `\tierapply`, `\tierextend`, all starred so the
  table of contents does not grow forty-eight entries. Two recurring boxes:
  `bridge` for an intermediate paper the spine needs, `measured` for a number I
  ran myself. The chapter's argument runs outside the boxes, so a reader can
  skip every box and still follow it. Chapters in parts II to VI also end with a
  section naming what the paper left unsolved and what it created.
- **Companion code:** a second git repo, public on GitHub, name still open. The
  environment is conda from a pinned `environment.yml`; the verify script
  activates that env before doing anything, so a run does not depend on the
  machine. Tag convention `chNN`, and `chNN-<step>` when a chapter needs a
  before and an after. A chapter is not drafted until that repo's verify script
  passes at the chapter's tag and the tag is pushed. If a chapter legitimately
  changes a number the script asserts, change the script and say so in the
  commit; never loosen an assertion to make a run pass.
- **Research:** yes, one note per chapter under `research/`, plus the source
  manifest already there. The cliff is already crossed (decision 20), so every
  decimal printed anywhere in the book must appear in a note. A note records the
  exact command, the versions, the raw output rather than a summary, and the
  date. Record the measurements that turned out to be uninteresting too.
- **Sources:** citations are `~\autocite{...}`, always with the tilde. A number
  from a paper is cited and, where the claim is load-bearing, page-anchored
  against the exact PDF named in the source manifest. A number I measured goes
  in a `measured` box, says in the prose that I measured it, and traces to a
  research note. Quoted material uses `\enquote{}`, never a literal quote
  character. The arXiv copies of Vaswani and Bahdanau postdate their
  conferences by six years and one year, so wording quoted from them is not
  automatically wording from 2017 or 2015; check the proceedings before
  attributing a sentence to a year.

## Open items

- **Chapters 01 and 02 gloss below the cadence decision 16 now states.** Counted
  2026-08-09: 12 uses of `\tn` in chapter 01, 2 in chapter 02, 36 in chapter 03.
  The rule is once per section, and chapter 03 is the only one that meets it.
  Nothing is wrong on the page, so this is not urgent; sweep each of the two when
  it is next opened rather than in a pass of its own. This is also the first real
  data point for the deferred `gloss` check, which needs a second before it can
  be proposed as a family in `scripts/check-chapter.ps1`.
- **A listing wider than the measure is a defect no check catches.** Three tables
  in chapter 03 shipped at 82 to 101 characters and wrapped with continuation
  markers inside a 155mm measure; all three were found by reading the PDF, not by
  the gate. The fix each time was to narrow the experiment's output at the
  source. Whether this becomes a check in `scripts/check-chapter.ps1` depends on
  it biting a second book; until then, read the built pages.


- **The companion repo now exists.** Named `rnn-to-transformer-lab`, public
  at `github.com/Giang-Dang/rnn-to-transformer-lab`. Conda env name matches.
  Tag `ch01` created and pushed. Resolved 2026-08-09.
- **Appendix A's notation is settled.** The table now maps the book's notation
  to LSTM 1997, Pascanu 2013, Sutskever 2014, Bahdanau 2015, and Vaswani 2017.
  Resolved 2026-08-09.
- **A `gloss` check for decision 16, deliberately deferred.** The rule is
  machine-checkable: read appendix B's glossary, and flag every occurrence of a
  translated term that is not inside `\tn`. It cannot live in
  `check-chapter.psd1`, whose schema rejects unknown keys, so it would be a new
  family in `scripts/check-chapter.ps1`. `draft-chapter`'s retro rules forbid
  editing that script in a drafting session and forbid proposing a cross-book
  check until the same mistake has bitten in two different chapters. Unblocking
  condition: after chapters 01 and 02 are drafted, if the audit finds missed
  glosses in both, propose the family with fixtures in
  `scripts/check-chapter.tests.ps1`. Until then decision 21's macro is the only
  thing holding the rule, and it holds it by making the right thing easy rather
  than by making the wrong thing fail.
- **The running example is proposed, not settled.** A toy Vietnamese-English
  parallel set carried from chapter 05 to chapter 08, chosen because Vietnamese
  and English word order differ enough that chapter 06's alignment matrix shows
  something real, and because it fits on a CPU. Chapters 02 to 04 use the adding
  and copy tasks; chapter 11 uses CIFAR-10. Settle the corpus, its license and
  its size when the companion repo is created.
- **Per-experiment CPU time budgets are now set.** Chapter 02 uses ~10 min
  total for adding problem (3×T, 5000 samples each) and copy task (3×T_mem,
  2000 epochs each). Later chapters inherit this baseline: each experiment
  should finish on CPU in single-digit minutes. Settled 2026-08-09.
- **The final list of bridge papers is not closed.** The TOC names Cho 2014,
  Luong 2015, Gers 2000, Hochreiter 1991, Bengio 1994, layer norm, residuals,
  BERT, GPT, Kaplan and Hoffmann. Hochreiter 1991 and Bengio 1994 are now
  summarised in chapter 02 bridge boxes; Bengio 1994 has a `refs.bib` entry.
  The remaining bridge papers land in the chapter that cites them.
- **The `Empty bibliography` warning is now cleared.** Chapter 02 added the
  first `refs.bib` entry (Bengio 1994) and cites Pascanu 2013. The warning
  should no longer appear in the build log.
