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
    "${psql[@]}" --dbname="$DB" <<-'EOSQL'
        SET APPLICATION_NAME TO securedump;
        CREATE EXTENSION IF NOT EXISTS postgis;
        --CREATE EXTENSION IF NOT EXISTS postgis_topology;
EOSQL
done

