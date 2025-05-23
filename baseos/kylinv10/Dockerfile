#
# 基础镜像：hxsoongkylinv10-sp3
#

FROM hxsoong/kylin:v10-sp3

# 安装 gosu
COPY ./gosu /usr/local/bin/gosu
RUN set -eux; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true

COPY ./libnss_wrapper.so /usr/lib64/libnss_wrapper.so
RUN set -eux; \
    chmod 755 /usr/lib64/libnss_wrapper.so

# 将宿主机的 en_US.utf8 目录拷贝到容器中
#ADD en_US.utf8.tar.gz /usr/lib/locale/
