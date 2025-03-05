### Nacos

```shell
# 普通单机模式版本  注：需要修改docker-compose-nacos.yml 中相关数据库连接信息和JVM参数相关信息
docker-compose -f docker-compose-nacos.yml -p nacos up -d
```

访问地址：[`ip地址:8848/nacos`](http://www.zhengqingya.com:8848/nacos)
登录账号密码默认：`nacos/nacos`

### 数据目录权限设置

如果使用 SMB 挂载存储，需要正确设置数据目录权限：

```shell
# 检查当前权限
ls -la /mnt/mk_data/database/nacos_data

# 修改所有者为 999:999
sudo chown -R 999:999 /mnt/mk_data/database/nacos_data

# 设置目录权限为 700（只有所有者有读写执行权限）
sudo chmod -R 700 /mnt/mk_data/database/nacos_data

# 验证权限设置
ls -la /mnt/mk_data/database/nacos_data
```

预期输出：
```
drwx------ 2 999 docker 0 Mar 5 21:54 .
drwx------ 2 999 docker 0 Mar 5 21:54 ..
```

完成权限设置后，重启容器使配置生效：
```shell
docker compose -f docker-compose-nacos.yml down
docker compose -f docker-compose-nacos.yml up -d
```



