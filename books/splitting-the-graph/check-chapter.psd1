@{
    # This book's half of the prose gate. scripts/check-chapter.ps1 supplies the
    # checks and the defaults; everything below is where this book differs, and
    # only that. Anything absent here is the library default, and the resolved
    # policy is printed at the top of every run.
    #
    # The reasons live in SPEC.md's "Writing rules (book-specific)" section and
    # its decision log. Keep the two in step: a setting here without a rule
    # there is a rule nobody agreed to, and a rule there without a setting here
    # is a rule nothing enforces.

    # Every listing in this book is C#, SDL, executable GraphQL or captured
    # console output, and all of it is ASCII. A stray Unicode character in a
    # listing is a paste that went through something, which is exactly the
    # class of defect the verbatim check exists for, so this book wants the
    # strictest setting rather than the punctuation-only default. SPEC
    # decision 30.
    Characters = @{
        Mode = 'Ascii'

        # The exception the rule above cannot avoid: tooling writes prose.
        # Composition errors and router output carry punctuation that is not
        # ours to edit, and the three options without this setting are to edit
        # the capture, drop the evidence, or weaken Ascii mode for the whole
        # book. This is the narrowest of the four.
        #
        # It applies only inside `minted:text`, which is where this book puts
        # console output. Prose is not in a listing, so it cannot reach prose.
        # A control character is never forgiven.
        AllowInCapturedListings = @('minted:text')
    }

    # The printed index is the reader's vocabulary. This book refers to its own
    # decision log by number constantly - in prose comments, in commit
    # messages, and in the research notes - and a chapter 9 draft indexed
    # `decision 43`, which would have printed a term no reader has seen and
    # cannot look up. SPEC.md is internal and never ships. The pattern carries
    # a word boundary so that an entry about how the book records a decision,
    # which is a legitimate reader-facing subject, stays silent.
    # SPEC decision 93.
    Index = @{
        ForbidPattern = '\\index\{decision\b'
    }

    # No contractions in the author's own voice; they appear only inside quoted
    # material, which the check already exempts because \enquote{} spans are
    # masked before it runs. Off by default across the library, because whether
    # contractions belong in a voice is a decision most books have not made and
    # this one has. SPEC decision 26.
    Contractions = @{
        Enabled = $true
    }

    # SPEC decision 50. Measured in this book on 2026-08-19 rather than copied
    # from another: lines of 70 to 76 columns, each ending in a run with no
    # break point, set in a chapter file at this book's own geometry and
    # \setminted settings and read off the page. 73 fits; 74 gains a
    # continuation arrow, and the build log says nothing either way, which is
    # the whole reason this family exists.
    #
    # Every C# file the book prints is written to 73. Two kinds of block cannot
    # be and declare their own fontsize instead, which is how they tell the
    # check to stand down: the project file, whose package identifiers are not
    # ours to shorten, and the exported schema, whose directive descriptions
    # are the vendor's own prose. Captured compiler output adds breakanywhere
    # as well, because a fully qualified .NET type name offers no break point
    # anywhere and breaklines cannot help it.
    #
    # Re-measure if the geometry or the mono font changes. Do not carry this
    # number to another book; two books that happen to agree on it agree by
    # coincidence.
    Listings = @{
        MaxLineLength = 73
    }

    Spelling = @{
        Preset = 'en-US'

        # The second table, on. The preset's own list covers the differences
        # that follow a rule; this covers the ones that do not, and chapter 9
        # is why it is on: a draft carried `programme` and three of `judgement`
        # through a clean run of the base table and a cold reader found all
        # four. SPEC decision 92.
        Variants = $true

        # Deliberately empty. SPEC decision 29: the exemptions this book will
        # need are British spellings appearing inside captured tool output or a
        # vendor's own prose, and each one is added here only when the gate
        # finds a real case. An exemption is never added to accommodate a
        # habit of mine.
        Exempt = @()
    }
}
