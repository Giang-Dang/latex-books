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

Write-Host ''
if ($failed) {
    Write-Host "--- $($actual.Count) finding(s), $($Expected.Count) expected ---"
    Write-Host 'FAIL' -ForegroundColor Red
    exit 1
}

Write-Host "check-chapter.tests: $($Expected.Count) findings, all as expected"
Write-Host 'PASS' -ForegroundColor Green
exit 0
