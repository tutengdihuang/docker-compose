#!/bin/bash

# 启动 Redis 容器
echo "启动 Redis 容器..."
docker compose -f docker-compose-redis-cluster.yml up -d

# 等待容器启动
echo "等待容器启动..."
sleep 5

# 初始化集群
echo "初始化集群..."
docker exec redis-6381 redis-cli -a 123456 --cluster create \
  172.28.0.11:6379 172.28.0.12:6379 172.28.0.13:6379 \
  172.28.0.14:6379 172.28.0.15:6379 172.28.0.16:6379 \
  172.28.0.18:6379 \
  --cluster-replicas 1 --cluster-yes

# 检查集群状态
echo "检查集群状态..."
docker exec redis-6381 redis-cli -a 123456 cluster info