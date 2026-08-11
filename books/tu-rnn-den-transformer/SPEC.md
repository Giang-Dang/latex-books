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

Chapters 01 through 07 drafted. Six appendices now: C was split out
of B on 2026-08-09 (decision 28) and the old C, D and E became D, E and F.

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

Chapter 06's debt is paid too: Cho et al. 2014b is now read in full, from both
the arXiv and the Anthology copies. Its length curves are plots with no table
behind them, so the chapter quotes as figures only the two BLEU numbers that
paper writes out in prose, 27.81 and 33.08, and says on the page that the
ranges it gives when describing the plots are eyeball readings of shape.

The whole-run budget stopped being a worry and became a decision. `BUDGET_TOTAL`
is 900 seconds from tag `ch06`, raised from 600 with the measurement rather than
after a failure; decision 43 has the reasoning and `verify.py` carries it next
to the number.

Both warnings the SPEC handed chapter 07 turned out to matter, and neither in
the shape expected. The arXiv-date warning was much bigger than a wording
question: the two copies of Vaswani are not the same document and they disagree
on a BLEU score (decision 47). The budget warning turned out not to bind at all,
because three of chapter 07's five verification items train nothing at all and
the two that do are cheap; the whole repo runs in 663.51s against the 900s of
decision 43, so that number is untouched.

The open items list is empty for the first time since the skeleton session. It
had reached fourteen entries, of which nine were settled calls with their
reasons attached - a decision filed where nobody looks for one - and only three
named work anyone still had to do. Those three are done: chapter 03's six
captured tables and chapter 01's three came out of `\footnotesize` and are now
measured by the gate (decision 52), chapter 04's two spliced quotations were
reworded, and appendix B's `giả thuyết` row lost the scoping note three chapters
had already ignored (decision 53). The other eleven became rows 49 to 58, two
amendments, four writing rules, a section of `research/README.md` and a comment
in `scripts/check-chapter.ps1`. Nothing was dropped.

Next action: chapter 08, "Chi phí, song song hóa, và cái giá phải trả". It
inherits `transformer.py` at tag `ch07` and three debts chapter 07 names on the
page and does not pay. Post-LN against pre-LN: chapter 07 sets equation (5) of
the paper in the paper's own order and says chapter 08 measures the other one.
Warmup: chapter 07 tried the paper's schedule at 658 training steps, found it
worse than the shared recipe, and said so, which is a result about 658 steps
rather than about warmup. And the wall-clock half of the multi-head cost claim,
which chapter 07 states in FLOPs only. Chapter 08 also owns the re-measurement
of table 1, which chapter 07 quotes and does not check. Three of the new
decision rows are aimed at it: 57 names the `torch.nn.LSTM` lever and what
pulling it would cost, which is the one thing to reach for if the wall clock
this chapter measures runs into decision 43's budget; 54 says the `q . k`
statistics after training are still unmeasured and that chapter 07's exercise
does not count as having measured them; and 56 leaves chapter 06's reversal
result on the table for whoever explains it.

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
| 31 | Listings are 73 columns wide | Measured 2026-08-09, not derived: `\the\textwidth` is 441.01773pt under this book's geometry, one character of texgyrecursor at `\small` in an 11pt class advances exactly 6.0pt, and a built page confirms that a 73-column line carrying a break point sets flush to the margin while the same line at 74 gains a continuation arrow. Enforced by `Listings.MaxLineLength` in `check-chapter.psd1`. The reason it needed a rule at all: `\setminted` loads `breaklines`, which breaks an over-wide line silently, so no Overfull box is raised and `MaxOverfull = 0` never fires. An Overfull box comes back only for a line with no break point anywhere, which real code never is. Chapter 03 shipped three tables at 82 to 101 columns and two code listings at 80 and 81 through that blind spot; all five were found by reading the PDF. A block that needs more width says so in its own option list and is not measured. **Amended 2026-08-11, see decision 52:** this row used to name chapter 01's three `\footnotesize` listings as the example of that hatch. They did not need the width either, and neither did chapter 03's six; all nine were swept, so the hatch is now a rule with no user in the book rather than a rule with an example. It stays for the block that genuinely needs it |

| 32 | The two squashing functions of LSTM 1997 are `g_in` and `g_out` | The paper writes them `g` (range [-2,2]) and `h` (range [-1,1]), and `h` collides with the book's hidden state `h_t` head-on: the cell output equation sets `y^c = y^out h(s_c)`, which in the book's notation would be `h_t` on both sides meaning two different things. Renamed rather than worked around, and appendix A carries the mapping plus two further reading traps: the paper's table 10 contradicts its own appendix A.1 about which range belongs to which function, and `c_j` in the paper is the *name* of a cell rather than its state, which is `s_{c_j}`. That last one had already gone wrong: appendix A shipped with LSTM 1997 writing `c_t` for the cell state. Fixed in the chapter 04 session |
| 33 | The book sets the memory cell in layer form, and the parameter count follows from that | The 1997 paper's hidden layer is fully connected: a gate receives connections from every memory cell *and* every other gate unit. What the field converged on, and what `torch.nn.LSTM` implements, is a layer form where all blocks read the same `h_{t-1}`. The book teaches the layer form, because it is what a reader will meet, and says so in the chapter rather than letting the difference pass silently. The difference is not cosmetic: it is exactly why the paper quotes a factor of `3^2` while everyone else quotes 4. Measured at tag `ch04`: layer form gives 3 for LSTM 1997, 4 for LSTM 2000, 3 for Cho's unit; the paper's own topology gives exactly 9.0000 on the recurrent block and 8.2603 over a whole layer once input weights and biases are counted. **This also corrects the chapter's own TOC line**, which said "four times the parameters" and was describing the 2000 architecture, not the one chapter 04 reads. Every derivative argument in the chapter holds under both topologies, because neither has a path into `c_{t-1}` other than the first term of the state update |
| 34 | Truncation is load-bearing, not a shortcut, and the chapter says so | The paper presents the gradient truncation as an efficiency measure that does no harm. Measured at tag `ch04`, the untruncated derivative through the cell *grows* with distance, reaching 128.34 at distance 100 even at the paper's own initialization scale, while the truncated one is bit-exactly 1 at every distance. So the truncation is also what makes the constant error carousel constant rather than approximately constant. The chapter states this as a reading of the paper's own equations, explicitly not as a correction: the paper's "no harm" claim is about training outcomes, and the chapter's cosine measurement is about gradient direction at initialization, which are two different quantities. Keeping those apart is the whole point of the passage |

| 35 | The running example is generated from a grammar, not taken from a real corpus | Settled 2026-08-10, closing the open item that had carried it as a proposal since the skeleton session. Three constraints have to hold at once and no public parallel corpus holds all three: the experiments finish on a CPU inside decision 27's budget, the data is reproducible from a seed with no download so `verify.py` runs on someone else's machine, and the two languages differ in word order enough that chapter 06's alignment matrix shows a crossing rather than a diagonal. So `toy_corpus.py` generates English-to-Vietnamese pairs from a small context-free grammar. The one thing it models for real is the noun phrase reversing: English sets determiner, adjective, noun and Vietnamese sets classifier, noun, adjective, with the classifier answering to no English word at all. What it does not model is written into the module docstring and into the chapter, because it is load-bearing: the grammar is finite so a model can learn it exactly, the vocabulary is closed so the out-of-vocabulary problem that penalised Sutskever et al.'s BLEU cannot arise, and the sentences are semantically silly. The consequence the chapters must hold to: no number measured on this corpus is ever compared with a BLEU score from a paper. What these experiments test is the papers' *arguments*, which do not change with scale. **Amended 2026-08-11 with two measured ceilings**, because what the grammar does not model has now cost two chapters something. The grammar has no ambiguity in it, so a mechanism that exists to resolve ambiguity cannot show what it is for: that is why chapter 06's parameter-matched ablation could not make the backward pass earn anything (decision 44), and it will bite any later chapter with the same shape - chapter 07's masked self-attention is not one, chapter 09's pretraining argument may be. The grammar does have binding, two clauses of the same shape each with its own adjective and noun, and that is what the Transformer gets wrong at 14 epochs (decision 48); it is a harder thing for the corpus to run out of than ambiguity was. The fix, when a chapter needs it, is a grammar where one English word's Vietnamese translation depends on a word after it. Chapter 06's tier-three exercise 1 specifies exactly that and nobody has built it |
| 36 | From chapter 05 the book's own cell is the 2000 forget-gate LSTM with tanh, not chapter 04's 1997 cell | Chapter 04 derives the 1997 cell, whose self-connection is a fixed 1.0 and whose squashing functions are scaled logistics. Chapter 05 needs a cell that trains on a real task, and Sutskever et al. name theirs in one sentence: \enquote{the LSTM formulation from Graves}. Graves (2013) section 2.1, equations (7) to (11), read in full: forget gate *and* peephole connections, tanh on both the cell input and the cell output. So the honest reading is that this paper's LSTM is chapter 04's cell plus both of chapter 04's bridge boxes. `seq2seq.py` implements the forget gate and tanh, and not the peepholes, and uses one layer where the paper uses four; both are size decisions forced by the CPU budget, and chapter 05 states them in the prose rather than letting the listing imply the paper was simpler than it is. This also settles the open item saying `LstmForget` was left at bridge-box quality: chapter 05 does not extend it, it writes a separate trainable layer, and the chapter 04 module is untouched because its tag is published |
| 37 | The per-experiment budget is 60 seconds **per model trained**, from chapter 05 on | Amends decision 27, which set 60 seconds per experiment. That figure was measured against chapters 1 to 4, where each script probes a computation that is fixed before the script starts. From chapter 05 a script trains several models in order to compare them: the reversal table is six trainings, and no amount of care makes six trainings fit one training's budget. The rule is now one training's budget per model, with a floor of 30 seconds for a script that trains none, and `verify.py` carries the reasoning next to the table it applies to. What is deliberately **not** amended is `BUDGET_TOTAL`, because that is the number standing behind the promise decision 13 makes to the reader. Measured at tag `ch05`: 557.52 seconds against a 600 second budget |
| 38 | The `algorithm` float is named in Vietnamese | `\floatname{algorithm}{Thuật toán}` in `preamble/macros.tex`. babel localizes every caption label this book uses except this one, because the `algorithm` package sets its own name rather than taking one from the language, so a Vietnamese page was printing \enquote{Algorithm 1}. Chapter 03 shipped that way and chapter 05 would have been the second; recorded as a decision rather than fixed silently because it changes how an already-drafted chapter sets |
| 39 | Decision 16's cadence is one rule with no direction in it, and a script enforces it | A term the chapter **owns** is glossed once per section; a term it does **not** own is glossed once per chapter. Ownership is which block of appendix B the term sits in, and nothing turns on whether the owning chapter comes earlier or later. The old wording said \enquote{a term an earlier chapter introduced}, which left chapter 02 using `trị riêng` and chapter 04 using `chỗ thắt` outside the rule entirely; seven sites were that shape. The `Gloss` family in `scripts/check-chapter.ps1` checks it, and `check-chapter.psd1` names appendix B, the `\tn` macro and the two headings that carve the appendix up. Four finding ids: an owned term unglossed in a section, an unowned term unglossed in a chapter, a `\tn` whose term is in no block of appendix B, and the same term glossed twice in one section. **Measured before the shape was chosen.** An earlier plan proposed shipping the unowned half switched off, on the grounds that 13 of its 20 findings were ordinary Vietnamese words; reading the list showed the number is one, `chuỗi`, which is now the whole of `Gloss.Exempt`. The rest are `hàm mất mát`, `ma trận trọng số`, `lan truyền ngược qua thời gian` and their kind, and honouring them cost one `\tn` each, three to six per chapter, which is not the bilingual dictionary the second amendment to decision 16 was written to prevent: that problem was per *section* and this is per *chapter*. **What the check cannot see**, and it is exactly the defect chapter 05 shipped: a term central to a chapter that was never added to appendix B at all. Decision 16 makes appendix B the source of truth, so a term in neither the appendix nor a `\tn` is indistinguishable from ordinary Vietnamese. `chỗ thắt` was that until an audit read the prose. The orphan check closes only the cheap half; the rest stays a reading job |
| 40 | \enquote{gradient} stays in English | Appendix B listed `độ dốc` as the translation and four of the five drafted chapters ignored it: chapter 01 wrote the bare English 71 times against 0, chapter 02 79/0, chapter 04 22/1, chapter 05 3/0. Only chapter 03 followed the appendix. The entry and its footnote are gone, `gradient` moves to the keep-in-English table, and the seven `\tn{độ dốc}{gradient}` calls are unwrapped. Three bare uses in chapter 03's wall section meant the gradient norm and now say `chuẩn gradient`, matching the prose two lines away that already did. Settled the way a Vietnamese ML reader would expect rather than the way the appendix promised, because the promise had been broken in four chapters and the cost of keeping it grew by one chapter per session |
| 41 | The tone mark goes on the first vowel of a vowel cluster | `bão hòa`, not `bão hoà`. Stated for the cluster and not for the one word, so `hóa`, `khóa`, `xóa`, `lũy`, `tùy` and `túy` follow without reopening it; closed syllables like `hoàn` and `thoát` are unaffected, because there the tone already sits on the nucleus under both conventions. Both styles are standard Vietnamese and this is a house choice, not a correctness one; it went the way appendix B and three of the five drafted chapters already wrote it. 26 sites changed. `Spelling.Extra` in `check-chapter.psd1` holds the pairs, so the rule is enforced rather than remembered |
| 42 | Chapter 06 is titled \enquote{Một vector cho mỗi từ}, and the folder and label followed the title | The TOC line said \enquote{Đồng chỉnh}, which is the book's translation of \enquote{alignment} and is opaque on first meeting: it was the one line in the table of contents a reader had to look up before knowing what the chapter was about. The new title is the problem rather than the mechanism, which is decision 2, and it pairs exactly with chapter 05's own section 5.1, \enquote{Một vector cho cả câu}: the distance between the two headings is the distance between the two architectures. The term `đồng chỉnh` is untouched and still carries `alignment` throughout the prose and appendix B. **The slug moved too**, against the usual rule that a stub's label is fixed because earlier chapters forward-reference it. That rule protects against a broken reference, not against a rename done properly: `chapters/06-dong-chinh/` became `chapters/06-mot-vector-cho-moi-tu/` and `ch:dong-chinh` became `ch:mot-vector-cho-moi-tu` in the same session, all nine sites at once, verified by a grep for the old slug returning nothing. Cost: one `git mv`, one `\include`, one `\label` and seven `\ref` in chapter 05 |
| 43 | `BUDGET_TOTAL` is 900 seconds, raised from 600 | The open item listed three honest options once chapter 06 needed roughly 240 seconds of new experiments: speed chapter 02 up, let chapter 06 share chapter 05's models, or raise the number with a recorded reason. The first rewrites a drafted chapter's published figures, the second is impossible because each experiment is its own process. So the third. What made the case is not the new total but the spread: three whole runs at tag `ch05` on identical code came in at 557.52, 495.51 and 487.27 seconds, so the seventy-second range is larger than the forty seconds of headroom the old number had, and a budget that clears the measurement by less than its own noise is not a budget. Measured at tag `ch06`: 680.47 seconds. What is deliberately not touched is what the budget is for. Decision 13 promises a reader with no graphics card that a run finishes in minutes, and 900 seconds is still minutes; the question before raising it again is not whether the run fits but whether a reader would sit through one |
| 44 | An ablation without a parameter-matched control measures the parameter count | Chapter 06 ran chapter 05's reversal question against the bidirectional encoder and, in the same table, dropped the backward pass. Read four rows, the backward pass is worth 0.0467 exact match and the gain sits on long sentences. Add a fifth row where a forward-only encoder is widened to 41495 parameters against the bidirectional model's 40805, and it scores 1.0000: the gain was the parameters. The chapter prints the control and says so. **And the honest reading is about the corpus, not the paper.** Section 3.2 of Bahdanau wants an annotation to summarise the words that follow, and the reason is disambiguation; the grammar of decision 35 has no ambiguity in it at all, as `toy_corpus.py` has said in its docstring since chapter 05. A corpus with nothing to disambiguate cannot show what a disambiguating mechanism is for, so this measures the running example's ceiling rather than the paper's claim. Generalised, because it is not about this one table: a table comparing two architectures states their parameter counts, and an ablation ships a size-matched control or says why it has none |
| 45 | `ma trận đồng chỉnh` belongs to chapter 06's block of appendix B, not chapter 05's | Appendix B carried it under chapter 05 with the note \enquote{chương 05 mượn trước của chương 06}, which is a note saying the row is in the wrong place. Decision 39 makes ownership mean the section cadence, and chapter 06 names the matrix in four sections while chapter 05 names it in one, so chapter 06 is the owner by the test the rule actually applies. Moved, and the note rewritten to `chương~05 mượn trước`, which is now a fact about chapter 05's usage rather than an apology for the row being in the wrong block. Chapter 05 keeps its single gloss and is now correct as a borrower rather than correct by accident. Two more rows arrived from chapter 06's audit, both of them the defect decision 39 says the check cannot see - a term central to a chapter that is in no block at all: bare `đồng chỉnh`, which was the chapter's own former title, and `phép cắt bỏ`, which is the name of the method behind decision 44. Plus `alignment error rate` to the keep-in-English table. Added in the same pass: `attention` and `annotation` to the keep-in-English table. `annotation` is the interesting one - it is Bahdanau's name for `h_j`, and the obvious Vietnamese word, `chú giải`, means a footnote or a commentary, so translating it would have taught a reader the wrong thing |

| 46 | Query, key, value and head stay in English | Decision 16 says a term the book translates carries its English original, and a term it keeps takes no parentheses. These four sit on the keep side, and the reason is the one decision 39 already found for `chuỗi`: the obvious Vietnamese renderings are ordinary Vietnamese words. `khóa` is a lock and a key, `giá trị` is worth and value, `đầu` is a head and also the start of everything - chapter 07 alone writes `cái giá`, `giá trị của tích`, `chỗ khóa lại`, `đầu ra`, `bắt đầu` and `đầu tiên` in their everyday senses. Glossing the technical sense would set `giá trị (value)` beside `giá trị` meaning worth on the same page, which is worse than not translating. Chapter 07's own block of appendix B therefore holds four rows and not eight: `tích vô hướng`, `mã hóa vị trí`, `kết nối tắt`, `chuẩn hóa theo tầng`, all four of which are unambiguous. The chapter says on the page why the other four are in English rather than leaving a reader to wonder. Generalised, because the next chapter will hit it too: a candidate row whose Vietnamese side is a word the book already uses in a different sense does not go in the appendix, it goes in the keep-in-English table |
| 47 | The two copies of \enquote{Attention Is All You Need} are different documents, and the book says which one it read | The source manifest warned that the arXiv copy is dated 2023 and that wording from it is not automatically wording from 2017. Reading both copies through showed the gap is not about wording. The NIPS 2017 proceedings PDF is 11 pages; arXiv:1706.03762v7 is 15. The proceedings has no section 6.3 and no table 4 on constituency parsing, no appendix of attention visualisations, no parsing sentence in its abstract, and a reference list ending at [32] against v7's [40]. **And they disagree on a number.** The proceedings gives BLEU 41.0 for Transformer (big) on English-French in its abstract, its table 2 and its body alike; v7 gives 41.8 in the abstract and table 2 while its own section 6.1 still reads \enquote{a BLEU score of 41.0}. Both were checked at full page resolution, in both files, because 41.8 is the figure nearly every secondary source repeats. The `refs.bib` note records all of it and chapter 07 prints both numbers with the version each belongs to. What this generalises to is a rule the book already half had: a citation names a version, and for a paper with more than one live copy \enquote{the authors report X} is an incomplete sentence |
| 48 | Chapter 07's table sweeps epochs, and that is the finding rather than the axis | Chapters 05 and 06 both swept width, so the obvious chapter 07 table was width again. It says the wrong thing. Held at the shared recipe's 14 epochs the Transformer scores 0.4700 against the attention model's 1.0000, and three separate explanations had to be killed before that number meant anything: it is not overfitting (training-split accuracy is no higher than test), not broken plumbing (teacher-forced token accuracy is 0.9657, and 0.9499 to the 19th power is 0.3765 against a measured 0.3421 on long sentences), and not the optimizer (seven learning-rate recipes were tried, including the paper's own warmup shrunk to fit 658 steps, and the shared recipe beat all of them). What is left is steps: the same run at 42 epochs reaches 0.9967 and holds there at 56, carrying 35845 parameters against the attention model's 40805. So the table sweeps epochs at one width, and it is one training scored at four checkpoints rather than four trainings, which costs one run instead of four and makes the rows exactly comparable. The residual errors at 14 epochs are all one kind - right words, wrong noun phrase - which is the inductive-bias gap chapters 08 and 10 own, showing up early. **Consequence for decision 37**, whose per-model budget was written for models trained at the shared epoch count: a script that deliberately trains past it scales with the epochs, and `verify.py` carries that reasoning next to `ch07_corpus.py`'s 180-second budget |

Rows 49 to 58 were written 2026-08-11 in one pass, when the open items list was
emptied. Every one of them had been sitting in that list as a settled call with
its reason attached, which is a decision filed in the wrong place: an open item
is a thing nobody has done, and a call already taken is a thing nobody should
take again. Nothing here is new reasoning. What changed is that a session
looking for the reason will now find it where it looks.

| # | Question | Decision |
|---|----------|----------|
| 49 | The divisibility check on measured numbers is declined, and the measurement is why | Every exact-match figure is a count over a test split, so it must be a multiple of `1/N`, and `0.9425 * 300 = 282.75` would identify both that a number is wrong and which discarded run it came from without rerunning anything. Prototyped over the drafted chapters, it does not survive contact. Rounding kills the naive form outright: 256 of 300 prints as 0.8533 and `0.8533 * 300` is 255.99, so an exact-integer test flags every correct figure too, 401 of 701 decimals. A rounding-aware version allowing half a unit in the last place, restricted to values in [0, 1] printed to at least three decimals, still flags 210 of 344. The reason is structural rather than fixable: this book counts exact matches over the full test split, the short-sentence subset and the long-sentence subset, so no single `N` is right, and most decimals in that range are gradient norms and probabilities rather than counts at all. Same verdict and the same reason as the quotation rule in the writing rules: a check that is wrong most of the time trains its reader to skip it, which costs more than the rule it enforces. What survives is the manual habit - a number goes in the note with the configuration that produced it |
| 50 | The `number` check accepts a decimal that traces to the wrong note, and that hole is accepted rather than closed | Chapter 06 caught it. The chapter prints three differences of cited BLEU figures - 19.38, 11.01 and 8.37 - and only 19.38 fired. `8.37` passed because `research/2026-08-09-ch02-symptoms.md` records a loss of 8.3705 at `T_mem=20`, which is a chapter 02 measurement of something else entirely. The check asks whether a number appears *somewhere* under `research/`, not whether it appears where it came from, so it gets weaker every time the book grows a note. Not fixed, because the obvious fix - scope each chapter's numbers to its own note - breaks every legitimate case where a chapter quotes an earlier chapter's figure, and chapter 06 alone does that four times. All three differences are now recorded in the chapter 06 note with the subtraction behind each. `scripts/check-chapter.ps1` carries this next to the Numbers family, so the hole is documented where someone would go to close it |
| 51 | Chapter 01's gloss density is the cadence's cost, and the cost is accepted | Chapter 01 introduces the foundational vocabulary, so its own terms are the ones that appear in every section: printed page 3 carries five glosses and pages 4 and 5 carry four each, and decision 39 has since added more. `chuỗi (sequence)` lands twice on printed page 5, in sections 1.2 and 1.3, twelve lines apart, because the two sections are short and the cadence is per section. Nothing is wrong - every one is a term being introduced. Left as it is, because consistency with a written rule beats a judgement call made once, and a chapter that quietly drops a gloss the rule asks for is how the four consecutive cadence regressions started |
| 52 | The `\footnotesize` hatch is for a block that needs the width, and chapters 01 and 03 were not using it that way | Decision 31 waives `Listings.MaxLineLength` for any block carrying its own option list, on the grounds that whoever set a fontsize for one block owns its width. Chapter 04's audit found the first misuse and fixed it there: eight tables between 19 and 68 columns, all well inside the 73-column budget at `\small`, so the smaller size bought nothing and cost the page a third type size. Chapters 03 and 01 had the same pattern and were left alone at the time because neither was that session's chapter. Swept 2026-08-11: chapter 03's six captured tables measure 40, 51, 54, 54, 64 and 68 columns and chapter 01's three measure 39, 45 and 45, so all nine came out of `\footnotesize` and are now visible to the gate that exists to measure them. This retires the example decision 31 and `check-chapter.psd1` section 11 both used for the hatch; the hatch itself stays, for a block that genuinely needs the width |
| 53 | Appendix B's `giả thuyết` row loses its scoping note | The row read \enquote{nghĩa trong beam search}, and three chapters then used the word in its ordinary sense: chapter 03 for the paper's hypothesis, chapter 05 in the beam-search sense the note describes, and chapter 06 for a guess about why one row of an alignment matrix behaves oddly. No check can read a scoping note in a table cell, so all three glossed it and all three were right - \enquote{hypothesis} is the correct English every time. Three chapters is enough evidence that the note described one chapter's usage rather than the book's, so it is gone rather than being carried as an apology. Recorded because appendix B is shared state and decision 30 says two sessions can be editing it at once |
| 54 | The statistics of `q . k` after training stay unmeasured, and an exercise is not a measurement | Everything in chapter 07's scaling section is at initialization, where the measurement is that PyTorch's default `nn.Linear` gives component variance 1/3 rather than the footnote's 1, so `var(q.k)` is about `d_k/9` and the `1/sqrt(d_k)` divisor over-corrects roughly threefold. The chapter argues this does not matter, because the divisor's job is to remove the dependence on `d_k` rather than to set an absolute scale, and the measured flatness of the scaled columns across `d_k` from 8 to 1024 supports that. What nobody has checked is whether a trained model's scores still sit at that scale, and the chapter says so on the page. Chapter 07's tier-three exercise 1 hands it to the reader, and that is where it stays. **Generalised**: an exercise handed to the reader is not a measurement. A later chapter that needs the answer measures it and puts the number in a note, rather than citing the exercise as though the question had been settled |
| 55 | Experiment scripts are not run through `conda run` | It captures the child's stdout and re-encodes it with the system code page, so `utf8_stdout()` inside the child cannot help and a Vietnamese line surfaces as a `UnicodeEncodeError` raised inside conda's own `main_run` - a traceback that names conda rather than the repo, and cost two failed runs before the real error was visible at the top of the output rather than the tail. `verify.py` is immune because it invokes `sys.executable` through `subprocess` with an explicit encoding. So: run the environment's interpreter directly, or activate the environment first. Chapter 07's tier-two preamble warns the reader, and appendix E teaches the conda path, so both halves of the audience are covered |
| 56 | Chapter 06's forward-only encoder gets worse under source reversal, and the chapter prints that without explaining it | Exact match falls 0.9500 to 0.8667, and the loss lands entirely on long sentences, 0.9079 to 0.7434, while short sentences do not move at all. With the bidirectional encoder reversal is worth 0.0033, so the interaction between the two is real rather than noise. Nobody knows why. The chapter prints it as an observation and tier-three exercise 2 hands it to the reader, which is the honest shape: decision 7 says a number I measured goes in a `measured` box and traces to a note, and it says nothing about having to explain one. All five figures are in `research/2026-08-ch06-dong-chinh.md`. **Generalised**: an unexplained direction in a table is recorded with the chapter that owns it, because a later chapter can accidentally explain it and then never go back to connect the two |
| 57 | The companion repo keeps hand-written recurrent loops, and `torch.nn.LSTM` is a named lever rather than an option | Every recurrent layer in the repo is a Python loop over time steps. That is the right choice for chapters 01 to 04, which reach inside the loop and could not use a fused kernel if they wanted to. Chapter 05 does not reach inside it - it trains and measures - and there the loop costs measurable time: fifteen trainings at roughly nineteen seconds each is most of what chapter 05 spends, and the fused version would be a large multiple faster. Not changed, because a book that builds from scratch and then quietly swaps in the library for the chapter where it matters has stopped building from scratch, and decision 4 is what the reader was promised. Recorded so that whoever hits the budget wall of decision 43 knows this lever exists and knows what pulling it costs |
| 58 | `refs.bib`'s `note` field is the only ledger of how much of a paper was read | The SPEC carried a second list of partially-read papers, which duplicated what every one of those entries already says in its own `note`, and drifted: `cho2014properties` left the list a session after chapter 06 read it in full. So the entry is the ledger. A paper cited from less than a full read says so there and names which sections were read, and that field is a claim with the same standard as a number - `he2016deep`'s note was first written claiming a read of section 3.2 from a subagent's summary rather than from the paper, and the chapter's sentence about the degradation result was circular on top of that; fetching the PDF and reading page 1 fixed both. The same applies to the bridge-paper list, which closes one paper at a time as each lands in the chapter that cites it, and where the TOC's \enquote{Cho 2014} is two entries: `cho2014encdec`, the EMNLP encoder-decoder paper, and `cho2014properties`, the SSST-8 paper that measured the length degradation. Bahdanau distinguishes them as 2014a and 2014b and the whole received story about chapter 05 turns on which one is meant |

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
6. **Một vector cho mỗi từ** (Bahdanau, Cho, Bengio 2015) - who actually
   measured the bottleneck, which is Cho 2014b and not this paper, since this
   one says \enquote{conjecture} and cites two workshop papers; additive
   attention, scored from the state *before* the step; the derivation showing a
   direct gradient path from every source step to every target step, and that
   path measured as a reach that stops shrinking with sentence length; chapter
   05's width sweep run again with attention on the same recipe; the BiRNN
   encoder, with a parameter-matched ablation showing this corpus cannot say
   what the backward pass is for; a measured English-Vietnamese alignment
   matrix and its crossing rate; a bridge box for Luong 2015; gap: attention is
   still an accessory bolted onto an RNN, and the paper's own \enquote{drawback}
   sentence about `T_x` times `T_y` scores is the seed of chapter 12

### Part IV - Bỏ hẳn recurrence

7. **Kiến trúc Transformer** (Vaswani et al. 2017) - self-attention, with
   permutation equivariance measured rather than asserted, which is what makes
   positional encoding compulsory; the three places the model uses attention and
   how they differ; scaled dot-product with the variance argument behind
   1/sqrt(d_k) derived, measured, and then measured against the initialization
   the code actually uses; multi-head attention and why the head count does not
   move the parameter count; sinusoidal positional encoding, its linear-shift
   property checked analytically, the stronger offset-only property of its inner
   product, and the point where that inner product stops being monotone so it
   does *not* encode distance; residuals, layer norm and the position-wise FFN,
   with bridge boxes for He 2015 and Ba 2016; masked decoder self-attention
   tested by intervention, where the unmasked model reaches a *lower* training
   loss and scores zero; and the chapter's own table, which sweeps epochs rather
   than width (decision 48). Two copies of this paper exist and disagree on a
   BLEU score (decision 47)
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
| 06 | drafted | Companion tag `ch06`, module `attention.py`. Retitled from \enquote{Đồng chỉnh} with the folder and label following (decision 42). Pays chapter 05's debt: Cho 2014b read in full, from the arXiv and Anthology copies, both nine pages. The chapter's spine is that the paper this chapter reads *conjectured* the bottleneck and cited two SSST-8 workshop papers for it, while chapter 05 is where this book measured it. Reproduces chapter 05's width table digit for digit on its fixed-vector rows, which is what makes the two chapters' tables comparable. Two TikZ figures. `BUDGET_TOTAL` raised to 900 (decision 43) |
| 07 | drafted | Companion tag `ch07`, module `transformer.py`. Four experiments, two of which train nothing, so the whole repo verifies in 663.51s against the 900s budget and decision 43 is untouched. Reads both copies of the paper and finds they are different documents that disagree on a BLEU score (decision 47). The chapter's table sweeps epochs rather than width, after three other explanations for the 14-epoch result were killed (decision 48). Two TikZ figures. Four appendix B rows, and four terms deliberately kept in English (decision 46) |
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

  **Not `conda run`** (decision 55). Run the environment's interpreter directly,
  or activate the environment first. `conda run` re-encodes the child's stdout
  with the system code page, so a Vietnamese line dies as a `UnicodeEncodeError`
  raised inside conda rather than inside the script, and the traceback sends you
  looking in the wrong repo.
- **Research:** yes, one note per chapter under `research/`, plus the source
  manifest already there. The cliff is already crossed (decision 20), so every
  decimal printed anywhere in the book must appear in a note. A note records the
  exact command, the versions, the raw output rather than a summary, and the
  date. Record the measurements that turned out to be uninteresting too.

  **A table comparing two architectures prints their parameter counts**, and an
  ablation ships a size-matched control or says in the prose why it has none
  (decision 44). Chapter 06 is where this cost something: four rows said the
  bidirectional encoder was worth five points of exact match, and a fifth row
  with the parameter counts matched said it was worth nothing. The rule is
  cheap to follow and the sentence it prevents is one the book cannot take
  back.

  **A number goes in the note with the configuration that produced it**, never
  on its own. The `number` family checks that a decimal appears in a note, and a
  note recording a figure from a configuration nobody can name still satisfies
  it: that is how six wrong decimals from a discarded probe run got past a green
  gate in chapter 05. A measurement taken before the recipe was pinned is
  retaken afterwards or dropped, and there is no third option. And when an audit
  reports a wrong number, the question to ask it is **what else came from
  here**, not whether that one is fixed now; the first audit of chapter 05 found
  four and the second found two more with the same origin.

  **An exercise handed to the reader is not a measurement** (decision 54). A
  chapter may leave a question open and hand it to a tier-three exercise; what
  it may not do is let a later chapter cite that exercise as though the question
  had been answered. The later chapter measures it and puts the number in a
  note. The statistics of `q . k` after training are the open case.

  **An unexplained direction in a table is recorded with the chapter that owns
  it** (decision 56). A number that moves the wrong way and is printed anyway is
  fine, and honest; what goes wrong is that a later chapter accidentally
  explains it and never goes back to connect the two. Chapter 06's reversal
  result is the open case.
- **Sources:** citations are `~\autocite{...}`, always with the tilde. A number
  from a paper is cited and, where the claim is load-bearing, page-anchored
  against the exact PDF named in the source manifest. A number I measured goes
  in a `measured` box, says in the prose that I measured it, and traces to a
  research note. Quoted material uses `\enquote{}`, never a literal quote
  character.

  **A paper with more than one live copy is cited by version, and the
  differences are checked rather than assumed** (decision 47). The arXiv copies
  of Vaswani and Bahdanau postdate their conferences by six years and one year,
  so wording quoted from them is not automatically wording from 2017 or 2015.
  Chapter 07 is where the cost of not checking became concrete: the two copies
  of Vaswani differ by four pages of content and by a BLEU score, and the widely
  quoted 41.8 appears in the abstract and table of the 2023 arXiv copy while
  that same copy's body says 41.0. Read both, diff the passages the chapter
  leans on, and put what you found in the `refs.bib` note.

  **A bridge box needs the same first-hand check as a number.** It is prose
  about a paper, and prose about a paper is where a summary from memory or from
  a subagent slips through unchallenged, because nothing in the gate reads it.
  Both of chapter 07's bridge boxes shipped a first draft that overstated what
  had been read; one of them argued in a circle. The `note` field saying which
  sections were read is itself a claim and has to be true.

  **`refs.bib`'s `note` field is the ledger** (decision 58), and the SPEC does
  not keep a second copy. A paper cited from less than a full read says so in
  its entry, naming which sections were read; a paper later read in full has its
  note rewritten in the same session. The bridge papers the TOC names close one
  at a time, in the chapter that cites them, and \enquote{Cho 2014} is two
  entries. To see where the book stands, read the notes.

## Open items

Closed items are deleted rather than kept with a note, and whatever they were
carrying moves to the decision log, the writing rules, or a comment in the file
that enforces it. A list where half the entries say "resolved" stops being read,
which is how the four consecutive gloss regressions kept getting past a rule
that was written down.

(None. Emptied 2026-08-11: every entry became a decision-log row, a
writing rule, or a comment in the file that enforces it. Rows 49 to 58 are
where most of them landed.)
