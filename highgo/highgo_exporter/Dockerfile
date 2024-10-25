# 使用参数化的基础镜像
FROM quay.io/prometheus/busybox-${TARGETOS}-${TARGETARCH}:latest

# 镜像标签
LABEL maintainer="RogerQiu <qiuchenjun@highgo.com>"

# 声明构建参数
ARG TARGETOS TARGETARCH

# 复制对应平台的 postgres_exporter 二进制文件
COPY ${TARGETOS}-${TARGETARCH}/highgo_exporter /bin/highgo_exporter

# 暴露端口
EXPOSE 9187

# 使用非 root 用户运行
USER nobody

# 启动命令
ENTRYPOINT [ "/bin/highgo_exporter" ]
