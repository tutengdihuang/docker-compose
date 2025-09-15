# MinIO Access Denied 错误解决方案

## 问题描述

您遇到的错误：
```
<Error>
<Code>AccessDenied</Code>
<Message>Access Denied.</Message>
<Key>tmp/download/服务器主机查询合并20250825155435182142.xlsx</Key>
<BucketName>monitor-platform</BucketName>
<Resource>/monitor-platform/tmp/download/服务器主机查询合并20250825155435182142.xlsx</Resource>
<RequestId>185EF3623ED8BC5F</RequestId>
<HostId>dd9025bab4ad464b049177c95eb6ebf374d3b3fd1af9251148b658df7ac2e3e8</HostId>
</Error>
```

## 问题原因

1. **存储桶权限配置不正确**：`monitor-platform` 存储桶没有正确的访问权限
2. **目录结构不存在**：`tmp/download/` 目录可能不存在
3. **文件权限问题**：目标文件可能没有正确的读取权限

## 解决方案

### 1. 自动修复脚本

运行以下脚本自动修复权限问题：

```bash
# 进入MinIO目录
cd /Volumes/mac_data/code/go_code/docker-compose/Linux/minio/latest

# 运行权限修复脚本
./configure_minio_permissions.sh
```

### 2. 手动配置步骤

如果自动脚本无法解决问题，请按以下步骤手动配置：

#### 步骤1：检查MinIO服务状态
```bash
docker-compose -f docker-compose-minio.yml -p minio ps
```

#### 步骤2：配置mc客户端
```bash
docker exec minio mc alias set myminio http://localhost:9000 admin minio123456
```

#### 步骤3：创建存储桶和目录
```bash
# 创建存储桶
docker exec minio mc mb myminio/monitor-platform --ignore-existing

# 创建目录结构
docker exec minio mc cp /dev/null myminio/monitor-platform/tmp/download/.keep
```

#### 步骤4：设置存储桶权限
```bash
# 设置为公开下载权限
docker exec minio mc anonymous set download myminio/monitor-platform

# 验证权限设置
docker exec minio mc anonymous get myminio/monitor-platform
```

### 3. 验证解决方案

#### 测试文件访问
```bash
# 创建测试文件
echo "test content" | docker exec -i minio mc pipe myminio/monitor-platform/tmp/download/test.txt

# 测试访问
curl -I http://localhost:9002/monitor-platform/tmp/download/test.txt
```

#### 访问MinIO控制台
- 地址：http://localhost:9001/minio
- 用户名：admin
- 密码：minio123456

## 配置信息

### MinIO服务配置
- **API端口**：9002
- **控制台端口**：9001
- **用户名**：admin
- **密码**：minio123456
- **存储桶**：monitor-platform
- **访问权限**：公开下载

### 文件访问URL格式
```
http://localhost:9002/monitor-platform/tmp/download/文件名
```

## 常见问题

### 1. 仍然出现Access Denied
- 检查文件路径是否正确
- 确认存储桶名称拼写正确
- 验证文件是否已上传到正确位置

### 2. 存储桶不存在
```bash
# 列出所有存储桶
docker exec minio mc ls myminio

# 创建存储桶
docker exec minio mc mb myminio/monitor-platform
```

### 3. 权限设置失败
```bash
# 检查当前权限
docker exec minio mc anonymous get myminio/monitor-platform

# 重新设置权限
docker exec minio mc anonymous set download myminio/monitor-platform
```

## 安全建议

### 生产环境配置
对于生产环境，建议：

1. **使用私有权限**：
```bash
docker exec minio mc anonymous set private myminio/monitor-platform
```

2. **创建专用用户**：
```bash
# 创建新用户（需要管理员权限）
docker exec minio mc admin user add myminio newuser newpassword
```

3. **设置访问策略**：
```bash
# 创建访问策略
docker exec minio mc admin policy create myminio readonly-policy readonly-policy.json
```

## 相关命令

### 管理命令
```bash
# 启动服务
docker-compose -f docker-compose-minio.yml -p minio up -d

# 停止服务
docker-compose -f docker-compose-minio.yml -p minio down

# 查看日志
docker logs minio

# 重启服务
docker-compose -f docker-compose-minio.yml -p minio restart
```

### 文件操作
```bash
# 上传文件
docker exec minio mc cp localfile.txt myminio/monitor-platform/tmp/download/

# 下载文件
docker exec minio mc cp myminio/monitor-platform/tmp/download/file.txt ./

# 删除文件
docker exec minio mc rm myminio/monitor-platform/tmp/download/file.txt

# 列出文件
docker exec minio mc ls myminio/monitor-platform/tmp/download/
```

## 联系支持

如果问题仍然存在，请：
1. 检查MinIO服务日志：`docker logs minio`
2. 确认网络连接正常
3. 验证端口映射正确
4. 检查防火墙设置

