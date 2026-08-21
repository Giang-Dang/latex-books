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
    # Index = @{
    #     Enabled      = $true
    #     RangeMarkers = $true
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
    # Enabled - a second switch, so a book can keep its Preset on record while
    #           the check is off. Both have to be set for the check to run.
    # Exempt  - regexes matched whole against the flagged word, case
    #           insensitively. For product names and chapter titles that only
    #           look like the wrong variety. An exemption costs one word; it is
    #           narrower than turning the check off, and that is the point.
    # Extra   - book-specific pairs, written as pattern = correction and merged
    #           into the preset table. The keys are regex fragments, not
    #           literals, and this map is the one place a book's own keys are
    #           accepted without schema checking.
    # Schema, kept for reference now that this key is live below:
    # Spelling = @{
    #     Enabled = $true
    #     Preset  = ''
    #     Exempt  = @()
    #     Extra   = @{}
    # }
    #
    # THIS BOOK: on, en-US. Exempt and Extra are left to the library defaults;
    # tables merge key by key, so naming two settings here leaves those two
    # alone.
    #
    # The prose is Vietnamese, so at first glance a spelling variety looks like
    # a setting that cannot apply. It applies to the other half of every page.
    # This book translates a term into Vietnamese and then carries the English
    # original in parentheses at every occurrence, so a few thousand English
    # words end up in the running text, and they should be spelled the way the
    # six papers spell them. All six are American: "initialization",
    # "normalization", "labeling", "center". A gloss reading
    # "(initialisation)" sends a student to search for a string that is not in
    # the paper they are about to open, which is the one thing the gloss rule
    # exists to prevent.
    #
    # No Vietnamese word collides with the eighteen pairs in the table, so
    # turning this on costs nothing on the Vietnamese side. Exempt stays empty
    # until a real product name needs it.
    # Extra also carries the Vietnamese half of decision 41: the tone mark goes
    # on the first vowel of a vowel cluster. The keys are whole words, matched
    # on word boundaries, which is what keeps 'hoa' with a mark from firing
    # inside 'hoan' and 'thoat' - a blanket search and replace does not have
    # that property, and one pass of it turned 'thoat' into a non-word that only
    # the rebuild caught. Closed syllables are absent on purpose: there the mark
    # already sits on the nucleus under both conventions, so 'hoat' and 'thoat'
    # are correct as they stand. Listing the open syllable 'hoa' catches what
    # is wrong without touching them, which is the whole reason these are
    # whole-word keys.
    #
    # 'hoa' and 'toa' with the mark on the second vowel were added in the
    # chapter 06 session, after an audit found the first in two already
    # drafted chapters and the second in the new one. Decision 41 is stated
    # for the vowel cluster rather than as a list of words, so those three
    # sites were wrong before anyone typed them; nothing except this table was
    # ever going to find them. That is the argument for adding a pair here
    # whenever one turns up, instead of fixing the site and moving on.
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
    # log check cannot see. This book loads minted with breaklines, so an
    # over-wide line is broken to fit and no Overfull box is raised; the page
    # gains a wrap nobody chose. The Overfull box comes back only when the line
    # offers no break point at all, which real code never does.
    # Enabled       - the master switch.
    # MaxLineLength - the column budget. 0 means no budget has been declared and
    #                 the check does not run, which is the library default.
    #
    # A block whose \begin line carries its own [option list] is not measured.
    # Naming a fontsize, or an explicit breaklines, for one block is a
    # typographic decision taken about that block, and whoever took it owns the
    # width. Chapter 01's three listings use that hatch: they are set at
    # \footnotesize, where the same measure holds 81 columns.
    #
    # A starred \newminted alias waives the same way with {braces}, because that
    # is the form minted declares it with. This book declares no aliases, so the
    # case cannot arise here; braces after an unstarred \begin{minted} hold the
    # language and waive nothing.
    #
    # What the count is not: display columns. It counts UTF-16 code units, so a
    # CJK glyph counts one and sets two. A tab counts one. autogobble strips a
    # block's common indent before typesetting, so an indented block is measured
    # wider than it sets. This book's listings start at column zero.
    #
    # AliasAsLexer - the family's other check. A book that writes
    #                \newminted[NAME]{lexer} can then write \begin{minted}{NAME}
    #                by mistake, which sends NAME to Pygments and kills the run
    #                with `Pygments lexer "NAME" is unknown`. This book declares
    #                no aliases, so the check has nothing to compare against and
    #                costs nothing; it is left on rather than switched off,
    #                because the day this book declares one is the day it wants
    #                the check.
    # Schema, kept for reference now that MaxLineLength is live below:
    # Listings = @{
    #     Enabled       = $true
    #     MaxLineLength = 0
    #     AliasAsLexer  = $true
    # }
    #
    # THIS BOOK: 73 columns, measured rather than assumed. \the\textwidth is
    # 441.01773pt under the geometry in preamble/packages.tex, and one character
    # of texgyrecursor at \small in an 11pt class advances exactly 6.0pt, so 73
    # columns fill 438.0pt and 74 need 444.0pt. Confirmed on a built page: a
    # line of 73 columns carrying a break point sets flush to the margin, and
    # the same line at 74 gains a continuation arrow.
    #
    # The chapter that made this a rule shipped three tables at 82 to 101
    # columns and two code listings at 80 and 81, all of them wrapping, none of
    # them visible to the gate. Recalculate this number if the geometry, the
    # mono font or \setminted's fontsize ever changes.
    Listings = @{
        MaxLineLength = 73
    }

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
    # Decision 16's cadence, which four consecutive chapter audits caught a
    # drafting session breaking. One rule with no direction in it: a term this
    # chapter owns is glossed once per section, a term another chapter owns is
    # glossed once per chapter. Ownership is which block of appendix B the term
    # sits in.
    # Enabled      - the master switch. Emptying Glossary is the other way off.
    # Glossary     - the appendix, relative to the book root. It is the source
    #                of truth for what is translated, per decision 16.
    # Macro        - the gloss macro from decision 21. \tn{vi}{en}.
    # BlockPattern - the heading that opens a chapter's block; capture group 1
    #                is that chapter's number. Vietnamese, so it cannot be a
    #                library default.
    # KeepPattern  - the heading that opens the keep-in-English block. Only
    #                sharpens a message: a gloss on a keep-in-English term sets
    #                "bias (bias)", which is a different mistake from glossing a
    #                term nobody put in the appendix.
    # Exempt       - terms that are also ordinary Vietnamese, where a gloss
    #                helps nobody. Keep it short: an exception list carrying
    #                most of a check's signal is a list, not a check.
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
    # THIS BOOK: on, against appendix B, which decision 16 already makes the
    # source of truth for what is translated.
    #
    # Exempt was measured before it was set. Of the borrowed-term findings on
    # the five drafted chapters, exactly one term is a word a Vietnamese reader
    # needs no help with: "chuoi", sequence. The rest are technical and are
    # glossed. An earlier plan for this family proposed shipping the whole
    # borrowed half switched off on the grounds that thirteen of twenty
    # findings were ordinary words; reading the list is what showed that was
    # one, not thirteen.
    Gloss = @{
        Enabled      = $true
        Glossary     = 'backmatter/appendix-b-thuat-ngu.tex'
        Macro        = 'tn'
        BlockPattern = '\\textbf\{Chương\s+(\d+)\}'
        KeepPattern  = '\\textbf\{Giữ nguyên'
        Exempt       = @('chuỗi')
    }

    # -- 15. Figures ----------------------------------------------------------
    # TikZ style names pgfkeys has already taken. `step/.style={...}` shadows
    # nothing: it fails the build with an error naming the key rather than the
    # style, which reads as a missing \usetikzlibrary and sends you looking in
    # the preamble.
    # Enabled      - the master switch, and it takes both checks below.
    # NodeText     - `--` inside node or label text, which sets an en dash. TikZ
    #                draws a segment with `--` and that is why these files are
    #                outside the prose dash check; the text inside a node is
    #                prose all the same, and nothing else reads it. Only braced
    #                groups after a node or label are read, so path syntax stays
    #                silent.
    # Paths        - which folders hold picture sources, relative to the book
    #                root. They sit outside Paths.Prose on purpose, so this is
    #                the only check that reads them, and -Chapter does not
    #                narrow them.
    # ReservedKeys - the names to reject. Emptying the list is the other way to
    #                switch the key check off, so a book that disagrees with one
    #                name does not have to disable the family to say so, and it
    #                leaves NodeText running.
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
