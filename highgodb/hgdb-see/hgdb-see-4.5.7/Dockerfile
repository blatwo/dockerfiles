#
# 基础镜像：debian:bullseye-slim
# 数据库：hgdb-see-4.5.7-x86_64
#

FROM debian:bullseye-slim

RUN set -ex; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
		; \
		rm -rf /var/lib/apt/lists/*; \
	fi

# 明确设置“用户”和“组”ID
# 创建用户目录
RUN set -eux; \
	groupadd -r highgo --gid=999; \
	useradd -r -g highgo --uid=999 --home-dir=/home/highgo --shell=/bin/bash highgo; \
	mkdir -p /home/highgo; \
	chown -R highgo:highgo /home/highgo

# grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION 1.16
RUN set -eux; \
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends ca-certificates wget; \
	rm -rf /var/lib/apt/lists/*; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	chmod +x /usr/local/bin/gosu; \
	gosu --version; \
	gosu nobody true

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN set -eux; \
	if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then \
# if this file exists, we're likely in "debian:xxx-slim", and locales are thus being excluded so we need to remove that exclusion (since we need locales)
		grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
		sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker; \
		! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
	fi; \
	apt-get update; apt-get install -y --no-install-recommends locales; rm -rf /var/lib/apt/lists/*; \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libnss-wrapper \
		xz-utils \
		zstd \
	; \
	rm -rf /var/lib/apt/lists/*

RUN mkdir /docker-entrypoint-initdb.d

# 设置瀚高数据库版本、环境变量以及安装
ENV HG_VERSION=hgdb-see-4.5.7
ENV HGDB_HOME=/opt/highgo/${HG_VERSION}
ENV PATH=$PATH:${HGDB_HOME}/bin
ENV PGDATA=/home/highgo/hgdb/data

# 添加瀚高数据库程序压缩包
ADD ${HG_VERSION}.tar.gz /

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
