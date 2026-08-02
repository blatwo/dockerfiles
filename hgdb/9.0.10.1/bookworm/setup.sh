
# 创建 PostgreSQL 密码文件
tee ~/.pgpass >/dev/null <<-'EOF' && chmod 0600 ~/.pgpass
# host:port:database:user:password
localhost:5866:*:${POSTGRES_USER}:${POSTGRES_PASSWORD}
localhost:5866:*:syssao:${POSTGRES_PASSWORD}
localhost:5866:*:syssso:${POSTGRES_PASSWORD}
EOF


# 创建归档目录
mkdir -p /home/highgo/hgdb/hgdbbak/archive && chown -R highgo:highgo /home/highgo/hgdb && chmod 777 /home/highgo/hgdb

# 设置 PostgreSQL 连接参数
psql highgo sysdba <<- 'EOF'
	alter system set listen_addresses='*';
	alter system set log_destination='csvlog';
	alter system set logging_collector=on;
	alter system set log_directory='hgdb_log';
	alter system set log_filename='highgodb_%d.log';
	alter system set log_rotation_age='1d';
	alter system set log_rotation_size=0;
	alter system set log_truncate_on_rotation=on;
	alter system set log_statement='ddl';
	alter system set log_connections=on;
	alter system set log_disconnections=on;
	alter system set log_line_prefix='%m [%p] %a %u %d %r %h';
EOF

# Execute sql script, passed via stdin (or -f flag of pqsl)
# usage: docker_process_sql [psql-cli-args]
#    ie: docker_process_sql --dbname=mydb <<<'INSERT ...'
#    ie: docker_process_sql -f my-file.sql
#    ie: docker_process_sql <my-file.sql
docker_process_sql() {
	local query_runner=( psql -v ON_ERROR_STOP=1 --username "sysdba" --no-password --no-psqlrc )
	if [ -n "$POSTGRES_DB" ]; then
		query_runner+=( --dbname "$POSTGRES_DB" )
	fi

	PGHOST= PGHOSTADDR= "${query_runner[@]}" "$@"
}

# create super DBA user
# uses environment variables for input: POSTGRES_USER
docker_setup_user() {
	local userAlreadyExists
	userAlreadyExists="$(
		POSTGRES_USER= docker_process_sql --dbname highgo --set user="$POSTGRES_USER" --tuples-only <<-'EOSQL'
			SELECT 1 FROM pg_roles WHERE rolname = :'user' ;
		EOSQL
	)"
	if [ -z "$userAlreadyExists" ]; then
		POSTGRES_USER= docker_process_sql --dbname highgo --set user="$POSTGRES_USER" --set password="$POSTGRES_PASSWORD" <<-'EOSQL'
			SET application_name = securedump;
        		CREATE ROLE :"user" WITH SUPERUSER CREATEDB CREATEROLE LOGIN REPLICATION BYPASSRLS PASSWORD :'password';
		EOSQL
		printf '\n'
	fi
}

# create initial database
# uses environment variables for input: POSTGRES_DB
docker_setup_db() {
	local dbAlreadyExists
	dbAlreadyExists="$(
		POSTGRES_DB= docker_process_sql --dbname highgo --set db="$POSTGRES_DB" --tuples-only <<-'EOSQL'
			SELECT 1 FROM pg_database WHERE datname = :'db' ;
		EOSQL
	)"
	if [ -z "$dbAlreadyExists" ] && [ "$POSTGRES_DB" != "sysdba" ]; then
		POSTGRES_DB= docker_process_sql --dbname highgo --set db="$POSTGRES_DB" --set user="$POSTGRES_USER" <<-'EOSQL'
			CREATE DATABASE :"db" OWNER :"user";
		EOSQL
		printf '\n'
	fi
}


docker_setup_user
docker_setup_db
