#!/usr/bin/env pwsh
# One-time setup per clone, on Windows, macOS or Linux. Safe to re-run.
#   - points git at .githooks, which is the pre-commit build gate and the four
#     Git LFS hooks
#   - configures the Git LFS filters, or says loudly that git-lfs is missing
#   - links .agents/skills at .claude/skills, for agent runtimes that look in
#     .agents/ rather than .claude/. The link is generated, never committed:
#     .claude/skills is the only tracked copy.
# Usage: pwsh scripts/setup.ps1 [-Force]
param(
    # Replace an existing real .agents/skills directory (a stale copy from the
    # fallback path below). Links are always replaced without asking.
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSEdition -eq 'Desktop') {
    Write-Error 'Needs PowerShell 7+ (pwsh), not Windows PowerShell 5.1.'
}

$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
    # --- 1. the hooks directory --------------------------------------------
    # Relative on purpose: git resolves it against each worktree, so a branch
    # runs the hooks it ships rather than main's, and a clone that moves on
    # disk keeps working. --default keeps an unset key from failing the call.
    $prior = git config --get --default '' core.hooksPath
    if ($prior -and $prior -ne '.githooks') {
        Write-Host "==> core.hooksPath was '$prior'; correcting it"
    }
    git config core.hooksPath .githooks
    Write-Host '==> core.hooksPath = .githooks'

    # --- 2. Git LFS --------------------------------------------------------
    # dist/*.pdf lives in LFS and .githooks tracks the four hooks LFS needs, so
    # all that is left per clone is the filters. This runs after step 1 because
    # git lfs install writes hooks into whatever core.hooksPath points at - the
    # tracked ones are byte-identical to what it would write, so it finds its
    # own work already done and changes nothing.
    if (-not (Get-Command git-lfs -ErrorAction SilentlyContinue)) {
        Write-Warning 'git-lfs is not on PATH. Those hooks abort every checkout, commit, merge and push until it is installed, and dist/*.pdf checks out as a pointer file rather than a PDF. Install it from https://git-lfs.com and re-run this script.'
    }
    elseif (git config --get --default '' filter.lfs.process) {
        Write-Host '==> git lfs: filters already configured'
    }
    else {
        git lfs install --local
        Write-Host '==> git lfs: filters written to .git/config'
    }

    # --- 3. the skills mirror ----------------------------------------------
    $target = Join-Path $root '.claude/skills'
    $link = Join-Path $root '.agents/skills'

    if (-not (Test-Path $target)) {
        Write-Error "No .claude/skills to link to at '$target'"
    }

    $existing = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
    if ($existing) {
        if ($existing.LinkType) {
            # Remove the link itself, never its contents. -Recurse is the one
            # switch that could follow the link into .claude/skills, so it is
            # deliberately absent from both attempts. Windows junctions and
            # Unix symlinks each fail the other's call on some versions, hence
            # the pair.
            try {
                Remove-Item -LiteralPath $existing.FullName -Force
            }
            catch {
                [System.IO.Directory]::Delete($existing.FullName)
            }
        }
        elseif ($Force) {
            Remove-Item -LiteralPath $link -Recurse -Force
        }
        else {
            Write-Error ".agents/skills exists as a real directory. Re-run with -Force to replace it."
        }
    }

    $parent = Split-Path -Parent $link
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
    }

    # Junction first on Windows: it is the only directory link that works
    # without Developer Mode or an elevated shell. Everywhere else a symlink
    # is the unprivileged default. Targets are absolute, so a clone that moves
    # on disk re-runs this script rather than silently pointing nowhere.
    $kinds = if ($IsWindows) { @('Junction', 'SymbolicLink') } else { @('SymbolicLink') }

    $made = $null
    foreach ($kind in $kinds) {
        try {
            New-Item -ItemType $kind -Path $link -Target $target -ErrorAction Stop | Out-Null
            $made = $kind
            break
        }
        catch {
            Write-Host "==> $kind failed: $($_.Exception.Message)"
        }
    }

    if (-not $made) {
        # Last resort: a real copy, which will go stale the moment a skill is
        # edited. Loud on purpose - it is the one outcome that reintroduces the
        # two-places problem this script exists to avoid.
        Copy-Item -Recurse -Force $target $link
        Write-Warning 'Could not create a link; copied instead. This copy goes stale as soon as a skill changes - re-run "pwsh scripts/setup.ps1 -Force" after editing anything under .claude/skills.'
        $made = 'copy'
    }

    # --- 4. prove it resolves ----------------------------------------------
    $probe = Join-Path $link 'draft-chapter/SKILL.md'
    if (-not (Test-Path $probe)) {
        Write-Error "Created .agents/skills as $made, but '$probe' does not resolve."
    }

    Write-Host "==> .agents/skills -> .claude/skills ($made)"
    Write-Host '==> setup: done'
}
finally {
    Pop-Location
}
