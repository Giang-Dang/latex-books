#Requires -Version 7
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string] $VerificationRoot,
    [ValidateSet('Canonical', 'HC14')][string] $Mode = 'Canonical'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$sourceRoot = (Resolve-Path -LiteralPath $VerificationRoot).Path
$services = if ($Mode -eq 'Canonical') {
    @('Sessions', 'Speakers', 'Ratings', 'Search')
} else { @('Sessions') }
$writer = [System.Text.StringBuilder]::new()
foreach ($service in $services) {
    [void]$writer.AppendLine("\section{$service}")
    $paths = @(git -C $sourceRoot ls-files "src/$service")
    if ($LASTEXITCODE -ne 0) { throw 'Cannot enumerate source files.' }
    foreach ($relative in $paths) {
        $extension = [IO.Path]::GetExtension($relative)
        if ($extension -notin @('.cs', '.csproj', '.json')) { continue }
        $language = switch ($extension) {
            '.cs' { 'csharp' }
            '.csproj' { 'xml' }
            '.json' { 'json' }
        }
        $text = [IO.File]::ReadAllText((Join-Path $sourceRoot $relative))
        # Reader-facing comments must not refer to the private history.
        # These exact comment-only transformations are recorded in the ledger.
        if ($Mode -eq 'HC14') {
            $text = $text.Replace('the rest of this branch uses',
                'the generated type-class example uses')
            $text = $text.Replace('for Speaker on this branch,',
                'for Speaker in this version,')
        }
        [void]$writer.AppendLine()
        [void]$writer.AppendLine("\subsection*{\code{$relative}}")
        $options = if ($language -eq 'csharp') { '' } else {
            '[fontsize=\footnotesize,breakanywhere]'
        }
        [void]$writer.AppendLine("\begin{minted}$options{$language}")
        [void]$writer.AppendLine($text.TrimEnd())
        [void]$writer.AppendLine('\end{minted}')
    }
}
if ($Mode -eq 'Canonical') {
    [void]$writer.AppendLine('\section{Composition and Router Configuration}')
    foreach ($relative in @('graph/graph.yaml', 'router/config.yaml')) {
        [void]$writer.AppendLine()
        [void]$writer.AppendLine("\subsection*{\code{$relative}}")
        [void]$writer.AppendLine('\begin{minted}{yaml}')
        [void]$writer.AppendLine(
            [IO.File]::ReadAllText((Join-Path $sourceRoot $relative)).TrimEnd())
        [void]$writer.AppendLine('\end{minted}')
    }
}
$writer.ToString()
