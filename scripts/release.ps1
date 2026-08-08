#!/usr/bin/env pwsh
# Rebuild every book from scratch and copy the final PDFs into dist/ (LFS-tracked).
# Usage: pwsh scripts/release.ps1
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$books = Get-ChildItem (Join-Path $root 'books') -Directory | Sort-Object Name

if (-not $books) {
    Write-Host 'No books under books/ yet - nothing to release.'
    exit 0
}

foreach ($book in $books) {
    Write-Host "==> Building $($book.Name)"
    Push-Location $book.FullName
    try {
        # -gg forces a full from-scratch rebuild so the release PDF is current
        latexmk -gg
        if ($LASTEXITCODE -ne 0) {
            throw "latexmk failed for $($book.Name)"
        }
    }
    finally {
        Pop-Location
    }

    $pdf = Join-Path $book.FullName 'build/main.pdf'
    if (-not (Test-Path $pdf)) {
        throw "No PDF produced for $($book.Name)"
    }
    Copy-Item $pdf (Join-Path $root "dist/$($book.Name).pdf") -Force
    Write-Host "==> dist/$($book.Name).pdf updated"
}

Write-Host 'Release build complete. Review and commit the dist/ changes.'
