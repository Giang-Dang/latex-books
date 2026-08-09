#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Regression tests for scripts/check-chapter.ps1.

.DESCRIPTION
    check-chapter.ps1 is the only prose gate in the repository, and "it still
    prints clean" proves nothing about it: a version with every check disabled
    prints clean too. So this runs it against scripts/tests/fixture-book, a
    directory whose only purpose is to trigger exactly one of each check, and
    compares the findings against the list below.

    The fixture lives under scripts/ rather than books/ because
    .githooks/pre-commit builds only books/* and template. Nothing here is ever
    compiled and nothing here costs anything at commit time.

    Add a check to check-chapter.ps1 and you add a trigger to the fixture and a
    line to $Expected. That is the point: until this file existed there was no
    cost to hard-coding one book's policy into the shared script, because
    nothing else exercised it.

.EXAMPLE
    pwsh scripts/check-chapter.tests.ps1
#>

[CmdletBinding()]
param(
    # Print the whole run, not only the differences. Not named -Verbose:
    # CmdletBinding already defines that one.
    [switch] $ShowOutput
)

$ErrorActionPreference = 'Stop'

$root    = Split-Path -Parent $PSScriptRoot
$checker = Join-Path $PSScriptRoot 'check-chapter.ps1'
$fixture = Join-Path $PSScriptRoot 'tests' 'fixture-book'
$prefix  = 'scripts/tests/fixture-book'

# ---------------------------------------------------------------------------
# What the fixture must produce, in order
# ---------------------------------------------------------------------------

# Every finding id check-chapter.ps1 can emit appears here at least once, and
# 01-clean.tex appears nowhere: it holds a contraction, two American spellings,
# a dash ligature and a literal quote, all inside \code{}, so a masking
# regression shows up as an extra line rather than as a missing one.
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
    "chapters/01-triggers/08-verbatim.tex:6: [verbatim] line~'this line was never captured anywhere' is in no research/ note, but line 4 calls this listing a capture ('in full')"
    "chapters/01-triggers/09-bytes.tex:5: [ascii] byte 0xC3 is not printable ASCII"
    "chapters/01-triggers/09-bytes.tex:5: [ascii] byte 0xA9 is not printable ASCII"
    "build/main.log: [log] 1 Overfull box(es); locate with: grep -A3 Overfull build/main.log"
    "build/main.log: [log] 1 line(s) mentioning undefined references or citations"
)

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

if (-not (Test-Path -LiteralPath $fixture)) {
    Write-Host "[FAIL] the fixture is missing: $fixture" -ForegroundColor Red
    exit 1
}

# The log check warns when a .tex file is newer than build/main.log, and that
# warning is noise here: the fixture's log is fabricated and its freshness
# means nothing. Touch it so the warning never fires and the output stays
# comparable run to run.
$fixtureLog = Join-Path $fixture 'build' 'main.log'
if (Test-Path -LiteralPath $fixtureLog) {
    (Get-Item -LiteralPath $fixtureLog).LastWriteTime = Get-Date
}

# Through a child pwsh rather than with the call operator: check-chapter.ps1
# reports with Write-Host, which writes to the information stream, so an
# in-process call would capture nothing at all. A child process turns it into
# ordinary stdout, and it is also exactly how .githooks/pre-commit invokes it.
$output = @(& pwsh -NoProfile -File $checker $fixture 2>&1 | ForEach-Object { "$_" })

# Findings are the lines naming a file inside the fixture. Everything else is
# the header, the policy line and the trailing count.
$actual = @($output |
    Where-Object { $_ -like "$prefix/*" } |
    ForEach-Object { $_.Substring($prefix.Length + 1) })

if ($ShowOutput) {
    Write-Host '--- run output ---'
    $output | ForEach-Object { Write-Host $_ }
    Write-Host ''
}

# ---------------------------------------------------------------------------
# Compare
# ---------------------------------------------------------------------------

$failed = $false

# Order matters as well as membership: the script walks files and lines in a
# fixed order, and a reordering usually means a check moved between passes.
$max = [Math]::Max($Expected.Count, $actual.Count)
for ($i = 0; $i -lt $max; $i++) {
    $want = if ($i -lt $Expected.Count) { $Expected[$i] } else { '(nothing)' }
    $got = if ($i -lt $actual.Count) { $actual[$i] } else { '(nothing)' }
    if ($want -cne $got) {
        if (-not $failed) {
            Write-Host '[FAIL] the fixture did not produce the expected findings' -ForegroundColor Red
            $failed = $true
        }
        Write-Host "  at $($i + 1):"
        Write-Host "    expected: $want"
        Write-Host "    actual:   $got"
    }
}

if ($failed) {
    Write-Host ''
    Write-Host "--- $($actual.Count) finding(s), $($Expected.Count) expected ---"
    Write-Host 'FAIL' -ForegroundColor Red
    exit 1
}

Write-Host "[ok]   defaults: $($Expected.Count) findings, all as expected"

# ---------------------------------------------------------------------------
# Wiring: every setting silences the check it names, and only that one
# ---------------------------------------------------------------------------

# The baseline above proves the checks fire. It says nothing about whether the
# policy keys are connected to them: a key wired to the wrong check, or to
# nothing, passes every test so far. So each section is switched off in turn
# and the findings that disappear are compared against the findings that were
# supposed to disappear.
$WiringCases = @(
    @{ Name = 'Characters';   Config = "@{ Characters = @{ Mode = 'Off' } }";        Silences = @('ascii') }
    @{ Name = 'Citations';    Config = '@{ Citations = @{ Enabled = $false } }';     Silences = @('tilde-cite', 'cite-key') }
    @{ Name = 'Quotes';       Config = '@{ Quotes = @{ Enabled = $false } }';        Silences = @('quote') }
    @{ Name = 'Index';        Config = '@{ Index = @{ Enabled = $false } }';         Silences = @('index-pct') }
    @{ Name = 'Dashes';       Config = '@{ Dashes = @{ Enabled = $false } }';        Silences = @('dash') }
    @{ Name = 'Contractions'; Config = '@{ Contractions = @{ Enabled = $false } }';  Silences = @('contraction') }
    @{ Name = 'Spelling';     Config = '@{ Spelling = @{ Enabled = $false } }';      Silences = @('spelling') }
    @{ Name = 'Numbers';      Config = '@{ Numbers = @{ Enabled = $false } }';       Silences = @('number') }
    @{ Name = 'Verbatim';     Config = '@{ Verbatim = @{ Enabled = $false } }';      Silences = @('verbatim') }
    @{ Name = 'Log';          Config = '@{ Log = @{ Enabled = $false } }';           Silences = @('log') }
    # Paths.Prose empties the prose pass. The character scan reads its own list
    # and must survive, which is what keeps the two lists genuinely separate.
    @{ Name = 'Paths.Prose';  Config = '@{ Paths = @{ Prose = @() } }'
       Silences = @('tilde-cite', 'cite-key', 'quote', 'index-pct', 'contraction',
                    'spelling', 'dash', 'number', 'verbatim') }
)

function Get-FindingIds {
    param([string[]]$Lines)
    return @($Lines |
        ForEach-Object { if ($_ -match '\[([a-z-]+)\]') { $Matches[1] } } |
        Sort-Object -Unique)
}

$fixturePolicy = Join-Path $fixture 'check-chapter.psd1'
$baselineIds = Get-FindingIds $actual

function Invoke-Fixture {
    param([string]$Config)
    Set-Content -LiteralPath $fixturePolicy -Value $Config -Encoding utf8
    try {
        return @(& pwsh -NoProfile -File $checker $fixture 2>&1 |
            ForEach-Object { "$_" } |
            Where-Object { $_ -like "$prefix/*" })
    } finally {
        Remove-Item -LiteralPath $fixturePolicy -Force -ErrorAction SilentlyContinue
    }
}

try {
    foreach ($case in $WiringCases) {
        $ids = Get-FindingIds (Invoke-Fixture $case.Config)
        $want = @($baselineIds | Where-Object { $case.Silences -notcontains $_ }) | Sort-Object
        $got = @($ids) | Sort-Object

        if (($want -join ',') -ne ($got -join ',')) {
            Write-Host "[FAIL] $($case.Name) did not silence exactly what it names" -ForegroundColor Red
            Write-Host "    expected to remain: $($want -join ', ')"
            Write-Host "    actually remained:  $($got -join ', ')"
            $failed = $true
        }
    }

    # The masking macros are not a check, so switching them off must ADD
    # findings rather than remove them: 01-clean.tex hides a contraction, two
    # American spellings, a dash ligature and a literal quote inside \code{}.
    $unmasked = Invoke-Fixture '@{ Macros = @{ Code = @() } }'
    $leaked = @($unmasked | Where-Object { $_ -like '*01-clean.tex*' })
    if ($leaked.Count -eq 0) {
        Write-Host '[FAIL] Macros.Code is not wired: emptying it left 01-clean.tex silent' -ForegroundColor Red
        Write-Host '    that file only passes because \code{} masks what is inside it'
        $failed = $true
    }
} finally {
    Remove-Item -LiteralPath $fixturePolicy -Force -ErrorAction SilentlyContinue
}

Write-Host ''
if ($failed) {
    Write-Host 'FAIL' -ForegroundColor Red
    exit 1
}

Write-Host "[ok]   wiring: $($WiringCases.Count) settings silence exactly the check they name"
Write-Host 'PASS' -ForegroundColor Green
exit 0
