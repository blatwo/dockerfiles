#
# 基础镜像：debian:bookworm-slim
# 数据库：hgdb-see-4.5.8
#

FROM qiuchenjun/baseos:bookworm-slim

# 明确设置“用户”和“组”ID
# 创建用户目录
ENV HIGHGO_HOME=/home/highgo
RUN set -eux; \
	groupadd -r highgo --gid=999; \
	useradd -r -g highgo --uid=999 --home-dir=${HIGHGO_HOME} --shell=/bin/bash highgo; \
	mkdir -p ${HIGHGO_HOME}; \
	chown -R highgo:highgo ${HIGHGO_HOME}

# 创建目录用于存放数据库初始化脚本和配置
# 当数据库镜像的容器第一次启动时，容器的入口点脚本（entrypoint script）会检查这个目录下的文件，
# 并按顺序执行其中的 SQL 脚本、Shell 脚本等，以完成数据库的初始化工作。
# 这包括但不限于创建用户、创建数据库、初始化数据库表结构和数据。
# 文件和脚本按照文件名的字典序升序执行。这意味着，文件名较小的文件会先执行。例如，01-init.sql 会在 02-init.sql 之前执行。
RUN mkdir /docker-entrypoint-initdb.d

# 设置瀚高数据库版本、环境变量以及安装
ENV HG_VERSION=hgdb-see-4.5.8
ENV HGDB_HOME=/opt/highgo/${HG_VERSION}
ENV PATH=$PATH:${HGDB_HOME}/bin
ENV PGDATA=${HIGHGO_HOME}/hgdb/data

# 添加瀚高数据库程序压缩包
#ADD hgdb-see-4.5.8.tar.gz /
ARG TARGETPLATFORM
ADD hgdb-see-4.5.8-${TARGETPLATFORM}.tar.gz /

# 添加 ssl 证书文件并修改权限，因为镜像里没有 openssl 命令，无法创建它们。
COPY --from=qiuchenjun/hgdb-crts /root.crt /server.* ${HIGHGO_HOME}/
RUN chown -R highgo:highgo ${HIGHGO_HOME}/root.crt; \
	chown -R highgo:highgo ${HIGHGO_HOME}/server.*; \
	chmod 0600 ${HIGHGO_HOME}/server.key

# 查看输出版本
RUN postgres --version

# 修改默认配置，监听所有IP，否则宿主机无法访问端口
RUN set -eux; \
	sed -ri "s/^#?(listen_addresses)\s*=\s*\S+.*/\1 = '*'/" ${HGDB_HOME}/share/postgresql/postgresql.conf.sample; \
	grep -F "listen_addresses = '*'" ${HGDB_HOME}/share/postgresql/postgresql.conf.sample

# 创建数据目录并授权
RUN mkdir -p "$PGDATA" && chown -R highgo:highgo "$PGDATA" && chmod 777 "$PGDATA"
# 映射到宿主机的目录
VOLUME ${HIGHGO_HOME}/hgdb

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
