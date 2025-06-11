#!/bin/bash

# 停止并删除所有容器
echo "停止并删除 Redis 容器..."
docker compose -f docker-compose-redis-cluster.yml down

# 删除网络（如果存在）
echo "清理网络..."
docker network rm redis 2>/dev/null || true 