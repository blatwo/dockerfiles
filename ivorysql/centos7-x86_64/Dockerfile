# IvorySQL Dockerfile
# Create by Highgo RogerQ

FROM centos:centos7

LABEL org.opencontainers.image.authors="The Highgo IvorySQL Project <general@ivorysql.org>"

# 设置 IvorySQL 大版本号环境变量 IVY_MAJOR 为 2 即可。
ENV IVY_MAJOR 2

# 设置时区
#ENV TZ Asia/Shanghai
#RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
#    && echo ${TZ} > /etc/timezone

# 安装 gosu
COPY --from=gosu/assets /opt/gosu /opt/gosu
RUN set -x \
    && /opt/gosu/gosu.install.sh \
    && rm -fr /opt/gosu

# 明确设置“用户”或“组”的ID
RUN set -eux; \
	groupadd -r ivorysql --gid=996; \
	useradd -r -g ivorysql --uid=996 --home-dir=/var/lib/ivorysql/ivorysql-${IVY_MAJOR} --shell=/bin/bash ivorysql; \
# 还要创建 ivorysql 用户的主目录，并赋予相应的权限
	mkdir -p /var/lib/ivorysql/ivorysql-${IVY_MAJOR}; \
	chown -R ivorysql:ivorysql /var/lib/ivorysql/ivorysql-${IVY_MAJOR}

# 使用语言环境 "en_US.UTF-8"，如此 postgres 将默认启用 utf-8
#RUN set -eux; \
#	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
#ENV LANG en_US.utf8

# 该目录在 docker-entrypoint.sh 中有用
RUN mkdir /docker-entrypoint-initdb.d

# 安装 IvorySQL
#ENV IVY_MAJOR 2
ENV PATH $PATH:/usr/local/ivorysql/ivorysql-${IVY_MAJOR}/bin
1
RUN set -ex; \
    # download ivorysql-release-1.0-${IVY_MAJOR}.noarch.rpm
    curl -o ivorysql-release-1.0-${IVY_MAJOR}.noarch.rpm https://yum.highgo.ca/dists/ivorysql-rpms/repo/ivorysql-release-1.0-${IVY_MAJOR}.noarch.rpm; \
    rpm -ivh ivorysql-release-1.0-${IVY_MAJOR}.noarch.rpm; \
    rm -fr ivorysql-release-1.0-${IVY_MAJOR}.noarch.rpm; \
    yum update -y; yum clean all; \
    yum install -y ivorysql${IVY_MAJOR}-server ivorysql${IVY_MAJOR} ivorysql${IVY_MAJOR}-contrib; yum clean all; \
    postgres --version

# make the sample config easier to munge (and "correct by default")
RUN set -eux; \
	sed -ri "s/^#?(listen_addresses)\s*=\s*\S+.*/\1 = '*'/" /usr/local/ivorysql/ivorysql-${IVY_MAJOR}/share/postgresql.conf.sample; \
	grep -F "listen_addresses = '*'" /usr/local/ivorysql/ivorysql-${IVY_MAJOR}/share/postgresql.conf.sample; \
    sed -i '/#@orafce/a\@orafce' /usr/local/ivorysql/ivorysql-${IVY_MAJOR}/share/ivy_module.config; \
    grep -F "@orafce" /usr/local/ivorysql/ivorysql-${IVY_MAJOR}/share/ivy_module.config
    
# 
RUN mkdir -p /var/run/ivorysql/ivorysql-${IVY_MAJOR} && chown -R ivorysql:ivorysql /var/run/ivorysql/ivorysql-${IVY_MAJOR} && chmod 2777 /var/run/ivorysql/ivorysql-${IVY_MAJOR}

ENV PGDATA /var/lib/ivorysql/ivorysql-${IVY_MAJOR}/data
# 这里的 777 在运行 IvorySQL 服务时会被 700 替换 (允许 semi-arbitrary "--user" 值)
RUN mkdir -p ${PGDATA} && chown -R ivorysql:ivorysql ${PGDATA} && chmod 777 ${PGDATA}
VOLUME ["${PGDATA}"]
#VOLUME ["/var/lib/ivorysql"]

COPY docker-entrypoint.sh /usr/local/bin/
# 需要修改可执行权限，或者制作时就授予可执行权限
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# 发送给容器的退出信号
# 我们将默认的 STOPSIGNAL 设置为 SIGINT，这对应于 PostgreSQL 所谓的“快速关机模式（Fast Shutdown mode）”，
STOPSIGNAL SIGINT

EXPOSE 5333
CMD ["postgres"]
