#
# 基础镜像：hxsoongkylinv10-sp3
#
# 第一阶段：编译阶段
FROM debian:bullseye-slim AS build

RUN apt-get update && apt-get install -y \
    gcc \
    make \
    cmake \
    libc6-dev \
    wget \
    git

# 克隆并编译 libnss_wrapper
RUN git clone https://git.samba.org/nss_wrapper.git /src
WORKDIR /src
RUN mkdir build && cd build && cmake .. && make

# 第二阶段：从构建阶段复制文件
FROM hxsoong/kylin:v10-sp3

# 安装 gosu
COPY --from=qiuchenjun/gosu /gosu /usr/local/bin/gosu
RUN set -eux; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true

COPY --from=build /src/libnss_wrapper.so /usr/lib64/libnss_wrapper.so

RUN set -eux; \
    chmod 755 /usr/lib64/libnss_wrapper.so

# 将宿主机的 en_US.utf8 目录拷贝到容器中
#ADD en_US.utf8.tar.gz /usr/lib/locale/
