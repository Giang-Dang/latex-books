@{
    # Everything off except the character scan, so this fixture reports
    # character findings and nothing else. It is also the only committed psd1
    # in the test tree, which makes it the proof that a book's file is read at
    # all rather than quietly ignored.
    Characters   = @{ Mode = 'Punctuation' }

    Citations    = @{ Enabled = $false }
    Quotes       = @{ Enabled = $false }
    Index        = @{ Enabled = $false }
    Dashes       = @{ Enabled = $false }
    Contractions = @{ Enabled = $false }
    Spelling     = @{ Enabled = $false }
    Numbers      = @{ Enabled = $false }
    Verbatim     = @{ Enabled = $false }
    Log          = @{ Enabled = $false }
}
