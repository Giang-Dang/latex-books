@{
    # This book's half of the prose gate. scripts/check-chapter.ps1 supplies the
    # checks and the defaults; everything below is where this book differs, and
    # only that. Anything absent here is the library default, and the resolved
    # policy is printed at the top of every run.
    #
    # The reasons live in SPEC.md's "Writing rules (book-specific)" section.
    # Keep the two in step: a setting here without a rule there is a rule
    # nobody agreed to, and a rule there without a setting here is a rule
    # nothing enforces.

    # Every listing in this book is captured console output, SDL or C#, and all
    # of it is ASCII. A stray Unicode character in a listing is a paste that
    # went through something, which is exactly the class of defect the verbatim
    # check exists for, so this book wants the strictest setting rather than
    # the punctuation-only default.
    Characters = @{
        Mode = 'Ascii'

        # The exception the rule above did not anticipate: tooling writes
        # prose. Chapter 9 prints a composition error whose own text contains
        # an em dash, and the three options without this setting were to edit
        # the capture, drop the evidence, or weaken Ascii mode for the whole
        # book. This is the narrowest of the four.
        #
        # It applies only inside `minted:text`, which is where this book puts
        # console output, and only to a line that appears in a research note.
        # Prose is not in a listing and an invented listing traces to nothing,
        # so neither can reach it. A control character is never forgiven.
        AllowInCapturedListings = @('minted:text')
    }

    # No contractions in the author's own voice; they appear only inside quoted
    # material, which the check already exempts because \enquote{} spans are
    # masked before it runs. Off by default across the library, because whether
    # contractions belong in a voice is a decision most books have not made and
    # this one has.
    Contractions = @{
        Enabled = $true
    }

    Spelling = @{
        Preset = 'en-GB'

        # Four words the en-GB preset flags that are not mistakes here. Each
        # one is a name or a title rather than a spelling choice, and the whole
        # point of an exemption is that it is narrower than turning the check
        # off. Matched whole against the offending word, case-insensitively.
        Exempt = @(
            'catalogs?'                             # Catalog is a Mosaic domain service
            'analyz\w*'                             # HotChocolate ships Types.Analyzers
            'authoriz\w*'                           # chapter 15's title, and the OAuth term of art
            'modell?ing'                            # chapter 13's title
        )
    }
}
