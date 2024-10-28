#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM debian:bookworm-slim

# https://www.postgresql.org/docs/16/app-psql.html#APP-PSQL-META-COMMAND-PSET-PAGER
# https://github.com/postgres/postgres/blob/REL_16_1/src/include/fe_utils/print.h#L25
# 如果可以使用“less”，它将被用作 psql 的默认分页器，并且仅会使我们的镜像大小增加大约 1.5 MiB。
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		gnupg \
		less \
	; \
	rm -rf /var/lib/apt/lists/*

# 获取 gosu 以便于从 root 用户轻松降级。
# 使用 gosu 工具可以方便地将程序的执行权限从 root 用户切换到其他普通用户。这在容器化应用或需要在高权限下
# 启动某些进程后，降低权限以增强安全性时非常有用。通过这种方式，可以避免以 root 用户身份运行不必要的服务，
# 从而降低潜在的安全风险。
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION=1.17
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

# 创建 "en_US.UTF-8" 语言环境，以便 PostgreSQL 默认启用 UTF-8。
# 创建 "zh_CN.UTF-8" 和 "zh_CN.GB18030" 语言环境，以便支持中文。
RUN set -eux; \
	if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then \
# 如果该文件存在，我们可能处于 "debian:xxx-slim" 环境，因此语言环境被排除了，我们需要去除该排除（因为我们需要语言环境）。
		grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
		sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker; \
		! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
	fi; \
	apt-get update; apt-get install -y --no-install-recommends locales; rm -rf /var/lib/apt/lists/*; \
	echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen; \
	echo 'zh_CN.UTF-8 UTF-8' >> /etc/locale.gen; \
	echo 'zh_CN.GB18030 GB18030' >> /etc/locale.gen; \
	locale-gen; \
	locale -a | grep 'en_US.utf8'; \
	locale -a | grep 'zh_CN.utf8'; \
	locale -a | grep 'zh_CN.GB18030';
ENV LANG=en_US.utf8

# 更新软件包列表并安装几个必要的软件包。
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libnss-wrapper \
		xz-utils \
		zstd \
	; \
	rm -rf /var/lib/apt/lists/*
