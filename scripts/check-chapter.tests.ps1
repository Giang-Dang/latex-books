#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Regression tests for scripts/check-chapter.ps1.

.DESCRIPTION
    check-chapter.ps1 is the only prose gate in the repository, and "it still
    prints clean" proves nothing about it: a version with every check disabled
    prints clean too. So this runs it against two fixtures and asserts what
    comes out.

    scripts/tests/fixture-book triggers exactly one of each prose check.
    scripts/tests/fixture-punctuation covers the character check, whose default
    mode has to pass letters of any script and still reject a pasted smart
    quote.

    Both live under scripts/ rather than books/ because .githooks/pre-commit
    builds only books/* and template. Nothing here is compiled and nothing here
    costs anything at commit time.

    Add a check to check-chapter.ps1 and you add a trigger to a fixture, a line
    to $Expected, and a row to $WiringCases. That is the point: until these
    existed there was no cost to hardcoding one book's policy into the shared
    script, because nothing else exercised it.

.EXAMPLE
    pwsh scripts/check-chapter.tests.ps1
#>

[CmdletBinding()]
param(
    # Print each run in full, not only the differences. Not named -Verbose:
    # CmdletBinding already defines that one.
    [switch] $ShowOutput
)

$ErrorActionPreference = 'Stop'

$checker  = Join-Path $PSScriptRoot 'check-chapter.ps1'
$bookFix  = Join-Path $PSScriptRoot 'tests' 'fixture-book'
$punctFix = Join-Path $PSScriptRoot 'tests' 'fixture-punctuation'

$failed = $false

function Write-Fail {
    param([string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
    $script:failed = $true
}

# check-chapter.ps1 reports with Write-Host, which writes to the information
# stream, so an in-process call would capture nothing. A child pwsh turns it
# into ordinary stdout, and it is also how .githooks/pre-commit invokes it.
function Invoke-Checker {
    param([string]$Fixture)

    $prefix = 'scripts/tests/' + (Split-Path -Leaf $Fixture)
    $lines = @(& pwsh -NoProfile -File $checker $Fixture 2>&1 | ForEach-Object { "$_" })
    if ($ShowOutput) {
        Write-Host "--- $Fixture ---"
        $lines | ForEach-Object { Write-Host $_ }
        Write-Host ''
    }
    return @($lines |
        Where-Object { $_ -like "$prefix/*" } |
        ForEach-Object { $_.Substring($prefix.Length + 1) })
}

function Get-FindingIds {
    param([string[]]$Lines)
    return @($Lines |
        ForEach-Object { if ($_ -match '\[([a-z-]+)\]') { $Matches[1] } } |
        Sort-Object -Unique)
}

function Compare-Findings {
    param([string]$What, [string[]]$Expected, [string[]]$Actual)

    $bad = $false
    $max = [Math]::Max($Expected.Count, $Actual.Count)
    for ($i = 0; $i -lt $max; $i++) {
        $want = if ($i -lt $Expected.Count) { $Expected[$i] } else { '(nothing)' }
        $got = if ($i -lt $Actual.Count) { $Actual[$i] } else { '(nothing)' }
        if ($want -cne $got) {
            if (-not $bad) { Write-Fail "$What did not produce the expected findings"; $bad = $true }
            Write-Host "  at $($i + 1):"
            Write-Host "    expected: $want"
            Write-Host "    actual:   $got"
        }
    }
    return (-not $bad)
}

# ---------------------------------------------------------------------------
# fixture-book: the prose checks
# ---------------------------------------------------------------------------

# The fixture ships no check-chapter.psd1. This script writes one before each
# run instead, which is what lets the same tree serve as both "every check on"
# and "library defaults" without two copies of the prose drifting apart.
$BaseSections = [ordered]@{
    Characters   = "@{ Mode = 'Ascii' }"
    Contractions = "@{ Enabled = `$true; Preset = 'english' }"
    Spelling     = "@{ Enabled = `$true; Preset = 'en-GB' }"
}

$bookPolicy = Join-Path $bookFix 'check-chapter.psd1'

function New-BookConfig {
    param([System.Collections.IDictionary]$Override = @{})

    $sections = [ordered]@{}
    foreach ($k in $BaseSections.Keys) { $sections[$k] = $BaseSections[$k] }
    foreach ($k in $Override.Keys) { $sections[$k] = $Override[$k] }

    $body = ($sections.Keys | ForEach-Object { "    $_ = $($sections[$_])" }) -join [Environment]::NewLine
    return "@{" + [Environment]::NewLine + $body + [Environment]::NewLine + "}"
}

function Invoke-BookFixture {
    param([System.Collections.IDictionary]$Override, [switch]$NoPolicy)

    if ($NoPolicy) {
        Remove-Item -LiteralPath $bookPolicy -Force -ErrorAction SilentlyContinue
    } else {
        Set-Content -LiteralPath $bookPolicy -Value (New-BookConfig $Override) -Encoding utf8
    }
    try {
        return Invoke-Checker $bookFix
    } finally {
        Remove-Item -LiteralPath $bookPolicy -Force -ErrorAction SilentlyContinue
    }
}

# Every finding id the prose half can emit appears here at least once, and
# 01-clean.tex appears nowhere: it holds a contraction, two American spellings,
# a dash ligature and a literal quote, all inside \code{}, so a masking
# regression shows up as an extra line rather than a missing one.
$Expected = @(
    "chapters/01-triggers/02-citations.tex:4: [tilde-cite] use a non-breaking tie: ~\autocite{...}"
    "chapters/01-triggers/02-citations.tex:8: [cite-key] citation key 'missingkey' not found in refs.bib"
    "chapters/01-triggers/03-quoting.tex:4: [quote] literal double quote in prose; use \enquote{...}"
    "chapters/01-triggers/04-index.tex:4: [index-pct] \index{...} line must end with %"
    "chapters/01-triggers/05-language.tex:4: [contraction] contraction 'It's' in the author's voice"
    "chapters/01-triggers/05-language.tex:7: [spelling] 'color' -> colour(s)"
    "chapters/01-triggers/05-language.tex:7: [spelling] 'center' -> centre(s)"
    "chapters/01-triggers/05-language.tex:7: [spelling] 'gray' -> grey"
    "chapters/01-triggers/06-dashes.tex:4: [dash] en/em dash ligature in prose; reword or use ASCII punctuation"
    "chapters/01-triggers/07-numbers.tex:7: [number] '9.99' is in no research/ note; measure it, or record where it came from"
    # 3.14 appears only in research/README.md, which documents the folder and is
    # deliberately not counted as a note.
    "chapters/01-triggers/07-numbers.tex:9: [number] '3.14' is in no research/ note; measure it, or record where it came from"
    "chapters/01-triggers/08-verbatim.tex:6: [verbatim] line~'this line was never captured anywhere' is in no research/ note, but line 4 calls this listing a capture ('in full')"
    "chapters/01-triggers/09-bytes.tex:5: [ascii] byte 0xC3 is not printable ASCII"
    "chapters/01-triggers/09-bytes.tex:5: [ascii] byte 0xA9 is not printable ASCII"
    # One line out of a picture that also grids on step=0.5cm, scales a node,
    # sets text=gray and names a style with a space in it. Exactly one of those
    # is a style declaration using a reserved name.
    "figures/tikz/10-reserved-key.tex:10: [tikz] style name 'step' is a pgfkeys key already; the picture will fail to compile with an error naming the key rather than the style"
    "build/main.log: [log] 1 Overfull box(es); locate with: grep -A3 Overfull build/main.log"
    "build/main.log: [log] 1 line(s) mentioning undefined references or citations"
)

# The log check warns when a .tex file is newer than build/main.log, and that
# warning is noise here: the fixture's log is fabricated and its freshness
# means nothing.
$fixtureLog = Join-Path $bookFix 'build' 'main.log'
if (Test-Path -LiteralPath $fixtureLog) {
    (Get-Item -LiteralPath $fixtureLog).LastWriteTime = Get-Date
}

$actual = Invoke-BookFixture @{}
if (Compare-Findings 'fixture-book with every check on' $Expected $actual) {
    Write-Host "[ok]   prose: $($Expected.Count) findings, all as expected"
}

# ---------------------------------------------------------------------------
# The library defaults, which are not the same policy
# ---------------------------------------------------------------------------

# A book that says nothing gets a gate that assumes nothing about its language:
# letters of any script pass, spelling has no variety to enforce, and whether
# contractions belong in the voice is left to the book.
$DefaultIds = @('cite-key', 'dash', 'index-pct', 'log', 'number', 'quote', 'tikz', 'tilde-cite', 'verbatim')
$defaultIds = Get-FindingIds (Invoke-BookFixture -NoPolicy)
if (($defaultIds -join ',') -ne ($DefaultIds -join ',')) {
    Write-Fail 'the library defaults are not the expected reduced set'
    Write-Host "    expected: $($DefaultIds -join ', ')"
    Write-Host "    actual:   $($defaultIds -join ', ')"
} else {
    Write-Host '[ok]   defaults: ascii, contraction and spelling are off until a book asks'
}

# ---------------------------------------------------------------------------
# Wiring: every setting silences the check it names, and only that one
# ---------------------------------------------------------------------------

# The baseline proves the checks fire. It says nothing about whether the policy
# keys are connected to them: a key wired to the wrong check, or to nothing,
# passes every test above. So each section is switched off in turn and what
# disappears is compared against what was supposed to disappear.
$WiringCases = @(
    @{ Name = 'Characters';   Override = @{ Characters = "@{ Mode = 'Off' }" };            Silences = @('ascii') }
    @{ Name = 'Citations';    Override = @{ Citations = '@{ Enabled = $false }' };         Silences = @('tilde-cite', 'cite-key') }
    @{ Name = 'Quotes';       Override = @{ Quotes = '@{ Enabled = $false }' };            Silences = @('quote') }
    @{ Name = 'Index';        Override = @{ Index = '@{ Enabled = $false }' };             Silences = @('index-pct') }
    @{ Name = 'Dashes';       Override = @{ Dashes = '@{ Enabled = $false }' };            Silences = @('dash') }
    @{ Name = 'Contractions'; Override = @{ Contractions = '@{ Enabled = $false }' };      Silences = @('contraction') }
    @{ Name = 'Spelling';     Override = @{ Spelling = '@{ Enabled = $false }' };          Silences = @('spelling') }
    @{ Name = 'Numbers';      Override = @{ Numbers = '@{ Enabled = $false }' };           Silences = @('number') }
    @{ Name = 'Verbatim';     Override = @{ Verbatim = '@{ Enabled = $false }' };          Silences = @('verbatim') }
    @{ Name = 'Figures';      Override = @{ Figures = '@{ Enabled = $false }' };           Silences = @('tikz') }
    # Emptying the reserved list is the other way to turn it off, and it has to
    # work: a book that disagrees with one name should not have to disable the
    # family to say so.
    @{ Name = 'Figures.Keys'; Override = @{ Figures = '@{ ReservedKeys = @() }' };         Silences = @('tikz') }
    @{ Name = 'Log';          Override = @{ Log = '@{ Enabled = $false }' };               Silences = @('log') }
    # Paths.Prose empties the prose pass. The character scan reads its own list
    # and must survive, which is what keeps the two lists genuinely separate.
    @{ Name = 'Paths.Prose';  Override = @{ Paths = '@{ Prose = @() }' }
       Silences = @('tilde-cite', 'cite-key', 'quote', 'index-pct', 'contraction',
                    'spelling', 'dash', 'number', 'verbatim') }
)

$baselineIds = Get-FindingIds $actual
foreach ($case in $WiringCases) {
    $ids = Get-FindingIds (Invoke-BookFixture $case.Override)
    $want = @($baselineIds | Where-Object { $case.Silences -notcontains $_ }) | Sort-Object
    $got = @($ids) | Sort-Object

    if (($want -join ',') -ne ($got -join ',')) {
        Write-Fail "$($case.Name) did not silence exactly what it names"
        Write-Host "    expected to remain: $($want -join ', ')"
        Write-Host "    actually remained:  $($got -join ', ')"
    }
}

# The masking macros are not a check, so emptying them must ADD findings rather
# than remove them: 01-clean.tex passes only because \code{} hides a
# contraction, two American spellings, a dash ligature and a literal quote.
$unmasked = Invoke-BookFixture @{ Macros = '@{ Code = @() }' }
if (@($unmasked | Where-Object { $_ -like '*01-clean.tex*' }).Count -eq 0) {
    Write-Fail 'Macros.Code is not wired: emptying it left 01-clean.tex silent'
}

if (-not $failed) {
    Write-Host "[ok]   wiring: $($WiringCases.Count) settings silence exactly the check they name"
}

# ---------------------------------------------------------------------------
# fixture-punctuation: the character check under the default mode
# ---------------------------------------------------------------------------

$PunctExpected = @(
    'chapters/01-modes/02-lookalikes.tex:8: [unicode] U+2014 is em dash, a Unicode look-alike of ASCII punctuation'
    'chapters/01-modes/02-lookalikes.tex:9: [unicode] U+201C is left double quote, a Unicode look-alike of ASCII punctuation'
    'chapters/01-modes/02-lookalikes.tex:10: [unicode] U+201D is right double quote, a Unicode look-alike of ASCII punctuation'
    'chapters/01-modes/02-lookalikes.tex:11: [unicode] U+2026 is ellipsis, a Unicode look-alike of ASCII punctuation'
    'chapters/01-modes/02-lookalikes.tex:12: [unicode] U+00A0 is no-break space, a Unicode look-alike of ASCII punctuation'
    # 03-captured.tex holds four em dashes, one per case. The committed fixture
    # policy does not set Characters.AllowInCapturedListings, so all four are
    # findings here. The next block turns the setting on and asserts that
    # exactly one of them goes away.
    'chapters/01-modes/03-captured.tex:12: [unicode] U+2014 is em dash, a Unicode look-alike of ASCII punctuation'
    'chapters/01-modes/03-captured.tex:18: [unicode] U+2014 is em dash, a Unicode look-alike of ASCII punctuation'
    'chapters/01-modes/03-captured.tex:24: [unicode] U+2014 is em dash, a Unicode look-alike of ASCII punctuation'
    'chapters/01-modes/03-captured.tex:29: [unicode] U+2014 is em dash, a Unicode look-alike of ASCII punctuation'
)

$punct = Invoke-Checker $punctFix
if (Compare-Findings 'fixture-punctuation' $PunctExpected $punct) {
    Write-Host '[ok]   punctuation: look-alikes caught, letters of five scripts passed'
}

# ---------------------------------------------------------------------------
# Characters.AllowInCapturedListings
# ---------------------------------------------------------------------------

# The setting forgives a character the mode would reject, so what it must NOT
# forgive is the whole test. 03-captured.tex holds the same em dash four times:
# in a named environment and traceable to research/ (line 12), in a named
# environment and traceable to nothing (18), traceable but in an environment
# the setting does not name (24), and in prose (29). Only line 12 may go.
#
# The fixture's own psd1 also has Numbers and Verbatim off, which makes this
# the case that proves the research notes are read for this family rather than
# only as a side effect of one of those two being on.
$punctPolicy = Join-Path $punctFix 'check-chapter.psd1'
$punctPolicyOriginal = Get-Content -LiteralPath $punctPolicy -Raw

try {
    Set-Content -LiteralPath $punctPolicy -Encoding utf8 -Value @'
@{
    Characters   = @{ Mode = 'Punctuation'; AllowInCapturedListings = @('minted:text') }

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
'@
    $CapturedExpected = @($PunctExpected | Where-Object { $_ -notlike '*03-captured.tex:12:*' })
    $captured = Invoke-Checker $punctFix
    if (Compare-Findings 'fixture-punctuation with AllowInCapturedListings' $CapturedExpected $captured) {
        Write-Host '[ok]   captured: the traced listing line is forgiven, the other three are not'
    }

    # And the run has to admit it. A gate that forgives bytes somewhere while
    # printing a bare "chars=Punctuation" is the silent weakening the printed
    # policy exists to prevent, so the exemption belongs on that line.
    $policyLine = @(& pwsh -NoProfile -File $checker $punctFix 2>&1 |
            ForEach-Object { "$_" } | Where-Object { $_ -like '*==> policy:*' })
    if (@($policyLine | Where-Object { $_ -match 'chars=Punctuation\(captured:minted:text\)' }).Count -ne 1) {
        Write-Fail 'the policy line did not report the captured-listing exemption'
        $policyLine | ForEach-Object { Write-Host "    actual: $_" }
    } else {
        Write-Host '[ok]   captured: the policy line names the exemption'
    }
} finally {
    Set-Content -LiteralPath $punctPolicy -Encoding utf8 -Value $punctPolicyOriginal -NoNewline
}

# A file that is not valid UTF-8 has to be reported, not silently repaired.
# Reading it with a lenient decoder would turn the bad byte into U+FFFD and let
# the file pass, which is worse than the byte-level complaint Ascii mode makes.
# Written here rather than committed, so no git text filter can normalise the
# one thing the case depends on.
$latin1File = Join-Path $punctFix 'chapters' '01-modes' '03-latin1.tex'
try {
    [System.IO.File]::WriteAllBytes($latin1File, [byte[]]@(
        0x25, 0x20, 0x4C, 0x61, 0x74, 0x69, 0x6E, 0x2D, 0x31, 0x0A,   # "% Latin-1\n"
        0x63, 0x61, 0x66, 0xE9, 0x0A))                                # "caf<E9>\n"
    $enc = Invoke-Checker $punctFix
    $wanted = 'chapters/01-modes/03-latin1.tex: [encoding] not valid UTF-8; re-save the file as UTF-8'
    if ($enc -notcontains $wanted) {
        Write-Fail 'a file that is not valid UTF-8 was not reported'
        Write-Host "    expected among the findings: $wanted"
        $enc | ForEach-Object { Write-Host "    actual: $_" }
    } else {
        Write-Host '[ok]   encoding: a mis-encoded file is reported, not silently repaired'
    }
} finally {
    Remove-Item -LiteralPath $latin1File -Force -ErrorAction SilentlyContinue
}

Write-Host ''
if ($failed) {
    Write-Host 'FAIL' -ForegroundColor Red
    exit 1
}
Write-Host 'PASS' -ForegroundColor Green
exit 0
