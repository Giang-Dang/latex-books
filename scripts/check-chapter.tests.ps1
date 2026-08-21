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

# Invoke-Checker keeps only the finding lines and throws the exit code away,
# which is the whole output when the run fails on the policy rather than on the
# prose. This returns both, and takes the extra arguments the -Chapter mode
# needs.
function Invoke-CheckerRaw {
    param([string]$Fixture, [string[]]$ExtraArgs = @())

    $lines = @(& pwsh -NoProfile -File $checker $Fixture @ExtraArgs 2>&1 | ForEach-Object { "$_" })
    return [pscustomobject]@{ Lines = $lines; ExitCode = $LASTEXITCODE }
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
    # 60, not any real book's number: the fixture is not typeset and has no
    # measure. It only has to be a budget the trigger clears and the listing in
    # 08-verbatim.tex, whose widest body line is 37, does not.
    Listings     = "@{ Enabled = `$true; MaxLineLength = 60 }"
    # The glossary and the two headings that carve it up. Both patterns are
    # book facts in a real book, written in the book's own language, which is
    # why the library cannot default them.
    Gloss        = "@{ Enabled = `$true; Glossary = 'backmatter/appendix-b.tex'; " +
                   "BlockPattern = '\\textbf\{Chapter\s+(\d+)\}'; KeepPattern = '\\textbf\{Keep' }"
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
#
# 03-quoting.tex is listed twice on purpose. Line 4 is a plain literal quote
# and line 11 is a line break followed by one; between them sit two accented
# names, \"u and \"{o}, which must stay silent. A fix that stops reading an
# accent macro as a quotation mark can overshoot into swallowing line 11, so
# both ends of that behaviour are pinned here.
$Expected = @(
    "chapters/01-triggers/02-citations.tex:4: [tilde-cite] use a non-breaking tie: ~\autocite{...}"
    "chapters/01-triggers/02-citations.tex:8: [cite-key] citation key 'missingkey' not found in refs.bib"
    "chapters/01-triggers/03-quoting.tex:4: [quote] literal double quote in prose; use \enquote{...}"
    "chapters/01-triggers/03-quoting.tex:11: [quote] literal double quote in prose; use \enquote{...}"
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
    # Exactly one line of that file may be reported. The other body line is 20
    # columns, the \begin and \end lines are not measured at all, and the second
    # block is the same width but carries its own option list, so it is waived.
    "chapters/01-triggers/10-listings.tex:11: [listing] listing line is 78 columns against a budget of 60; it will wrap or overflow the measure"
    # A commented-out \begin used to open a listing region that nothing closed,
    # and everything below it went silent. So the assertion is a finding that
    # has to survive: a regression takes this line away rather than adding one.
    "chapters/01-triggers/11-commented-begin.tex:9: [quote] literal double quote in prose; use \enquote{...}"
    # In a subfolder, so it is only reached when the walk recurses. The full
    # path always did; -Chapter did not, and -Chapter is the mode a drafting
    # session iterates with. The group below runs that mode and looks for this.
    # Three ways to write an alias where a lexer goes, and all three fail the
    # build identically: bare, behind an option list, and opened and closed on
    # one line. That last one is why the check sits before the single-line
    # guard rather than inside it. The three blocks below them in the fixture
    # are the negative cases - the alias used as the environment it is, the
    # real lexer it borrows, and an option list in front of a lexer that is not
    # an alias - and a regression there adds a line rather than taking one away.
    "chapters/01-triggers/14-minted-alias.tex:9: [minted-alias] 'fixturesdl' is an environment this book declares with \newminted, not a Pygments lexer; write \begin{fixturesdl} instead"
    "chapters/01-triggers/14-minted-alias.tex:15: [minted-alias] 'fixturesdl' is an environment this book declares with \newminted, not a Pygments lexer; write \begin{fixturesdl} instead"
    "chapters/01-triggers/14-minted-alias.tex:20: [minted-alias] 'fixturesdl' is an environment this book declares with \newminted, not a Pygments lexer; write \begin{fixturesdl} instead"
    # Both halves of one hand-wrapped response: the line that opens the string
    # and the line that closes it, because each leaves a string open at its own
    # end. Everything else in that file is a negative case and a regression
    # there adds a line rather than taking one away - a config fragment that
    # never parses on its own, an elision, a value carrying escaped quotes and
    # a trailing escaped backslash, and the same defect in a text listing,
    # which is not an environment this book nominated as holding JSON.
    "chapters/01-triggers/15-json.tex:9: [json] a JSON string opens on this line and does not close on it; a raw newline inside a string is invalid JSON, so break between tokens instead, or let the listing wrap on its own"
    "chapters/01-triggers/15-json.tex:10: [json] a JSON string opens on this line and does not close on it; a raw newline inside a string is invalid JSON, so break between tokens instead, or let the listing wrap on its own"
    "chapters/01-triggers/nested/01-nested.tex:4: [dash] en/em dash ligature in prose; reword or use ASCII punctuation"
    # The gloss family runs as its own pass after the line-at-a-time loop, so
    # its findings arrive together and sorted by file and line rather than
    # interleaved with the ones above.
    #
    # 13-gloss.tex's first section is the negative case and is absent on
    # purpose: it names 'gear box' only inside an \index entry, and an index
    # entry is markup rather than running text. A regression there adds a line.
    "chapters/01-triggers/13-gloss.tex:17: [gloss-repeat] 'widget' is glossed 2 times in one section; the cadence is once"
    "chapters/01-triggers/13-gloss.tex:20: [gloss-orphan] 'cog' is in no glossary block; add it, or drop the gloss"
    "chapters/01-triggers/13-gloss.tex:21: [gloss-orphan] 'flange' is on the keep-as-is list, so the gloss sets it beside itself"
    "chapters/01-triggers/13-gloss.tex:23: [gloss-borrowed] 'sprocket' belongs to chapter 2 and this chapter never glosses it; a term this chapter does not own is glossed once"
    # Line 27, not 26: the term is split as 'gear' / 'box' across two source
    # lines and only shows up once the section is flattened. The finding is
    # anchored where the match lands, which is the second half.
    "chapters/01-triggers/13-gloss.tex:27: [gloss-missing] 'gear box' is this chapter's own term and this section never glosses it"
    # One line out of a picture that also grids on step=0.5cm, scales a node,
    # sets text=gray and names a style with a space in it. Exactly one of those
    # is a style declaration using a reserved name.
    "figures/tikz/12-reserved-key.tex:12: [tikz] style name 'step' is a pgfkeys key already; the picture will fail to compile with an error naming the key rather than the style"
    # The other half of that file: one node whose text sets an en dash, out of
    # a picture that also draws six `--` path segments and a node containing an
    # ASCII hyphen. TikZ path syntax is why these files are outside the prose
    # dash check in the first place, so a node-text pass that read paths would
    # report every segment and the exclusion would have bought nothing.
    "figures/tikz/12-reserved-key.tex:32: [tikz-dash] en/em dash ligature in node text; figure sources sit outside the prose dash check, so this is the only pass that reads them"
    # Line 38 is the case a line-at-a-time scan cannot see: the \node on one
    # line and its braced text on the next, which is how every label long
    # enough to want an en dash is actually written, and which is why this
    # family missed two real dashes in a drafted book until the scan was made
    # file-scoped. Line 42 is the other half of the same rewrite: the label
    # carries braces of its own and the dash is past them, so the non-greedy
    # group the old version used stopped short and never read it.
    "figures/tikz/12-reserved-key.tex:38: [tikz-dash] en/em dash ligature in node text; figure sources sit outside the prose dash check, so this is the only pass that reads them"
    "figures/tikz/12-reserved-key.tex:42: [tikz-dash] en/em dash ligature in node text; figure sources sit outside the prose dash check, so this is the only pass that reads them"
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
# letters of any script pass, spelling has no variety to enforce, whether
# contractions belong in the voice is left to the book, and no column budget has
# been declared, so the listing-width check does not run either.
$DefaultIds = @('cite-key', 'dash', 'index-pct', 'json', 'log', 'number', 'quote', 'tikz', 'tikz-dash', 'tilde-cite', 'verbatim')
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
    # Two ways to switch the width check off, and both have to work. Neither row
    # gets the other half for free the way Figures does: the budget defaults to
    # 0, so a row naming only Enabled would silence the family for the wrong
    # reason and pass even if Enabled were wired to nothing.
    @{ Name = 'Listings';     Override = @{ Listings = '@{ Enabled = $false; MaxLineLength = 60 }' }; Silences = @('listing', 'minted-alias') }
    @{ Name = 'Listings.Max'; Override = @{ Listings = '@{ Enabled = $true; MaxLineLength = 0 }' };   Silences = @('listing') }
    # The family's second check has its own switch, and the two rows above and
    # below pin the boundary between them: Enabled off takes both, MaxLineLength
    # takes only the width one, and this takes only the alias one.
    @{ Name = 'Listings.Alias'; Override = @{ Listings = '@{ Enabled = $true; MaxLineLength = 60; AliasAsLexer = $false }' }
       Silences = @('minted-alias') }
    # Two ways off again, and for the same reason as Listings: the glossary path
    # defaults to empty, so a row naming only Enabled would silence the family
    # whether or not Enabled is wired to anything.
    @{ Name = 'Gloss';        Override = @{ Gloss = '@{ Enabled = $false; Glossary = ''backmatter/appendix-b.tex'' }' }
       Silences = @('gloss-borrowed', 'gloss-missing', 'gloss-orphan', 'gloss-repeat') }
    @{ Name = 'Gloss.File';   Override = @{ Gloss = '@{ Enabled = $true; Glossary = '''' }' }
       Silences = @('gloss-borrowed', 'gloss-missing', 'gloss-orphan', 'gloss-repeat') }
    # Exempt is the escape hatch for a term that is also an ordinary word, so it
    # has to reach the check. 'gear box' is the fixture's only gloss-missing.
    @{ Name = 'Gloss.Exempt'; Override = @{ Gloss = '@{ Glossary = ''backmatter/appendix-b.tex''; BlockPattern = ''\\textbf\{Chapter\s+(\d+)\}''; KeepPattern = ''\\textbf\{Keep''; Exempt = @(''gear box'') }' }
       Silences = @('gloss-missing') }
    @{ Name = 'Figures';      Override = @{ Figures = '@{ Enabled = $false }' };           Silences = @('tikz', 'tikz-dash') }
    # Emptying the reserved list is the other way to turn it off, and it has to
    # work: a book that disagrees with one name should not have to disable the
    # family to say so. It must not take the node-text check with it, which is
    # the regression this row exists to catch: the loop used to be gated on the
    # key list alone, so a book with no reserved keys would have stopped
    # reading its figures for dashes as well.
    @{ Name = 'Figures.Keys'; Override = @{ Figures = '@{ ReservedKeys = @() }' };         Silences = @('tikz') }
    @{ Name = 'Figures.Text'; Override = @{ Figures = '@{ NodeText = $false }' };          Silences = @('tikz-dash') }
    @{ Name = 'Log';          Override = @{ Log = '@{ Enabled = $false }' };               Silences = @('log') }
    # Paths.Prose empties the prose pass. The character scan reads its own list
    # and must survive, which is what keeps the two lists genuinely separate.
    # The gloss family reads the same file list, so emptying Prose empties it
    # too. Worth asserting rather than assuming: the glossary itself is found
    # by its own path, and a family that kept reading files nobody asked it to
    # read would look like it still worked.
    @{ Name = 'Paths.Prose';  Override = @{ Paths = '@{ Prose = @() }' }
       Silences = @('tilde-cite', 'cite-key', 'quote', 'index-pct', 'contraction',
                    'spelling', 'dash', 'number', 'verbatim', 'listing', 'minted-alias',
                    'json', 'gloss-borrowed', 'gloss-missing', 'gloss-orphan', 'gloss-repeat') }
    @{ Name = 'Json';         Override = @{ Json = '@{ Enabled = $false }' };            Silences = @('json') }
    @{ Name = 'Json.Envs';    Override = @{ Json = '@{ Environments = @() }' };          Silences = @('json') }
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
# The schema rejects a setting whose type is wrong
# ---------------------------------------------------------------------------

# Test-PolicySchema branched on tables, arrays and bools and nothing else, so
# every count the library takes - the two Verbatim windows, the two Log
# ceilings, the Listings budget - accepted a word, passed the policy line, and
# then threw somewhere in the middle of the run on a comparison, in a message
# naming a variable. The failure belongs on the policy, and it has to say which
# key is wrong.
Set-Content -LiteralPath $bookPolicy -Encoding utf8 -Value (New-BookConfig @{ Verbatim = "@{ Window = 'six' }" })
try {
    $bad = Invoke-CheckerRaw $bookFix
    if ($bad.ExitCode -eq 0) {
        Write-Fail 'a word where Verbatim.Window wants a count did not fail the run'
    } elseif (@($bad.Lines | Where-Object { $_ -like '*Verbatim.Window*' }).Count -eq 0) {
        Write-Fail 'the run failed, but the message did not name Verbatim.Window'
        $bad.Lines | ForEach-Object { Write-Host "    actual: $_" }
    } else {
        Write-Host '[ok]   schema: a count written as a word fails the run and names its key'
    }
} finally {
    Remove-Item -LiteralPath $bookPolicy -Force -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------------------
# -Chapter, the mode a drafting session actually runs
# ---------------------------------------------------------------------------

# Everything above runs the whole book. -Chapter walks one folder, and it walked
# it without -Recurse, so a chapter keeping a section in a subfolder was linted
# by one mode and not the other. Nothing in either book has a subfolder today,
# which is exactly why nobody noticed.
Set-Content -LiteralPath $bookPolicy -Encoding utf8 -Value (New-BookConfig @{})
try {
    $scoped = Invoke-CheckerRaw $bookFix @('-Chapter', '01')
    $nested = @($scoped.Lines | Where-Object { $_ -like '*nested/01-nested.tex*' -or $_ -like '*nested\01-nested.tex*' })
    if ($nested.Count -ne 1) {
        Write-Fail '-Chapter 01 did not reach the section in a subfolder'
        $scoped.Lines | ForEach-Object { Write-Host "    actual: $_" }
    } else {
        Write-Host '[ok]   chapter: -Chapter recurses, and reaches a section in a subfolder'
    }
} finally {
    Remove-Item -LiteralPath $bookPolicy -Force -ErrorAction SilentlyContinue
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

# ---------------------------------------------------------------------------
# The psd1 files still document the schema they claim to
# ---------------------------------------------------------------------------

# template/check-chapter.psd1 says of itself that the commented block is the
# schema: "Every key check-chapter.ps1 accepts appears below, in the sections
# and the order the script defines them." Nothing held it to that, and it was
# false for two families - Figures and Characters.AllowInCapturedListings - from
# the day the figures check landed. A book cannot set what it cannot find, so a
# family missing from that block is a family nobody uses.
#
# Read from the source rather than from a copy of it: the AST gives the keys
# Get-DefaultPolicy actually declares, so this cannot drift the way a hand-kept
# list would.
function Get-HashtableKeys {
    param([System.Management.Automation.Language.Ast]$Node)

    $ht = $Node.Find({ param($n) $n -is [System.Management.Automation.Language.HashtableAst] }, $true)
    if (-not $ht) { return @() }
    return @($ht.KeyValuePairs | ForEach-Object { $_.Item1.Value })
}

function Get-DocumentedSchema {
    param([string]$Path)

    $lines = [System.IO.File]::ReadAllLines($Path)
    $order = @()
    $keys = @{}

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -notmatch '^\s*#\s*--\s*(\d+)\.\s*(\w+)') { continue }
        $name = $Matches[2]
        $order += [pscustomobject]@{ Number = [int]$Matches[1]; Name = $name }

        # The block from '# <Name> = ' to the line that balances its braces.
        # Strip one level of comment and what is left is PowerShell, because the
        # prose inside these blocks is written as a nested comment - which is
        # also why the brace count skips any line that is still a comment after
        # stripping, and why Spelling's Extra = @{} does not end the block early.
        $block = @()
        $started = $false
        $depth = 0
        for ($j = $i + 1; $j -lt $lines.Count; $j++) {
            if ($lines[$j] -match '^\s*#\s*--\s*\d+\.') { break }
            if (-not $started) {
                if ($lines[$j] -match ('^\s*#\s' + [regex]::Escape($name) + '\s*=')) { $started = $true }
                else { continue }
            }
            if ($lines[$j] -notmatch '^\s*#') { break }
            $line = $lines[$j] -replace '^(\s*)#\s?', '$1'
            $block += $line
            if ($line -match '^\s*#') { continue }
            $depth += ([regex]::Matches($line, '\{')).Count - ([regex]::Matches($line, '\}')).Count
            if ($depth -le 0) { break }
        }

        if (-not $started) { $keys[$name] = $null; continue }

        $t = $null; $e = $null
        $blockAst = [System.Management.Automation.Language.Parser]::ParseInput(
            ($block -join [Environment]::NewLine), [ref]$t, [ref]$e)
        $keys[$name] = if ($e.Count) { $null } else { Get-HashtableKeys $blockAst }
    }
    return [pscustomobject]@{ Order = $order; Keys = $keys }
}

$repoRoot = Split-Path -Parent $PSScriptRoot

$t = $null; $e = $null
$scriptAst = [System.Management.Automation.Language.Parser]::ParseFile($checker, [ref]$t, [ref]$e)
$policyFn = $scriptAst.Find({ param($n)
        $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
        $n.Name -eq 'Get-DefaultPolicy' }, $true)
$policyHt = $policyFn.Find({ param($n) $n -is [System.Management.Automation.Language.HashtableAst] }, $true)

$Families = [ordered]@{}
foreach ($kv in $policyHt.KeyValuePairs) { $Families[$kv.Item1.Value] = Get-HashtableKeys $kv.Item2 }

# The template is the schema by declaration. A book's copy is checked only if it
# carries the block at all: a psd1 written as differences-only, with no banners,
# is a legitimate second shape and is not being asked to grow one.
$schemaFiles = @(Join-Path $repoRoot 'template' 'check-chapter.psd1') +
    @(Get-ChildItem (Join-Path $repoRoot 'books') -Directory |
        ForEach-Object { Join-Path $_.FullName 'check-chapter.psd1' } |
        Where-Object { Test-Path -LiteralPath $_ })

$checkedSchemas = 0
foreach ($path in $schemaFiles) {
    $rel = $path.Substring($repoRoot.Length + 1) -replace '\\', '/'
    $doc = Get-DocumentedSchema $path
    if ($doc.Order.Count -eq 0) { continue }
    $checkedSchemas++

    $wantOrder = @($Families.Keys | ForEach-Object { $_ })
    $gotOrder = @($doc.Order | ForEach-Object { $_.Name })
    if (($wantOrder -join ',') -ne ($gotOrder -join ',')) {
        Write-Fail "$rel does not document the families the script defines, in order"
        Write-Host "    expected: $($wantOrder -join ', ')"
        Write-Host "    actual:   $($gotOrder -join ', ')"
        continue
    }

    $badNumber = @($doc.Order | Where-Object { $_.Number -ne ($doc.Order.IndexOf($_) + 1) })
    if ($badNumber) {
        Write-Fail "$rel numbers its sections out of step: $(($doc.Order | ForEach-Object { "$($_.Number). $($_.Name)" }) -join ', ')"
        continue
    }

    foreach ($family in $Families.Keys) {
        $want = @($Families[$family]) | Sort-Object
        $got = $doc.Keys[$family]
        if ($null -eq $got) {
            Write-Fail "$rel section '$family' has no readable settings block"
        } elseif ((@($got | Sort-Object) -join ',') -ne ($want -join ',')) {
            Write-Fail "$rel documents the wrong settings under '$family'"
            Write-Host "    expected: $($want -join ', ')"
            Write-Host "    actual:   $(@($got | Sort-Object) -join ', ')"
        }
    }
}

if (-not $failed) {
    Write-Host "[ok]   schema: $checkedSchemas psd1 file(s) document all $($Families.Count) families and their settings"
}

Write-Host ''
if ($failed) {
    Write-Host 'FAIL' -ForegroundColor Red
    exit 1
}
Write-Host 'PASS' -ForegroundColor Green
exit 0
