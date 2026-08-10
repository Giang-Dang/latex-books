#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Regression tests for scripts/release.ps1.

.DESCRIPTION
    release.ps1 asks which books to release, and the answer decides which PDFs
    in dist/ get overwritten. Every way that can go wrong is silent: a range
    that quietly releases one book, an 'a' that matches a book name instead of
    meaning all, an out-of-range number dropped rather than refused, a list
    ordered by folder name while the numbers people typed were read against a
    list ordered by date. None of those look like a failure. Two of them
    overwrite the wrong PDF.

    So the selection is tested through the CLI, on -DryRun, against a fixture
    repository this script builds in a temp folder: three books with fixed
    commit dates, one released and current, one released and then edited, one
    never released. Fixed dates are the point - "most recently changed first"
    is only assertable if the fixture's dates are not the clone's.

    Nothing here compiles, and nothing here touches the real books/ or dist/.

.EXAMPLE
    pwsh scripts/release.tests.ps1
#>

[CmdletBinding()]
param(
    # Print every run in full, not only the failures.
    [switch] $ShowOutput,

    # Leave the fixture repository on disk and print where it is.
    [switch] $KeepFixture
)

$ErrorActionPreference = 'Stop'

$release = Join-Path $PSScriptRoot 'release.ps1'
$failed = $false

function Write-Fail {
    param([string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
    $script:failed = $true
}

function Write-Ok {
    param([string]$Message)
    Write-Host "[ok]   $Message"
}

# ---------------------------------------------------------------------------
# The fixture repository
# ---------------------------------------------------------------------------

$fixture = Join-Path ([System.IO.Path]::GetTempPath()) "latex-books-release-tests-$PID"
if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }

New-Item -ItemType Directory -Path (Join-Path $fixture 'scripts') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $fixture 'dist') -Force | Out-Null
Copy-Item -LiteralPath $release -Destination (Join-Path $fixture 'scripts/release.ps1')

function Invoke-FixtureGit {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$GitArgs)

    # A throwaway repository, so it carries its own identity rather than
    # borrowing whatever the machine is configured with, and does not stop to
    # sign anything. None of this reaches a real history.
    $config = @(
        '-c', 'user.name=release tests'
        '-c', 'user.email=tests@example.invalid'
        '-c', 'commit.gpgsign=false'
    )
    & git -C $fixture @config @GitArgs 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "fixture git failed: git $($GitArgs -join ' ')" }
}

function Add-FixtureFile {
    param([string]$RelativePath, [string]$Content = 'fixture')

    $full = Join-Path $fixture $RelativePath
    New-Item -ItemType Directory -Path (Split-Path -Parent $full) -Force | Out-Null
    Set-Content -LiteralPath $full -Value $Content -Encoding utf8
}

function New-FixtureCommit {
    param([string]$Message, [string]$Date)

    # Committer date is what release.ps1 reads (git log --format=%ct), so it is
    # the one that has to be pinned.
    $env:GIT_AUTHOR_DATE = $Date
    $env:GIT_COMMITTER_DATE = $Date
    try {
        Invoke-FixtureGit add -A
        Invoke-FixtureGit commit -m $Message
    } finally {
        Remove-Item Env:GIT_AUTHOR_DATE, Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
    }
}

Invoke-FixtureGit init -q -b main

# alpha is committed first and released, then edited again last: it ends up the
# most recently changed book and a stale release. Sorting by anything other
# than the last commit - folder name, creation order, file mtime in a fresh
# clone - puts it somewhere other than first, which is the point of it.
Add-FixtureFile 'books/alpha-book/main.tex'
New-FixtureCommit 'alpha' '2026-01-02T10:00:00+00:00'

Add-FixtureFile 'dist/alpha-book.pdf'
New-FixtureCommit 'release alpha' '2026-01-03T10:00:00+00:00'

# beta is committed and never released.
Add-FixtureFile 'books/beta-book/main.tex'
New-FixtureCommit 'beta' '2026-01-04T10:00:00+00:00'

# gamma is committed and released in the same commit: current.
Add-FixtureFile 'books/gamma-book/main.tex'
Add-FixtureFile 'dist/gamma-book.pdf'
New-FixtureCommit 'gamma' '2026-01-05T10:00:00+00:00'

Add-FixtureFile 'books/alpha-book/main.tex' 'fixture, revised'
New-FixtureCommit 'alpha again' '2026-01-06T10:00:00+00:00'

# Recency order from here on, and the numbering every case below counts on:
#   1 alpha-book  (2026-01-06, released 01-03) stale
#   2 gamma-book  (2026-01-05, released 01-05) current
#   3 beta-book   (2026-01-04, never released)
$Order = @('alpha-book', 'gamma-book', 'beta-book')

# ---------------------------------------------------------------------------
# Running it
# ---------------------------------------------------------------------------

$fixtureScript = Join-Path $fixture 'scripts/release.ps1'

# -DryRun on every run: these tests assert on the selection, and building the
# fixture would mean a LaTeX toolchain and minutes per case for an answer the
# dry run already gives.
function Invoke-Release {
    param(
        [string]$What,
        [string[]]$Arguments = @(),
        # $null means "give the child no stdin at all"; '' means "answer the
        # prompt with a blank line", which is how a person cancels.
        [string]$Answers
    )

    $all = @('-NoProfile', '-File', $fixtureScript) + $Arguments + @('-DryRun')
    $lines = if ($null -eq $Answers) {
        @(& pwsh @all 2>&1 | ForEach-Object { "$_" })
    } else {
        @($Answers | & pwsh @all 2>&1 | ForEach-Object { "$_" })
    }
    $code = $LASTEXITCODE

    if ($ShowOutput) {
        Write-Host "--- $What ---"
        $lines | ForEach-Object { Write-Host "    $_" }
        Write-Host "    (exit $code)"
    }
    [pscustomobject]@{ Lines = $lines; ExitCode = $code }
}

# The books a run says it would release, in the order it would build them.
function Get-Selection {
    param([string[]]$Lines)
    @($Lines | ForEach-Object { if ($_ -match '^\s+(\S+) -> dist/') { $Matches[1] } })
}

# The menu, one object per numbered row.
function Get-MenuRows {
    param([string[]]$Lines)
    @($Lines | ForEach-Object {
            if ($_ -match '^\s+(\d+)\s\s+(\S+)(\s\*)?\s\s+(\S.*?)\s\s+(\S.*?)\s*$') {
                [pscustomobject]@{
                    Index = [int]$Matches[1]
                    Name  = $Matches[2]
                    Dirty = [bool]$Matches[3]
                    Age   = $Matches[4]
                    Dist  = $Matches[5]
                }
            }
        })
}

function Test-Selection {
    param([string]$What, [string[]]$Expected, [string[]]$Arguments = @(), [string]$Answers, [int]$ExitCode = 0)

    $run = Invoke-Release -What $What -Arguments $Arguments -Answers $Answers
    $got = Get-Selection $run.Lines

    if (($got -join ',') -ne ($Expected -join ',')) {
        Write-Fail "$What selected the wrong books"
        Write-Host "    expected: $(($Expected -join ', '))"
        Write-Host "    actual:   $(($got -join ', '))"
        return $false
    }
    if ($run.ExitCode -ne $ExitCode) {
        Write-Fail "$What exited $($run.ExitCode), expected $ExitCode"
        return $false
    }
    return $true
}

# ---------------------------------------------------------------------------
# The list: what it shows and the order it shows it in
# ---------------------------------------------------------------------------

$menu = Get-MenuRows (Invoke-Release -What 'menu' -Answers '').Lines

if (@($menu.Name) -join ',' -ne ($Order -join ',')) {
    Write-Fail 'the list is not in most-recently-changed-first order'
    Write-Host "    expected: $($Order -join ', ')"
    Write-Host "    actual:   $(@($menu.Name) -join ', ')"
} else {
    Write-Ok "order: $($Order -join ' > '), by last commit and not by name"
}

# One row per dist/ state, because they are what tells someone which book is
# worth the rebuild. 'current' is the one that must not be reported loosely:
# it is the only value that says "do not bother".
$DistExpected = @(
    @{ Name = 'alpha-book'; Like = 'stale*'; Why = 'released, then committed to again' }
    @{ Name = 'gamma-book'; Like = 'current*'; Why = 'released in its own last commit' }
    @{ Name = 'beta-book'; Like = 'never released*'; Why = 'no PDF in dist/' }
)
foreach ($case in $DistExpected) {
    $row = $menu | Where-Object Name -EQ $case.Name
    if (-not $row) {
        Write-Fail "$($case.Name) is missing from the list"
    } elseif ($row.Dist -notlike $case.Like) {
        Write-Fail "$($case.Name) ($($case.Why)) reads '$($row.Dist)', expected '$($case.Like)'"
    }
}
if (-not $failed) { Write-Ok 'dist/: stale, current and never-released each reported' }

# ---------------------------------------------------------------------------
# The answers
# ---------------------------------------------------------------------------

$Cases = @(
    @{ What = 'a single number'; Answers = '2'; Expected = @('gamma-book') }
    @{ What = 'a comma list'; Answers = '1,3'; Expected = @('alpha-book', 'beta-book') }
    @{ What = 'a range'; Answers = '1-2'; Expected = @('alpha-book', 'gamma-book') }
    @{ What = 'a mixed list'; Answers = '3, 1'; Expected = @('alpha-book', 'beta-book') }
    # Two ways to say all of them, and the -All switch, must agree.
    @{ What = "'a'"; Answers = 'a'; Expected = $Order }
    @{ What = "'all'"; Answers = 'all'; Expected = $Order }
    @{ What = '-All'; Arguments = @('-All'); Expected = $Order }
    # A duplicate is a typo, not a request to build twice.
    @{ What = 'a repeated number'; Answers = '2,2,2'; Expected = @('gamma-book') }
    # Selection order follows the list, not the typing order: what gets built
    # has to match the numbers that were on screen.
    @{ What = 'a reversed range'; Answers = '3-1'; Expected = $Order }
    # Cancelling is not a failure, and it must build nothing.
    @{ What = 'a blank answer'; Answers = ''; Expected = @() }
    @{ What = "'q'"; Answers = 'q'; Expected = @() }
    # A wrong answer costs a re-prompt, never a wrong build and never an abort.
    @{ What = 'a word, then a number'; Answers = "zzz`n2"; Expected = @('gamma-book') }
    @{ What = 'an out-of-range number, then a number'; Answers = "9`n2"; Expected = @('gamma-book') }
    @{ What = 'a range running past the end'; Answers = "1-9`n2"; Expected = @('gamma-book') }
    @{ What = 'a bad answer, then cancel'; Answers = "zzz`n"; Expected = @() }
    # By name, which is what a script calling this uses.
    @{ What = 'one book by name'; Arguments = @('beta-book'); Expected = @('beta-book') }
    @{ What = 'two books by name'; Arguments = @('beta-book', 'alpha-book'); Expected = @('alpha-book', 'beta-book') }
    @{ What = '-Book by name'; Arguments = @('-Book', 'gamma-book'); Expected = @('gamma-book') }
    # A name is matched case-insensitively and answered with the folder that
    # exists, so the same command works on a case-insensitive Windows checkout
    # and a case-sensitive one. What must not happen is a run reporting the
    # name as typed while building something else.
    @{ What = 'a name in the wrong case'; Arguments = @('Alpha-Book'); Expected = @('alpha-book') }
)

$passed = 0
foreach ($case in $Cases) {
    $ok = Test-Selection -What $case.What `
        -Expected $case.Expected `
        -Arguments (@($case.Arguments) | Where-Object { $_ }) `
        -Answers $case.Answers
    if ($ok) { $passed++ }
}
if ($passed -eq $Cases.Count) { Write-Ok "answers: $passed forms of selection all resolve as expected" }

# ---------------------------------------------------------------------------
# The refusals
# ---------------------------------------------------------------------------

# A run that cannot do what was asked has to say so and exit non-zero. Exiting
# 0 having built nothing is the failure mode that matters here: a caller reads
# that as a release.
$Refusals = @(
    @{ What = 'an unknown book name'; Arguments = @('no-such-book'); Names = 'no-such-book' }
    @{ What = 'one known and one unknown name'; Arguments = @('alpha-book', 'no-such-book'); Names = 'no-such-book' }
    # A near miss is still a miss. The message has to name what was not found,
    # because "no such book" alone reads like the library is empty.
    @{ What = 'a name missing its suffix'; Arguments = @('alpha'); Names = 'alpha' }
    @{ What = '-All together with a name'; Arguments = @('-All', '-Book', 'alpha-book'); Names = '-All' }
)

foreach ($case in $Refusals) {
    $run = Invoke-Release -What $case.What -Arguments $case.Arguments
    $selected = Get-Selection $run.Lines
    if ($run.ExitCode -eq 0) {
        Write-Fail "$($case.What) exited 0"
    } elseif ($selected.Count) {
        Write-Fail "$($case.What) failed but still resolved a selection: $($selected -join ', ')"
    } elseif (-not @($run.Lines | Where-Object { $_ -like "*$($case.Names)*" })) {
        Write-Fail "$($case.What) failed without naming '$($case.Names)' in the message"
        $run.Lines | ForEach-Object { Write-Host "    actual: $_" }
    }
}
if (-not $failed) { Write-Ok "refusals: $($Refusals.Count) impossible requests each exit non-zero" }

# ---------------------------------------------------------------------------
# Uncommitted work
# ---------------------------------------------------------------------------

# A book with no commit behind it is the newest thing in the list, and a book
# with edits in the working tree is marked, because both change what a release
# of it would contain.
Add-FixtureFile 'books/delta-book/main.tex'
Add-FixtureFile 'books/beta-book/main.tex' 'fixture, edited but not committed'

$dirtyMenu = Get-MenuRows (Invoke-Release -What 'uncommitted' -Answers '').Lines
$DirtyOrder = @('delta-book') + $Order

if (@($dirtyMenu.Name) -join ',' -ne ($DirtyOrder -join ',')) {
    Write-Fail 'a book with no commit yet is not at the top of the list'
    Write-Host "    expected: $($DirtyOrder -join ', ')"
    Write-Host "    actual:   $(@($dirtyMenu.Name) -join ', ')"
} else {
    $marked = @(($dirtyMenu | Where-Object Dirty).Name) | Sort-Object
    if (($marked -join ',') -ne 'beta-book,delta-book') {
        Write-Fail "the working-tree marker is on the wrong rows: $($marked -join ', ')"
    } elseif (($dirtyMenu | Where-Object Name -EQ 'delta-book').Age -ne 'uncommitted') {
        Write-Fail "a book with no commit reads '$(($dirtyMenu | Where-Object Name -EQ 'delta-book').Age)', expected 'uncommitted'"
    } else {
        Write-Ok 'uncommitted: an uncommitted book sorts first, edited books are marked'
    }
}

# It still has to be selectable, and by name as well as by number.
[void](Test-Selection -What 'an uncommitted book by number' -Answers '1' -Expected @('delta-book'))
[void](Test-Selection -What 'an uncommitted book by name' -Arguments @('delta-book') -Expected @('delta-book'))

# ---------------------------------------------------------------------------
# An empty library
# ---------------------------------------------------------------------------

$empty = Join-Path ([System.IO.Path]::GetTempPath()) "latex-books-release-tests-empty-$PID"
New-Item -ItemType Directory -Path (Join-Path $empty 'scripts') -Force | Out-Null
Copy-Item -LiteralPath $release -Destination (Join-Path $empty 'scripts/release.ps1')
try {
    $out = @(& pwsh -NoProfile -File (Join-Path $empty 'scripts/release.ps1') -DryRun 2>&1 | ForEach-Object { "$_" })
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "no books/ at all exited $LASTEXITCODE, expected 0"
        $out | ForEach-Object { Write-Host "    actual: $_" }
    } elseif (-not @($out | Where-Object { $_ -like '*nothing to release*' })) {
        Write-Fail 'no books/ at all did not say there was nothing to release'
        $out | ForEach-Object { Write-Host "    actual: $_" }
    } else {
        Write-Ok 'empty: no books/ at all says so and exits 0, without prompting'
    }
} finally {
    Remove-Item -LiteralPath $empty -Recurse -Force -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------------------

if ($KeepFixture) {
    Write-Host "Fixture left at $fixture"
} else {
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}

if ($failed) {
    Write-Host 'FAILED' -ForegroundColor Red
    exit 1
}
Write-Host 'All release.ps1 tests passed.' -ForegroundColor Green
