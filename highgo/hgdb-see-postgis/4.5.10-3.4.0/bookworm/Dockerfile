FROM registry.cn-beijing.aliyuncs.com/hgdb/hgdb-see:4.5.10
#FROM qiuchenjun/hgdb-see:4.5.10

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS 3.4.0+Hgdb-see-4.5.10 spatial database extension with HGDB-See-4.5.10" \
      org.opencontainers.image.source="https://github.com/"

ENV POSTGIS_MAJOR=3
ENV POSTGIS_VERSION=postgis340-hgdb-see-4.5.10-a64a611-20240426

ARG TARGETOS TARGETARCH

ADD postgis340-hgdb-see-4.5.10-a64a611-20240426.${TARGETARCH}.tar.gz /opt/highgo/hgdb-see-4.5.10

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/20_postgis.sh
#COPY ./update-postgis.sh /usr/local/bin

