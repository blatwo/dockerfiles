#!/bin/bash

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER=sysdba
export PGPASSWORD=${POSTGRES_PASSWORD}
psql=(psql -dhighgo)

# Create the 'template_postgis' template db
"${psql[@]}" <<- 'EOSQL'
CREATE DATABASE template_postgis IS_TEMPLATE true;
EOSQL

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB"; do
    # 判断当前数据库是否为 sysdba，如果是则跳过
    if [ "$DB" = "sysdba" ]; then
        echo "Skipping PostGIS extension creation for sysdba database."
        continue
    fi

    echo "Loading PostGIS extensions into $DB"
    # 判断数据库版本号 HGDB_SEE_VERSION，如果是4.5.10.3，就使用最新的关三权方案
    if [[ "$HGDB_SEE_VERSION" == "4.5.10.3" ]]; then
        echo "Detected specific version $HGDB_SEE_VERSION, using set_secure_param instead of securedump"
		psql highgo syssso <<-"EOF"
			SELECT set_secure_param('hg_sepv4','dyn_off');
		EOF
		"${psql[@]}" --dbname="$DB" <<-'EOSQL'
			CREATE EXTENSION IF NOT EXISTS postgis;
			--CREATE EXTENSION IF NOT EXISTS postgis_topology;
		EOSQL
		psql highgo syssso <<-"EOF"
			SELECT set_secure_param('hg_sepv4','on');
		EOF
    else
        echo "Executing default user setup flow, including SET application_name"
		"${psql[@]}" --dbname="$DB" <<-'EOSQL'
			SET APPLICATION_NAME TO securedump;
			CREATE EXTENSION IF NOT EXISTS postgis;
			--CREATE EXTENSION IF NOT EXISTS postgis_topology;
		EOSQL
    fi
done
