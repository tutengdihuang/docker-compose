# Consul

服务发现和配置管理工具

## SMB 挂载配置指南

1. 备份和配置步骤

```shell
# 备份 fstab 文件
sudo cp /etc/fstab /etc/fstab.backup

# 编辑 fstab 文件，添加新的挂载配置
sudo bash -c 'cat >> /etc/fstab << EOF

# Consul data mount
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
ls -la /mnt/mk_data/database/consul_data
```

3. 预期输出

```shell
//192.168.1.200/mk_data on /mnt/mk_data type cifs (rw,relatime,vers=3.1.1,cache=strict,username=admin,uid=999,forceuid,gid=999,forcegid,addr=192.168.1.200,file_mode=0700,dir_mode=0700,soft,nounix,serverino,mapposix,noperm,rsize=4194304,wsize=4194304,bsize=1048576,retrans=1,echo_interval=60,actimeo=1,closetimeo=1)
```

4. 检查挂载权限

```shell
ls -la /mnt/mk_data/database/consul_data

drwx------ 2 999 docker 0 Mar 5 01:25 .
drwx------ 2 999 docker 0 Mar 5 01:51 ..
```

## 运行说明

### 1. 设置数据目录权限

```bash
# 创建数据目录
sudo mkdir -p /mnt/mk_data/database/consul_data

# 设置目录权限
sudo chown -R 999:999 /mnt/mk_data/database/consul_data
sudo chmod -R 700 /mnt/mk_data/database/consul_data
```

### 2. 启动服务

```bash
# 启动 Consul
docker compose up -d

# 查看日志
docker logs -f consul
```

### 3. 访问管理界面

Web UI 地址：http://192.168.1.20:8500

### 4. 常用操作

```bash
# 查看集群成员
docker exec consul consul members

# 查看集群状态
docker exec consul consul info

# 停止服务
docker compose down
```

## 配置说明

- 端口说明：
  - 8500: HTTP API & Web UI
  - 8600: DNS 服务

- 数据目录：
  - 容器内：/consul/data
  - 主机：/mnt/mk_data/database/consul_data

- 环境变量：
  - TZ: 时区设置
  - CONSUL_BIND_INTERFACE: 绑定网络接口

## 注意事项

1. 确保数据目录权限正确
2. 首次启动可能需要几秒钟初始化
3. 使用 DNS 功能需要配置本地 DNS 解析
