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

Chapters 01, 02, 03, 04 and 05 drafted. Six appendices now: C was split out of B
on 2026-08-09 (decision 28) and the old C, D and E became D, E and F.

Chapter 03 was drafted out of order, in a session that branched before chapters
01 and 02 landed on main. Nothing was lost, but the reconciliation cost real
time; decision 30 exists so the next session does not repeat it. Chapters 04 and
05 followed it and cost nothing to reconcile.

Both debts chapter 05 was carrying are paid. The venue of the Sutskever paper is
NIPS 2014, Advances in Neural Information Processing Systems 27, pages
3104-3112; and the running example is settled by decision 35 as a corpus
generated from a grammar rather than a real one.

The gloss cadence is now enforced by a script rather than remembered. Decision
39 built the `Gloss` family in `scripts/check-chapter.ps1`; it found 32 defects
across the five drafted chapters, all fixed, and the two terminology questions
that had been open since chapter 01 are settled as decisions 40 and 41.

Next action: chapter 06, "Đồng chỉnh". It inherits the corpus of decision 35 and
the companion module `seq2seq.py` at tag `ch05`, and it owes one reading: Cho et
al. 2014b (arXiv:1409.1259) has only been read as far as its abstract, and
chapter 06 is the chapter that wants its BLEU-against-length curve. Note also
that the whole-run budget now has about forty seconds of headroom (see open
items), so chapter 06 cannot simply add four more training scripts.

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
| 14 | Where the work happens | Companion code is a second git repo, public on GitHub. The book's own work started in a dedicated worktree of `latex-books` on a long-lived branch `book/tu-rnn-den-transformer`, at `F:/repo/latex-books-transformers`. **Amended 2026-08-09:** AGENTS.md now requires a per-session branch cut from `origin/main`, in a worktree under `.claude/worktrees/`, ending in a pull request. The library rule wins over this row. The chapter 03 session followed AGENTS.md and reused only the directory; the long-lived branch is dead and has diverged from main, which is the failure mode decision 30 exists to prevent |
| 15 | Title | "Từ RNN đến Transformer", folder `tu-rnn-den-transformer`. The subtitle offered during the interview said "Mười ba năm kiến trúc chuỗi", which was written before decision 5 extended the book to 2026; corrected to "Sáu bài báo gốc từ 1997 đến 2021, và những gì đến sau" in the same session |
| 16 | Glossed terms | A term this book translates carries its English original in parentheses, so that a reader opening at chapter 9 gets the same help as one who started at page 1. A term the book keeps in English takes no parentheses: "attention (attention)" helps nobody. Which terms fall on which side is settled once in appendix B. **Amended 2026-08-09:** this row originally set the cadence at every occurrence, not just the first. Chapter 03 showed what that costs: it names the spectral radius sixteen times, and a parenthesis on each turns the page into a bilingual dictionary. The cadence is now once per section, which still serves the reason this row gave, because a reader opening the book anywhere lands inside a section. The writing-rules section carries the rule. **Amended again 2026-08-09:** the cadence covers the terms a chapter introduces, which are the terms in that chapter's own block of appendix B; a term an earlier chapter owns is glossed once at its first use in the chapter and not again. Measuring every appendix B term against every section is what forced this: chapter 03 was 36 sites of 48, chapter 01 was 9 of 38, chapter 02 was 0 of 22, and the terms making up most of the shortfall were ordinary Vietnamese words like "chuoi" that appear in nearly every section of every chapter. Glossing those once per section sets "chuoi (sequence)" about fifteen times, which is the same bilingual dictionary this row already ruled out, one level down. Chapter 03's practice is the definition rather than an approximation of it. **Amended a third time 2026-08-11, see decision 39:** the second amendment said \enquote{a term an earlier chapter owns}, which left a forward reference outside the rule entirely, and the cadence now turns only on whether the chapter owns the term. The two counts above were measured against the appendix B of that day and are not a statement about the tree now; a row added to the appendix later creates obligations retroactively, which is what chapter 05 then demonstrated |
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
| 31 | Listings are 73 columns wide | Measured 2026-08-09, not derived: `\the\textwidth` is 441.01773pt under this book's geometry, one character of texgyrecursor at `\small` in an 11pt class advances exactly 6.0pt, and a built page confirms that a 73-column line carrying a break point sets flush to the margin while the same line at 74 gains a continuation arrow. Enforced by `Listings.MaxLineLength` in `check-chapter.psd1`. The reason it needed a rule at all: `\setminted` loads `breaklines`, which breaks an over-wide line silently, so no Overfull box is raised and `MaxOverfull = 0` never fires. An Overfull box comes back only for a line with no break point anywhere, which real code never is. Chapter 03 shipped three tables at 82 to 101 columns and two code listings at 80 and 81 through that blind spot; all five were found by reading the PDF. A block that needs more width says so in its own option list and is not measured, which is how chapter 01's `\footnotesize` listings pass |

| 32 | The two squashing functions of LSTM 1997 are `g_in` and `g_out` | The paper writes them `g` (range [-2,2]) and `h` (range [-1,1]), and `h` collides with the book's hidden state `h_t` head-on: the cell output equation sets `y^c = y^out h(s_c)`, which in the book's notation would be `h_t` on both sides meaning two different things. Renamed rather than worked around, and appendix A carries the mapping plus two further reading traps: the paper's table 10 contradicts its own appendix A.1 about which range belongs to which function, and `c_j` in the paper is the *name* of a cell rather than its state, which is `s_{c_j}`. That last one had already gone wrong: appendix A shipped with LSTM 1997 writing `c_t` for the cell state. Fixed in the chapter 04 session |
| 33 | The book sets the memory cell in layer form, and the parameter count follows from that | The 1997 paper's hidden layer is fully connected: a gate receives connections from every memory cell *and* every other gate unit. What the field converged on, and what `torch.nn.LSTM` implements, is a layer form where all blocks read the same `h_{t-1}`. The book teaches the layer form, because it is what a reader will meet, and says so in the chapter rather than letting the difference pass silently. The difference is not cosmetic: it is exactly why the paper quotes a factor of `3^2` while everyone else quotes 4. Measured at tag `ch04`: layer form gives 3 for LSTM 1997, 4 for LSTM 2000, 3 for Cho's unit; the paper's own topology gives exactly 9.0000 on the recurrent block and 8.2603 over a whole layer once input weights and biases are counted. **This also corrects the chapter's own TOC line**, which said "four times the parameters" and was describing the 2000 architecture, not the one chapter 04 reads. Every derivative argument in the chapter holds under both topologies, because neither has a path into `c_{t-1}` other than the first term of the state update |
| 34 | Truncation is load-bearing, not a shortcut, and the chapter says so | The paper presents the gradient truncation as an efficiency measure that does no harm. Measured at tag `ch04`, the untruncated derivative through the cell *grows* with distance, reaching 128.34 at distance 100 even at the paper's own initialization scale, while the truncated one is bit-exactly 1 at every distance. So the truncation is also what makes the constant error carousel constant rather than approximately constant. The chapter states this as a reading of the paper's own equations, explicitly not as a correction: the paper's "no harm" claim is about training outcomes, and the chapter's cosine measurement is about gradient direction at initialization, which are two different quantities. Keeping those apart is the whole point of the passage |

| 35 | The running example is generated from a grammar, not taken from a real corpus | Settled 2026-08-10, closing the open item that had carried it as a proposal since the skeleton session. Three constraints have to hold at once and no public parallel corpus holds all three: the experiments finish on a CPU inside decision 27's budget, the data is reproducible from a seed with no download so `verify.py` runs on someone else's machine, and the two languages differ in word order enough that chapter 06's alignment matrix shows a crossing rather than a diagonal. So `toy_corpus.py` generates English-to-Vietnamese pairs from a small context-free grammar. The one thing it models for real is the noun phrase reversing: English sets determiner, adjective, noun and Vietnamese sets classifier, noun, adjective, with the classifier answering to no English word at all. What it does not model is written into the module docstring and into the chapter, because it is load-bearing: the grammar is finite so a model can learn it exactly, the vocabulary is closed so the out-of-vocabulary problem that penalised Sutskever et al.'s BLEU cannot arise, and the sentences are semantically silly. The consequence the chapters must hold to: no number measured on this corpus is ever compared with a BLEU score from a paper. What these experiments test is the papers' *arguments*, which do not change with scale |
| 36 | From chapter 05 the book's own cell is the 2000 forget-gate LSTM with tanh, not chapter 04's 1997 cell | Chapter 04 derives the 1997 cell, whose self-connection is a fixed 1.0 and whose squashing functions are scaled logistics. Chapter 05 needs a cell that trains on a real task, and Sutskever et al. name theirs in one sentence: \enquote{the LSTM formulation from Graves}. Graves (2013) section 2.1, equations (7) to (11), read in full: forget gate *and* peephole connections, tanh on both the cell input and the cell output. So the honest reading is that this paper's LSTM is chapter 04's cell plus both of chapter 04's bridge boxes. `seq2seq.py` implements the forget gate and tanh, and not the peepholes, and uses one layer where the paper uses four; both are size decisions forced by the CPU budget, and chapter 05 states them in the prose rather than letting the listing imply the paper was simpler than it is. This also settles the open item saying `LstmForget` was left at bridge-box quality: chapter 05 does not extend it, it writes a separate trainable layer, and the chapter 04 module is untouched because its tag is published |
| 37 | The per-experiment budget is 60 seconds **per model trained**, from chapter 05 on | Amends decision 27, which set 60 seconds per experiment. That figure was measured against chapters 1 to 4, where each script probes a computation that is fixed before the script starts. From chapter 05 a script trains several models in order to compare them: the reversal table is six trainings, and no amount of care makes six trainings fit one training's budget. The rule is now one training's budget per model, with a floor of 30 seconds for a script that trains none, and `verify.py` carries the reasoning next to the table it applies to. What is deliberately **not** amended is `BUDGET_TOTAL`, because that is the number standing behind the promise decision 13 makes to the reader. Measured at tag `ch05`: 557.52 seconds against a 600 second budget |
| 38 | The `algorithm` float is named in Vietnamese | `\floatname{algorithm}{Thuật toán}` in `preamble/macros.tex`. babel localizes every caption label this book uses except this one, because the `algorithm` package sets its own name rather than taking one from the language, so a Vietnamese page was printing \enquote{Algorithm 1}. Chapter 03 shipped that way and chapter 05 would have been the second; recorded as a decision rather than fixed silently because it changes how an already-drafted chapter sets |
| 39 | Decision 16's cadence is one rule with no direction in it, and a script enforces it | A term the chapter **owns** is glossed once per section; a term it does **not** own is glossed once per chapter. Ownership is which block of appendix B the term sits in, and nothing turns on whether the owning chapter comes earlier or later. The old wording said \enquote{a term an earlier chapter introduced}, which left chapter 02 using `trị riêng` and chapter 04 using `chỗ thắt` outside the rule entirely; seven sites were that shape. The `Gloss` family in `scripts/check-chapter.ps1` checks it, and `check-chapter.psd1` names appendix B, the `\tn` macro and the two headings that carve the appendix up. Four finding ids: an owned term unglossed in a section, an unowned term unglossed in a chapter, a `\tn` whose term is in no block of appendix B, and the same term glossed twice in one section. **Measured before the shape was chosen.** An earlier plan proposed shipping the unowned half switched off, on the grounds that 13 of its 20 findings were ordinary Vietnamese words; reading the list showed the number is one, `chuỗi`, which is now the whole of `Gloss.Exempt`. The rest are `hàm mất mát`, `ma trận trọng số`, `lan truyền ngược qua thời gian` and their kind, and honouring them cost one `\tn` each, three to six per chapter, which is not the bilingual dictionary the second amendment to decision 16 was written to prevent: that problem was per *section* and this is per *chapter*. **What the check cannot see**, and it is exactly the defect chapter 05 shipped: a term central to a chapter that was never added to appendix B at all. Decision 16 makes appendix B the source of truth, so a term in neither the appendix nor a `\tn` is indistinguishable from ordinary Vietnamese. `chỗ thắt` was that until an audit read the prose. The orphan check closes only the cheap half; the rest stays a reading job |
| 40 | \enquote{gradient} stays in English | Appendix B listed `độ dốc` as the translation and four of the five drafted chapters ignored it: chapter 01 wrote the bare English 71 times against 0, chapter 02 79/0, chapter 04 22/1, chapter 05 3/0. Only chapter 03 followed the appendix. The entry and its footnote are gone, `gradient` moves to the keep-in-English table, and the seven `\tn{độ dốc}{gradient}` calls are unwrapped. Three bare uses in chapter 03's wall section meant the gradient norm and now say `chuẩn gradient`, matching the prose two lines away that already did. Settled the way a Vietnamese ML reader would expect rather than the way the appendix promised, because the promise had been broken in four chapters and the cost of keeping it grew by one chapter per session |
| 41 | The tone mark goes on the first vowel of a vowel cluster | `bão hòa`, not `bão hoà`. Stated for the cluster and not for the one word, so `hóa`, `khóa`, `xóa`, `lũy`, `tùy` and `túy` follow without reopening it; closed syllables like `hoàn` and `thoát` are unaffected, because there the tone already sits on the nucleus under both conventions. Both styles are standard Vietnamese and this is a house choice, not a correctness one; it went the way appendix B and three of the five drafted chapters already wrote it. 26 sites changed. `Spelling.Extra` in `check-chapter.psd1` holds the pairs, so the rule is enforced rather than remembered |

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
   carousel derived by solving the constant-error equation, and the derivative
   through it; the input and output weight conflicts, the second of them solved
   in closed form; input and output gates; the gradient truncation in the
   original, and the measurement showing it is what makes the carousel exactly
   constant; bridge boxes for the Gers 2000 forget gate, peepholes, and Cho's
   gated unit; gap: still sequential, and three times the parameters of a plain
   layer rather than four (decision 33)

### Part III - Ánh xạ chuỗi sang chuỗi

5. **Encoder-decoder** (Sutskever, Vinyals, Le 2014) - the fixed-length context
   vector, and the bottleneck measured by shrinking that vector rather than by
   lengthening sentences; the generated English-Vietnamese corpus that chapters
   05 to 08 run on (decision 35); source reversal, with the paper's distance
   argument turned into a prediction and tested; beam search; ensembling; bridge
   boxes for Kalchbrenner and Blunsom 2013, Cho 2014a and Cho 2014b.
   Careful here: this paper's own abstract says its LSTM did **not** struggle on
   long sentences, and the length-degradation result belongs to Cho **2014b**,
   the SSST-8 paper, not to the EMNLP one chapter 04 cites. See the research
   note
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
8. **Chi phí, song song hóa, và cái giá phải trả** - the paper's complexity
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
| 04 | drafted | Companion tag `ch04`. Reads the 1997 paper rather than the modern cell: no forget gate, squashing functions that are not tanh, truncation as three named substitutions. Input weight conflict solved in closed form (`w* = 1/T`). Two TikZ figures. Corrects appendix A, which had the paper writing `c_t` for the cell state when it writes `s_c` |
| 05 | drafted | Companion tag `ch05`. Venue confirmed: NIPS 2014, Advances in NIPS 27, pages 3104-3112 (pages from DBLP, since the publisher's own BibTeX export leaves the field empty). Settles the running example as a generated corpus (decision 35). The bottleneck measured by shrinking the context vector rather than by lengthening sentences, which is what lets the chapter say the bottleneck is real *and* that this paper never hit it. Separates Cho 2014a from Cho 2014b, which is who the length-degradation result actually belongs to. One TikZ figure |
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
- **How often a gloss repeats:** once per section, for the terms the chapter
  introduces. Decision 16 originally said every occurrence, and chapter 03 is
  what showed the cost: it names the spectral radius sixteen times, and a
  parenthesis on each turns the page into a bilingual dictionary. Once per
  section still serves the reason decision 16 gave, because a reader opening the
  book anywhere lands inside a section. After the gloss, carry the term as
  notation where there is one: `\rho(W_hh)` reads better than the words fifteen
  times over, and it is more precise.
- **Which terms that cadence covers:** the ones in the chapter's own block of
  appendix B. A term the chapter does **not** own - whichever chapter owns it,
  earlier or later - is glossed once per chapter instead, at its first use.
  That is the whole rule and it has no direction in it (decision 39). It used to
  say "an earlier chapter", which left a forward reference like chapter 02 using
  `tri rieng` outside the rule; seven sites were that shape. A chapter that
  borrows a term and then leans on it - makes it load-bearing rather than
  passing - treats it as its own and follows the section cadence; that judgement
  is the author's and the reason goes in the decision log, not here.
  `Gloss.Exempt` in `check-chapter.psd1` holds the one term too ordinary to
  gloss, `chuoi`; keep that list short, because an exception list carrying most
  of a check's signal is a list rather than a check.
- **A gloss never goes in a heading.** No `\section` or `\subsection` in the
  book carries one, and a parenthetical there would follow into the table of
  contents and the running head. So a term whose only appearance in a section is
  its heading gets no gloss. Observed rather than argued, but it is now what the
  check assumes, so it is written down.
- **A `\tn` on a term appendix B does not list is a miss in the other
  direction** from decision 21. Either the term belongs in the appendix and goes
  in, or the gloss comes out. Glossing a term the appendix keeps in English is
  the same defect one step worse: `\tn{bias}{bias}` sets "bias (bias)", which
  decision 16 names as the thing not to do.
- **Adding a row to appendix B is retroactive, and the chapter is re-swept in
  the same session.** The appendix is the source of truth, so a new row creates
  a gloss obligation in every section where the term already appears, including
  sections written months earlier. All eight of chapter 05's cadence misses were
  this: its audit added `cho that`, `tu dien`, `ngoai tu dien` and `gia thuyet`
  to the appendix and did not go back through the prose. Adding a row can also
  cost typesetting - the longest term in the book made appendix B's first table
  overfull by 30pt - so build after editing the appendix, not only after editing
  prose.
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

  **The tone mark goes on the first vowel of a vowel cluster** (decision 41):
  `bao hoa`, `hoa`, `khoa`, `xoa`, `luy`, `tuy` written with the mark on the o
  or the u, never on the following a or y. Closed syllables such as `hoan` and
  `thoat` are unaffected. Both styles are standard and this is a house choice;
  `Spelling.Extra` in `check-chapter.psd1` holds the pairs, so it is enforced
  rather than remembered. Do not fix this class with a blanket search and
  replace: `hoa` with the mark is a substring of `thoat`, and one pass turned
  `thoat` into a non-word that only a rebuild caught.
- **How an English quotation attaches to a Vietnamese sentence.** A quotation is
  either *introduced* - by a colon, or by a verb of saying - or it sits in
  parentheses after the Vietnamese has already said the thing. It is never a
  grammatical constituent of the Vietnamese sentence around it. What that rules
  out is the shape where a Vietnamese subject takes an English finite verb, or a
  Vietnamese clause runs on into an English prepositional phrase:

  - Wrong: `mang tich chap thi \enquote{lose the ordering of the words}`
  - Wrong: `no \enquote{enables the model to define a distribution ...}`
  - Wrong: `tang so tham so \enquote{at negligible computational cost} va ...`
  - Right: `... lam mat thu tu tu (\enquote{lose the ordering of the words})`
  - Right: `Bai neu dung ly do: \enquote{enables the model to ...}`

  This book quotes English on nearly every page and translates none of it, so
  the two grammars meet constantly and the seam has to be a stated rule rather
  than an ear. Added 2026-08-10 after chapter 05 shipped ten of these into a
  draft and chapter 04 turned out to have two. An English *noun phrase* as the
  object of a Vietnamese verb is fine and stays - `bai khong dung chu
  \enquote{GRU}` reads correctly - so the test is whether the quotation is
  carrying the sentence's grammar or only its wording.

  **No `check-chapter.psd1` setting stands behind this one, on purpose.** The
  library principle is that a rule with no setting is a rule nothing enforces,
  so the exception needs its reason on the record: the only mechanical form of
  this check is "an English quotation not preceded by a colon or an open
  parenthesis", and measured against chapters 01 to 04 that flags about thirty
  sites of which roughly four are real. A check that is wrong six times out of
  seven trains its reader to skip it, which costs more than the rule it enforces.
- **Humanizer skill:** `humanizer-vi`. Never the English `humanizer`.
- **Listings:** `minted` with the `python` lexer for code, `text` for captured
  console and training output, `console` for a shell session. Code comes from
  the companion repo at the chapter's tag and nowhere else. Algorithms that
  describe a mechanism rather than ship as code use `algpseudocode`, and the
  prose calls them pseudo-code so nothing pretends to be runnable that is not.
  No `\newminted` aliases are declared; if one is added, record it here.
- **Listings are 73 columns wide** (decision 31). That is what this measure
  holds at `\small`, measured rather than assumed, and `Listings.MaxLineLength`
  in `check-chapter.psd1` enforces it. Narrow the source until it fits: a
  captured table gets a narrower experiment, a signature gets wrapped the way
  Python wraps one. A block that genuinely needs more says so in its own option
  list, `[fontsize=\footnotesize]`, where the same measure holds 81, and the
  check stands down for it. Do not reach for the smaller size to avoid an edit:
  a page with three type sizes in its listings reads as a page nobody set.
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

  **A number goes in the note with the configuration that produced it**, never
  on its own. The `number` family checks that a decimal appears in a note, and a
  note recording a figure from a configuration nobody can name still satisfies
  it: that is how six wrong decimals from a discarded probe run got past a green
  gate in chapter 05. A measurement taken before the recipe was pinned is
  retaken afterwards or dropped, and there is no third option. And when an audit
  reports a wrong number, the question to ask it is **what else came from
  here**, not whether that one is fixed now; the first audit of chapter 05 found
  four and the second found two more with the same origin.
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

Closed items are deleted rather than kept with a note, and whatever they were
carrying moves to the decision log, the writing rules, or a comment in the file
that enforces it. A list where half the entries say "resolved" stops being read,
which is how the four consecutive gloss regressions kept getting past a rule
that was written down.

- **Chapter 01's gloss density is the rule's cost, and it should be looked at
  once on paper.** Chapter 01 introduces the foundational vocabulary, so its own
  terms are the ones that appear in every section: printed page 3 carries five
  glosses and pages 4 and 5 carry four each. Nothing is wrong and every one is a
  term being introduced, but `chuoi (sequence)` lands twice on printed page 5,
  in sections 1.2 and 1.3, twelve lines apart, because the two sections are
  short and the cadence is per section. Leaving it: consistency with a written
  rule beats a judgement call made once. Worth a look next time chapter 01 is
  open, and decision 39 has since added a few more.
- **`gia thuyet` carries two senses and appendix B only scopes one.** The row
  says "nghia trong beam search", but chapter 03 uses the word in its ordinary
  sense - the paper's hypothesis - and no check can read a scoping note in a
  table cell, so chapter 03 now glosses it too. The gloss is not wrong,
  "hypothesis" is the right English either way, but a reader may wonder why a
  beam-search term is being introduced in a chapter about spectral radius.
  Either the appendix drops the scoping note, or the term joins `Gloss.Exempt`
  and chapter 05 keeps its glosses by hand. Left open because it is one word and
  the current state is cheap to live with.
- **Chapter 03's captured tables sit at `\footnotesize` without needing to.**
  Found by the chapter 04 audit 2026-08-10, in chapter 04's own tables, and
  fixed there: all eight were between 19 and 68 columns, well inside the
  73-column budget at `\small`, so the smaller size bought nothing and cost the
  page a third type size. Decision 31 says the option list is for a block that
  genuinely needs the width, and it also waives `Listings.MaxLineLength`, so
  every one of those blocks was invisible to the gate that exists to measure
  them. Chapter 03 has the same pattern and was left alone, because it is not
  this session's chapter. Whoever opens chapter 03 next should widen them and
  let the check see them.
- **Chapter 04 has two spliced quotations, left alone.** Found 2026-08-10 while
  checking whether the quotation rule had two chapters of evidence behind it,
  which it does: `04-lstm/02-hai-xung-dot.tex` line 12 has "cac tin hieu cap
  nhat" taking the English finite verb "will attempt", and
  `04-lstm/05-cat-gradient.tex` line 20 has "loi toi net input ... cua cong"
  taking "do not get propagated". Both read as a Vietnamese subject with an
  English predicate. Not fixed, because chapter 04 is not this session's chapter
  and the same restraint was shown for chapter 03's tables; whoever opens
  chapter 04 next should reword both. Everything else the scan turned up in
  chapters 01 to 04 is an English noun phrase after a Vietnamese verb, which the
  rule permits.
- **If a later chapter wants a task that isolates the constant error carousel,
  chapter 02's copy task is the one with the measured decay.** Chapter 04 leans
  on chapter 02's adding problem, which chapter 02 concluded in bold is not a
  good test for vanishing gradients; chapter 04 now says so and points the
  result at the input weight conflict, which is what the task actually probes.
  Recorded because the first draft did not say so and the audit is what caught
  it.
- **The divisibility check on measured numbers: declined 2026-08-11, with the
  measurement.** The idea looked sound and cheap. Every exact-match figure is a
  count over a test split, so it must be a multiple of 1/N, and
  `0.9425 * 300 = 282.75` identifies both that the number is wrong and which
  discarded run it came from without rerunning anything. Prototyped over the
  drafted chapters, it does not survive contact. Rounding kills the naive form
  outright: 256 of 300 prints as 0.8533 and `0.8533 * 300` is 255.99, so an
  exact-integer test flags every correct figure too, 401 of 701 decimals. A
  rounding-aware version allowing half a unit in the last place, restricted to
  values in [0, 1] printed to at least three decimals, still flags 210 of 344.
  The reason is structural rather than fixable: this book counts exact matches
  over several different denominators - the full test split, the short-sentence
  subset, the long-sentence subset - so no single N is right, and most decimals
  in that range are gradient norms and probabilities rather than counts at all.
  Same verdict and the same reason as the quotation rule: a check that is wrong
  most of the time trains its reader to skip it. What survives is the manual
  habit, now in the writing rules - a number goes in the note with the
  configuration that produced it.
- **The whole-run budget has about forty seconds of headroom, and that is the
  next thing to bite.** Two runs at tag `ch05` on the same machine: 557.52
  seconds against `BUDGET_TOTAL = 600`, and 495.51 in another. The gap between
  them is the point, because it means the total is sensitive to load and a
  passing run is not proof the next one passes. Chapter 05 added 268 seconds,
  and chapter 06 wants the same corpus and at least one more comparison. The
  single largest item is not chapter 05: chapter 02's verify took 197.59 seconds
  in the slower run against 99.66 recorded at tag `ch04`. Chapter 02's own
  baseline is about ten minutes total - adding problem at 3 x T with 5000
  samples each, copy task at 3 x T_mem with 2000 epochs each - and decision 37
  tightened the rule to 60 seconds per model trained from chapter 05 on. The
  cheapest real saving in chapter 05 would be dropping the reversal experiment
  from three seeds to two, which is exactly the thing that experiment exists to
  avoid, because the per-seed spread there is wider than the effect. So the
  honest options are speeding chapter 02 up, raising `BUDGET_TOTAL` with a
  recorded reason, or letting chapter 06 share chapter 05's trained models.
- **`torch.nn.LSTM` is still not used anywhere, and from chapter 05 that costs
  measurable time.** Every recurrent layer in the companion repo is a Python
  loop over time steps, which is the right choice for chapters 01 to 04 because
  those chapters reach inside the loop. Chapter 05 does not: it trains and
  measures. Fifteen trainings at roughly nineteen seconds each is most of what
  chapter 05 spends, and the fused-kernel version would be a large multiple
  faster. Not changed, because a book that builds from scratch and then quietly
  swaps in the library for the chapter where it matters has stopped building
  from scratch. Recorded so that whoever hits the budget wall knows this lever
  exists and what it costs to pull.
- **The final list of bridge papers is not closed.** The TOC names Cho 2014,
  Luong 2015, Gers 2000, Hochreiter 1991, Bengio 1994, layer norm, residuals,
  BERT, GPT, Kaplan and Hoffmann. Hochreiter 1991 and Bengio 1994 are now
  summarised in chapter 02 bridge boxes; Bengio 1994 has a `refs.bib` entry.
  The remaining bridge papers land in the chapter that cites them. **The TOC's
  \enquote{Cho 2014} is two papers, not one**, and chapter 05 had to split them:
  `cho2014encdec` is the EMNLP encoder-decoder paper that chapter 04 already
  cited for the gated unit, and `cho2014properties` is the SSST-8 paper that
  measured the length degradation. Bahdanau distinguishes them as 2014a and
  2014b and the whole received story about chapter 05 turns on which one is
  meant.
- **Three papers are cited from less than a full read, and each entry says so.**
  `cho2014properties` from its abstract only; `kalchbrenner2013recurrent` from
  its ACL Anthology record only, used for nothing beyond the priority claim
  Sutskever et al. themselves make; `graves2013generating` from section 2.1
  only, which is the part that matters because it is where the LSTM equations
  are. Chapter 06 wants a number out of the first of those and will have to read
  the body before it can print one.
