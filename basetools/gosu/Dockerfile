# 使用 scratch 作为基础镜像
FROM scratch
# 添加参数，用于接收构建时传入的目标平台
ARG TARGETOS TARGETARCH
# 添加二进制文件
ADD ${TARGETOS}-${TARGETARCH}/gosu /gosu
# 其他必要的文件和指令...
