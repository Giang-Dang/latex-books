#!/usr/bin/env pwsh
# Deterministic lint gate for one book's prose: the machine half of the
# draft-chapter build gate. Checks bytes, citation ties and keys, quoting,
# index termination, contractions, spellings, dashes, measured-number
# provenance, verbatim-capture claims, and the build log.
# Usage: pwsh scripts/check-chapter.ps1 books/<name> [-Chapter NN]

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

# --- file set: prose sources only. figures/tikz/ is excluded (TikZ -- path
# syntax) and preamble/ is excluded (macro code, not prose).
$texFiles = @()
if ($Chapter) {
    $chapterDirs = @(Get-ChildItem (Join-Path $bookPath 'chapters') -Directory -Filter "$Chapter-*")
    if ($chapterDirs.Count -eq 0) {
        Write-Error "No folder matches chapters/$Chapter-* under '$Book'"
    }
    $texFiles = @($chapterDirs | Get-ChildItem -Filter '*.tex' | Sort-Object FullName)
} else {
    foreach ($part in 'chapters', 'frontmatter', 'backmatter') {
        $p = Join-Path $bookPath $part
        if (Test-Path $p) {
            $texFiles += @(Get-ChildItem $p -Recurse -Filter '*.tex' | Sort-Object FullName)
        }
    }
}

# --- verbatim environments: the stock ones plus any the book declares with
# \newminted[NAME]{lexer}{opts} in its preamble (e.g. graphqlsdl).
$verbatimEnvs = @('minted', 'verbatim', 'Verbatim')
$preambleDir = Join-Path $bookPath 'preamble'
if (Test-Path $preambleDir) {
    foreach ($f in Get-ChildItem $preambleDir -Filter '*.tex') {
        foreach ($m in [regex]::Matches((Get-Content $f.FullName -Raw), '\\newminted\[([A-Za-z]+)\]')) {
            $verbatimEnvs += $m.Groups[1].Value
        }
    }
}

# --- research notes, as one blob. A book without a research/ folder simply
# skips the number check rather than failing every number in it.
$researchText = ''
$researchDir = Join-Path $bookPath 'research'
if (Test-Path $researchDir) {
    $researchFiles = @(Get-ChildItem $researchDir -Filter '*.md' -File)
    if ($researchFiles.Count -gt 0) {
        $researchText = ($researchFiles | ForEach-Object {
                [System.IO.File]::ReadAllText($_.FullName)
            }) -join "`n"
    }
}

# --- research notes again, as one whitespace-collapsed blob. The verbatim
# check below matches a listing line against this rather than against lines,
# so that a capture re-wrapped for the page still traces to the note it came
# from. Built once; it is the whole research folder and rebuilding it per line
# would dominate the run.
$researchBlob = if ($researchText) { $researchText -replace '\s+', ' ' } else { '' }

# --- bibliography keys
$bibKeys = [System.Collections.Generic.HashSet[string]]::new()
$bibPath = Join-Path $bookPath 'refs.bib'
if (Test-Path $bibPath) {
    foreach ($m in [regex]::Matches((Get-Content $bibPath -Raw), '(?m)^\s*@[A-Za-z]+\{([^,\s{}]+)\s*,')) {
        [void]$bibKeys.Add($m.Groups[1].Value)
    }
}

$findings = [System.Collections.Generic.List[string]]::new()

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

# Every line of a listing the prose called a capture has to appear in this
# book's research/ notes, matched against the whitespace-collapsed blob so that
# a capture re-wrapped to fit the measure still traces.
#
# Chapter 07 printed a query plan under "the only listing I have not trimmed"
# whose embedded query strings had in fact been reformatted, and a JSON response
# whose 749.00 had become 749.0 because the capture went through
# `python -m json.tool` on the way to the page. Neither is a lie about the
# system and both are lies about the listing, which is the same defect the
# number check exists for, one level up.
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
        [string]$blob
    )

    $missed = @()
    foreach ($line in $lines) {
        $n = ($line.Trim() -replace '\s+', ' ')
        if ($n.Length -lt 12) { continue }
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

$contractionRe = "(?i)\b(?:aren't|can't|couldn't|didn't|doesn't|don't|hadn't|hasn't|haven't|here's|i'd|i'll|i'm|i've|isn't|it's|let's|mustn't|needn't|shouldn't|that's|there's|they're|they've|wasn't|we'll|we're|we've|weren't|what's|who's|won't|wouldn't|you'll|you're|you've)\b"

# Prose that promises a listing is a capture rather than an illustration. Only
# these phrases arm the verbatim check; a listing nobody claimed anything about
# is not checked, because most text listings are commands to type rather than
# output to trust.
$verbatimClaimRe = '(?i)(?:\bverbatim\b|\bunmodified\b|\buntouched\b|character for character|(?:have|has|had)\s+not\s+(?:been\s+)?(?:trimmed|edited|altered)|\bnot\s+(?:been\s+)?trimmed\b|\bin full\b|exactly as)'

# How many prose lines after the claim a listing may appear in before the claim
# is considered to have been about something else.
$verbatimClaimWindow = 6

# American spellings the prose must not use. Deliberately NOT on this list:
#   catalog    - Mosaic domain vocabulary (the Catalog service)
#   analyz*    - house-style blesses "analyzers" as a product term
#   authoriz*  - chapter 15 title and the OAuth term of art
#   modeling   - chapter 13 title
$spellings = [ordered]@{
    'behaviors?'               = 'behaviour(s)'
    'behavioral'               = 'behavioural'
    'colors?'                  = 'colour(s)'
    'colored'                  = 'coloured'
    'centers?'                 = 'centre(s)'
    'centered'                 = 'centred'
    'initialization'           = 'initialisation'
    'initializ(?:e|es|ed|ing)' = 'initialise'
    'organizations?'           = 'organisation(s)'
    'organiz(?:e|es|ed|ing)'   = 'organise'
    'labeled'                  = 'labelled'
    'labeling'                 = 'labelling'
    'favorites?'               = 'favourite(s)'
    'gray'                     = 'grey'
}

Write-Host "==> Checking $(Get-RelPath $bookPath) ($($texFiles.Count) files)"

$latin1 = [System.Text.Encoding]::GetEncoding(28591)
foreach ($f in $texFiles) {

    # 1. ascii: raw bytes, everywhere including verbatim. Latin-1 maps each
    # byte to one char, so match positions are byte positions.
    $rawText = [System.IO.File]::ReadAllText($f.FullName, $latin1)
    $bad = [regex]::Matches($rawText, '[^\x09\x0A\x0D\x20-\x7E]')
    $reported = 0
    foreach ($m in $bad) {
        if ($reported -ge 5) {
            Add-Finding $f.FullName 0 'ascii' "...and $($bad.Count - 5) more non-ASCII bytes"
            break
        }
        $lineNo = 1 + [regex]::Matches($rawText.Substring(0, $m.Index), "`n").Count
        Add-Finding $f.FullName $lineNo 'ascii' ('byte 0x{0:X2} is not printable ASCII' -f [int][char]$m.Value)
        $reported++
    }

    $rawLines = @(Get-Content $f.FullName)
    $inVerb = $null
    $codeDepth = 0
    $enqDepth = 0
    $numCodeDepth = 0

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
                    Test-VerbatimClaim $f.FullName $captureLine $claimLine $claimPhrase $capture $researchBlob
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

                    # A claim arms the check only for captured output. csharp,
                    # graphql and SDL listings come out of the companion repo,
                    # which this script cannot read; text and json are where a
                    # console paste lives, and where an invented one hides.
                    $lm = [regex]::Match($raw, '\\begin\{minted\}(?:\[[^\]]*\])?\{(text|json)\}')
                    if ($claimWindow -gt 0 -and $lm.Success -and $researchBlob) {
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

        # noCode: stripped minus \code{...}; prose: noCode minus \enquote{...}
        $noCode = Remove-MacroSpans $stripped 'code' ([ref]$codeDepth)
        $prose = Remove-MacroSpans $noCode 'enquote' ([ref]$enqDepth)

        # words: prose minus tokens that are identifiers, not English
        $words = $prose -replace '\\(?:begin|end|label|ref|pageref|input|include|autocite)(?:\[[^\]]*\])?\{[^}]*\}', ' '

        # 2. tilde-cite
        if ($stripped -match '(?<!~)\\autocite') {
            Add-Finding $f.FullName $lineNo 'tilde-cite' 'use a non-breaking tie: ~\autocite{...}'
        }

        # 3. cite-key
        foreach ($cm in [regex]::Matches($stripped, '\\autocite(?:\[[^\]]*\])?\{([^}]*)\}')) {
            foreach ($key in ($cm.Groups[1].Value -split ',')) {
                $k = $key.Trim()
                if ($k -and -not $bibKeys.Contains($k)) {
                    Add-Finding $f.FullName $lineNo 'cite-key' "citation key '$k' not found in refs.bib"
                }
            }
        }

        # 4. quote: \enquote content is NOT exempt (nested quotes nest \enquote)
        if ($noCode.Contains('"')) {
            Add-Finding $f.FullName $lineNo 'quote' 'literal double quote in prose; use \enquote{...}'
        }

        # 5. index-pct: raw line, range markers |( |) excepted by convention
        if ($raw -match '\\index\{') {
            if (-not ($raw -match '%\s*$' -or $raw -match '\\index\{[^{}]*\|[()]\}\s*$')) {
                Add-Finding $f.FullName $lineNo 'index-pct' '\index{...} line must end with %'
            }
        }

        # 6. contraction
        foreach ($m in [regex]::Matches($words, $contractionRe)) {
            Add-Finding $f.FullName $lineNo 'contraction' "contraction '$($m.Value)' in the author's voice"
        }

        # 7. spelling
        foreach ($pat in $spellings.Keys) {
            foreach ($m in [regex]::Matches($words, "(?i)\b(?:$pat)\b")) {
                Add-Finding $f.FullName $lineNo 'spelling' "'$($m.Value)' -> $($spellings[$pat])"
            }
        }

        # 8. dash: runs of exactly 2-3 hyphens read as en/em dashes in prose
        if ($prose -match '(?<!-)---?(?!-)') {
            Add-Finding $f.FullName $lineNo 'dash' 'en/em dash ligature in prose; reword or use ASCII punctuation'
        }

        # 9. number: a decimal printed in the book must appear somewhere in
        # this book's research/ notes. Chapter 04 printed a request-timeline
        # line that had never been captured, and chapter 02 asserted a latency,
        # a line count and an API attribute name the same way; the SPEC rule is
        # that a measured number is reproducible from the research file, and
        # this is that rule with teeth.
        #
        # Captured listings are checked and \code{} spans are not: a timeline
        # line inside a minted block is exactly where a made-up number hides,
        # while an argument like `docker update --cpus 0.25` is an instruction
        # rather than a measurement. Dotted versions (16.6.0) are skipped by
        # the lookaround. Numbers written as words are not covered at all.
        #
        # The research side is matched from a digit boundary but left open at
        # the end, so prose may round: 9.2 is accepted against a recorded 9.22.
        # The cost of allowing that is a number which merely prefixes a real
        # one slips through. Catching invented numbers is worth more than
        # catching rounded ones, and demanding exact equality would flag every
        # rounded figure in the book and get this check deleted within a week.
        if ($researchText) {
            $numberLine = if ($verbLine) { $raw } else { $stripped }
            $numberLine = Remove-MacroSpans $numberLine 'code' ([ref]$numCodeDepth)
            foreach ($m in [regex]::Matches($numberLine, '(?<![\d.])\d+\.\d+(?![\d.])')) {
                $traced = [regex]::IsMatch($researchText, '(?<![\d.])' + [regex]::Escape($m.Value))
                if (-not $traced) {
                    Add-Finding $f.FullName $lineNo 'number' "'$($m.Value)' is in no research/ note; measure it, or record where it came from"
                }
            }
        }

        # 10. verbatim: arm the check when the prose promises a capture. The
        # comparison itself happens where the block ends; see Test-VerbatimClaim.
        if (-not $verbLine) {
            $cm2 = [regex]::Match($prose, $verbatimClaimRe)
            if ($cm2.Success) {
                $claimWindow = $verbatimClaimWindow
                $claimLine = $lineNo
                $claimPhrase = $cm2.Value
            } elseif ($claimWindow -gt 0) {
                $claimWindow--
            }
        }
    }
}

# 11. log: parse an existing build/main.log; never invoke latexmk (perl is not
# on PowerShell's PATH on this machine).
$logPath = Join-Path $bookPath 'build/main.log'
if (-not (Test-Path $logPath)) {
    Write-Host "==> WARNING: $(Get-RelPath $logPath) not found; log checks skipped. Run latexmk first."
} else {
    $logTime = (Get-Item $logPath).LastWriteTime
    $newer = @($texFiles | Where-Object { $_.LastWriteTime -gt $logTime })
    if ($newer.Count -gt 0) {
        Write-Host "==> WARNING: build/main.log is older than $($newer[0].Name); rebuild before trusting log checks."
    }
    $overfull = @(Select-String -Path $logPath -Pattern 'Overfull' -CaseSensitive).Count
    if ($overfull -gt 0) {
        Add-Finding $logPath 0 'log' "$overfull Overfull box(es); locate with: grep -A3 Overfull build/main.log"
    }
    $undefined = @(Select-String -Path $logPath -Pattern 'undefined').Count
    if ($undefined -gt 0) {
        Add-Finding $logPath 0 'log' "$undefined line(s) mentioning undefined references or citations"
    }
}

if ($findings.Count -eq 0) {
    Write-Host '==> check-chapter: clean'
    exit 0
}
Write-Host "==> check-chapter: $($findings.Count) finding(s)"
exit 1
