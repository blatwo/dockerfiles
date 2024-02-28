#
# 基础镜像：debian:bullseye-slim
# 数据库：hgdb-see-4.5.8
#

FROM qiuchenjun/baseos:bullseye-slim

# 明确设置“用户”和“组”ID
# 创建用户目录
RUN set -eux; \
	groupadd -r highgo --gid=999; \
	useradd -r -g highgo --uid=999 --home-dir=/home/highgo --shell=/bin/bash highgo; \
	mkdir -p /home/highgo; \
	chown -R highgo:highgo /home/highgo

# 设置瀚高数据库版本、环境变量以及安装
ENV HG_VERSION=hgdb-see-4.5.8
ENV HGDB_HOME=/opt/highgo/${HG_VERSION}
ENV PATH=$PATH:${HGDB_HOME}/bin
ENV PGDATA=/home/highgo/hgdb/data

# 添加瀚高数据库程序压缩包
ADD hgdb-see-4.5.8.tar.gz /

# 添加 ssl 证书文件并修改权限，因为镜像里没有 openssl 命令，无法创建它们。
COPY --from=qiuchenjun/hgdb-crts /root.crt /server.* /home/highgo/
RUN chown -R highgo:highgo /home/highgo/root.crt; \
	chown -R highgo:highgo /home/highgo/server.*; \
	chmod 0600 /home/highgo/server.key

# 查看输出版本
RUN postgres --version

# 修改默认配置，监听所有IP，否则宿主机无法访问端口
RUN set -eux; \
	sed -ri "s/^#?(listen_addresses)\s*=\s*\S+.*/\1 = '*'/" ${HGDB_HOME}/share/postgresql/postgresql.conf.sample; \
	grep -F "listen_addresses = '*'" ${HGDB_HOME}/share/postgresql/postgresql.conf.sample

# 创建数据目录并授权
RUN mkdir -p "$PGDATA" && chown -R highgo:highgo "$PGDATA" && chmod 777 "$PGDATA"
# 映射到宿主机的目录
VOLUME /home/highgo/hgdb

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
