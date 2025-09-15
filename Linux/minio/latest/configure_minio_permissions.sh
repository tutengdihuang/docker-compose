#!/bin/bash

# MinIO详细权限配置脚本
echo "=== MinIO详细权限配置脚本 ==="

# 检查MinIO容器是否运行
if ! docker ps | grep -q minio; then
    echo "错误：MinIO容器未运行，请先启动MinIO服务"
    echo "运行命令：docker-compose -f docker-compose-minio.yml -p minio up -d"
    exit 1
fi

echo "MinIO容器正在运行..."

# 配置mc客户端
echo "配置mc客户端..."
docker exec minio mc alias set myminio http://localhost:9000 admin minio123456

# 列出现有存储桶
echo "现有存储桶："
docker exec minio mc ls myminio

# 创建monitor-platform存储桶（如果不存在）
echo "创建monitor-platform存储桶..."
docker exec minio mc mb myminio/monitor-platform --ignore-existing

# 创建tmp/download目录结构
echo "创建目录结构..."
docker exec minio mc cp /dev/null myminio/monitor-platform/tmp/download/.keep

# 设置存储桶权限为公开下载
echo "设置存储桶权限为公开下载..."
docker exec minio mc anonymous set download myminio/monitor-platform

# 验证权限设置
echo "验证权限设置..."
docker exec minio mc anonymous get myminio/monitor-platform

# 创建测试文件
echo "创建测试文件..."
echo "test content" | docker exec -i minio mc pipe myminio/monitor-platform/tmp/download/test.txt

echo "=== 权限配置完成 ==="
echo ""
echo "配置信息："
echo "- 存储桶：monitor-platform"
echo "- 访问权限：公开下载"
echo "- 控制台地址：http://localhost:9001/minio"
echo "- API地址：http://localhost:9002"
echo "- 用户名：admin"
echo "- 密码：minio123456"
echo ""
echo "测试访问："
echo "curl -I http://localhost:9002/monitor-platform/tmp/download/test.txt"

