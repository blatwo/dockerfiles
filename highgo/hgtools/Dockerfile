# 使用 Alpine 作为基础镜像
FROM alpine:latest

ENV HG_VERSION=hgtools-linux

# 设置工作目录
WORKDIR /opt

# 将本地的二进制 tarball 复制到容器中的工作目录
ARG TARGETOS TARGETARCH
ADD ${HG_VERSION}-${TARGETARCH}.tar.gz /opt/highgo

# 环境变量
ENV LD_LIBRARY_PATH=/opt/highgo/hgtools/lib
ENV PATH=/opt/highgo/hgtools/bin:$PATH

# 设定容器启动时默认执行的命令
CMD ["/bin/sh"]

