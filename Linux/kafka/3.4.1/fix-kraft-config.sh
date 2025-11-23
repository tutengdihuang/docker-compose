#!/bin/bash
# 修复 Bitnami Kafka 3.4.1 KRaft 配置的脚本

CONFIG_FILE="/opt/bitnami/kafka/config/server.properties"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "配置文件不存在: $CONFIG_FILE"
    exit 1
fi

# 备份原配置
cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"

# 移除 legacy 配置
sed -i '/^broker\.id=/d' "$CONFIG_FILE"

# 确保 KRaft 配置存在
if ! grep -q "^process\.roles=" "$CONFIG_FILE"; then
    echo "process.roles=broker,controller" >> "$CONFIG_FILE"
fi

if ! grep -q "^node\.id=" "$CONFIG_FILE"; then
    echo "node.id=1" >> "$CONFIG_FILE"
fi

if ! grep -q "^controller\.quorum\.voters=" "$CONFIG_FILE"; then
    echo "controller.quorum.voters=1@kafka:9093" >> "$CONFIG_FILE"
fi

if ! grep -q "^controller\.listener\.names=" "$CONFIG_FILE"; then
    echo "controller.listener.names=CONTROLLER" >> "$CONFIG_FILE"
fi

# 确保 log.dirs 正确
sed -i 's|^log\.dirs=.*|log.dirs=/bitnami/kafka/data|' "$CONFIG_FILE"
if ! grep -q "^log\.dirs=" "$CONFIG_FILE"; then
    echo "log.dirs=/bitnami/kafka/data" >> "$CONFIG_FILE"
fi

# 确保 metadata.log.dir 存在
if ! grep -q "^metadata\.log\.dir=" "$CONFIG_FILE"; then
    echo "metadata.log.dir=/bitnami/kafka/data" >> "$CONFIG_FILE"
fi

# 确保 inter.broker.listener.name 存在
if ! grep -q "^inter\.broker\.listener\.name=" "$CONFIG_FILE"; then
    echo "inter.broker.listener.name=INTERNAL" >> "$CONFIG_FILE"
fi

# 移除 security.inter.broker.protocol（KRaft 模式下不应该有这个）
sed -i '/^security\.inter\.broker\.protocol=/d' "$CONFIG_FILE"

echo "配置文件已修复"

