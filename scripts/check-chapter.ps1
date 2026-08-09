#!/usr/bin/env pwsh
# Deterministic lint gate for one book's prose: the machine half of the
# draft-chapter build gate. Checks characters, citation ties and keys, quoting,
# index termination, contractions, spellings, dashes, measured-number
# provenance, verbatim-capture claims, and the build log.
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
        Characters   = [ordered]@{
            Mode  = 'Punctuation'
            Extra = @()
            Allow = @()
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

        # The masking macros. These default to the template's own \code and
        # csquotes' \enquote, so they are library facts rather than book facts;
        # they are settable only so a book that renames them keeps masking.
        Macros       = [ordered]@{
            Code        = @('code')
            Quoted      = @('enquote')
            Identifiers = @('begin', 'end', 'label', 'ref', 'pageref', 'input', 'include', 'autocite')
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
        return @($chapterDirs | Get-ChildItem -Filter '*.tex' | Sort-Object FullName)
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
$verbatimEnvs = @('minted', 'verbatim', 'Verbatim')
$preambleDir = Join-Path $bookPath 'preamble'
if (Test-Path $preambleDir) {
    foreach ($f in Get-ChildItem $preambleDir -Filter '*.tex') {
        foreach ($m in [regex]::Matches((Get-Content $f.FullName -Raw), '\\newminted\[([A-Za-z]+)\]')) {
            $verbatimEnvs += $m.Groups[1].Value
        }
    }
}

# --- research notes, as one blob. A book without research notes simply skips
# the number and verbatim checks rather than failing every number in it.
$researchText = ''
if ($policy.Numbers.Enabled -or $policy.Verbatim.Enabled) {
    $researchDir = Join-Path $bookPath $policy.Numbers.ResearchDir
    if (Test-Path $researchDir) {
        $researchFiles = @(Get-ChildItem $researchDir -Filter $policy.Numbers.ResearchGlob -File)
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

# ---------------------------------------------------------------------------
# Report the policy before using it
# ---------------------------------------------------------------------------

function Format-Policy {
    $bits = @()
    $bits += "chars=$charMode"

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

function Test-Characters {
    param([System.IO.FileInfo]$File)

    if ($charMode -eq 'Ascii') {
        # Raw bytes, everywhere including verbatim. Latin-1 maps each byte to
        # one char, so match positions are byte positions.
        $rawText = [System.IO.File]::ReadAllText($File.FullName, $latin1)
        $bad = [regex]::Matches($rawText, '[^\x09\x0A\x0D\x20-\x7E]')
        $reported = 0
        foreach ($m in $bad) {
            if ($reported -ge 5) {
                Add-Finding $File.FullName 0 'ascii' "...and $($bad.Count - 5) more non-ASCII bytes"
                break
            }
            $lineNo = 1 + [regex]::Matches($rawText.Substring(0, $m.Index), "`n").Count
            Add-Finding $File.FullName $lineNo 'ascii' ('byte 0x{0:X2} is not printable ASCII' -f [int][char]$m.Value)
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
# 2-10. prose, line by line
# ---------------------------------------------------------------------------

foreach ($f in $texFiles) {
    if ($charSet.Contains($f.FullName)) {
        Test-Characters $f
        [void]$charSet.Remove($f.FullName)
    }

    $rawLines = @(Get-Content $f.FullName)
    $inVerb = $null
    $maskState = @{}

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
            if ($raw -match ('\\end\{' + [regex]::Escape($inVerb) + '\}')) {
                $inVerb = $null
                if ($null -ne $capture) {
                    Test-VerbatimClaim $f.FullName $captureLine $claimLine $claimPhrase $capture $researchBlob $policy.Verbatim.MinLineLength
                    $capture = $null
                }
            } elseif ($null -ne $capture) {
                [void]$capture.Add($raw)
            }
            $stripped = ''
            $verbLine = $true
        } else {
            $bm = [regex]::Match($raw, '\\begin\{([A-Za-z]+\*?)\}')
            if ($bm.Success -and $verbatimEnvs -contains $bm.Groups[1].Value) {
                if ($raw -notmatch ('\\end\{' + [regex]::Escape($bm.Groups[1].Value) + '\}')) {
                    $inVerb = $bm.Groups[1].Value

                    # A claim arms the check only for the environments the book
                    # nominated as holding captured output. Listings that come
                    # out of a companion repo are checked by that repo, not
                    # here, and commands to type are not captures at all.
                    if ($claimWindow -gt 0 -and $verbatimArmRe -and $researchBlob -and $raw -match $verbatimArmRe) {
                        $capture = [System.Collections.Generic.List[string]]::new()
                        $captureLine = $lineNo
                    }
                    $claimWindow = 0
                }
                $stripped = ''
                $verbLine = $true
            } else {
                $stripped = $raw -replace '(?<!\\)%.*$', ''
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
}

# Anything Paths.Characters named that Paths.Prose did not.
foreach ($f in $charFiles) {
    if ($charSet.Contains($f.FullName)) {
        Test-Characters $f
        [void]$charSet.Remove($f.FullName)
    }
}

# ---------------------------------------------------------------------------
# 11. log: parse an existing build log; never invoke latexmk (perl is not on
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
