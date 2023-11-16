#
# 基础镜像：centos:centos7
# 数据库：hgdb-ee-6.0.4-x86_64
#

FROM centos:centos7

# 明确设置“用户”和“组”ID
# 创建用户目录
ENV HIGHGO_HOME=/home/highgo
#ENV HIGHGO_HOME=/var/lib/postgresql
RUN set -eux; \
	groupadd -r highgo --gid=996; \
	useradd -r -g highgo --uid=996 --home-dir=${HIGHGO_HOME} --shell=/bin/bash highgo; \
	mkdir -p ${HIGHGO_HOME}; \
	chown -R highgo:highgo ${HIGHGO_HOME}

# 安装 gosu
COPY --from=qiuchenjun/gosu /gosu-amd64 /usr/local/bin/gosu
RUN set -eux; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true

RUN mkdir /docker-entrypoint-initdb.d

# 设置瀚高数据库版本、环境变量以及安装
ENV HG_VERSION=HighGo6.0.4-cluster
ENV HGDB_HOME=/opt/${HG_VERSION}
ENV PATH=$PATH:${HGDB_HOME}/bin
ENV PGDATA=${HIGHGO_HOME}/data

# 添加瀚高数据库程序压缩包
ADD ${HG_VERSION}.tar.gz /

# 添加 ssl 证书文件并修改权限，因为镜像里没有 openssl 命令，无法创建它们。
COPY --from=qiuchenjun/hgdb-crts /root.crt /server.* ${HIGHGO_HOME}/
RUN chown -R highgo:highgo ${HIGHGO_HOME}/root.crt; \
	chown -R highgo:highgo ${HIGHGO_HOME}/server.*; \
	chmod 0600 ${HIGHGO_HOME}/server.key

RUN ln -s /opt/HighGo6.0.4-cluster/lib /usr/local/hgdb-ee

# 查看输出版本
RUN postgres --version

# 修改默认配置，监听所有IP，否则宿主机无法访问端口
RUN set -eux; \
	sed -ri "s/^#?(listen_addresses)\s*=\s*\S+.*/\1 = '*'/" ${HGDB_HOME}/share/postgresql/postgresql.conf.sample; \
	grep -F "listen_addresses = '*'" ${HGDB_HOME}/share/postgresql/postgresql.conf.sample

# 创建数据目录并授权
RUN mkdir -p "$PGDATA" && chown -R highgo:highgo "$PGDATA" && chmod 777 "$PGDATA"
# 映射到宿主机的目录
VOLUME ${HIGHGO_HOME}/data

# 将入口点脚本复制到镜像，修改可执行权限，或者制作时就授予可执行权限
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh
# 将数据库配置脚本 setup.sh 传入镜像（可以跟镜像构建分开，下次扩展传入）
COPY setup.sh /docker-entrypoint-initdb.d
RUN chmod a+x /docker-entrypoint-initdb.d/setup.sh

ENTRYPOINT ["docker-entrypoint.sh"]

STOPSIGNAL SIGINT

EXPOSE 5866
CMD ["postgres"]
