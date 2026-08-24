@{
    # This book's half of the prose gate. scripts/check-chapter.ps1 supplies the
    # checks and the defaults; this file holds only what this book decides
    # differently. The resolved policy is printed at the top of every run, so a
    # weakened gate is visible rather than silent.
    #
    # The table is empty and every setting below is commented out, on purpose. A
    # template that shipped today's defaults as live settings would freeze every
    # new book at the moment the template was written: the book would be
    # overriding the library with a copy of the old values, and later
    # improvements to the defaults would never reach it. So a new book inherits
    # everything until its author consciously chooses otherwise. Uncomment a
    # setting only when this book has a reason to differ, and write that reason
    # down beside it.
    #
    # Inheriting is safe because the library grows in one direction. A check
    # added to check-chapter.ps1 after this book started is off until this file
    # turns it on, so a later improvement can fix a check this book already runs
    # but cannot start reporting something new without this book's author
    # uncommenting the setting and writing the rule in SPEC.md. The new checks
    # are listed below like the old ones, with their default shown as off.
    #
    # The commented block is also the schema. Every key check-chapter.ps1
    # accepts appears below, in the sections and the order the script defines
    # them, showing the default it resolves to. A name that is not listed here
    # cannot be set: the schema check rejects unknown keys, so a typo fails the
    # run instead of quietly disabling a check.
    #
    # How overriding works: tables merge key by key, so naming one setting
    # inside Spelling leaves the rest of Spelling alone. Arrays and scalars
    # replace wholesale, because that is the only way a book can remove an entry
    # the library supplies. Uncommenting an array therefore means listing every
    # element the book wants, not just the new ones.
    #
    # The prose half of these rules lives in SPEC.md, under "Writing rules
    # (book-specific)". Keep the two in step: a setting here without a rule
    # there is a rule nobody agreed to, and a rule there without a setting here
    # is a rule nothing enforces.

    # -- 1. Paths -------------------------------------------------------------
    # Which folders are read, relative to the book root. Prose is what the
    # English checks read. Characters is what the character scan reads, and it
    # is a separate list because a book may want refs.bib scanned for a Unicode
    # dash pasted out of a web page without having its BibTeX linted as English.
    # preamble/ and figures/tikz/ are absent by design: macro definitions and
    # TikZ path syntax are not prose, and adding them costs a stream of findings
    # about code.
    # Paths = @{
    #     Prose      = @('chapters', 'frontmatter', 'backmatter')
    #     Characters = @('chapters', 'frontmatter', 'backmatter')
    # }

    # -- 2. Characters --------------------------------------------------------
    # Mode is one of:
    #   'Punctuation' - the default. Letters of any script pass, so the book can
    #       quote Vietnamese or CJK in the running text. What is rejected is
    #       control characters and Unicode look-alikes of ASCII punctuation:
    #       curly quotes, en and em dashes, the minus sign, ellipsis,
    #       non-breaking and zero-width spaces, the soft hyphen, guillemets. The
    #       file must also decode as UTF-8, and a file that does not is reported
    #       rather than silently read as replacement characters.
    #   'Ascii' - the stricter opt-in. No byte outside printable ASCII, tab, LF
    #       or CR, checked on the raw bytes and inside verbatim environments
    #       too. Worth the cost for a book whose listings are all captured
    #       console output, where a stray Unicode character means the paste went
    #       through something that rewrote it. The cost is every accented name
    #       and every non-Latin example in the running text.
    #   'Off' - no character scan at all.
    # Characters = @{
    #     Mode  = 'Punctuation'
    #
    #     # Further code points to reject, each written as U+XXXX. Punctuation
    #     # mode only; ignored under Ascii and Off.
    #     Extra = @()
    #
    #     # Code points to allow back in, each written as U+XXXX. Every entry is
    #     # a hole in the check, so name the one character the book needs.
    #     Allow = @()
    #
    #     # Listing environments inside which a character this mode would
    #     # otherwise reject is allowed to stand, in the same 'name' or
    #     # 'name:lexer' form Verbatim.Environments uses. Tooling writes prose:
    #     # a compiler or a linter can emit a message containing an em dash, and
    #     # a book that prints what a tool said should not have to edit the
    #     # capture, weaken the mode for every file, or drop the evidence. Both
    #     # halves are required and the second is the point: the character has
    #     # to be inside one of these environments AND the line it sits on has
    #     # to appear in a research note. A book with no notes cannot use it.
    #     AllowInCapturedListings = @()
    # }

    # -- 3. Citations ---------------------------------------------------------
    # Enabled    - the master switch for all three citation checks. A book with
    #              no bibliography loses nothing by turning it off, and gains
    #              nothing by leaving it on.
    # Macros     - the citation macros to look for, written without backslashes.
    # RequireTie - a citation must be preceded by ~, so a bracketed number can
    #              never start a line on its own. Turning this off is a
    #              typographic decision, not a convenience.
    # CheckKeys  - every key cited must exist in BibFile. This is the check that
    #              catches a citation invented while drafting, which is the most
    #              expensive kind of error to find later.
    # BibFile    - the bibliography, relative to the book root.
    # Citations = @{
    #     Enabled    = $true
    #     Macros     = @('autocite')
    #     RequireTie = $true
    #     CheckKeys  = $true
    #     BibFile    = 'refs.bib'
    # }

    # -- 4. Quotes ------------------------------------------------------------
    # Bans the literal " in prose in favour of \enquote{...}, which is what
    # gives the book correct quotation marks in every language babel is loaded
    # for. Inline code is masked before the check (see Macros below), so a quote
    # inside \code{...} is fine, and a nested quotation is fine because the
    # macro nests. A LaTeX accent macro is fine too: \"u and \"{o} are a
    # diaeresis rather than a quotation mark, and under Characters.Mode =
    # 'Ascii' they are the only way to spell such a name without misspelling
    # it. A line break followed by a real quote, \\", is still caught.
    # Turning it off means choosing quote glyphs by hand for the rest of the
    # book.
    # Quotes = @{ Enabled = $true }

    # -- 5. Index -------------------------------------------------------------
    # Enabled      - an \index{...} line must end with %, so that the line break
    #                after it does not become a space in the typeset text. The
    #                house form is the entry on its own line immediately before
    #                the paragraph it belongs to.
    # RangeMarkers - exempt the range forms \index{term|(} and \index{term|)},
    #                which stand alone by convention. Turning it off means
    #                writing % after those too.
    # ForbidPattern - a regex matched against the whole \index line. Empty means
    #                the check does not run. The printed index is the reader's
    #                vocabulary, so a term they have never met cannot be looked
    #                up; a book that names its own internal machinery in prose
    #                can index that machinery by accident. One book indexed a
    #                numbered row of its own decision log, which the reader has
    #                never seen. Forbid a term, a prefix or a shape.
    # Index = @{
    #     Enabled      = $true
    #     RangeMarkers = $true
    #     ForbidPattern = ''
    # }

    # -- 6. Dashes ------------------------------------------------------------
    # Flags runs of exactly two or three hyphens in prose, which TeX sets as en
    # and em dashes. The repo wants neither: reword, or use ASCII punctuation. A
    # book that decides to set ranges with -- turns this off and gives up the
    # check on --- with it, because one flag covers both ligatures.
    # Dashes = @{ Enabled = $true }

    # -- 7. Json --------------------------------------------------------------
    # Flags a JSON string literal that opens on a line and does not close on
    # it. JSON forbids a raw newline inside a string, so this is invalid in a
    # whole document and equally invalid in an excerpt of one, which is what
    # makes it safe to leave on: it fires on neither of the two things books
    # legitimately print here, a fragment lifted out of a larger config file
    # and a listing carrying an elision.
    #
    # The defect it exists for is a long response wrapped by hand to fit the
    # measure, with the break landing inside a "message". The page looks right
    # and a reader who types the listing out gets a parse error.
    #
    # Parsing the block instead was tried and rejected: across the books in
    # this repository it reported a dozen findings and every one was a
    # deliberate excerpt or elision, which is a check that gets switched off
    # within the week.
    #
    # Environments - where this book puts JSON, in the same notation
    #                Verbatim.Environments uses: a bare name matches
    #                \begin{name}, and minted:json matches
    #                \begin{minted}[opts]{json}. Emptying the list turns the
    #                family off as surely as Enabled = $false does.
    # Json = @{
    #     Enabled      = $true
    #     Environments = @('minted:json')
    # }

    # -- 8. Contractions ------------------------------------------------------
    # Off by default, because contractions are a voice decision rather than a
    # language fact, and the house first-person practitioner voice wants some.
    # Turning it on bans the whole preset list in the author's own words, and
    # the cost lands on the writing rather than the tooling: "it is" for "it's"
    # everywhere reads more formal than most chapters want, and the rule is only
    # worth having if the book means to hold that register throughout. Quoted
    # material and inline code are masked first, so the check never fires on
    # someone else's words or on an identifier.
    # Preset - 'english' is the only list that ships.
    # Allow  - contractions to permit anyway, written exactly as they appear in
    #          the preset list.
    # Contractions = @{
    #     Enabled = $false
    #     Preset  = 'english'
    #     Allow   = @()
    # }

    # -- 9. Spelling ----------------------------------------------------------
    # Preset accepts 'en-GB' or 'en-US'. The default is '', meaning no variety
    # has been chosen and the check does not run: the library will not guess
    # which side of the Atlantic a new book is written on, and a book written in
    # another language has no business being held to either. Choose in the first
    # drafting session, because a variety picked after ten chapters is a rewrite
    # rather than a setting.
    #
    # This is not a spell checker. It is a fixed table of about eighteen word
    # pairs where the two varieties differ, and it fires on the wrong one.
    # Enabled  - a second switch, so a book can keep its Preset on record while
    #            the check is off. Both have to be set for the check to run.
    # Variants - adds a second table of about ten more pairs, off by default.
    #            The base table above holds the differences that follow a rule;
    #            this one holds the leftovers, words like programme/program and
    #            judgement/judgment whose two spellings follow none, which is
    #            why the base table cannot generate them and why a draft can
    #            carry one past a clean run. A book that has chosen a Preset
    #            probably wants these too.
    # Exempt   - regexes matched whole against the flagged word, case
    #            insensitively. For product names and chapter titles that only
    #            look like the wrong variety. An exemption costs one word; it is
    #            narrower than turning the check off, and that is the point.
    # Extra    - book-specific pairs, written as pattern = correction and merged
    #            into the preset table, after Variants so a book can override
    #            one of them. The keys are regex fragments, not literals, and
    #            this map is the one place a book's own keys are accepted
    #            without schema checking.
    # Schema, kept for reference now that this key is live below:
    # Spelling = @{
    #     Enabled  = $true
    #     Preset   = ''
    #     Variants = $false
    #     Exempt   = @()
    #     Extra    = @{}
    # }
    #
    # THIS BOOK: on, en-US (SPEC "Language and spelling"). The prose is
    # Vietnamese; the variety governs the English inside every gloss and
    # quotation, which must match how the 32 corpus papers spell, because a
    # gloss in the wrong variety sends a reader searching the paper for a
    # string it does not contain.
    #
    # Extra carries the SPEC's tone-mark rule: the mark goes on the first
    # vowel of a vowel cluster. The keys are whole words, matched on word
    # boundaries, so 'hoà' fires while closed syllables like 'hoàn' and
    # 'thoát' - correctly marked under both conventions - never do. The nine
    # pairs are adopted from tu-rnn-den-transformer, which grew them one
    # audit finding at a time; add a pair here whenever a new cluster word
    # turns up wrong, instead of fixing the site and moving on.
    Spelling = @{
        Enabled = $true
        Preset  = 'en-US'
        Extra   = @{
            'hoà'  = 'hòa'
            'hoá'  = 'hóa'
            'hoạ'  = 'họa'
            'toạ'  = 'tọa'
            'khoá' = 'khóa'
            'xoá'  = 'xóa'
            'luỹ'  = 'lũy'
            'tuỳ'  = 'tùy'
            'tuý'  = 'túy'
        }
    }

    # -- 10. Numbers ----------------------------------------------------------
    # Every decimal printed in the book has to appear in one of this book's
    # research notes, so that a measured number is reproducible rather than
    # remembered. While the notes folder is empty the check is skipped entirely;
    # see research/README.md for what changes the moment the first note lands.
    #
    # What it does not cover: numbers written as words, and dotted version
    # strings. The research side is matched from a digit boundary and left open
    # at the end, so prose may round and 9.2 is accepted against a recorded
    # 9.22.
    # ResearchDir  - the notes folder, relative to the book root.
    # ResearchGlob - which files in it count as notes. Narrow it if the folder
    #                grows files that are not notes.
    # Allow        - regexes for numbers that are not measurements and should
    #                never have to trace: a version in prose, a fraction in an
    #                instruction. Each entry is a hole, so keep them tight.
    # Numbers = @{
    #     Enabled      = $true
    #     ResearchDir  = 'research'
    #     ResearchGlob = '*.md'
    #     Allow        = @()
    # }

    # -- 11. Verbatim ---------------------------------------------------------
    # When prose calls a listing a capture, every substantial line of that
    # listing has to appear in this book's research notes. It catches the
    # listing that was tidied on the way to the page, which is the number check
    # one level up. Like the number check it does nothing until the book has
    # notes.
    # Environments  - which listing environments a claim can arm. A bare name
    #                 matches \begin{name}; 'minted:text' matches
    #                 \begin{minted}[opts]{text}. Keep the list to environments
    #                 that hold captured output: listings that come out of a
    #                 companion repo are checked by that repo, and commands to
    #                 type are not captures at all. Widening it means every
    #                 listing near the word "verbatim" now has to trace.
    # ClaimPattern  - the regex that recognises a claim in the prose. Setting it
    #                 replaces the whole phrase list, so start from the default
    #                 below rather than from scratch.
    # Window        - how many lines after a claim can still open the listing it
    #                 refers to. A larger window arms listings the claim was not
    #                 about.
    # MinLineLength - listing lines shorter than this are skipped, because a
    #                 bare brace matches everything and proves nothing.
    #                 Lowering it buys noise.
    # Verbatim = @{
    #     Enabled       = $true
    #     Environments  = @('minted:text', 'minted:json')
    #     ClaimPattern  = '(?i)(?:\bverbatim\b|\bunmodified\b|\buntouched\b|character for character|(?:have|has|had)\s+not\s+(?:been\s+)?(?:trimmed|edited|altered)|\bnot\s+(?:been\s+)?trimmed\b|\bin full\b|exactly as)'
    #     Window        = 6
    #     MinLineLength = 12
    # }

    # -- 12. Listings ---------------------------------------------------------
    # A listing line wider than the measure is the one typographic defect the
    # log check cannot see. A book that loads minted with breaklines has asked
    # for an over-wide line to be broken to fit, and it is obliged silently: no
    # Overfull box, and a wrap on the page nobody chose. The Overfull box comes
    # back only when the line offers no break point at all, which is the case
    # real code never falls into.
    # Enabled       - the master switch.
    # MaxLineLength - the column budget. 0 means no budget has been declared and
    #                 the check does not run, which is the default. The number
    #                 falls out of this book's measure, its mono font and the
    #                 size its listings are set at, so the library will not
    #                 guess it.
    #
    # Measure it rather than deriving it. Put lines of N and N+1 columns, each
    # carrying a break point, in a listing at this book's own settings, build,
    # and see which one gains a continuation arrow. The arithmetic agrees when
    # the mono font is Courier-metric: \the\textwidth over the advance width of
    # one character at the listing's fontsize, both of which \settowidth and
    # \typeout will tell you.
    #
    # A block whose \begin line carries its own [option list] is not measured.
    # Naming a fontsize, or an explicit breaklines, for one block is a
    # typographic decision taken about that block, and whoever took it owns the
    # width. That is the escape hatch, and it sits in the source where a reader
    # of the chapter can see it rather than in this file.
    #
    # A starred \newminted alias waives the same way with {braces}, because that
    # is the form minted declares it with: \begin{NAME} reads an optional
    # [options] and \begin{NAME*} takes a mandatory {options}. Braces after an
    # unstarred \begin{minted} hold the language and waive nothing.
    #
    # What the count is not: display columns. It counts UTF-16 code units, so a
    # CJK glyph counts one and sets two, and an emoji counts two and sets one. A
    # tab counts one. autogobble strips a block's common indent before
    # typesetting, so an indented block is measured wider than it sets. A book
    # absorbs all three by measuring its own number instead of borrowing one.
    #
    # AliasAsLexer - the family's other check, and a build failure rather than a
    #                typographic one. A book that writes \newminted[NAME]{lexer}
    #                has given itself two ways to spell NAME, and only
    #                \begin{NAME} is one of them: \begin{minted}{NAME} sends
    #                NAME to Pygments, which has never heard of it, and the run
    #                dies with `Pygments lexer "NAME" is unknown`. That reads as
    #                a missing lexer and sends you into Pygments rather than
    #                into your own preamble. On by default and free for a book
    #                that declares no aliases, because there is then nothing to
    #                confuse. Unlike MaxLineLength it needs no number, so
    #                Enabled = $false is the only other way off.
    # Listings = @{
    #     Enabled       = $true
    #     MaxLineLength = 0
    #     AliasAsLexer  = $true
    # }

    # -- 13. Macros -----------------------------------------------------------
    # The masking macros: what is blanked out of a line before the line is read
    # as English. These are library facts rather than book decisions, and they
    # are settable only so that a book which renames one of them keeps its
    # masking. Renaming without updating this costs you the exemption silently.
    # Code        - inline code spans. Their contents are exempt from the quote,
    #               dash, contraction, spelling and number checks.
    # Quoted      - quotation macros. Their contents are exempt from the dash,
    #               contraction and spelling checks, because quoted words are
    #               someone else's; they are deliberately not exempt from the
    #               quote check, so nested quotations still use the macro.
    # Identifiers - macros whose argument is a name rather than English, so that
    #               a label, a path or a citation key is never read as a
    #               contraction or a misspelling.
    # Macros = @{
    #     Code        = @('code')
    #     Quoted      = @('enquote')
    #     Identifiers = @('begin', 'end', 'label', 'ref', 'pageref', 'input', 'include', 'autocite')
    # }

    # -- 14. Gloss ------------------------------------------------------------
    # For a book that translates its vocabulary and prints the original
    # alongside. One rule with no direction in it: a term the chapter owns is
    # glossed once per section, a term another chapter owns is glossed once per
    # chapter. Ownership is which block of the glossary the term sits in, and
    # which chapter a file belongs to comes from its path, chapters/NN-.
    #
    # Off until Glossary names a file, because everything the check needs is a
    # book fact and most of it is written in the book's own language. A book
    # that ships one language, or glosses nothing, leaves this alone.
    #
    # What it cannot see: a term central to a chapter that was never added to
    # the glossary at all. The glossary is the source of truth, so a term in
    # neither it nor a gloss call reads as ordinary prose. That stays a reading
    # job.
    # Enabled      - the master switch. Emptying Glossary is the other way off.
    # Glossary     - the glossary source, relative to the book root.
    # Macro        - the gloss macro, \tn{original}{translation} or whichever
    #                way round the book writes it; the first argument is the
    #                term the glossary lists.
    # BlockPattern - the heading that opens one chapter's block of the glossary.
    #                Capture group 1 must be that chapter's number.
    # KeepPattern  - the heading that opens the block of terms the book does not
    #                translate. Optional; it only sharpens a message, because
    #                glossing a term the book keeps as is sets it beside itself.
    # Exempt       - terms that are also ordinary words in the book's language,
    #                where a gloss helps nobody. Keep it short: an exception
    #                list carrying most of a check's signal is a list, not a
    #                check. Measure before adding to it.
    # Schema, kept for reference now that this key is live below:
    # Gloss = @{
    #     Enabled      = $true
    #     Glossary     = ''
    #     Macro        = 'tn'
    #     BlockPattern = ''
    #     KeepPattern  = ''
    #     Exempt       = @()
    # }
    #
    # THIS BOOK: on from init, against appendix B, which the SPEC's gloss
    # regime makes the source of truth for what is translated. Armed before
    # the first chapter is drafted so every chapter meets the cadence from
    # the start: tu-rnn-den-transformer armed it after five chapters and the
    # sweep found 32 defects. With zero glossary rows the check passes
    # trivially, so arming now costs nothing. Exempt starts empty and grows
    # one measured term at a time; the SPEC's open items already flag "chuỗi"
    # as the likely first candidate.
    Gloss = @{
        Enabled      = $true
        Glossary     = 'backmatter/appendix-b-thuat-ngu.tex'
        Macro        = 'tn'
        BlockPattern = '\\textbf\{Chương\s+(\d+)\}'
        KeepPattern  = '\\textbf\{Giữ nguyên'
        Exempt       = @()
    }

    # -- 15. Figures ----------------------------------------------------------
    # TikZ style names pgfkeys has already taken. `step/.style={...}` shadows
    # nothing: it fails the build with an error naming the key rather than the
    # style, which reads as a missing \usetikzlibrary and sends you looking in
    # the preamble.
    # Enabled      - the master switch, and it takes both checks below.
    # NodeText     - the second thing that exclusion costs, and the reason it is
    #                a check rather than a footnote. TikZ draws a segment with
    #                `--`, which is precisely why these files are kept out of
    #                the prose dash check; node and label text is prose all the
    #                same, and `--` there sets an en dash the repo-wide rule
    #                bans and nothing else reads. Only braced groups following a
    #                node or label are read, because a coordinate never carries
    #                one and a node's text always does, so the exclusion still
    #                buys quiet on paths without buying it on words.
    # Paths        - which folders hold picture sources, relative to the book
    #                root. They sit outside Paths.Prose on purpose, so this is
    #                the only check that reads them, and -Chapter does not
    #                narrow them.
    # ReservedKeys - the names to reject. Emptying the list is the other way to
    #                switch the key check off, so a book that disagrees with one
    #                name does not have to disable the family to say so. It
    #                leaves NodeText running, which is the point of their being
    #                two switches.
    # Figures = @{
    #     Enabled      = $true
    #     NodeText     = $true
    #     Paths        = @('figures/tikz')
    #     ReservedKeys = @('in', 'out', 'step', 'shift', 'scale', 'text', 'style')
    # }

    # -- 16. Log --------------------------------------------------------------
    # Reads the build log that latexmk already wrote. The check never runs
    # latexmk itself, so a missing log is a warning and a log older than the
    # sources is a warning; build first if you want these numbers to mean
    # anything.
    # Path         - the log, relative to the book root.
    # MaxOverfull  - how many Overfull boxes are tolerated. Zero means every
    #                line that runs into the margin is a finding. Raising it is
    #                how a book stops noticing that it sets badly. It does not
    #                cover a listing line that was too wide and got broken to
    #                fit: that raises no box at all, and section 11 is what
    #                catches it.
    # MaxUndefined - how many log lines may mention an undefined reference or
    #                citation. Above zero, broken cross-references ship.
    # Log = @{
    #     Enabled      = $true
    #     Path         = 'build/main.log'
    #     MaxOverfull  = 0
    #     MaxUndefined = 0
    # }
}
