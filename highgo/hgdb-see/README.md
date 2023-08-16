# 瀚高数据库安全版

便于等保分保密评等安全评审。



# 如何扩展运行镜像

现在可以用自己制作的镜像，也可以从在线仓库里拉取一个镜像来运行。

## 运行镜像

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
