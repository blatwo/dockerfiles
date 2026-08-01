[CmdletBinding()]
param(
    [string]$RepositoryRoot
)

$ErrorActionPreference = 'Stop'
$failures = [System.Collections.Generic.List[string]]::new()

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RepositoryRoot = Split-Path -Parent $scriptDirectory
}

function Add-Failure([string]$Message) {
    [void]$failures.Add($Message)
}

$dockerfiles = Get-ChildItem -LiteralPath $RepositoryRoot -Recurse -File -Filter Dockerfile |
    Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }

if ($dockerfiles.Count -eq 0) {
    Add-Failure 'No Dockerfile was found.'
}

foreach ($dockerfile in $dockerfiles) {
    $content = Get-Content -LiteralPath $dockerfile.FullName -Raw
    $relativePath = $dockerfile.FullName.Substring($RepositoryRoot.Length).TrimStart('\', '/')

    if ([string]::IsNullOrWhiteSpace($content)) {
        Add-Failure "$relativePath is empty."
        continue
    }

    if ($content -notmatch '(?im)^\s*FROM\s+') {
        Add-Failure "$relativePath does not contain a FROM instruction."
    }
}

$migrationRoots = @(
    'hgdb\6.0\enterprise\6.0.4',
    'hgdb\4.5\see\4.5.7',
    'hgdb\4.5\see\4.5.8',
    'hgdb\4.5\see\4.5.10',
    'hgdb\4.5\see-postgis\4.5-3.4.0',
    'hgdb\4.5\see-postgis\4.5.10-3.4.0'
)

foreach ($relativeRoot in $migrationRoots) {
    $absoluteRoot = Join-Path $RepositoryRoot $relativeRoot
    if (-not (Test-Path -LiteralPath $absoluteRoot -PathType Container)) {
        Add-Failure "Migration root is missing: $relativeRoot"
        continue
    }

    if (-not (Get-ChildItem -LiteralPath $absoluteRoot -Recurse -File -Filter Dockerfile)) {
        Add-Failure "Migration root has no Dockerfile: $relativeRoot"
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "Validated $($dockerfiles.Count) Dockerfiles and $($migrationRoots.Count) migration roots."
