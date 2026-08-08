#!/usr/bin/env pwsh
# Create a new book from template/.
# Usage: pwsh scripts/new-book.ps1 <kebab-case-name>
param(
    [Parameter(Mandatory = $true)]
    [string]$Name
)

$ErrorActionPreference = 'Stop'

if ($Name -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
    Write-Error "Book name must be kebab-case (lowercase letters, digits, single hyphens): got '$Name'"
}

$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root 'template'
$target = Join-Path $root "books/$Name"

if (Test-Path $target) {
    Write-Error "books/$Name already exists"
}

Copy-Item -Recurse $source $target

# The template may have been test-built locally; a fresh book starts clean.
$buildDir = Join-Path $target 'build'
if (Test-Path $buildDir) {
    Remove-Item -Recurse -Force $buildDir
}

Write-Host "Created books/$Name"
Write-Host "Next: edit the title metadata in books/$Name/preamble/macros.tex"
Write-Host "Build with: cd books/$Name; latexmk"
