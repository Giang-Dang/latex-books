#!/usr/bin/env pwsh
# Deterministic lint gate for one book's prose: the machine half of the
# draft-chapter build gate. Checks characters, citation ties and keys, quoting,
# index termination, contractions, spellings, dashes, measured-number
# provenance, verbatim-capture claims, listing width, glossary cadence, and the
# build log.
#
# The checks are general; the policy is the book's. Everything a book can
# decide - which spelling variety, whether contractions are allowed, which
# characters are legal, which listing environments hold captures - lives in
# books/<name>/check-chapter.psd1. A book without one gets the defaults below,
# and the resolved policy is printed on every run so a weakened gate is visible
# rather than silent.
#
# Usage: pwsh scripts/check-chapter.ps1 books/<name> [-Chapter NN]
# Tests: pwsh scripts/check-chapter.tests.ps1

param(
    [Parameter(Mandatory = $true)]
    [string]$Book,

    [string]$Chapter
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

if ($Chapter -and $Chapter -notmatch '^[0-9]{2}$') {
    Write-Error "Chapter must be a two-digit prefix like 03: got '$Chapter'"
}

$bookPath = if ([System.IO.Path]::IsPathRooted($Book)) { $Book } else { Join-Path $root $Book }
$bookPath = [System.IO.Path]::GetFullPath($bookPath)
if (-not (Test-Path (Join-Path $bookPath 'main.tex'))) {
    Write-Error "Not a book folder (no main.tex): got '$Book'"
}

# ---------------------------------------------------------------------------
# Policy
# ---------------------------------------------------------------------------

# The defaults, and the schema a book's file is validated against. Anything not
# named here cannot be set by a book, which is what makes a typo an error
# instead of a silently disabled check.
function Get-DefaultPolicy {
    [ordered]@{
        # Which trees are read. Characters is separate from Prose because a
        # book may want refs.bib character-scanned - it is the file most likely
        # to receive a Unicode dash pasted out of a web page - without wanting
        # its BibTeX linted as English.
        Paths        = [ordered]@{
            Prose      = @('chapters', 'frontmatter', 'backmatter')
            Characters = @('chapters', 'frontmatter', 'backmatter')
        }

        # Punctuation - letters of any script are fine; control characters and
        #               Unicode look-alikes of ASCII punctuation are not. This
        #               is what the repo rule actually bans, and it is the only
        #               setting under which a book in a language with diacritics
        #               can exist at all.
        # Ascii       - stricter, and an opt-in: no byte outside printable
        #               ASCII, tab, LF or CR.
        # Off         - no character scan.
        #
        # AllowInCapturedListings names listing environments, in the same
        # 'name' or 'name:lexer' form the Verbatim family uses, inside which a
        # character this mode would otherwise reject is allowed to stand. It
        # exists because tooling writes prose: a compiler, a composer or a
        # linter can emit a message containing an em dash, and a book that
        # prints what a tool said has three bad options otherwise - edit the
        # capture, weaken the mode for every file, or drop the evidence.
        #
        # Both halves are required and the second is the point. The character
        # has to be inside one of the named environments, AND the line it sits
        # on has to appear in a research note, by the same test the verbatim
        # family uses for whether a listing was captured. Prose is not in a
        # listing, and a listing somebody typed traces to nothing, so neither
        # can reach this. A book with no research notes cannot use it at all.
        Characters   = [ordered]@{
            Mode                    = 'Punctuation'
            Extra                   = @()
            Allow                   = @()
            AllowInCapturedListings = @()
        }

        Citations    = [ordered]@{
            Enabled    = $true
            Macros     = @('autocite')
            RequireTie = $true
            CheckKeys  = $true
            BibFile    = 'refs.bib'
        }

        Quotes       = [ordered]@{ Enabled = $true }
        Index        = [ordered]@{ Enabled = $true; RangeMarkers = $true }
        Dashes       = [ordered]@{ Enabled = $true }

        # Off by default: whether contractions belong in the author's voice is
        # a voice decision, and most books have not made it.
        Contractions = [ordered]@{
            Enabled = $false
            Preset  = 'english'
            Allow   = @()
        }

        # Preset is a name, not a boolean: turning this on for a new book
        # should be one word, not fourteen hand-written regexes. '' means no
        # variety chosen and the check does not run.
        Spelling     = [ordered]@{
            Enabled = $true
            Preset  = ''
            Exempt  = @()
            Extra   = @{}
        }

        Numbers      = [ordered]@{
            Enabled      = $true
            ResearchDir  = 'research'
            ResearchGlob = '*.md'
            Allow        = @()
        }

        # Environments: a bare name matches \begin{name}; a lexer-qualified
        # name like minted:text matches \begin{minted}[opts]{text}.
        Verbatim     = [ordered]@{
            Enabled       = $true
            Environments  = @('minted:text', 'minted:json')
            ClaimPattern  = '(?i)(?:\bverbatim\b|\bunmodified\b|\buntouched\b|character for character|(?:have|has|had)\s+not\s+(?:been\s+)?(?:trimmed|edited|altered)|\bnot\s+(?:been\s+)?trimmed\b|\bin full\b|exactly as)'
            Window        = 6
            MinLineLength = 12
        }

        # A listing line wider than the measure is the one typographic defect
        # the log family cannot see: a book that loads minted with breaklines
        # has told it to break an over-wide line to fit, so no Overfull box is
        # raised and the page silently gains a wrap nobody chose.
        #
        # MaxLineLength is a column count, and 0 means no budget declared and
        # the check does not run - the same shape as Spelling.Preset = ''. The
        # number falls out of the book's measure, its mono font and the size its
        # listings are set at, so the library will not guess it.
        #
        # A block whose \begin line carries its own [option list] is not
        # measured: naming fontsize or breaklines for one block is a deliberate
        # decision about that block, and whoever made it owns its width.
        Listings     = [ordered]@{
            Enabled       = $true
            MaxLineLength = 0
        }

        # The masking macros. These default to the template's own \code and
        # csquotes' \enquote, so they are library facts rather than book facts;
        # they are settable only so a book that renames them keeps masking.
        Macros       = [ordered]@{
            Code        = @('code')
            Quoted      = @('enquote')
            Identifiers = @('begin', 'end', 'label', 'ref', 'pageref', 'input', 'include', 'autocite')
        }

        # A book that translates its vocabulary and prints the original
        # alongside has a cadence for how often that repeats, and the cadence is
        # the kind of rule that does not survive being carried in a human head
        # while prose is being written. One book's audits caught the same class
        # of miss in four consecutive chapters.
        #
        # Off until a book names its glossary, because everything the check
        # needs to read one is a book fact: where the file is, what heading
        # opens a chapter's block inside it, what heading opens the
        # keep-in-the-original block, and which macro writes a gloss. Those
        # headings are written in the book's own language, so they cannot be
        # library defaults - the same shape as Spelling.Preset = '' and
        # Listings.MaxLineLength = 0.
        #
        # BlockPattern's first capture group is the owning chapter's number.
        # Exempt names terms that are also ordinary words in the language the
        # book is written in, where the cadence would set a parenthesis after a
        # word nobody needs translated. It is a list rather than a switch so
        # that using it costs a line naming the term.
        Gloss        = [ordered]@{
            Enabled      = $true
            Glossary     = ''
            Macro        = 'tn'
            BlockPattern = ''
            KeepPattern  = ''
            Exempt       = @()
        }

        # TikZ style names that pgfkeys has already taken. house-style.md has
        # listed these in prose since the first book; nothing enforced it, and
        # the cost of that is one full compile that dies with a pgfkeys error
        # naming the key rather than the style, which reads as a missing
        # library and is not. The list is exactly the documented one: a check
        # wider than its rule is a rule nobody agreed to.
        #
        # Figures are outside Paths.Prose on purpose, so this is the only
        # family that reads them.
        Figures      = [ordered]@{
            Enabled      = $true
            Paths        = @('figures/tikz')
            ReservedKeys = @('in', 'out', 'step', 'shift', 'scale', 'text', 'style')
        }

        Log          = [ordered]@{
            Enabled      = $true
            Path         = 'build/main.log'
            MaxOverfull  = 0
            MaxUndefined = 0
        }
    }
}

# Free-form maps: validated as leaves rather than recursed into, because their
# keys are the author's data, not settings.
$OpenMaps = @('Spelling.Extra')

# Hashtables merge key by key. Arrays and scalars replace wholesale: there is
# no other way for a book to remove an element the default supplies.
function Merge-Policy {
    param(
        [System.Collections.IDictionary]$Default,
        [System.Collections.IDictionary]$Override,
        [string]$Path = ''
    )

    $result = [ordered]@{}
    foreach ($key in $Default.Keys) {
        $where = if ($Path) { "$Path.$key" } else { "$key" }
        $d = $Default[$key]

        if ($Override -and $Override.Contains($key)) {
            $o = $Override[$key]
            if ($d -is [System.Collections.IDictionary] -and $OpenMaps -notcontains $where) {
                $result[$key] = Merge-Policy $d $o $where
            } else {
                $result[$key] = $o
            }
        } else {
            $result[$key] = $d
        }
    }
    return $result
}

# A typo like Spellings instead of Spelling must fail loudly. A silently
# disabled check is worse than no check at all, because the run still prints
# clean and nobody looks again.
function Test-PolicySchema {
    param(
        [System.Collections.IDictionary]$Config,
        [System.Collections.IDictionary]$Default,
        [string]$Path = ''
    )

    foreach ($key in $Config.Keys) {
        $where = if ($Path) { "$Path.$key" } else { "$key" }

        if (-not $Default.Contains($key)) {
            $known = ($Default.Keys | Sort-Object) -join ', '
            Write-Error "check-chapter.psd1: unknown setting '$where'. Known here: $known"
        }

        $d = $Default[$key]
        $c = $Config[$key]

        if ($d -is [System.Collections.IDictionary] -and $OpenMaps -notcontains $where) {
            if ($c -isnot [System.Collections.IDictionary]) {
                Write-Error "check-chapter.psd1: '$where' must be a table, e.g. @{ Enabled = `$false }"
            }
            Test-PolicySchema $c $d $where
        } elseif ($d -is [array]) {
            if ($c -isnot [array]) {
                Write-Error "check-chapter.psd1: '$where' must be an array, e.g. @('one', 'two')"
            }
        } elseif ($d -is [bool]) {
            if ($c -isnot [bool]) {
                Write-Error "check-chapter.psd1: '$where' must be `$true or `$false"
            }
        } elseif ($d -is [int]) {
            # Without this arm a string passed the schema and then threw
            # somewhere in the middle of a run, on a comparison, naming a
            # variable rather than the setting. It covers every count the
            # library takes: the two Verbatim windows, the two Log ceilings and
            # the Listings budget.
            if ($c -isnot [int]) {
                Write-Error "check-chapter.psd1: '$where' must be a whole number, e.g. 12"
            }
        }
    }
}

$policyPath = Join-Path $bookPath 'check-chapter.psd1'
$policyNotice = ''
$defaultPolicy = Get-DefaultPolicy

if (Test-Path -LiteralPath $policyPath) {
    try {
        $bookPolicy = Import-PowerShellDataFile -LiteralPath $policyPath
    } catch {
        Write-Error "check-chapter.psd1 could not be read: $($_.Exception.Message)"
    }
    Test-PolicySchema $bookPolicy $defaultPolicy
    $policy = Merge-Policy $defaultPolicy $bookPolicy
} else {
    $policy = $defaultPolicy
    $policyNotice = 'no check-chapter.psd1; using library defaults'
}

# ---------------------------------------------------------------------------
# Language data
# ---------------------------------------------------------------------------

# Contractions are a voice rule, not a language fact, so the list is data here
# and inert unless a book switches the check on.
function Get-ContractionList {
    param([string]$Preset)

    switch ($Preset) {
        'english' {
            return @(
                "aren't", "can't", "couldn't", "didn't", "doesn't", "don't", "hadn't",
                "hasn't", "haven't", "here's", "i'd", "i'll", "i'm", "i've", "isn't",
                "it's", "let's", "mustn't", "needn't", "shouldn't", "that's", "there's",
                "they're", "they've", "wasn't", "we'll", "we're", "we've", "weren't",
                "what's", "who's", "won't", "wouldn't", "you'll", "you're", "you've"
            )
        }
        default {
            Write-Error "check-chapter.psd1: Contractions.Preset '$Preset' is not one of: english"
        }
    }
}

# Ordered on purpose: findings come out in table order, so a reordering here
# would move output around for no reason. Import-PowerShellDataFile returns
# unordered hashtables, which is why Spelling.Extra is sorted at merge time.
function Get-SpellingTable {
    param([string]$Preset)

    switch ($Preset) {
        'en-GB' {
            return [ordered]@{
                'behaviors?'                        = 'behaviour(s)'
                'behavioral'                        = 'behavioural'
                'colors?'                           = 'colour(s)'
                'colored'                           = 'coloured'
                'centers?'                          = 'centre(s)'
                'centered'                          = 'centred'
                'initialization'                    = 'initialisation'
                'initializ(?:e|es|ed|ing)'          = 'initialise'
                'organizations?'                    = 'organisation(s)'
                'organiz(?:e|es|ed|ing)'            = 'organise'
                'labeled'                           = 'labelled'
                'labeling'                          = 'labelling'
                'favorites?'                        = 'favourite(s)'
                'gray'                              = 'grey'
                'catalogs?'                         = 'catalogue(s)'
                'analyz(?:e|es|ed|ing|er|ers)'      = 'analyse'
                'authoriz(?:e|es|ed|ing|ation|ations)' = 'authorise'
                'modeling'                          = 'modelling'
            }
        }
        'en-US' {
            return [ordered]@{
                'behaviours?'                          = 'behavior(s)'
                'behavioural'                          = 'behavioral'
                'colours?'                             = 'color(s)'
                'coloured'                             = 'colored'
                'centres?'                             = 'center(s)'
                'centred'                              = 'centered'
                'initialisation'                       = 'initialization'
                'initialis(?:e|es|ed|ing)'             = 'initialize'
                'organisations?'                       = 'organization(s)'
                'organis(?:e|es|ed|ing)'               = 'organize'
                'labelled'                             = 'labeled'
                'labelling'                            = 'labeling'
                'favourites?'                          = 'favorite(s)'
                'grey'                                 = 'gray'
                'catalogues?'                          = 'catalog(s)'
                'analys(?:e|es|ed|ing|er|ers)'         = 'analyze'
                'authoris(?:e|es|ed|ing|ation|ations)' = 'authorize'
                'modelling'                            = 'modeling'
            }
        }
        default {
            Write-Error "check-chapter.psd1: Spelling.Preset '$Preset' is not one of: en-GB, en-US"
        }
    }
}

# Unicode characters that look like ASCII punctuation and are not. Letters of
# any script are deliberately absent: this list is about punctuation, which is
# what the repo rule actually bans.
function Get-LookAlikeCodePoints {
    return @(
        0x2010, 0x2011, 0x2012, 0x2013, 0x2014, 0x2015,   # hyphens and dashes
        0x2212,                                           # minus sign
        0x2018, 0x2019, 0x201A, 0x201B,                   # single curly quotes
        0x201C, 0x201D, 0x201E, 0x201F,                   # double curly quotes
        0x2032, 0x2033,                                   # primes
        0x2026,                                           # ellipsis
        0x00A0, 0x202F, 0x2007, 0x2009, 0x200A,           # non-breaking and thin spaces
        0x200B, 0x200C, 0x200D, 0xFEFF,                   # zero-width and BOM
        0x00AD,                                           # soft hyphen
        0x2022,                                           # bullet
        0x00AB, 0x00BB, 0x2039, 0x203A                    # guillemets
    )
}

$CodePointNames = @{
    0x2010 = 'hyphen'; 0x2011 = 'non-breaking hyphen'; 0x2012 = 'figure dash'
    0x2013 = 'en dash'; 0x2014 = 'em dash'; 0x2015 = 'horizontal bar'
    0x2212 = 'minus sign'
    0x2018 = 'left single quote'; 0x2019 = 'right single quote'
    0x201C = 'left double quote'; 0x201D = 'right double quote'
    0x2026 = 'ellipsis'; 0x00A0 = 'no-break space'; 0x202F = 'narrow no-break space'
    0x200B = 'zero-width space'; 0xFEFF = 'byte order mark'; 0x00AD = 'soft hyphen'
    0x2022 = 'bullet'
}

function ConvertTo-CodePoint {
    param([string]$Value, [string]$Setting)

    if ($Value -match '^(?:U\+|0x)([0-9A-Fa-f]{2,6})$') {
        return [Convert]::ToInt32($Matches[1], 16)
    }
    Write-Error "check-chapter.psd1: $Setting entry '$Value' is not a code point; write it as U+2014"
}

# ---------------------------------------------------------------------------
# Resolved policy
# ---------------------------------------------------------------------------

$charMode = $policy.Characters.Mode
if ($charMode -notin @('Ascii', 'Punctuation', 'Off')) {
    Write-Error "check-chapter.psd1: Characters.Mode '$charMode' is not one of: Ascii, Punctuation, Off"
}

$bannedCodePoints = [System.Collections.Generic.HashSet[int]]::new()
if ($charMode -eq 'Punctuation') {
    foreach ($cp in Get-LookAlikeCodePoints) { [void]$bannedCodePoints.Add($cp) }
    foreach ($v in $policy.Characters.Extra) {
        [void]$bannedCodePoints.Add((ConvertTo-CodePoint $v 'Characters.Extra'))
    }
    foreach ($v in $policy.Characters.Allow) {
        [void]$bannedCodePoints.Remove((ConvertTo-CodePoint $v 'Characters.Allow'))
    }
}

$contractionRe = $null
if ($policy.Contractions.Enabled) {
    $list = @(Get-ContractionList $policy.Contractions.Preset |
        Where-Object { $policy.Contractions.Allow -notcontains $_ })
    if ($list.Count -gt 0) {
        $contractionRe = "(?i)\b(?:" + (($list | ForEach-Object { [regex]::Escape($_) }) -join '|') + ")\b"
    }
}

$spellings = [ordered]@{}
$spellingExemptRe = $null
if ($policy.Spelling.Enabled -and $policy.Spelling.Preset) {
    $spellings = Get-SpellingTable $policy.Spelling.Preset
    foreach ($k in ($policy.Spelling.Extra.Keys | Sort-Object)) {
        $spellings[$k] = $policy.Spelling.Extra[$k]
    }
    if ($policy.Spelling.Exempt.Count -gt 0) {
        $spellingExemptRe = '^(?:' + ($policy.Spelling.Exempt -join '|') + ')$'
    }
}

# One regex that says "this \begin line opens a listing a claim may arm".
$verbatimArmRe = $null
if ($policy.Verbatim.Enabled) {
    $armParts = @()
    foreach ($e in $policy.Verbatim.Environments) {
        if ($e -match '^([A-Za-z]+)[:]([A-Za-z0-9_+-]+)$') {
            $armParts += '\\begin\{' + [regex]::Escape($Matches[1]) + '\}(?:\[[^\]]*\])?\{' + [regex]::Escape($Matches[2]) + '\}'
        } elseif ($e -match '^[A-Za-z]+\*?$') {
            $armParts += '\\begin\{' + [regex]::Escape($e) + '\}'
        } else {
            Write-Error "check-chapter.psd1: Verbatim.Environments entry '$e' must be 'name' or 'name:lexer'"
        }
    }
    if ($armParts.Count -gt 0) {
        $verbatimArmRe = '(?:' + ($armParts -join '|') + ')'
    }
}

# The same thing for Characters.AllowInCapturedListings. Built separately
# rather than reusing the list above, because the two answer different
# questions: Verbatim.Environments is where a claim may be armed, and this is
# where a byte may survive. A book that wants them to be the same list says so
# twice, which is cheaper than discovering they were never separable.
$capturedArmRe = $null
if ($policy.Characters.AllowInCapturedListings.Count -gt 0) {
    $armParts = @()
    foreach ($e in $policy.Characters.AllowInCapturedListings) {
        if ($e -match '^([A-Za-z]+)[:]([A-Za-z0-9_+-]+)$') {
            $armParts += '\\begin\{' + [regex]::Escape($Matches[1]) + '\}(?:\[[^\]]*\])?\{' + [regex]::Escape($Matches[2]) + '\}'
        } elseif ($e -match '^[A-Za-z]+\*?$') {
            $armParts += '\\begin\{' + [regex]::Escape($e) + '\}'
        } else {
            Write-Error "check-chapter.psd1: Characters.AllowInCapturedListings entry '$e' must be 'name' or 'name:lexer'"
        }
    }
    if ($armParts.Count -gt 0) {
        $capturedArmRe = '(?:' + ($armParts -join '|') + ')'
    }
}

# 0 means no budget declared and no check. Resolved here rather than at the
# point of use, because Format-Policy has to report it long before the loop
# reaches a listing. Test-PolicySchema owns the type, so what is left here is
# the range: a whole number can still be a negative one, and the schema has no
# way to say that a count has a floor.
$listingMax = 0
if ($policy.Listings.Enabled) {
    $declared = $policy.Listings.MaxLineLength
    if ($declared -lt 0) {
        Write-Error "check-chapter.psd1: Listings.MaxLineLength must be 0 (no budget) or a positive column count; got $declared"
    }
    $listingMax = $declared
}

$citeMacroRe = ($policy.Citations.Macros | ForEach-Object { [regex]::Escape($_) }) -join '|'
$identifierRe = '\\(?:' + (($policy.Macros.Identifiers | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')(?:\[[^\]]*\])?\{[^}]*\}'

# ---------------------------------------------------------------------------
# Inputs
# ---------------------------------------------------------------------------

function Get-BookFiles {
    param([string[]]$Parts)

    $files = @()
    if ($Chapter) {
        $chapterDirs = @(Get-ChildItem (Join-Path $bookPath 'chapters') -Directory -Filter "$Chapter-*")
        if ($chapterDirs.Count -eq 0) {
            Write-Error "No folder matches chapters/$Chapter-* under '$Book'"
        }
        # -Recurse, to match the full path below. Without it a chapter that
        # keeps anything in a subfolder was linted by one mode and not the
        # other, which is the worst of the two: -Chapter is what a drafting
        # session runs while it iterates.
        return @($chapterDirs | Get-ChildItem -Recurse -Filter '*.tex' | Sort-Object FullName)
    }
    foreach ($part in $Parts) {
        $p = Join-Path $bookPath $part
        if (Test-Path $p) {
            $files += @(Get-ChildItem $p -Recurse -Filter '*.tex' | Sort-Object FullName)
        }
    }
    return $files
}

# Prose sources. figures/tikz/ is excluded (TikZ -- path syntax) and preamble/
# is excluded (macro code, not prose).
$texFiles = @(Get-BookFiles $policy.Paths.Prose)

$charFiles = if ($policy.Paths.Characters -join '|' -eq ($policy.Paths.Prose -join '|')) {
    $texFiles
} else {
    @(Get-BookFiles $policy.Paths.Characters)
}

# --- verbatim environments: the stock ones plus any the book declares with
# \newminted[NAME]{lexer}{opts} in its preamble.
#
# Every one of them has a starred twin, and they were missing here. That is not
# a listing going unmeasured, which would be the harmless version: an
# unrecognised environment is not blanked at all, so its body is read as English
# and reported for quotes, dashes, contractions and spelling, while its \end
# closes nothing.
#
# minted.sty declares the two aliases differently, and the difference decides
# the waiver below. \newenvironment{NAME} reads an optional [options];
# \newenvironment{NAME*} takes a mandatory {options}. So braces are an option
# list after a starred name and nothing else - after a bare \begin{minted} they
# hold the language.
$verbatimEnvs = @('minted', 'verbatim', 'verbatim*', 'Verbatim', 'Verbatim*')
$starredAliases = @()
$preambleDir = Join-Path $bookPath 'preamble'
if (Test-Path $preambleDir) {
    foreach ($f in Get-ChildItem $preambleDir -Filter '*.tex') {
        foreach ($m in [regex]::Matches((Get-Content $f.FullName -Raw), '\\newminted\[([A-Za-z]+)\]')) {
            $verbatimEnvs += $m.Groups[1].Value
            $verbatimEnvs += $m.Groups[1].Value + '*'
            $starredAliases += $m.Groups[1].Value + '*'
        }
    }
}

# --- research notes, as one blob. A book without research notes simply skips
# the number and verbatim checks rather than failing every number in it.
#
# Three families read it now, and the third is easy to forget: a book that
# turns Numbers and Verbatim off but sets Characters.AllowInCapturedListings
# still needs the notes, or its exemption silently never applies.
$researchText = ''
if ($policy.Numbers.Enabled -or $policy.Verbatim.Enabled -or
    $policy.Characters.AllowInCapturedListings.Count -gt 0) {
    $researchDir = Join-Path $bookPath $policy.Numbers.ResearchDir
    if (Test-Path $researchDir) {
        # A README in the notes folder documents the folder; it is not a note.
        # Counting it would let a number "trace" to the very file explaining
        # what tracing means, and it would put a brand-new book on the far side
        # of the cliff the README describes before it has a single note.
        $researchFiles = @(Get-ChildItem $researchDir -Filter $policy.Numbers.ResearchGlob -File |
            Where-Object { $_.BaseName -ne 'README' })
        if ($researchFiles.Count -gt 0) {
            $researchText = ($researchFiles | ForEach-Object {
                    [System.IO.File]::ReadAllText($_.FullName)
                }) -join "`n"
        }
    }
}

# The same notes, whitespace-collapsed. The verbatim check matches a listing
# line against this rather than against lines, so that a capture re-wrapped for
# the page still traces to the note it came from. Built once; rebuilding it per
# line would dominate the run.
$researchBlob = if ($researchText) { $researchText -replace '\s+', ' ' } else { '' }

# --- bibliography keys
$bibKeys = [System.Collections.Generic.HashSet[string]]::new()
if ($policy.Citations.Enabled -and $policy.Citations.CheckKeys) {
    $bibPath = Join-Path $bookPath $policy.Citations.BibFile
    if (Test-Path $bibPath) {
        foreach ($m in [regex]::Matches((Get-Content $bibPath -Raw), '(?m)^\s*@[A-Za-z]+\{([^,\s{}]+)\s*,')) {
            [void]$bibKeys.Add($m.Groups[1].Value)
        }
    }
}

$findings = [System.Collections.Generic.List[string]]::new()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Get-RelPath([string]$path) {
    $full = [System.IO.Path]::GetFullPath($path)
    if ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        $full = $full.Substring($root.Length).TrimStart('\', '/')
    }
    return $full -replace '\\', '/'
}

function Add-Finding([string]$file, [int]$line, [string]$check, [string]$message) {
    $where = Get-RelPath $file
    if ($line -gt 0) { $where = "${where}:${line}" }
    $findings.Add("${where}: [$check] $message")
    Write-Host "${where}: [$check] $message"
}

# Blank the contents of \NAME{...} spans in one line, carrying brace depth
# across lines via $depth so a span opened on one line keeps masking the next.
# Braces escaped with a backslash do not change the depth.
function Remove-MacroSpans([string]$line, [string]$name, [ref]$depth) {
    $sb = [System.Text.StringBuilder]::new()
    $token = '\' + $name + '{'
    $i = 0
    while ($i -lt $line.Length) {
        if ($depth.Value -gt 0) {
            $c = $line[$i]
            $escaped = ($i -gt 0 -and $line[$i - 1] -eq '\')
            if ($c -eq '{' -and -not $escaped) { $depth.Value++ }
            elseif ($c -eq '}' -and -not $escaped) { $depth.Value-- }
            $i++
            continue
        }
        $idx = $line.IndexOf($token, $i)
        if ($idx -lt 0) {
            [void]$sb.Append($line.Substring($i))
            break
        }
        [void]$sb.Append($line.Substring($i, $idx - $i))
        [void]$sb.Append(' ')
        $i = $idx + $token.Length
        $depth.Value = 1
    }
    return $sb.ToString()
}

# Apply a list of macros, each keeping its own brace depth across lines. The
# stage matters: the number check re-masks a different input string from the
# prose checks, so the two must not share a depth counter or a span left open
# at the end of one line would close in the wrong pass.
function Remove-MacroSpanList {
    param([string]$Line, [string[]]$Names, [hashtable]$State, [string]$Stage)

    $result = $Line
    foreach ($name in $Names) {
        $key = "$Stage/$name"
        $depth = if ($State.ContainsKey($key)) { $State[$key] } else { 0 }
        $result = Remove-MacroSpans $result $name ([ref]$depth)
        $State[$key] = $depth
    }
    return $result
}

# ---------------------------------------------------------------------------
# Gloss helpers
# ---------------------------------------------------------------------------

# Every \<Name> in $Text followed by $Count brace-balanced groups, with the
# offset and length of the whole call so a caller can blank it out in place.
#
# Brace counting rather than [^}]*, because the first argument of a gloss can
# hold a macro: \tn{\textbf{ma tran Jacobi}}{Jacobian matrix} is ordinary prose
# in at least one book, and a lazy pattern ends the term at the inner brace,
# fails to match it against the glossary, and then reports the same term as
# unglossed a line later. That was two false findings out of the first twelve.
function Get-BalancedCalls {
    param([string]$Text, [string]$Name, [int]$Count)

    $out = @()
    $needle = '\' + $Name
    $i = 0
    while ($true) {
        $start = $Text.IndexOf($needle, $i)
        if ($start -lt 0) { break }
        $after = $start + $needle.Length
        # \tnfoo is a different macro
        if ($after -lt $Text.Length -and [char]::IsLetter($Text[$after])) { $i = $after; continue }

        $p = $after
        $groups = @()
        $ok = $true
        for ($g = 0; $g -lt $Count; $g++) {
            while ($p -lt $Text.Length -and [char]::IsWhiteSpace($Text[$p])) { $p++ }
            if ($p -ge $Text.Length -or $Text[$p] -ne '{') { $ok = $false; break }
            $depth = 0
            $open = $p
            while ($p -lt $Text.Length) {
                if ($Text[$p] -eq '{') { $depth++ }
                elseif ($Text[$p] -eq '}') { $depth--; if ($depth -eq 0) { break } }
                $p++
            }
            if ($depth -ne 0) { $ok = $false; break }
            $groups += $Text.Substring($open + 1, $p - $open - 1)
            $p++
        }
        if ($ok) {
            $out += [pscustomobject]@{ Index = $start; Length = $p - $start; Args = $groups }
            $i = $p
        } else {
            $i = $after
        }
    }
    return , $out
}

# Blank a range to spaces rather than deleting it, so every offset after it
# still maps to the source line it came from.
function Clear-Span {
    param([string]$Text, [int]$Index, [int]$Length)
    if ($Index -lt 0 -or $Index -ge $Text.Length) { return $Text }
    $len = [Math]::Min($Length, $Text.Length - $Index)
    return $Text.Substring(0, $Index) + (' ' * $len) + $Text.Substring($Index + $len)
}

# Strip the markup a glossary cell or a gloss call may carry around the term,
# and keep the term. The macro name goes and its braces go, but what was inside
# them stays, because \textbf{ma tran Jacobi} is the term set in bold rather
# than a marker beside it. What is then left over from something like
# \textsuperscript{*} is punctuation, and punctuation is dropped: a term is
# letters, digits, spaces and hyphens.
function ConvertTo-GlossTerm {
    param([string]$Cell)
    $t = [regex]::Replace($Cell, '\\[A-Za-z]+\s*', ' ')
    $t = $t -replace '[{}]', ' '
    $t = $t -replace '[^\p{L}\p{Nd}\s-]', ' '
    return ([regex]::Replace($t, '\s+', ' ')).Trim()
}

# The book's glossary, as two lookups: term -> owning chapter number, and the
# set of terms it keeps in the source language.
#
# Nothing about the file's shape is a library fact. Which heading opens a
# chapter's block, and which opens the keep-as-is block, are regexes the book
# supplies, because those headings are written in the book's own language. What
# is assumed is booktabs: rows are read between \midrule and \bottomrule, which
# is what skips the header row without having to know what it says.
function Get-GlossaryTerms {
    param([string]$Path, [string]$BlockPattern, [string]$KeepPattern)

    $owner = @{}                                    # case-insensitive by default
    $keep = [System.Collections.Generic.HashSet[string]]::new(
        [StringComparer]::InvariantCultureIgnoreCase)

    $chapter = $null
    $isKeep = $false
    $inRows = $false

    foreach ($raw in [System.IO.File]::ReadAllLines($Path)) {
        $line = ($raw -replace '(?<!\\)%.*$', '').Trim()
        if (-not $line) { continue }

        if ($BlockPattern) {
            $m = [regex]::Match($line, $BlockPattern)
            if ($m.Success) { $chapter = [int]$m.Groups[1].Value; $isKeep = $false; continue }
        }
        if ($KeepPattern -and $line -match $KeepPattern) { $chapter = $null; $isKeep = $true; continue }

        if ($line -match '^\\midrule') { $inRows = $true; continue }
        if ($line -match '^\\(bottomrule|end\{tabular\})') { $inRows = $false; continue }
        if (-not $inRows) { continue }
        if ($line -notmatch '\\\\\s*$') { continue }

        $term = ConvertTo-GlossTerm (($line -split '&')[0])
        if (-not $term) { continue }
        if ($isKeep) { [void]$keep.Add($term) }
        elseif ($null -ne $chapter) { $owner[$term] = $chapter }
    }

    return [pscustomobject]@{ Owner = $owner; Keep = $keep }
}

# One file to a list of sections. A section is what the cadence counts, so the
# split is on \section and nothing else: a \subsection does not start a new one,
# but its heading is still a heading and a gloss never goes in one. Text before
# the first \section is its own unit, which is what makes a chapter opener and
# an exercises file behave.
#
# Each section carries its prose flattened to one line, because a term broken
# across two source lines hides from a line-at-a-time scan and real books break
# them. Offsets survive the flattening: spans that are not prose - the gloss
# calls themselves, inline code, index entries, verbatim bodies - are blanked to
# spaces rather than removed, so a match still maps back to its source line.
function ConvertTo-GlossSections {
    param([string[]]$Lines, [string]$Macro, [string[]]$CodeMacros, [string[]]$VerbatimEnvs)

    $sections = @()

    function New-Unit { param([int]$line) return [pscustomobject]@{
        Builder = [System.Text.StringBuilder]::new()
        Map     = [System.Collections.Generic.List[int]]::new()
        Line    = $line } }

    $unit = New-Unit 1
    $inVerb = $null

    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $lineNo = $i + 1
        $text = $Lines[$i]

        if ($inVerb) {
            if ($text -match ('\\end\{' + [regex]::Escape($inVerb) + '\}')) { $inVerb = $null }
            $text = ''
        } else {
            $text = $text -replace '(?<!\\)%.*$', ''
            $bm = [regex]::Match($text, '\\begin\{([A-Za-z]+\*?)\}')
            if ($bm.Success -and $VerbatimEnvs -contains $bm.Groups[1].Value) {
                if ($text -notmatch ('\\end\{' + [regex]::Escape($bm.Groups[1].Value) + '\}')) {
                    $inVerb = $bm.Groups[1].Value
                }
                $text = ''
            }
        }

        if ($text -match '\\section\*?\{') {
            if ($unit.Builder.Length -gt 0) { $sections += $unit }
            $unit = New-Unit $lineNo
        }
        # headings of every level come out; the cadence is about running prose
        $text = [regex]::Replace($text, '\\(?:(?:sub){0,2}section|chapter|caption|title)\*?\{[^{}]*\}', ' ')

        [void]$unit.Builder.Append($text).Append(' ')
        for ($k = 0; $k -le $text.Length; $k++) { $unit.Map.Add($lineNo) }
    }
    if ($unit.Builder.Length -gt 0) { $sections += $unit }

    $out = @()
    foreach ($u in $sections) {
        $body = $u.Builder.ToString()
        $glossed = @()
        foreach ($call in (Get-BalancedCalls $body $Macro 2)) {
            $glossed += [pscustomobject]@{
                Term = ConvertTo-GlossTerm $call.Args[0]
                Line = $u.Map[[Math]::Min($call.Index, $u.Map.Count - 1)]
            }
            $body = Clear-Span $body $call.Index $call.Length
        }
        # \index{...} carries the term verbatim and is not prose; inline code is
        # an identifier. Both blanked after the gloss calls are read, so a term
        # inside one of them cannot be mistaken for a bare use.
        foreach ($name in (@('index') + $CodeMacros)) {
            foreach ($call in (Get-BalancedCalls $body $name 1)) {
                $body = Clear-Span $body $call.Index $call.Length
            }
        }
        $out += [pscustomobject]@{ Body = $body; Glossed = $glossed; Map = $u.Map; Line = $u.Line }
    }
    return , $out
}

# Every line of a listing the prose called a capture has to appear in this
# book's research notes, matched against the whitespace-collapsed blob so that
# a capture re-wrapped to fit the measure still traces.
#
# A chapter once called a query plan the only listing it had not trimmed after
# reformatting the strings inside it, and printed a response whose trailing
# zero a JSON formatter had silently dropped on the way to the page. Neither is
# a lie about the system and both are lies about the listing, which is the same
# defect the number check exists for, one level up.
#
# Short and punctuation-only lines are skipped: a bare brace or a two-character
# fragment matches everything and proves nothing.
function Test-VerbatimClaim {
    param(
        [string]$file,
        [int]$listingLine,
        [int]$claimLine,
        [string]$phrase,
        [System.Collections.Generic.List[string]]$lines,
        [string]$blob,
        [int]$minLength
    )

    $missed = @()
    foreach ($line in $lines) {
        $n = ($line.Trim() -replace '\s+', ' ')
        if ($n.Length -lt $minLength) { continue }
        if ($n -notmatch '[A-Za-z0-9]') { continue }
        if (-not $blob.Contains($n)) { $missed += $n }
    }

    if ($missed.Count -eq 0) { return }

    $shown = $missed | Select-Object -First 2
    foreach ($m in $shown) {
        $snippet = if ($m.Length -gt 70) { $m.Substring(0, 70) + '...' } else { $m }
        Add-Finding $file $listingLine 'verbatim' "line~'$snippet' is in no research/ note, but line $claimLine calls this listing a capture ('$phrase')"
    }
    if ($missed.Count -gt $shown.Count) {
        Add-Finding $file $listingLine 'verbatim' "...and $($missed.Count - $shown.Count) more untraced line(s) in the same listing"
    }
}

# --- glossary. Read here rather than with the other inputs because parsing it
# needs the helpers above, and $null when the family is off for either of its
# two reasons: the book disabled it, or the book never named a glossary. The
# policy line reads that same variable, so a book whose path is wrong is told
# so instead of getting a silent pass.
$glossary = $null
if ($policy.Gloss.Enabled -and $policy.Gloss.Glossary) {
    $glossPath = Join-Path $bookPath $policy.Gloss.Glossary
    if (Test-Path $glossPath) {
        $glossary = Get-GlossaryTerms $glossPath $policy.Gloss.BlockPattern $policy.Gloss.KeepPattern
    } else {
        Write-Host "==> WARNING: $(Get-RelPath $glossPath) not found; gloss checks skipped."
    }
}

# ---------------------------------------------------------------------------
# Report the policy before using it
# ---------------------------------------------------------------------------

function Format-Policy {
    $bits = @()
    # The exemption is part of the mode, not a footnote to it. A run that
    # forgives bytes somewhere has to say where on the same line that says the
    # mode, or "chars=Ascii" reads as stricter than it is.
    $charBit = "chars=$charMode"
    if ($charMode -ne 'Off' -and $policy.Characters.AllowInCapturedListings.Count -gt 0) {
        $where = $policy.Characters.AllowInCapturedListings -join ','
        $charBit += if ($researchBlob) { "(captured:$where)" } else { "(captured:$where, no research notes so nothing traces)" }
    }
    $bits += $charBit

    if ($policy.Citations.Enabled) {
        $flags = @()
        if ($policy.Citations.RequireTie) { $flags += 'tie' }
        if ($policy.Citations.CheckKeys) { $flags += 'keys' }
        $suffix = if ($flags) { '(' + ($flags -join ',') + ')' } else { '' }
        $bits += "cite=$($policy.Citations.Macros -join ',')$suffix"
    } else { $bits += 'cite=off' }

    $bits += "quotes=$(if ($policy.Quotes.Enabled) { 'on' } else { 'off' })"
    $bits += "index=$(if ($policy.Index.Enabled) { 'on' } else { 'off' })"
    $bits += "dashes=$(if ($policy.Dashes.Enabled) { 'on' } else { 'off' })"
    $bits += "contractions=$(if ($contractionRe) { $policy.Contractions.Preset } else { 'off' })"

    if ($spellings.Count -gt 0) {
        $ex = $policy.Spelling.Exempt.Count
        $bits += "spelling=$($policy.Spelling.Preset)$(if ($ex) { "($ex exempt)" })"
    } else { $bits += 'spelling=off' }

    if ($policy.Numbers.Enabled) {
        $bits += "numbers=$($policy.Numbers.ResearchDir)/$($policy.Numbers.ResearchGlob)$(if (-not $researchText) { '(no notes)' })"
    } else { $bits += 'numbers=off' }

    $bits += "verbatim=$(if ($verbatimArmRe -and $researchBlob) { $policy.Verbatim.Environments -join ',' } else { 'off' })"

    # $listingMax is already 0 when the family is disabled, so one expression
    # covers both ways of switching it off.
    $bits += "listings=$(if ($listingMax -gt 0) { $listingMax } else { 'off' })"

    # $glossary is already $null when the family is off for either reason, so
    # one expression covers "Enabled = $false" and "no Glossary named".
    if ($glossary) {
        $ex = $policy.Gloss.Exempt.Count
        $bits += "gloss=$($glossary.Owner.Count) terms$(if ($ex) { "($ex exempt)" })"
    } else { $bits += 'gloss=off' }

    if ($policy.Figures.Enabled) {
        $bits += "figures=$($policy.Figures.ReservedKeys.Count) reserved keys"
    } else { $bits += 'figures=off' }

    $bits += "log=$(if ($policy.Log.Enabled) { "$($policy.Log.MaxOverfull)/$($policy.Log.MaxUndefined)" } else { 'off' })"

    return ($bits -join ' ')
}

Write-Host "==> Checking $(Get-RelPath $bookPath) ($($texFiles.Count) files)"
if ($policyNotice) { Write-Host "==> $policyNotice" }
Write-Host "==> policy: $(Format-Policy)"

# ---------------------------------------------------------------------------
# 1. characters
# ---------------------------------------------------------------------------

$latin1 = [System.Text.Encoding]::GetEncoding(28591)
$utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)

# The lines of one file on which Characters.AllowInCapturedListings applies:
# inside one of the environments the book named, and traceable to a research
# note. Empty unless the book asked for the setting and has notes to trace to,
# so the ordinary case costs one comparison and no reading.
function Get-CapturedLineNumbers {
    param([System.IO.FileInfo]$File)

    # Every return here is comma-wrapped: PowerShell unrolls a collection on
    # the way out, which turns an empty set into $null and a full one into an
    # int array, and both of those lose .Contains() at the call site.
    $forgiven = [System.Collections.Generic.HashSet[int]]::new()
    if (-not $capturedArmRe -or -not $researchBlob) { return , $forgiven }

    # Decoded as UTF-8, deliberately, even for Ascii mode, which scans bytes.
    # A line has to be compared with a research note as text, and the
    # characters this setting exists for are exactly the ones the two decodings
    # disagree about. A file that will not decode is forgiven nothing, which is
    # the right answer: Ascii mode is about to complain about every byte in it.
    try {
        $text = [System.IO.File]::ReadAllText($File.FullName, $utf8Strict)
    } catch {
        return , $forgiven
    }

    # The same floor the verbatim family uses, and for the same reason: a short
    # or punctuation-only line is contained in every document and proves
    # nothing. Without it, a line holding one em dash and nothing else would
    # trace to any note that happened to contain an em dash anywhere.
    $minLength = $policy.Verbatim.MinLineLength

    $inside = $false
    $lineNo = 0
    foreach ($line in ($text -split "`r?`n")) {
        $lineNo++
        if (-not $inside) {
            if ($line -match $capturedArmRe) { $inside = $true }
            continue
        }
        if ($line -match '\\end\{') { $inside = $false; continue }

        $normalised = ($line.Trim() -replace '\s+', ' ')
        if ($normalised.Length -lt $minLength) { continue }
        if ($normalised -notmatch '[A-Za-z0-9]') { continue }
        if ($researchBlob.Contains($normalised)) { [void]$forgiven.Add($lineNo) }
    }

    return , $forgiven
}

function Test-Characters {
    param([System.IO.FileInfo]$File)

    $forgiven = Get-CapturedLineNumbers $File

    if ($charMode -eq 'Ascii') {
        # Raw bytes, everywhere including verbatim. Latin-1 maps each byte to
        # one char, so match positions are byte positions.
        $rawText = [System.IO.File]::ReadAllText($File.FullName, $latin1)
        # Line numbers first, forgiveness second, reporting last. Filtering
        # after the cap would make the "...and N more" count the bytes this
        # book has already said it accepts.
        $bad = @([regex]::Matches($rawText, '[^\x09\x0A\x0D\x20-\x7E]') | ForEach-Object {
                [pscustomobject]@{
                    Line  = 1 + [regex]::Matches($rawText.Substring(0, $_.Index), "`n").Count
                    Value = $_.Value
                }
            } | Where-Object { -not $forgiven.Contains($_.Line) })

        $reported = 0
        foreach ($m in $bad) {
            if ($reported -ge 5) {
                Add-Finding $File.FullName 0 'ascii' "...and $($bad.Count - 5) more non-ASCII bytes"
                break
            }
            Add-Finding $File.FullName $m.Line 'ascii' ('byte 0x{0:X2} is not printable ASCII' -f [int][char]$m.Value)
            $reported++
        }
        return
    }

    if ($charMode -ne 'Punctuation') { return }

    # A throwing decoder, not a lenient one. Without it a mis-encoded file
    # decodes to U+FFFD and passes silently, which is worse than the byte-level
    # complaint Ascii mode would have made.
    try {
        $text = [System.IO.File]::ReadAllText($File.FullName, $utf8Strict)
    } catch {
        Add-Finding $File.FullName 0 'encoding' 'not valid UTF-8; re-save the file as UTF-8'
        return
    }

    $lineNo = 1
    $reported = 0
    $total = 0
    for ($j = 0; $j -lt $text.Length; $j++) {
        $ch = $text[$j]
        if ($ch -eq "`n") { $lineNo++; continue }
        if ($ch -eq "`t" -or $ch -eq "`r") { continue }

        $cp = [int]$ch
        $isControl = ($cp -lt 0x20) -or ($cp -ge 0x7F -and $cp -le 0x9F)
        if (-not ($isControl -or $bannedCodePoints.Contains($cp))) { continue }

        # A control character is never captured output. It is a mangled edit,
        # which is the one thing this family catches that nothing else would,
        # so the forgiveness does not extend to it.
        if (-not $isControl -and $forgiven.Contains($lineNo)) { continue }

        $total++
        if ($reported -ge 5) { continue }
        $name = if ($isControl) {
            'a control character'
        } elseif ($CodePointNames.ContainsKey($cp)) {
            "$($CodePointNames[$cp]), a Unicode look-alike of ASCII punctuation"
        } else {
            'a Unicode look-alike of ASCII punctuation'
        }
        Add-Finding $File.FullName $lineNo 'unicode' ('U+{0:X4} is {1}' -f $cp, $name)
        $reported++
    }
    if ($total -gt $reported) {
        Add-Finding $File.FullName 0 'unicode' "...and $($total - $reported) more"
    }
}

# Character-scanned files are usually the prose files, and then the scan runs
# as each file comes up so that everything about one file is reported together.
# A book that widens Paths.Characters gets the extra files in a pass of their
# own afterwards; they have no prose to interleave with.
$charSet = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]@($charFiles | ForEach-Object { $_.FullName }),
    [System.StringComparer]::OrdinalIgnoreCase)

# ---------------------------------------------------------------------------
# 2-11. prose, line by line
# ---------------------------------------------------------------------------

foreach ($f in $texFiles) {
    if ($charSet.Contains($f.FullName)) {
        Test-Characters $f
        [void]$charSet.Remove($f.FullName)
    }

    $rawLines = @(Get-Content $f.FullName)
    $inVerb = $null
    $maskState = @{}

    # listing-width state: whether the open block waived the check by carrying
    # its own option list, and how many wide lines this file has already shown.
    $listingWaived = $false
    $listingReported = 0
    $listingTotal = 0

    # verbatim-claim state: how many lines the pending claim has left, what it
    # said, and the block being collected once one starts.
    $claimWindow = 0
    $claimLine = 0
    $claimPhrase = ''
    $capture = $null
    $captureLine = 0

    for ($i = 0; $i -lt $rawLines.Count; $i++) {
        $raw = $rawLines[$i]
        $lineNo = $i + 1

        # stripped view: blank inside verbatim environments, drop % comments.
        # $verbLine records which branch we took, because the number check
        # below wants captured listings and the other checks do not.
        $verbLine = $false
        if ($inVerb) {
            # Matched on $raw, and that asymmetry with the \begin below is
            # deliberate: inside a verbatim block % is a literal character
            # rather than a comment, so stripping here would lose an \end that
            # happens to follow one.
            if ($raw -match ('\\end\{' + [regex]::Escape($inVerb) + '\}')) {
                $inVerb = $null
                if ($null -ne $capture) {
                    Test-VerbatimClaim $f.FullName $captureLine $claimLine $claimPhrase $capture $researchBlob $policy.Verbatim.MinLineLength
                    $capture = $null
                }
            } else {
                # 11. listing: a body line wider than this book's measure. Every
                # body line of every listing environment, not only the ones a
                # claim armed, because the defect is typographic and a listing
                # nobody called a capture wraps exactly as silently as one that
                # was. This branch is the only place that holds a body line and
                # nothing else: the \begin line has just set $inVerb and the
                # \end line has just cleared it, so neither is measured, which
                # is right because neither sets any columns.
                if ($listingMax -gt 0 -and -not $listingWaived) {
                    $columns = $raw.TrimEnd().Length
                    if ($columns -gt $listingMax) {
                        $listingTotal++
                        if ($listingReported -lt 3) {
                            Add-Finding $f.FullName $lineNo 'listing' "listing line is $columns columns against a budget of $listingMax; it will wrap or overflow the measure"
                            $listingReported++
                        }
                    }
                }
                if ($null -ne $capture) { [void]$capture.Add($raw) }
            }
            $stripped = ''
            $verbLine = $true
        } else {
            # Comments come off before the \begin is looked for. A commented-out
            # % \begin{minted} used to open a region that nothing ever closed,
            # and the rest of the file went silent for every prose check.
            $stripped = $raw -replace '(?<!\\)%.*$', ''

            $bm = [regex]::Match($stripped, '\\begin\{([A-Za-z]+\*?)\}')
            if ($bm.Success -and $verbatimEnvs -contains $bm.Groups[1].Value) {
                if ($stripped -notmatch ('\\end\{' + [regex]::Escape($bm.Groups[1].Value) + '\}')) {
                    $inVerb = $bm.Groups[1].Value

                    # A block that carries its own option list has had a
                    # typographic decision made about it - a smaller fontsize,
                    # an explicit breaklines - and whoever made it owns the
                    # block's width. The width check stands down for it.
                    #
                    # Brackets count everywhere. Braces count only after a
                    # starred \newminted alias, which is the one form that takes
                    # its options that way; counting them everywhere would waive
                    # every \begin{minted}{python} in the book and turn the
                    # whole family off without saying so.
                    $rest = $stripped.Substring($bm.Index + $bm.Length)
                    $listingWaived = $rest -match '^\s*\[' -or
                        ($starredAliases -contains $bm.Groups[1].Value -and $rest -match '^\s*\{')

                    # A claim arms the check only for the environments the book
                    # nominated as holding captured output. Listings that come
                    # out of a companion repo are checked by that repo, not
                    # here, and commands to type are not captures at all.
                    if ($claimWindow -gt 0 -and $verbatimArmRe -and $researchBlob -and $stripped -match $verbatimArmRe) {
                        $capture = [System.Collections.Generic.List[string]]::new()
                        $captureLine = $lineNo
                    }
                    $claimWindow = 0
                }
                $stripped = ''
                $verbLine = $true
            }
        }

        # noCode: stripped minus the inline-code macros; prose: noCode minus
        # the quoting macros.
        $noCode = Remove-MacroSpanList $stripped $policy.Macros.Code $maskState 'prose'
        $prose = Remove-MacroSpanList $noCode $policy.Macros.Quoted $maskState 'prose-quoted'

        # words: prose minus tokens that are identifiers, not English
        $words = $prose -replace $identifierRe, ' '

        # 2. tilde-cite
        if ($policy.Citations.Enabled -and $policy.Citations.RequireTie) {
            if ($stripped -match "(?<!~)\\(?:$citeMacroRe)\b") {
                Add-Finding $f.FullName $lineNo 'tilde-cite' "use a non-breaking tie: ~\autocite{...}"
            }
        }

        # 3. cite-key
        if ($policy.Citations.Enabled -and $policy.Citations.CheckKeys) {
            foreach ($cm in [regex]::Matches($stripped, "\\(?:$citeMacroRe)(?:\[[^\]]*\])?\{([^}]*)\}")) {
                foreach ($key in ($cm.Groups[1].Value -split ',')) {
                    $k = $key.Trim()
                    if ($k -and -not $bibKeys.Contains($k)) {
                        Add-Finding $f.FullName $lineNo 'cite-key' "citation key '$k' not found in $($policy.Citations.BibFile)"
                    }
                }
            }
        }

        # 4. quote: quoted content is NOT exempt (nested quotes nest the macro)
        if ($policy.Quotes.Enabled -and $noCode.Contains('"')) {
            Add-Finding $f.FullName $lineNo 'quote' 'literal double quote in prose; use \enquote{...}'
        }

        # 5. index-pct: raw line, range markers |( |) excepted by convention
        if ($policy.Index.Enabled -and $raw -match '\\index\{') {
            $ranged = $policy.Index.RangeMarkers -and $raw -match '\\index\{[^{}]*\|[()]\}\s*$'
            if (-not ($raw -match '%\s*$' -or $ranged)) {
                Add-Finding $f.FullName $lineNo 'index-pct' '\index{...} line must end with %'
            }
        }

        # 6. contraction
        if ($contractionRe) {
            foreach ($m in [regex]::Matches($words, $contractionRe)) {
                Add-Finding $f.FullName $lineNo 'contraction' "contraction '$($m.Value)' in the author's voice"
            }
        }

        # 7. spelling
        foreach ($pat in $spellings.Keys) {
            foreach ($m in [regex]::Matches($words, "(?i)\b(?:$pat)\b")) {
                if ($spellingExemptRe -and $m.Value -match $spellingExemptRe) { continue }
                Add-Finding $f.FullName $lineNo 'spelling' "'$($m.Value)' -> $($spellings[$pat])"
            }
        }

        # 8. dash: runs of exactly 2-3 hyphens read as en/em dashes in prose
        if ($policy.Dashes.Enabled -and $prose -match '(?<!-)---?(?!-)') {
            Add-Finding $f.FullName $lineNo 'dash' 'en/em dash ligature in prose; reword or use ASCII punctuation'
        }

        # 9. number: a decimal printed in the book must appear somewhere in
        # this book's research notes. A chapter once printed a request-timeline
        # line that had never been captured, and another asserted a latency, a
        # line count and an API attribute name the same way; the rule is that a
        # measured number is reproducible from the research file, and this is
        # that rule with teeth.
        #
        # Captured listings are checked and inline-code spans are not: a
        # timeline line inside a listing is exactly where a made-up number
        # hides, while an argument like `--cpus 0.25` is an instruction rather
        # than a measurement. Dotted versions are skipped by the lookaround.
        # Numbers written as words are not covered at all.
        #
        # The research side is matched from a digit boundary but left open at
        # the end, so prose may round: 9.2 is accepted against a recorded 9.22.
        # The cost of allowing that is a number which merely prefixes a real one
        # slips through. Catching invented numbers is worth more than catching
        # rounded ones, and demanding exact equality would flag every rounded
        # figure in a book and get this check deleted within a week.
        #
        # KNOWN HOLE, with a worked example, left open deliberately. This asks
        # whether a decimal appears *somewhere* under the notes folder, never
        # whether it appears in the note it came from, so the check gets weaker
        # every time a book grows a note. A chapter printing a difference of two
        # cited BLEU figures, 8.37, passed against an unrelated chapter's
        # recorded loss of 8.3705. The obvious fix is to scope each chapter's
        # numbers to its own note, and it is wrong: a chapter legitimately
        # quotes an earlier chapter's figures, and the one that found this does
        # it four times. So the hole stays, and the rule that actually closes it
        # is a habit rather than a check - a number goes in the note with the
        # configuration that produced it.
        if ($policy.Numbers.Enabled -and $researchText) {
            $numberLine = if ($verbLine) { $raw } else { $stripped }
            $numberLine = Remove-MacroSpanList $numberLine $policy.Macros.Code $maskState 'number'
            foreach ($m in [regex]::Matches($numberLine, '(?<![\d.])\d+\.\d+(?![\d.])')) {
                $allowed = $false
                foreach ($a in $policy.Numbers.Allow) {
                    if ($m.Value -match $a) { $allowed = $true; break }
                }
                if ($allowed) { continue }
                if (-not [regex]::IsMatch($researchText, '(?<![\d.])' + [regex]::Escape($m.Value))) {
                    Add-Finding $f.FullName $lineNo 'number' "'$($m.Value)' is in no research/ note; measure it, or record where it came from"
                }
            }
        }

        # 10. verbatim: arm the check when the prose promises a capture. The
        # comparison itself happens where the block ends; see Test-VerbatimClaim.
        if ($verbatimArmRe -and -not $verbLine) {
            $cm2 = [regex]::Match($prose, $policy.Verbatim.ClaimPattern)
            if ($cm2.Success) {
                $claimWindow = $policy.Verbatim.Window
                $claimLine = $lineNo
                $claimPhrase = $cm2.Value
            } elseif ($claimWindow -gt 0) {
                $claimWindow--
            }
        }
    }

    if ($listingTotal -gt $listingReported) {
        Add-Finding $f.FullName 0 'listing' "...and $($listingTotal - $listingReported) more line(s) over the budget"
    }
}

# Anything Paths.Characters named that Paths.Prose did not.
foreach ($f in $charFiles) {
    if ($charSet.Contains($f.FullName)) {
        Test-Characters $f
        [void]$charSet.Remove($f.FullName)
    }
}

# ---------------------------------------------------------------------------
# 12. gloss: a translated term carries its original, on the book's own cadence
# ---------------------------------------------------------------------------
#
# Its own pass rather than a step in the loop above, for two reasons. A term
# broken across two source lines is invisible to a line-at-a-time scan and real
# books break them. And the borrowed cadence is per chapter, so no single line
# holds enough to decide it.
#
# One rule, stated without a direction in it: a term the chapter owns is
# glossed once per section, and a term it does not own is glossed once per
# chapter. Ownership comes from which block of the glossary the term sits in,
# and the chapter a file belongs to comes from its path, chapters/NN-, which is
# a repo-wide convention rather than one book's.
#
# What this cannot see: a term that is central to a chapter but was never added
# to the glossary at all. The glossary is the source of truth, so a term in
# neither it nor a gloss call is indistinguishable from ordinary prose. That
# stays a reading job, and gloss-orphan below closes only the cheap half of it.

if ($glossary -and $glossary.Owner.Count -gt 0) {
    $glossMacro = $policy.Gloss.Macro
    $exempt = [System.Collections.Generic.HashSet[string]]::new(
        [string[]]$policy.Gloss.Exempt, [StringComparer]::InvariantCultureIgnoreCase)

    # A term matches on a boundary of letters, not on \b: \b is defined against
    # ASCII word characters in some engines and the terms here are words in
    # whatever language the book is written in.
    $termPattern = @{}
    foreach ($t in $glossary.Owner.Keys) {
        $termPattern[$t] = '(?i)(?<!\p{L})' + [regex]::Escape($t) + '(?!\p{L})'
    }

    # chapter number -> the sections of every file in it, in book order.
    # A plain hashtable, not [ordered]: an ordered dictionary indexed by an int
    # resolves to the positional overload rather than the key one, so
    # $byChapter[5] would mean the sixth entry. Order is restored by sorting the
    # keys below.
    $byChapter = @{}
    foreach ($f in $texFiles) {
        $rel = Get-RelPath $f.FullName
        $cm = [regex]::Match($rel, '/chapters/(\d+)-')
        if (-not $cm.Success) { continue }
        $n = [int]$cm.Groups[1].Value
        if (-not $byChapter.ContainsKey($n)) { $byChapter[$n] = @() }
        foreach ($s in (ConvertTo-GlossSections `
                (@(Get-Content $f.FullName)) $glossMacro $policy.Macros.Code $verbatimEnvs)) {
            $byChapter[$n] += [pscustomobject]@{ File = $f.FullName; Section = $s }
        }
    }

    # Findings are collected per chapter and emitted sorted, because the term
    # loop runs in glossary order and a reader wants a file read downwards.
    # $found belongs to the chapter loop below; PowerShell resolves it through
    # the caller's scope.
    function Add-Gloss {
        param([string]$file, [int]$line, [string]$id, [string]$msg)
        $found.Add([pscustomobject]@{ File = $file; Line = $line; Id = $id; Msg = $msg })
    }

    foreach ($n in ($byChapter.Keys | Sort-Object)) {
        $units = $byChapter[$n]

        # every term this chapter glosses anywhere, for the once-per-chapter half
        $glossedInChapter = [System.Collections.Generic.HashSet[string]]::new(
            [StringComparer]::InvariantCultureIgnoreCase)
        foreach ($u in $units) {
            foreach ($g in $u.Section.Glossed) { [void]$glossedInChapter.Add($g.Term) }
        }
        $borrowedReported = [System.Collections.Generic.HashSet[string]]::new(
            [StringComparer]::InvariantCultureIgnoreCase)

        $found = [System.Collections.Generic.List[pscustomobject]]::new()

        foreach ($u in $units) {
            $s = $u.Section

            # gloss-orphan: a gloss call whose term is in no translated block.
            # The keep-as-is list gets its own message because "bias (bias)" is
            # a different mistake from a term nobody added to the glossary.
            foreach ($g in $s.Glossed) {
                if ($glossary.Owner.ContainsKey($g.Term)) { continue }
                $why = if ($glossary.Keep.Contains($g.Term)) {
                    "'$($g.Term)' is on the keep-as-is list, so the gloss sets it beside itself"
                } else {
                    "'$($g.Term)' is in no glossary block; add it, or drop the gloss"
                }
                Add-Gloss $u.File $g.Line 'gloss-orphan' $why
            }

            # gloss-repeat: once per section means once
            foreach ($grp in ($s.Glossed | Group-Object Term | Where-Object { $_.Count -gt 1 })) {
                if (-not $glossary.Owner.ContainsKey($grp.Name)) { continue }
                Add-Gloss $u.File ($grp.Group[1].Line) 'gloss-repeat' `
                    "'$($grp.Name)' is glossed $($grp.Count) times in one section; the cadence is once"
            }

            # Where every term occurs in this section. Collected for all terms
            # first because terms nest: 'lan truyen nguoc' sits inside 'lan
            # truyen nguoc qua thoi gian', and one occurrence of the longer term
            # is not an occurrence of the shorter one. A term counts only where
            # it appears outside every longer term's match.
            $hits = [System.Collections.Generic.List[pscustomobject]]::new()
            foreach ($term in $glossary.Owner.Keys) {
                foreach ($m in [regex]::Matches($s.Body, $termPattern[$term])) {
                    $hits.Add([pscustomobject]@{
                        Term = $term; Index = $m.Index; End = $m.Index + $m.Length; Len = $term.Length })
                }
            }

            foreach ($term in $glossary.Owner.Keys) {
                if ($exempt.Contains($term)) { continue }

                $own = @($hits | Where-Object { $_.Term -eq $term })
                $hit = $null
                foreach ($h in $own) {
                    $covered = $false
                    foreach ($o in $hits) {
                        if ($o.Len -le $h.Len) { continue }
                        if ($o.Index -le $h.Index -and $o.End -ge $h.End) { $covered = $true; break }
                    }
                    if (-not $covered) { $hit = $h; break }
                }
                if (-not $hit) { continue }
                $line = $s.Map[[Math]::Min($hit.Index, $s.Map.Count - 1)]

                if ($glossary.Owner[$term] -eq $n) {
                    # owned: once per section
                    if (@($s.Glossed | Where-Object { $_.Term -eq $term }).Count -eq 0) {
                        Add-Gloss $u.File $line 'gloss-missing' `
                            "'$term' is this chapter's own term and this section never glosses it"
                    }
                } elseif (-not $glossedInChapter.Contains($term)) {
                    # unowned: once per chapter, and reported at its first use
                    if ($borrowedReported.Add($term)) {
                        Add-Gloss $u.File $line 'gloss-borrowed' `
                            ("'$term' belongs to chapter $($glossary.Owner[$term]) and this " +
                             'chapter never glosses it; a term this chapter does not own is glossed once')
                    }
                }
            }
        }

        foreach ($x in ($found | Sort-Object File, Line)) {
            Add-Finding $x.File $x.Line $x.Id $x.Msg
        }
    }
}

# ---------------------------------------------------------------------------
# 13. figures: TikZ style names pgfkeys has already taken
# ---------------------------------------------------------------------------

# `step/.style={...}` does not shadow anything. It fails the build, and the
# error names the key rather than the style, so it reads as a missing
# \usetikzlibrary and sends you looking in the preamble. The whole picture is
# lost for a word.
#
# Deliberately narrow. A style name is only flagged where it is being declared,
# so `-{Stealth}` arrowheads, `text=gray` on a node and every ordinary use of
# these keys are untouched. -Chapter does not restrict this: figures live
# outside chapters/ and a book's figure is worth checking whichever chapter is
# being linted.

if ($policy.Figures.Enabled -and $policy.Figures.ReservedKeys.Count -gt 0) {
    $figureFiles = @()
    foreach ($part in $policy.Figures.Paths) {
        $p = Join-Path $bookPath $part
        if (Test-Path $p) {
            $figureFiles += @(Get-ChildItem $p -Recurse -Filter '*.tex' | Sort-Object FullName)
        }
    }

    # A declaration is `name/.style` or `name/.style args`, optionally preceded
    # by other keys. The name may contain spaces, which TikZ allows, so the
    # match starts after a brace or a comma rather than at a word boundary.
    $declPattern = '(?:^|[\[,{])\s*([A-Za-z][A-Za-z0-9 ]*?)\s*/\.style'

    foreach ($f in $figureFiles) {
        $n = 0
        foreach ($line in [System.IO.File]::ReadAllLines($f.FullName)) {
            $n++
            if ($line -match '^\s*%') { continue }

            foreach ($m in [regex]::Matches($line, $declPattern)) {
                $name = $m.Groups[1].Value.Trim()
                if ($policy.Figures.ReservedKeys -contains $name) {
                    Add-Finding $f.FullName $n 'tikz' (
                        "style name '$name' is a pgfkeys key already; the picture will " +
                        'fail to compile with an error naming the key rather than the style')
                }
            }
        }
    }
}

# ---------------------------------------------------------------------------
# 14. log: parse an existing build log; never invoke latexmk (perl is not on
# PowerShell's PATH on this machine).
# ---------------------------------------------------------------------------

if ($policy.Log.Enabled) {
    $logPath = Join-Path $bookPath $policy.Log.Path
    if (-not (Test-Path $logPath)) {
        Write-Host "==> WARNING: $(Get-RelPath $logPath) not found; log checks skipped. Run latexmk first."
    } else {
        $logTime = (Get-Item $logPath).LastWriteTime
        $newer = @($texFiles | Where-Object { $_.LastWriteTime -gt $logTime })
        if ($newer.Count -gt 0) {
            Write-Host "==> WARNING: $($policy.Log.Path) is older than $($newer[0].Name); rebuild before trusting log checks."
        }
        $overfull = @(Select-String -Path $logPath -Pattern 'Overfull' -CaseSensitive).Count
        if ($overfull -gt $policy.Log.MaxOverfull) {
            Add-Finding $logPath 0 'log' "$overfull Overfull box(es); locate with: grep -A3 Overfull $($policy.Log.Path)"
        }
        $undefined = @(Select-String -Path $logPath -Pattern 'undefined').Count
        if ($undefined -gt $policy.Log.MaxUndefined) {
            Add-Finding $logPath 0 'log' "$undefined line(s) mentioning undefined references or citations"
        }
    }
}

if ($findings.Count -eq 0) {
    Write-Host '==> check-chapter: clean'
    exit 0
}
Write-Host "==> check-chapter: $($findings.Count) finding(s)"
exit 1
