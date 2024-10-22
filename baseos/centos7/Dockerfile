#
# 基础镜像：centos:centos7
#

FROM centos:centos7

# 安装 gosu
COPY --from=qiuchenjun/gosu /gosu /usr/local/bin/gosu
RUN set -eux; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true
