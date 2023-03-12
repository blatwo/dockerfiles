瀚高数据库安全版v4.5的目前安装方式只有二进制安装（`rpm`或`deb`包），为了更快上手体验，以及使多个异构数据库共存在于一台宿主机，我们可以考虑使用`Docker`容器来运行它，这样就不会互相影响了。

# 导读

如果你已经有`Docker`环境，那就可以跳过第一部分；如果你不想自己制作镜像，可以跳过第二部分，直接到第三部分运行[Docker hub](https://hub.docker.com/)上的[瀚高数据库镜像](https://hub.docker.com/r/qiuchenjun/hgdb)（非官方制作，仅供测试体验）。

本文基于宿主机环境`Centos7.9_x86-64`进行实验的，Docker版本`20.10.23`，基于基础镜像`debian:bullseye-slim`制作。

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

# 二、Docker 镜像制作

想自己制作`瀚高数据库镜像`的小伙伴，可以参考制作看看，如有更好的`构建脚本`可以交流一下。作者主要遵循官方的脚本来构建，做了部分修改来满足数据库的构建需要。构建使用的脚本均已传到Github上`https://github.com/blatwo/dockerfiles.git`

## 2.1 前期准备

### 2.1.1 构建目录

一般来说，我们需要为瀚高数据库单独建个目录，便于把相关资源集中管理：

```bash
mkdir dfhgdb
cd dfhgdb/
```

### 2.1.2 相关文件

瀚高数据库的二进制包中包含了较多工具，占用空间较大，我们只提取出与`数据库服务相关的文件`放到构建目录`dfhgdb`下即可。把安装后的目录`/opt/highgo/hgdb-see-4.5.8/`压缩成`hgdb-see-4.5.8.tar.gz`，上传到构建目录。

由于基础镜像中没有`openssl`，事实上也没必要安装，只要能生成`root.crt`、`server.crt`、`server.key`并放到这个目录`dfhgdb`下备用即可。

最终，构建目录下内容如下：

```bash
-rw-r--r--. 1 root root 129309345 Dec 19 13:42 hgdb-see-4.5.8.tar.gz
-rw-r--r--. 1 root root      1338 Dec  5 16:06 root.crt
-rw-r--r--. 1 root root      1338 Dec  5 16:06 server.crt
-rw-r--r--. 1 root root      1679 Dec  5 16:06 server.key
```

## 2.2 构建脚本 Dockerfile

**文件链接**：GitHub 链接 [Dockerfile](https://github.com/blatwo/dockerfiles/blob/main/highgodb/hgdb-see/hgdb-see-4.5.8/bullseye-x86_64/Dockerfile)

**文件说明**：由于篇幅问题，这里不再赘述，可以我在[pgfans](https://pgfans.cn/)上发布的文章https://pgfans.cn/a/2108

**官方文件**：https://github.com/docker-library/postgres/blob/master/15/bullseye/Dockerfile

## 2.3 入口点脚本 docker-entrypoint.sh

**文件链接**：GitHub 链接 [docker-entrypoint.sh](https://github.com/blatwo/dockerfiles/blob/main/highgodb/hgdb-see/hgdb-see-4.5.8/bullseye-x86_64/docker-entrypoint.sh)

**脚本说明**：由于篇幅问题，这里不再赘述，可以我在[pgfans](https://pgfans.cn/)上发布的文章https://pgfans.cn/a/2113

**官方文件**：https://github.com/docker-library/postgres/blob/master/15/bullseye/docker-entrypoint.sh

## 2.4 开始构建

准备好后，就可以构建镜像了。构建命令如下：

```bash
docker build -t qiuchenjun/hgdb-see:4.5.8 .
```

构建玩抽，查看本地镜像：

```bash
[root@S1 ~]# docker images
结果：
REPOSITORY            TAG       IMAGE ID       CREATED         SIZE
qiuchenjun/hgdb-see   4.5.8     3bdfd3151050   5 minutes ago   531MB
```



# 三、运行镜像

现在可以用自己制作的镜像，也可以从在线仓库里拉取一个镜像来运行。

## 3.1 运行镜像

一般来，在`Linux`系统执行以下命令来运行即可：

```bash
docker run -dit --name=myhgdb-see-4.5.8 -p 5866:5866 \
           -v /home/hgdb458:/home/highgo/hgdb \
           -e TZ="Asia/Shanghai" \
           -e LANG="en_US.utf8" \
           -e POSTGRES_HOST_AUTH_METHOD="sm3" \
           -e POSTGRES_PASSWORD="Hello@1234" \
           -e POSTGRES_INITDB_ARGS="-e sm4 -c 'echo 12345678' -E 'UTF8'" \
           qiuchenjun/hgdb-see:4.5.8
```

在`Windows`下执行：

```bash
docker run -dit --name=myhgdb-see-4.5.8 -p 5866:5866 `
           -v D:\hgdata\hgdb458:/home/highgo/hgdb `
           -e TZ="Asia/Shanghai" `
           -e LANG="en_US.utf8" `
           -e POSTGRES_HOST_AUTH_METHOD="sm3" `
           -e POSTGRES_PASSWORD="Hello@1234" `
           -e POSTGRES_INITDB_ARGS="-e sm4 -c 'echo 12345678' -E 'UTF8'" `
           qiuchenjun/hgdb-see:4.5.8
```



> 说明：
>
> 1. 通过`--name`为构建后的容器命名，`-p`为宿主机端口与容器端口的映射。如果需要运行多个数据库容器，这里使用不同的命名以及不同的端口是最合适不过的；
> 2. 使用`-v`将宿主机目录映射到容器目录，这样可以从宿主机找到数据所在；
> 3. 通过`TZ`和`LANG`可以设置时区和字符集；
> 4. `POSTGRES_HOST_AUTH_METHOD` 用来设置客户端访问密码加密方式；
> 5. `POSTGRES_PASSWORD` 设置三权用户的密码；
> 6. `POSTGRES_INITDB_ARGS` 设置其他参数；
> 7. 授权文件请放到目录`/home/hgdb458/hgdb/data`下，命名为`hgdb.lic`，每次重启都会加载它。如果不想每次重启都加载，加载完后，从本地的data目录下删掉即可。

## 3.2 在线仓库镜像

已构建的镜像已经上传[docker仓库](https://hub.docker.com/r/qiuchenjun/hgdb-see)，更详细的操作说明可以参考这个链接。

如果不想自己制作，可以直接通过上面命令运行它，会自动拉去最新的。果想拉取指定版本的镜像，命令如下：

```bash
docker pull qiuchenjun/hgdb:v4.5.8
```



# 四、容器操作

容器运行后，就可以连接数据库服务进行操作了。这里简单讲述一些操作，更多操作请参见[官方使用说明（翻译）](https://pgfans.cn/a/2110)。

## 4.1 数据库配置

安全版数据库镜像构建容器实例时，已经通过setup.sh进行了一系列常见配置。额外的配置可以通过客户端执行SQL命令，或者有必要则进入容器修改。

进入容器的命令如下：

```bash
docker exec -it myhgdb-see-4.5.8 bash
```

这样你就跟进入一个Linux环境一样，进行操作了。只不过，命令工具不如自己完整安装的操作系统那样丰富。

也可以从宿主机直接登录`psql`：

```bash
docker exec -it myhgdb-see-4.5.8 gosu highgo psql highgo sysdba
```

然后就可以执行`psql`相关命令了。需要注意的是前面的`highgo`是容器操作系统用户，而后面的`highgo`是默认数据库，`sysdba`是三权用户之一的DBA用户。

改完配置，如果需要重启，则重启一下容器即可。重启命令如下：

```bash
docker restart myhgdb-see-4.5.8
```

## 4.2 授权安装

首先，把授权放到`$PGDATA`对应的宿主机目录下，且文件名为`hgdb.lic`。如：上传宿主机映射目录`/home/hgdb458/data`：

然后，重启以下容器即可加载授权了。需要注意的是，目前每次重启容器都会自动加载一次，若不像这样重复操作，加载完成后，授权文件从上传目录下删掉即可。



# 后记

好了，这就是我分享给大家的瀚高数据库镜像构建和使用，后面我们可以多讨论构建的方法以及使用过程中的实践操作。

------

`<<< There you go!!!`
