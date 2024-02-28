
PGPASSWORD=Hello@123456 psql highgo syssso <<- EOF
	select set_secure_param('hg_idcheck.pwdvaliduntil','0');
	alter user current_user password '${POSTGRES_PASSWORD}' valid until 'infinity';
	\c - sysdba
	alter user current_user password '${POSTGRES_PASSWORD}';
	\c - syssao
	alter user current_user password '${POSTGRES_PASSWORD}';
EOF

cat > ~/.pgpass <<- EOF
	host:port:database:user:password
	localhost:5866:*:sysdba:${POSTGRES_PASSWORD}
	localhost:5866:*:syssao:${POSTGRES_PASSWORD}
	localhost:5866:*:syssso:${POSTGRES_PASSWORD}
EOF
chmod 0600 ~/.pgpass

export PGPASSWORD=${POSTGRES_PASSWORD}
psql highgo syssso <<- 'EOF'
	select set_secure_param('hg_macontrol','min');
	select set_secure_param('hg_rowsecure','off');
	select set_secure_param('hg_showlogininfo','off');
	select set_secure_param('hg_clientnoinput','0');
	select set_secure_param('hg_idcheck.pwdpolicy','high');
EOF

psql highgo syssao <<- 'EOF'
	select set_audit_param('hg_audit','off');
EOF

# 创建归档目录
mkdir -p /home/highgo/hgdb/hgdbbak/archive && chown -R highgo:highgo /home/highgo/hgdb && chmod 777 /home/highgo/hgdb

psql highgo sysdba <<- 'EOF'
	alter system set listen_addresses = '*';
	alter system set max_connections = 2000;
	alter system set work_mem='16MB';
	alter system set shared_buffers = '1GB';
	alter system set checkpoint_completion_target = 0.9;
	alter system set log_destination = 'csvlog';
	alter system set logging_collector = on;
	alter system set log_directory = 'hgdb_log';
	alter system set log_filename = 'highgodb_%d.log';
	alter system set log_rotation_age = '1d';
	alter system set log_rotation_size = 0;
	alter system set log_truncate_on_rotation = on;
	alter system set log_statement = 'ddl';
	alter system set log_connections=on;
	alter system set log_disconnections=on;
	alter system set checkpoint_timeout='30min';
	alter system set maintenance_work_mem='1GB';
	alter system set archive_mode = on;
	alter system set archive_timeout = '30min';
	alter system set archive_command = 'cp %p /home/highgo/hgdb/hgdbbak/archive/%f';
	alter system set log_line_prefix = '%m [%p] %a %u %d %r %h';
	alter system set nls_length_semantics = 'char'; 
EOF
