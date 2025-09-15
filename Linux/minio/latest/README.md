# MinIO 对象存储服务配置

## 🚀 服务状态

✅ **MinIO 服务已成功启动并支持密码认证**

## 📋 配置信息

### 认证信息
- **用户名**: `admin`
- **密码**: `minio123456`
- **API 端口**: `9002`
- **控制台端口**: `9001`

### 访问地址
- **MinIO 控制台**: http://localhost:9001/minio
- **API 端点**: http://localhost:9002

## 🔧 配置详情

### Docker Compose 配置
```yaml
services:
  minio:
    image: minio/minio:latest
    container_name: minio
    restart: unless-stopped
    volumes:
      - "./minio/data:/data"
      - "./minio/minio:/minio"
      - "./minio/config:/root/.minio"
    environment:
      TZ: Asia/Shanghai
      LANG: en_US.UTF-8
      MINIO_PROMETHEUS_AUTH_TYPE: "public"
      MINIO_ROOT_USER: "admin"                        # 登录账号
      MINIO_ROOT_PASSWORD: "minio123456"              # 登录密码
    command: server /data --console-address ":9001"
    ports:
      - "9002:9000"  # API 端口
      - "9001:9001"  # 控制台端口
```

## 📦 Package COS 接口配置

### Go 代码配置示例
```go
config := &Config{
    AccessKey: "admin",
    SecretKey: "minio123456", 
    Endpoint:  "http://localhost:9002",
    Bucket:    "your-bucket-name",
}
```

### 支持的接口
1. ✅ **ListBuckets()** - 列出所有存储桶
2. ✅ **Upload(filename)** - 上传文件
3. ✅ **Download(filename)** - 下载文件
4. ✅ **GetKey(s)** - 路径处理

## 🛠️ 管理命令

### 启动服务
```bash
docker-compose -f docker-compose-minio.yml -p minio up -d
```

### 停止服务
```bash
docker-compose -f docker-compose-minio.yml -p minio down
```

### 查看服务状态
```bash
docker-compose -f docker-compose-minio.yml -p minio ps
```

### 查看日志
```bash
docker logs minio
```

## 🔒 安全特性

- ✅ **密码认证**: 使用强密码 `minio123456`
- ✅ **HTTPS 支持**: 可配置 SSL/TLS
- ✅ **访问控制**: 支持 IAM 策略
- ✅ **数据加密**: 支持服务端加密

## 📊 测试验证

运行测试脚本验证配置：
```bash
go run test_cos.go
```

## 🌐 使用说明

1. **访问控制台**: 打开 http://localhost:9001/minio
2. **登录**: 使用 `admin/minio123456`
3. **创建存储桶**: 在控制台中创建新的存储桶
4. **配置应用**: 使用上述配置信息连接您的应用

## 📝 注意事项

1. **数据持久化**: 数据存储在 `./minio/data` 目录
2. **配置持久化**: 配置存储在 `./minio/config` 目录
3. **端口映射**: API 端口 9002，控制台端口 9001
4. **密码安全**: 生产环境请使用更强的密码

## 🔗 相关链接

- [MinIO 官方文档](https://docs.min.io/)
- [MinIO Docker 指南](https://docs.min.io/docs/minio-docker-quickstart-guide.html)
- [AWS S3 兼容性](https://docs.min.io/docs/aws-cli-with-minio.html)

