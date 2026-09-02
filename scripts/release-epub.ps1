#!/usr/bin/env pwsh
# Rebuild books from scratch and copy the final EPUBs into dist/ (LFS-tracked).
#
# The EPUB sibling of release.ps1: same menu, same selection grammar, same
# dist/ discipline, a different converter underneath. Where release.ps1 runs
# latexmk and produces build/main.pdf, this runs tex4ebook and produces
# build/epub/main.epub.
#
# Usage: pwsh scripts/release-epub.ps1                     # choose from the list
#        pwsh scripts/release-epub.ps1 <name> [<name>...]  # named books, no prompt
#        pwsh scripts/release-epub.ps1 -All                # every book, no prompt
#        pwsh scripts/release-epub.ps1 -All -DryRun        # print the selection only
#
# The selection half of this file - Invoke-Git, Get-LastCommitEpoch,
# Format-Age, Resolve-Selection, Show-Menu and the row building around them -
# is a deliberate copy of release.ps1's, taken so that adding EPUB releases
# could not break the PDF release path or the tests that guard it. That makes
# it the one place in scripts/ where the same logic exists twice, and copies
# drift: a fix to the selection grammar in either file is only half a fix
# until it is applied to the other. Keep them in step, or extract the shared
# half into a scripts/release-common.ps1 that both dot-source, update
# release.tests.ps1's fixture to copy both files, and delete this notice.

[CmdletBinding()]
param(
    # Book folder names, as they appear under books/.
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Book,

    # Every book, without asking.
    [switch]$All,

    # Resolve the selection, print it, build nothing.
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$booksDir = Join-Path $root 'books'

if ($All -and $Book) {
    Write-Error '-All releases everything; passing book names as well is contradictory. Use one or the other.'
}

$folders = @(Get-ChildItem $booksDir -Directory -ErrorAction SilentlyContinue)
if (-not $folders) {
    Write-Host 'No books under books/ yet - nothing to release.'
    exit 0
}

# ---------------------------------------------------------------------------
# What the list knows about each book
# ---------------------------------------------------------------------------

# Recency and the dist/ column both come from git rather than from file
# timestamps: a fresh clone stamps every file with the clone time, which would
# order the list at random and call every released EPUB current.
$hasGit = [bool](Get-Command git -ErrorAction SilentlyContinue)

function Invoke-Git {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$GitArgs)

    if (-not $hasGit) { return $null }
    # Function-scoped, so it lapses on return: a git call that exits non-zero
    # here (a repo with no commits, a path git has never seen) is an answer,
    # not a terminating error.
    $PSNativeCommandUseErrorActionPreference = $false
    & git -C $root @GitArgs 2>$null
}

# Commit time of the newest commit touching a path, or $null if git has never
# recorded one - a book drafted but not yet committed, an EPUB not yet released.
function Get-LastCommitEpoch {
    param([string]$PathSpec)

    $out = Invoke-Git log -1 --format=%ct -- $PathSpec
    $line = @($out) | Where-Object { $_ } | Select-Object -First 1
    if (-not $line) { return $null }
    [long]$line
}

function Format-Age {
    param($Epoch)

    if ($null -eq $Epoch) { return '-' }
    $span = (Get-Date) - [DateTimeOffset]::FromUnixTimeSeconds($Epoch).LocalDateTime
    if ($span.TotalMinutes -lt 1) { return 'just now' }
    if ($span.TotalHours -lt 1) { return '{0}m ago' -f [int]$span.TotalMinutes }
    if ($span.TotalDays -lt 1) { return '{0}h ago' -f [int]$span.TotalHours }
    if ($span.TotalDays -lt 90) { return '{0}d ago' -f [int]$span.TotalDays }
    [DateTimeOffset]::FromUnixTimeSeconds($Epoch).LocalDateTime.ToString('yyyy-MM-dd')
}

$rows = @(foreach ($folder in $folders) {
        $name = $folder.Name
        $changed = Get-LastCommitEpoch "books/$name"
        $released = Get-LastCommitEpoch "dist/$name.epub"
        $distPath = Join-Path $root "dist/$name.epub"

        $dist =
        if (-not (Test-Path -LiteralPath $distPath)) { 'never released' }
        elseif ($null -eq $released) { 'released, not committed' }
        elseif ($null -eq $changed -or $released -lt $changed) { 'stale (released {0})' -f (Format-Age $released) }
        else { 'current ({0})' -f (Format-Age $released) }

        [pscustomobject]@{
            Name    = $name
            Path    = $folder.FullName
            Age     = if ($hasGit -and $null -eq $changed) { 'uncommitted' } else { Format-Age $changed }
            Dirty   = [bool](Invoke-Git status --porcelain -- "books/$name")
            Dist    = $dist
            # A book with no commit yet is the most recent thing there is.
            SortKey = if ($null -eq $changed) { [long]::MaxValue } else { $changed }
        }
    })

# Newest first, name as the tie-break so the numbering is stable between runs.
$rows = @($rows | Sort-Object @{ Expression = 'SortKey'; Descending = $true }, @{ Expression = 'Name'; Descending = $false })

# ---------------------------------------------------------------------------
# Choosing
# ---------------------------------------------------------------------------

# One answer to the prompt, turned into positions in $rows. Returns an Action
# of 'select', 'cancel' or 'invalid'; 'invalid' carries the reason and the
# caller asks again rather than aborting a release over a typo.
#
# Books are picked by number only. That is what keeps 'a' free to mean all of
# them without colliding with a book whose name starts with an a.
function Resolve-Selection {
    param(
        [string]$Answer,
        [int]$Count
    )

    function New-Result {
        param([string]$Action, [int[]]$Indexes = @(), [string]$Reason)
        [pscustomobject]@{ Action = $Action; Indexes = $Indexes; Reason = $Reason }
    }

    $text = "$Answer".Trim()
    if ($text -eq '' -or $text -in @('q', 'quit')) { return New-Result 'cancel' }
    if ($text -in @('a', 'all')) { return New-Result 'select' @(1..$Count) }

    $picked = [System.Collections.Generic.List[int]]::new()
    foreach ($token in @($text -split '[,\s]+' | Where-Object { $_ -ne '' })) {
        if ($token -match '^([0-9]+)-([0-9]+)$') {
            $from = [int]$Matches[1]
            $to = [int]$Matches[2]
            if ($from -lt 1 -or $to -lt 1 -or $from -gt $Count -or $to -gt $Count) {
                return New-Result 'invalid' -Reason "no such book in '$token' - the list has $Count"
            }
            $span = if ($from -le $to) { $from..$to } else { $to..$from }
            foreach ($i in $span) { if (-not $picked.Contains($i)) { $picked.Add($i) } }
        }
        elseif ($token -match '^[0-9]+$') {
            $i = [int]$token
            if ($i -lt 1 -or $i -gt $Count) {
                return New-Result 'invalid' -Reason "no such book: $i - the list has $Count"
            }
            if (-not $picked.Contains($i)) { $picked.Add($i) }
        }
        else {
            return New-Result 'invalid' -Reason "not a number: '$token'"
        }
    }

    # Sorted, so what gets built follows the list people read the numbers off
    # rather than the order they happened to type them in. '3, 1' and '1, 3'
    # are the same request.
    New-Result 'select' @($picked | Sort-Object)
}

function Show-Menu {
    param($Rows)

    function Get-Width {
        param([string[]]$Values)
        (@($Values | ForEach-Object { "$_".Length }) | Measure-Object -Maximum).Maximum
    }

    # The headers are part of the widest-cell measurement, or a column of short
    # values sits under a wider heading and the columns stop lining up.
    # The name column carries +2 for the dirty marker.
    $numWidth = Get-Width @('#', "$($Rows.Count)")
    $nameWidth = (Get-Width (@($Rows.Name) + 'Book')) + 2
    $ageWidth = Get-Width (@($Rows.Age) + 'Last change')
    $format = "  {0,$numWidth}  {1,-$nameWidth}  {2,-$ageWidth}  {3}"

    Write-Host ''
    Write-Host 'Books, most recently changed first:'
    Write-Host ''
    Write-Host ($format -f '#', 'Book', 'Last change', 'dist/ (epub)')
    for ($i = 0; $i -lt $Rows.Count; $i++) {
        $row = $Rows[$i]
        $label = if ($row.Dirty) { "$($row.Name) *" } else { $row.Name }
        Write-Host ($format -f ($i + 1), $label, $row.Age, $row.Dist)
    }
    if ($Rows | Where-Object Dirty) {
        Write-Host ''
        Write-Host '  * uncommitted changes in the working tree' -ForegroundColor Yellow
    }
    Write-Host ''
}

if ($All) {
    $selected = $rows
}
elseif ($Book) {
    # A PowerShell hashtable matches keys case-insensitively, which is wanted
    # here: the name is resolved to the folder that exists and the run then
    # reports that folder, so -Book Alpha-Book behaves the same on a
    # case-insensitive Windows checkout and a case-sensitive one.
    $byName = @{}
    foreach ($row in $rows) { $byName[$row.Name] = $row }

    $unknown = @($Book | Where-Object { -not $byName.ContainsKey($_) })
    if ($unknown) {
        # The list goes out separately: Write-Error renders a multi-line
        # message as one run-on line wrapped in its own source excerpt.
        Write-Host ("Books under books/: {0}" -f (@($rows.Name | Sort-Object) -join ', '))
        Write-Error ("No such book: {0}" -f ($unknown -join ', '))
    }

    # Keep list order, not the order they were typed, so the build order and
    # the numbering people saw in the menu agree. Duplicates collapse.
    $wanted = [System.Collections.Generic.HashSet[string]]::new([string[]]@($Book | ForEach-Object { $byName[$_].Name }))
    $selected = @($rows | Where-Object { $wanted.Contains($_.Name) })
}
else {
    Show-Menu $rows
    $selected = $null
    while ($null -eq $selected) {
        # At EOF - a caller that redirected stdin and passed no names - this
        # comes back empty, which cancels. Nothing here waits forever.
        $answer = Read-Host 'Release which? (1,3 / 1-3 / a=all / empty=cancel)'
        $choice = Resolve-Selection -Answer $answer -Count $rows.Count

        switch ($choice.Action) {
            'cancel' {
                Write-Host 'Nothing selected - nothing built.'
                if ([Console]::IsInputRedirected) {
                    Write-Host 'Pass book names or -All when running this without a terminal.'
                }
                exit 0
            }
            'invalid' {
                Write-Host "  $($choice.Reason)" -ForegroundColor Yellow
            }
            'select' {
                $selected = @($choice.Indexes | ForEach-Object { $rows[$_ - 1] })
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Building
# ---------------------------------------------------------------------------

if ($DryRun) {
    Write-Host "Would release (dry run), $($selected.Count) of $($rows.Count):"
    foreach ($row in $selected) {
        Write-Host "  $($row.Name) -> dist/$($row.Name).epub"
    }
    exit 0
}

if (-not (Get-Command tex4ebook -ErrorAction SilentlyContinue)) {
    Write-Error 'tex4ebook is not on PATH. It ships with both TeX Live and MiKTeX; install it before releasing an EPUB.'
}

# Two external tools decide whether the result is a valid EPUB or merely a
# zip file that opens. Neither ships with a TeX distribution, so neither can
# be required - but a release that skipped a validation step says so rather
# than passing quietly.
#
# tidy      tex4ebook's own packer calls it to clean the generated XHTML, and
#           warns "you should install it in order to make valid epub file"
#           when it is missing. Observed missing on a stock MiKTeX install.
# epubcheck the only thing here that reads the finished file the way a store
#           will. When it is present a rejection stops the release.
$missingTools = @()
if (-not (Get-Command tidy -ErrorAction SilentlyContinue)) {
    $missingTools += 'tidy (tex4ebook cleans its XHTML with it; without it the EPUB may not validate)'
}
$epubcheck = Get-Command epubcheck -ErrorAction SilentlyContinue
if (-not $epubcheck) {
    $missingTools += 'epubcheck (the EPUBs will be built but never validated)'
}
foreach ($tool in $missingTools) {
    Write-Host "Not on PATH: $tool" -ForegroundColor Yellow
}

Write-Host "Releasing $($selected.Count) of $($rows.Count) book(s): $(@($selected.Name) -join ', ')"

$updated = [System.Collections.Generic.List[string]]::new()
try {
    foreach ($row in $selected) {
        Write-Host "==> Building $($row.Name)"

        # \includeonly is a drafting aid that silently drops chapters, and a
        # book left with it uncommented still builds a well-formed EPUB - one
        # holding a single chapter. A PDF at least gives that away by its page
        # count on the way past; an EPUB has no page count to notice.
        $mainTex = Join-Path $row.Path 'main.tex'
        $activeIncludeOnly = @(Get-Content -LiteralPath $mainTex | Where-Object { $_ -match '^\s*\\includeonly' })
        if ($activeIncludeOnly) {
            throw "$($row.Name): \includeonly is active in main.tex - comment it out before a release build."
        }

        # The from-scratch guarantee, and this script's equivalent of the
        # latexmk -gg in release.ps1: tex4ebook carries .4ct/.4tc/.xref state
        # and cached figures across runs, which is what makes drafting fast
        # and a release unreliable.
        $workDir = Join-Path $row.Path 'build/epub-work'
        $outDir = Join-Path $row.Path 'build/epub'
        foreach ($dir in @($workDir, $outDir)) {
            if (Test-Path -LiteralPath $dir) { Remove-Item -LiteralPath $dir -Recurse -Force }
        }

        Push-Location $row.Path
        try {
            # A book may ship its own make4ht build file: dvisvgm settings for
            # its TikZ figures, a domfilter for its listings, its own CSS. The
            # same split as check-chapter.psd1 - the script is shared, the
            # policy is the book's. A book without one gets the defaults.
            $buildFile = @()
            if (Test-Path -LiteralPath (Join-Path $row.Path 'epub.mk4')) {
                $buildFile = @('-e', 'epub.mk4')
                Write-Host "    using this book's epub.mk4"
            }

            # -f epub3  EPUB 3, the only output format with MathML and modern CSS
            # -l        lualatex, because every book in this repo is LuaLaTeX
            # -s        shell escape, required by minted (Pygments is a subprocess)
            # -B/-d     every generated file under build/, which is gitignored;
            #           without them tex4ebook leaves .4ct, .4tc, .lg, .idv,
            #           .xref, .css, .xhtml and its figures in the book root,
            #           where .gitignore does not cover a single one of them
            $texArgs = @('-f', 'epub3', '-l', '-s', '-B', 'build/epub-work', '-d', 'build/epub') + $buildFile + @('main.tex')

            # minted v3 auto-detects its output directory on TeX Live 2024+ but
            # not on MiKTeX, exactly as each book's .latexmkrc already notes.
            # tex4ebook does not read .latexmkrc, so the variable is set again
            # here, pointing at the directory tex4ebook actually compiles in.
            $previousOutputDirectory = $env:TEXMF_OUTPUT_DIRECTORY
            $env:TEXMF_OUTPUT_DIRECTORY = $workDir
            try {
                tex4ebook @texArgs
            }
            finally {
                $env:TEXMF_OUTPUT_DIRECTORY = $previousOutputDirectory
            }

            if ($LASTEXITCODE -ne 0) {
                throw "tex4ebook failed for $($row.Name)"
            }
        }
        finally {
            Pop-Location
        }

        $epub = Join-Path $outDir 'main.epub'
        if (-not (Test-Path -LiteralPath $epub)) {
            throw "No EPUB produced for $($row.Name)"
        }

        if ($epubcheck) {
            Write-Host "    validating $($row.Name)"
            & $epubcheck.Source $epub
            if ($LASTEXITCODE -ne 0) {
                throw "epubcheck rejected $($row.Name) - dist/ left untouched."
            }
        }

        Copy-Item -LiteralPath $epub -Destination (Join-Path $root "dist/$($row.Name).epub") -Force
        $updated.Add($row.Name)
        Write-Host "==> dist/$($row.Name).epub updated"
    }
}
catch {
    # A selection of several stops at the first failure, and what already
    # landed in dist/ is committable work: say so rather than leaving it to be
    # discovered in git status.
    if ($updated.Count) {
        Write-Host "Stopped after a failure. Already updated: $(@($updated) -join ', ')" -ForegroundColor Yellow
    }
    throw
}

Write-Host "Release build complete: $(@($updated) -join ', '). Review and commit the dist/ changes."
