[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$RepositoryRoot
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RepositoryRoot = Split-Path -Parent $scriptDirectory
}

$migrations = @(
    @{ Source = 'highgo\hgdb-ee\hgdb-ee-6.0.4'; Destination = 'hgdb\6.0\enterprise\6.0.4' },
    @{ Source = 'highgo\hgdb-see\hgdb-see-4.5.7'; Destination = 'hgdb\4.5\see\4.5.7' },
    @{ Source = 'highgo\hgdb-see\hgdb-see-4.5.8'; Destination = 'hgdb\4.5\see\4.5.8' },
    @{ Source = 'highgo\hgdb-see\hgdb-see-4.5.10'; Destination = 'hgdb\4.5\see\4.5.10' },
    @{ Source = 'highgo\hgdb-see-postgis\4.5-3.4.0'; Destination = 'hgdb\4.5\see-postgis\4.5-3.4.0' },
    @{ Source = 'highgo\hgdb-see-postgis\4.5.10-3.4.0'; Destination = 'hgdb\4.5\see-postgis\4.5.10-3.4.0' }
)

foreach ($migration in $migrations) {
    $source = Join-Path $RepositoryRoot $migration.Source
    $destination = Join-Path $RepositoryRoot $migration.Destination

    if (-not (Test-Path -LiteralPath $source -PathType Container)) {
        throw "Migration source does not exist: $($migration.Source)"
    }

    if (-not (Test-Path -LiteralPath $destination -PathType Container)) {
        New-Item -ItemType Directory -Path $destination -Force | Out-Null
    }

    $sourceItems = Get-ChildItem -LiteralPath $source -Force
    if ($PSCmdlet.ShouldProcess($migration.Destination, "Copy $($migration.Source)")) {
        Copy-Item -LiteralPath $sourceItems.FullName -Destination $destination -Recurse -Force
        Write-Output "Copied $($migration.Source) -> $($migration.Destination)"
    }
}

Write-Output 'Legacy highgo paths were preserved.'
