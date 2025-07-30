#!/bin/bash

# Consul服务注册脚本
# 使用方法: ./register_service.sh <service_name> <service_id> <address> <port> <tags_json>

CONSUL_URL="http://localhost:8500"

if [ $# -lt 5 ]; then
    echo "使用方法: $0 <service_name> <service_id> <address> <port> <tags_json>"
    echo "示例: $0 windows-exporter windows-exporter-192.168.100.200-9182 192.168.100.200 9182 '[\"app=None\",\"area=全国\",\"biz=基础环境智能监控平台windows\",\"cluster=北中心\",\"env=生产\",\"instance=192.168.100.200\",\"job=linux_prod\",\"replica=0\",\"support=v1\",\"tmp_hash=1\"]'"
    exit 1
fi

SERVICE_NAME=$1
SERVICE_ID=$2
ADDRESS=$3
PORT=$4
TAGS=$5

# 构建服务注册JSON
SERVICE_JSON=$(cat <<EOF
{
  "Name": "$SERVICE_NAME",
  "ID": "$SERVICE_ID",
  "Address": "$ADDRESS",
  "Port": $PORT,
  "Tags": $TAGS,
  "Check": {
    "HTTP": "http://$ADDRESS:$PORT/metrics",
    "Interval": "10s",
    "Timeout": "5s"
  }
}
EOF
)

echo "注册服务: $SERVICE_NAME"
echo "服务ID: $SERVICE_ID"
echo "地址: $ADDRESS:$PORT"

# 发送注册请求
curl -X PUT \
  --data "$SERVICE_JSON" \
  "$CONSUL_URL/v1/agent/service/register"

if [ $? -eq 0 ]; then
    echo "✅ 服务注册成功"
else
    echo "❌ 服务注册失败"
    exit 1
fi 