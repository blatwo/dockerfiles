# HGDB_SEE_VERSION：瀚高数据库基础镜像版本号，要跟仓库里的版本一致，否则找不到镜像。如：4.5.10
# POSTGIS_VERSION：二进制 tar.gz 包名，如：postgis340-hgdb-see-4.5.10-a64a611-20240426
ARG HGDB_SEE_VERSION
ARG POSTGIS_VERSION

FROM registry.cn-beijing.aliyuncs.com/hgdb/hgdb-see:${HGDB_SEE_VERSION}

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS 3.4.0+Hgdb-see-4.5 spatial database extension with HGDB-SEE-4.5" \
      org.opencontainers.image.source="https://github.com/"

ENV POSTGIS_MAJOR=3
ENV POSTGIS_VERSION=${POSTGIS_VERSION}

ARG TARGETOS TARGETARCH

ADD ${POSTGIS_VERSION}.${TARGETARCH}.tar.gz /

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/20_postgis.sh
#COPY ./update-postgis.sh /usr/local/bin

