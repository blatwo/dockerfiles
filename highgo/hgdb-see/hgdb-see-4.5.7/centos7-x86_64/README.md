现在很多软件都喜欢以容器方式来运行，`PostgreSQL`也不例外，在[dockerhub](https://hub.docker.com/)上有不同PG版本的官方镜像（最新的是PG15），可以直接在线构建使用。具体介绍和使用可以参见官方链接https://hub.docker.com/_/postgres，也可以参考已翻译好的操作部分，链接https://pgfans.cn/a/2110。

基于PG的其他数据库也可以参照官方镜像的制作。官方镜像制作的脚本都存放在[Github](https://github.com/docker-library/postgres)上，链接为https://github.com/docker-library/postgres。下面我以`瀚高数据库安全版v4.5.7`为例，给大家分享一下镜像的制作过程。鉴于篇幅，脚本部分已经通过链接的方式来展现给大家。

# 导读

瀚高数据库v4.5.7的目前安装方式主要有二进制安装（`rpm`或`deb`包），为了更快上手体验，以及使多个异构数据库共存在于一台宿主机，我们就可以考虑使用`Docker`容器来运行它，这样各厂商的数据库之间就不会互相影响了。如果你已经有了`Docker`环境，那就可以跳过第一部分；如果你不想自己制作镜像，可以跳过第二部分，直接到第三、四部分运行[Docker hub](https://hub.docker.com/)上的[瀚高数据库镜像](https://hub.docker.com/r/qiuchenjun/hgdb)（非官方制作，仅供测试体验）和使用即可。

本文基于`Centos7.9_x86-64`的宿主机上进行实验的，Docker版本`20.10.23`，基于基础镜像`debian:bullseye-slim`制作。

截至发稿，Docker版本`23.0.1`也已经发布了，经过测试也能用，只不过第一次构建容器时，要等1-2分钟才开始初始化数据库实例。

`Here we go!!! >>>`

------

# 一、Docker 安装

使用 Docker 运行瀚高数据库之前，需要有一个 Docker 环境，推荐使用`YUM`安装。

## 1.1 设置 Docker 的 YUM 资源库

安装`yum-utils`包（它提供实用程序`yum-config-manager`）并设置资源库。

```bash
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```

## 1.2 安装 Docker Engine

安装最新版本的`Docker Engine`、`containerd`和`Docker Compose`：

```bash
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

这个命令会安装 Docker，但不会启动 Docker。

上面默认安装最新版本，如果要安装指定版本，如：`20.10.23`，按照如下命令来安装：

```bash
sudo yum install docker-ce-20.10.23 docker-ce-cli-20.10.23 containerd.io docker-compose-plugin 
```

## 1.3 查看版本并启动

查看已安装的 Docker 版本：

```bash
docker -v
```

> 结果：Docker version 20.10.23, build baeda1f

启动：

```bash
systemctl start docker
```

其他安装方式，请根据操作系统版本以及个人习惯安装，这里不再详细赘述。

# 二、镜像制作

想自己制作`瀚高数据库镜像`的小伙伴，可以参考制作看看，如有更好的`构建脚本`可以交流一下。作者主要遵循官方的脚本来构建，做了部分修改来满足数据库的构建需要。构建使用的脚本均已传到`Github`上，链接为`https://github.com/blatwo/dockerfiles.git`

## 2.1 前期准备

### 2.1.1 构建目录

一般来说，我们需要为瀚高数据库单独建个目录，如：dfhgdb（根据自己想法命名即可），便于把相关资源集中管理：

```bash
mkdir dfhgdb
cd dfhgdb/
```

### 2.1.2 相关文件

瀚高数据库的二进制包中包含了较多工具，占用空间较大，我们只提取出与`数据库服务相关的文件`放到构建目录`dfhgdb`下即可。把安装后的目录`/opt/highgo/hgdb-see-4.5.7/`压缩成`hgdb-see-4.5.7.tar.gz`，上传到构建目录。

```bash
解压其中的：./opt/highgo/hgdb-see-4.5.7/*
[root@S1 ~]# rpm2cpio hgdb-see-4.5.7-95821fb.x86_64.rpm | cpio -div ./opt/highgo/hgdb-see-4.5.7/*

[root@S1 ~]# tar -czvf hgdb-see-4.5.7.tar.gz ./opt/
[root@S1 ~]# ll
total 393844
-rw-------. 1 root root      1329 Oct 31  2021 anaconda-ks.cfg
drwxr-xr-x. 1 root root       174 Mar 12 18:39 dfhgdb
-rw-r--r--. 1 root root 296118669 Mar 15 14:45 hgdb-see-4.5.7-95821fb.x86_64.rpm
-rw-r--r--. 1 root root        68 Mar 15 14:41 hgdb-see-4.5.7-95821fb.x86_64.rpm.md5
-rw-r--r--. 1 root root 107165167 Mar 16 23:56 hgdb-see-4.5.7-95821fb.x86_64.tar.gz
drwxr-xr-x. 1 root root        12 Mar 16 23:50 opt
```

由于基础镜像中没有`openssl`，事实上也没必要安装，只要能生成`root.crt`、`server.crt`、`server.key`并放到这个目录`dfhgdb`下备用即可。

## 2.2 构建脚本 Dockerfile

**文件链接**：GitHub 链接 [Dockerfile](https://github.com/blatwo/dockerfiles/blob/main/highgodb/hgdb-see/hgdb-see-4.5.7/bullseye-x86_64/Dockerfile)

**官方文件**：https://github.com/docker-library/postgres/blob/master/15/bullseye/Dockerfile

**文件说明**：由于篇幅问题，这里不再赘述，可以我在[pgfans](https://pgfans.cn/)上发布的文章https://pgfans.cn/a/2108

## 2.3 入口点脚本 docker-entrypoint.sh

**文件链接**：GitHub 链接 [docker-entrypoint.sh](https://github.com/blatwo/dockerfiles/blob/main/highgodb/hgdb-see/hgdb-see-4.5.7/bullseye-x86_64/docker-entrypoint.sh)

**官方文件**：https://github.com/docker-library/postgres/blob/master/15/bullseye/docker-entrypoint.sh

**脚本说明**：由于篇幅问题，这里不再赘述，可以我在[pgfans](https://pgfans.cn/)上发布的文章https://pgfans.cn/a/2113

## 2.4 配置脚本 setup.sh

**文件链接**：GitHub 链接 [setup.sh](https://github.com/blatwo/dockerfiles/blob/main/highgodb/hgdb-see/hgdb-see-4.5.7/bullseye-x86_64/setup.sh)

**脚本说明**：该脚本是瀚高数据库安装完后的一些常见配置，里面包括一些注释了。

将前面这些文件都传到目录下。最终，构建目录下内容如下：

```bash
[root@S1 ~]# ll dfhgdb/
total 126320
-rw-r--r--. 1 root root     14587 Mar 11 22:57 docker-entrypoint.sh
-rw-r--r--. 1 root root      4142 Mar 11 22:57 Dockerfile
-rw-r--r--. 1 root root 129309345 Dec 19 13:42 hgdb-see-4.5.7.tar.gz
-rw-r--r--. 1 root root      1338 Dec  5 16:06 root.crt
-rw-r--r--. 1 root root      1338 Dec  5 16:06 server.crt
-rw-r--r--. 1 root root      1679 Dec  5 16:06 server.key
-rw-r--r--. 1 root root      2160 Feb  9 00:08 setup.sh
```

## 2.5 开始构建

准备好后，就可以构建镜像了。构建命令如下：

```bash
docker build -t qiuchenjun/hgdb-see:4.5.7 .
```

构建完后，查看本地镜像：

```bash
[root@S1 ~]# docker images
结果：
REPOSITORY            TAG       IMAGE ID       CREATED         SIZE
qiuchenjun/hgdb-see   4.5.7     9796fd136a9b   7 minutes ago   461MB
```



# 三、运行镜像

现在可以用自己制作的镜像，也可以从在线仓库里拉取一个镜像来运行。

## 3.1 运行镜像

一般来，在`Linux`系统执行以下命令来运行即可：

```bash
docker run -dit --name=my-hgdb457 -p 5866:5866 \
           -v /home/hgdb457/data:/home/highgo/data \
           -e TZ="Asia/Shanghai" \
           -e LANG="en_US.utf8" \
           -e POSTGRES_HOST_AUTH_METHOD="sm3" \
           -e POSTGRES_PASSWORD="Hello@123" \
           -e POSTGRES_INITDB_ARGS="-e sm4 -c 'echo 12345678' -E 'UTF8'" \
           qiuchenjun/hgdb-see:4.5.7
```

在`Windows`下执行：

```bash
docker run -dit --name=my-hgdb457 -p 5866:5866 `
           -v D:\hgdata\hgdb457\data:/home/highgo/data `
           -e TZ="Asia/Shanghai" `
           -e LANG="en_US.utf8" `
           -e POSTGRES_HOST_AUTH_METHOD="sm3" `
           -e POSTGRES_PASSWORD="Hello@123" `
           -e POSTGRES_INITDB_ARGS="-e sm4 -c 'echo 12345678' -E 'UTF8'" `
           qiuchenjun/hgdb-see:4.5.7
```



> 说明：
>
> 1. 通过`--name`为构建后的容器命名`my-hgdb457`，`-p`为宿主机端口与容器端口的映射。如果需要运行多个数据库容器，这里使用不同的命名以及不同的端口是最合适不过的；
> 2. 使用`-v`将宿主机目录映射到容器目录，这样可以从宿主机找到数据所在；
> 3. 通过`TZ`和`LANG`可以设置时区和字符集；
> 4. `POSTGRES_HOST_AUTH_METHOD` 用来设置客户端访问密码加密方式；
> 5. `POSTGRES_PASSWORD` 设置三权用户的密码；
> 6. `POSTGRES_INITDB_ARGS` 设置其他参数；
> 7. 授权文件请放到目录`/home/hgdb457/hgdb/data`下，命名为`hgdb.lic`，每次重启都会加载它。如果不想每次重启都加载，加载完后，从本地的data目录下删掉即可。

## 3.2 在线仓库镜像

已构建的镜像已经上传[docker仓库](https://hub.docker.com/r/qiuchenjun/hgdb-see)，更详细的操作说明可以参考这个链接。

如果不想自己制作，可以直接通过上面命令运行它，会自动拉去最新的。果想拉取指定版本的镜像，命令如下：

```bash
docker pull qiuchenjun/hgdb:v4.5.7
```



# 四、容器操作

容器运行后，就可以连接数据库服务进行操作了。这里简单讲述一些操作，更多操作请参见[官方使用说明（翻译）](https://pgfans.cn/a/2110)。

## 4.1 数据库配置

安全版数据库镜像构建容器实例时，已经通过setup.sh进行了一系列常见配置。额外的配置可以通过客户端执行SQL命令，或者有必要则进入容器修改。

进入容器的命令如下：

```bash
docker exec -it my-hgdb457 bash
```

这样你就跟进入一个Linux环境一样，进行操作了。只不过，命令工具不如自己完整安装的操作系统那样丰富。

也可以从宿主机直接登录`psql`：

```bash
docker exec -it my-hgdb457 gosu highgo psql highgo sysdba
```

然后就可以执行`psql`相关命令了。需要注意的是前面的`highgo`是容器操作系统用户，而后面的`highgo`是默认数据库，`sysdba`是三权用户之一的DBA用户。

改完配置，如果需要重启，则重启一下容器即可。重启命令如下：

```bash
docker restart my-hgdb457
```

## 4.2 授权安装

把授权放到`$PGDATA`对应的宿主机目录下，且文件名为`hgdb.lic`。如：上传宿主机映射目录`/home/hgdb457/data`，立即生效。检查命令：

```bash
docker exec -it my-hgdb457 gosu highgo check_lic
```



# 后记

好了，这就是我分享给大家的瀚高数据库镜像构建和使用，后面我们可以多讨论构建的方法以及使用过程中的实践操作。

------

`<<< There you go!!!`
