#
# 基础镜像：qiuchenjun/hgdb-see:4.5.8
# 数据库：hgdb-see-4.5.8-x86_64
# 扩展：hgdb-see-4.5.8-postgis3.1.tar.gz
#

FROM qiuchenjun/hgdb-see:4.5.8

# 添加 PostGIS 扩展包
ADD hgdb-see-4.5.8-postgis3.1.tar.gz /

# 查看输出版本
RUN postgres --version
