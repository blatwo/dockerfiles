# 使用 scratch 作为基础镜像
FROM scratch
# 添加参数，用于接收构建时传入的目标平台
ARG TARGETPLATFORM
# 添加二进制文件
ADD gosu-${TARGETPLATFORM} /gosu
# 其他必要的文件和指令...
