$ErrorActionPreference = 'Stop'

$entrypoint = Get-Content -Raw "$PSScriptRoot\..\hgdb\9.0.10.1\bookworm\docker-entrypoint.sh"

$requiredPatterns = @(
	'find "\$POSTGRES_INITDB_WALDIR" \\! -user highgo -exec chown highgo',
	'find "\$PGDATA" \\! -user highgo -exec chown highgo',
	'file_env ''POSTGRES_USER'' ''highgo''',
	'--dbname highgo',
	'\$\{PGPORT:-5866\}',
	'PGUSER="\$\{PGUSER:-highgo\}"',
	'exec gosu highgo "\$BASH_SOURCE" "\$@"'
)

foreach ($pattern in $requiredPatterns) {
	if ($entrypoint -notmatch $pattern) {
		throw "Missing HGDB entrypoint contract: $pattern"
	}
}

if ($entrypoint -match 'gosu postgres|chown postgres|--dbname postgres|POSTGRES_USER'' ''postgres''|\$\{PGPORT:-5432\}') {
	throw 'PostgreSQL defaults remain in the HGDB entrypoint.'
}
