#!/usr/bin/env pwsh
# Build books into EPUBs in dist/ (LFS-tracked), the way release.ps1 builds
# PDFs.
#
# This file only makes the environment. Everything that decides anything -
# which books, how they convert, what lands in dist/ - is in
# scripts/epub/release_epub.py, and the arguments below are passed straight
# through to it.
#
# Usage: pwsh scripts/release-epub.ps1                     # choose from the list
#        pwsh scripts/release-epub.ps1 <name> [<name>...]  # named books, no prompt
#        pwsh scripts/release-epub.ps1 --all               # every book, no prompt
#        pwsh scripts/release-epub.ps1 --all --dry-run     # print the selection only
#        pwsh scripts/release-epub.ps1 -Recreate           # rebuild the conda env first
#
# Why a conda environment rather than whatever python is on PATH: the driver
# pins its dependencies in scripts/epub/environment.yml, and a release should
# not convert differently because one machine has a different scour. The
# environment is created on first run and reused afterwards.
#
# The environment's python is invoked directly rather than through `conda run`,
# because the book menu reads from the terminal and `conda run` does not
# forward stdin.

[CmdletBinding()]
param(
    # Book names and driver flags, forwarded untouched. The parsing lives in
    # one place - the Python driver - so the two cannot disagree about what
    # --all means.
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Arguments,

    # Delete and rebuild the conda environment before running, for when
    # environment.yml has changed or the environment is broken.
    [switch]$Recreate
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$environmentFile = Join-Path $PSScriptRoot 'epub/environment.yml'
$driver = Join-Path $PSScriptRoot 'epub/release_epub.py'

foreach ($required in @($environmentFile, $driver)) {
    if (-not (Test-Path -LiteralPath $required)) {
        Write-Error "Missing $required. This script does nothing on its own."
    }
}

# The environment name is read back out of environment.yml rather than repeated
# here, so the two cannot drift apart.
$environmentName = (Select-String -Path $environmentFile -Pattern '^name:\s*(\S+)' |
    Select-Object -First 1).Matches.Groups[1].Value
if (-not $environmentName) {
    Write-Error "No 'name:' line in $environmentFile."
}

if (-not (Get-Command conda -ErrorAction SilentlyContinue)) {
    Write-Error 'conda is not on PATH. Install Miniconda, or run scripts/epub/release_epub.py directly with a python that has scour installed.'
}

# conda prints its own progress and errors; only the exit code matters here.
function Invoke-Conda {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$CondaArgs)

    & conda @CondaArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Error "conda $($CondaArgs -join ' ') failed with exit code $LASTEXITCODE."
    }
}

# `conda env list` prints "<name> <path>" per line, the active one marked with
# an asterisk, comments starting with #.
function Get-EnvironmentPrefix {
    param([string]$Name)

    $PSNativeCommandUseErrorActionPreference = $false
    foreach ($line in (& conda env list 2>$null)) {
        if ($line -match '^\s*#') { continue }
        if ($line -match '^\s*(\S+)\s+\*?\s*([A-Za-z]:\\.*|/.*)\s*$') {
            if ($Matches[1] -eq $Name) { return $Matches[2].Trim() }
        }
    }
    return $null
}

$prefix = Get-EnvironmentPrefix $environmentName

if ($prefix -and $Recreate) {
    Write-Host "Removing the $environmentName environment before rebuilding it."
    Invoke-Conda env remove -n $environmentName --yes
    $prefix = $null
}

if (-not $prefix) {
    Write-Host "Creating the $environmentName conda environment. First run only; later runs reuse it."
    Invoke-Conda env create -f $environmentFile
    $prefix = Get-EnvironmentPrefix $environmentName
    if (-not $prefix) {
        Write-Error "conda reported success but $environmentName is still missing from 'conda env list'."
    }
}

# Windows puts the interpreter at the prefix root, every other platform in
# bin/. Checking both keeps this working on a Linux or macOS clone.
$python = Join-Path $prefix 'python.exe'
if (-not (Test-Path -LiteralPath $python)) {
    $python = Join-Path $prefix 'bin/python'
}
if (-not (Test-Path -LiteralPath $python)) {
    Write-Error "No python interpreter inside $prefix. Rerun with -Recreate."
}

& $python $driver --root $root @Arguments
exit $LASTEXITCODE
