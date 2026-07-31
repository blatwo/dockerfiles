# 五、数据库扩展

本章节讲述基于这个瀚高数据库的镜像进行扩展。以`PostGis`扩展为例。

## 5.1 构建扩展镜像

压缩包`hgdb-see-4.5.8-postgis3.1.tar.gz`是从rpm包解开并压缩的，命令参见：

```bash
rpm2cpio p001_see_4.5.8_fh_db43858.x86_64.rpm | cpio -idmv && tar -czvf hgdb-see-4.5.8-postgis3.1.tar.gz ./opt
```

DockerFile内容如下：

```dockerfile
#
# 基础镜像：qiuchenjun/hgdb-see:4.5.8
# 数据库：hgdb-see-4.5.8-x86_64
# 扩展：hgdb-see-4.5.8-postgis3.1.tar.gz
#
FROM qiuchenjun/hgdb-see:4.5.8
# 添加 PostGIS 扩展包
ADD hgdb-see-4.5.8-postgis3.1.tar.gz /

```

构建命令：

```bash
docker build -t qiuchenjun/hgdb-see-postgis:4.5.8 .
```

## 5.2 运行扩展镜像

容器运行命令：

```bash
docker run -dit --name=myhgdb-see-4.5.8 -p 5866:5866 \
           -v /home/hgdb458:/home/highgo/hgdb \
           -e TZ="Asia/Shanghai" \
           -e LANG="en_US.utf8" \
           -e POSTGRES_HOST_AUTH_METHOD="sm3" \
           -e POSTGRES_PASSWORD="Hello@1234" \
           -e POSTGRES_INITDB_ARGS="-e sm4 -c 'echo 12345678' -E 'UTF8'" \
           qiuchenjun/hgdb-see-postgis:4.5.8
```

## 5.3 使用方式

创建用户和数据库：

```bash
docker exec -i -e PGPASSWORD=Hello@1234 myhgdb-see-4.5.8 psql highgo sysdba <<-"EOF"
create user test password 'Hello@123' valid until 'infinity';
create database testdb with owner=test encoding=utf8 connection limit=-1;
EOF
```

>   **说明：**
>
>   这里假设我们要在数据库`testdb`上使用扩展，数据库用户是`test`，密码是`Hello@123`.

使用管理员`sysdba`在数据库`testdb`上创建扩展，首先关闭三权：

```bash
# 首先关闭三权
docker exec -i -e PGPASSWORD=Hello@1234 myhgdb-see-4.5.8 psql highgo syssso <<-"EOF"
select set_secure_param('hg_sepofpowers','off');
EOF
# 重启容器
docker restart myhgdb-see-4.5.8
```

创建扩展：

```bash
docker exec -i -e PGPASSWORD=Hello@1234 myhgdb-see-4.5.8 psql testdb sysdba <<-"EOF"
create extension postgis;
EOF
```

>   说明：
>
>   注意数据库是你的数据库`testdb`，还要使用`sysdba`进行安装，其他用户无权限创建扩展。

重新开启三权：

```bash
# 开启三权
docker exec -i -e PGPASSWORD=Hello@1234 myhgdb-see-4.5.8 psql highgo syssso <<-"EOF"
select set_secure_param('hg_sepofpowers','on');
EOF
# 重启容器
docker restart myhgdb-see-4.5.8
```

验证扩展：

```bash
docker exec -i -e PGPASSWORD=Hello@123 myhgdb-see-4.5.8 psql testdb test <<-"EOF"
SELECT PostGIS_Version();
SELECT ST_AsText(ST_GeomFromText('POINT(1 1)'));
EOF
```

结果显示：

```bash
            postgis_version            
---------------------------------------
 3.1 USE_GEOS=1 USE_PROJ=1 USE_STATS=1
(1 row)

 st_astext  
------------
 POINT(1 1)
(1 row)
```

