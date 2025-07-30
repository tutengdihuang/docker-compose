#!/bin/bash

# 批量服务注册脚本
# 使用方法: ./batch_register.sh [services_file]

CONSUL_URL="http://localhost:8500"
SERVICES_FILE="${1:-example_services.json}"

if [ ! -f "$SERVICES_FILE" ]; then
    echo "❌ 服务配置文件不存在: $SERVICES_FILE"
    exit 1
fi

echo "📋 开始批量注册服务..."
echo "配置文件: $SERVICES_FILE"
echo "Consul地址: $CONSUL_URL"
echo ""

# 检查Consul连接
if ! curl -s "$CONSUL_URL/v1/status/leader" > /dev/null; then
    echo "❌ 无法连接到Consul服务: $CONSUL_URL"
    echo "请确保Consul服务正在运行"
    exit 1
fi

# 使用jq解析JSON文件并注册服务
jq -r '.services[] | "\(.name) \(.id) \(.address) \(.port) \(.tags | @json)"' "$SERVICES_FILE" | while read -r name id address port tags; do
    echo "🔄 注册服务: $name ($id)"
    
    # 构建服务注册JSON
    SERVICE_JSON=$(cat <<EOF
{
  "Name": "$name",
  "ID": "$id",
  "Address": "$address",
  "Port": $port,
  "Tags": $tags,
  "Check": {
    "HTTP": "http://$address:$port/metrics",
    "Interval": "10s",
    "Timeout": "5s"
  }
}
EOF
)
    
    # 发送注册请求
    if curl -s -X PUT --data "$SERVICE_JSON" "$CONSUL_URL/v1/agent/service/register" > /dev/null; then
        echo "✅ $name 注册成功"
    else
        echo "❌ $name 注册失败"
    fi
done

echo ""
echo "🎉 批量注册完成！"
echo "查看已注册的服务: curl $CONSUL_URL/v1/agent/services" 