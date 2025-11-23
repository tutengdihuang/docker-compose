#!/bin/bash
# Kafka 日志收集脚本
# 将所有日志收集到当前目录的 logs 文件夹

LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

echo "正在收集 Kafka 日志..."

# 收集 Docker 容器日志
if docker ps | grep -q kafka; then
    echo "收集 Docker 容器日志..."
    docker logs kafka > "$LOG_DIR/docker-kafka-$(date +%Y%m%d-%H%M%S).log" 2>&1
    docker logs kafka-map > "$LOG_DIR/docker-kafka-map-$(date +%Y%m%d-%H%M%S).log" 2>&1
fi

# 收集容器内的 Kafka 应用日志
if docker exec kafka test -d /opt/bitnami/kafka/logs 2>/dev/null; then
    echo "收集 Kafka 应用日志..."
    docker exec kafka tar czf - -C /opt/bitnami/kafka/logs . 2>/dev/null | tar xzf - -C "$LOG_DIR" 2>/dev/null || true
fi

# 收集系统日志（如果存在）
if [ -f /var/log/syslog ]; then
    echo "收集系统日志（Kafka相关）..."
    grep -i kafka /var/log/syslog > "$LOG_DIR/syslog-kafka-$(date +%Y%m%d-%H%M%S).log" 2>/dev/null || true
fi

echo "日志收集完成！日志保存在: $LOG_DIR"
ls -lh "$LOG_DIR"

