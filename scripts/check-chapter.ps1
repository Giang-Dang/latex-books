#!/usr/bin/env pwsh
# Deterministic lint gate for one book's prose: the machine half of the
# draft-chapter build gate. Checks bytes, citation ties and keys, quoting,
# index termination, contractions, spellings, dashes, and the build log.
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

$contractionRe = "(?i)\b(?:aren't|can't|couldn't|didn't|doesn't|don't|hadn't|hasn't|haven't|here's|i'd|i'll|i'm|i've|isn't|it's|let's|mustn't|needn't|shouldn't|that's|there's|they're|they've|wasn't|we'll|we're|we've|weren't|what's|who's|won't|wouldn't|you'll|you're|you've)\b"

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

    for ($i = 0; $i -lt $rawLines.Count; $i++) {
        $raw = $rawLines[$i]
        $lineNo = $i + 1

        # stripped view: blank inside verbatim environments, drop % comments
        if ($inVerb) {
            if ($raw -match ('\\end\{' + [regex]::Escape($inVerb) + '\}')) { $inVerb = $null }
            $stripped = ''
        } else {
            $bm = [regex]::Match($raw, '\\begin\{([A-Za-z]+\*?)\}')
            if ($bm.Success -and $verbatimEnvs -contains $bm.Groups[1].Value) {
                if ($raw -notmatch ('\\end\{' + [regex]::Escape($bm.Groups[1].Value) + '\}')) {
                    $inVerb = $bm.Groups[1].Value
                }
                $stripped = ''
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
    }
}

# 9. log: parse an existing build/main.log; never invoke latexmk (perl is not
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
