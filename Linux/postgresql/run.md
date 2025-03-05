# PostgreSQL

关系型数据库

### 运行

```shell
docker-compose -f docker-compose.yml -p postgresql up -d

# 若运行之后，postgresql启动日志报相关权限问题，给新产生的文件赋予权限
chmod -R 777 ./postgresql/data
```

连接

![postgresql-navicat-connection.png](images/postgresql-navicat-connection.png)

```shell
# 进入容器
docker exec -it postgresql /bin/bash
# 登录
psql -U postgres -W
# 查看版本
select version();
```

## SMB 挂载配置指南
1. 备份和配置步骤

```shell
# 备份 fstab 文件
sudo cp /etc/fstab /etc/fstab.backup

# 编辑 fstab 文件，添加新的挂载配置
sudo bash -c 'cat >> /etc/fstab << EOF

# PostgreSQL data mount
//192.168.1.200/mk_data /mnt/mk_data cifs _netdev,credentials=/home/allen/.smbcredentials,uid=999,gid=999,file_mode=0700,dir_mode=0700,soft,nounix,serverino,mapposix,noperm,cache=strict,rsize=4194304,wsize=4194304,bsize=1048576,retrans=1,echo_interval=60,actimeo=1,closetimeo=1 0 0
EOF'
```

2. 应用配置

```shell
# 卸载现有挂载
sudo umount /mnt/mk_data

# 重新挂载
sudo mount -a

# 验证挂载状态
mount | grep mk_data

# 检查目录权限
ls -la /mnt/mk_data/database/postgres_data
```

3. 预期输出

```shell
//192.168.1.200/mk_data on /mnt/mk_data type cifs (rw,relatime,vers=3.1.1,cache=strict,username=admin,uid=999,forceuid,gid=999,forcegid,addr=192.168.1.200,file_mode=0700,dir_mode=0700,soft,nounix,serverino,mapposix,noperm,rsize=4194304,wsize=4194304,bsize=1048576,retrans=1,echo_interval=60,actimeo=1,closetimeo=1)
```

4. 检查挂载权限

```shell
ls -la /mnt/mk_data/database/postgres_data

drwx------ 2 999 docker 0 Mar 5 01:25 .
drwx------ 2 999 docker 0 Mar 5 01:51 ..
drwx------ 2 999 docker 0 Mar 5 01:59 pgdata
```

5. 重新启动 PostgreSQL 容器

```shell
