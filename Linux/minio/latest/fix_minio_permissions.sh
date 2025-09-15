#!/bin/bash

# MinIO权限修复脚本
echo "=== MinIO权限修复脚本 ==="

# 检查MinIO容器是否运行
if ! docker ps | grep -q minio; then
    echo "错误：MinIO容器未运行，请先启动MinIO服务"
    echo "运行命令：docker-compose -f docker-compose-minio.yml -p minio up -d"
    exit 1
fi

echo "MinIO容器正在运行..."

# 使用mc客户端配置MinIO
echo "正在配置MinIO权限..."

# 创建mc配置
docker exec minio mc alias set myminio http://localhost:9000 admin minio123456

# 创建monitor-platform存储桶（如果不存在）
echo "创建monitor-platform存储桶..."
docker exec minio mc mb myminio/monitor-platform --ignore-existing

# 设置存储桶为公开读取（如果需要）
echo "设置存储桶权限..."
docker exec minio mc policy set download myminio/monitor-platform

# 或者设置为私有（推荐用于生产环境）
# docker exec minio mc policy set private myminio/monitor-platform

echo "=== 权限配置完成 ==="
echo "现在您可以："
echo "1. 访问控制台：http://localhost:9001/minio"
echo "2. 使用账号：admin"
echo "3. 使用密码：minio123456"
echo "4. 在monitor-platform存储桶中上传文件"
echo ""
echo "如果仍有权限问题，请检查："
echo "1. 文件路径是否正确"
echo "2. 存储桶名称是否正确"
echo "3. 用户权限是否足够"

