#!/bin/bash

# Consul 服务初始化脚本
# 在 Consul 启动后自动注册默认服务

CONSUL_URL="${CONSUL_URL:-http://consul-north:8500}"
MAX_RETRIES=30
RETRY_INTERVAL=2

echo "🚀 开始初始化 Consul 服务..."

# 等待 Consul 服务启动
wait_for_consul() {
    echo "⏳ 等待 Consul 服务启动..."
    for i in $(seq 1 $MAX_RETRIES); do
        if curl -s "$CONSUL_URL/v1/status/leader" > /dev/null 2>&1; then
            echo "✅ Consul 服务已启动"
            return 0
        fi
        echo "  尝试 $i/$MAX_RETRIES..."
        sleep $RETRY_INTERVAL
    done
    echo "❌ Consul 服务启动超时"
    return 1
}

# 注册 Prometheus 服务
register_prometheus() {
    echo "📊 注册 Prometheus 服务..."
    curl -X PUT --data '{
        "Name": "prometheus",
        "ID": "prometheus-192.168.100.200-9090",
        "Address": "192.168.100.200",
        "Port": 9090,
        "Tags": [
            "app=north_prometheus",
            "area=north",
            "biz=基础环境智能监控平台prometheus",
            "cluster=北中心",
            "env=生产",
            "instance=192.168.100.200",
            "job=linux",
            "replica=0",
            "support=v1",
            "tmp_hash=1"
        ],
        "Check": {
            "HTTP": "http://192.168.100.200:9090/-/healthy",
            "Interval": "10s",
            "Timeout": "5s"
        }
    }' "$CONSUL_URL/v1/agent/service/register"
    
    if [ $? -eq 0 ]; then
        echo "✅ Prometheus 服务注册成功"
    else
        echo "❌ Prometheus 服务注册失败"
        return 1
    fi
}

# 注册 Windows Exporter 服务
register_windows_exporter() {
    echo "🪟 注册 Windows Exporter 服务..."
    curl -X PUT --data '{
        "Name": "windows-exporter",
        "ID": "windows-exporter-192.168.100.200-9182",
        "Address": "windows-exporter",
        "Port": 80,
        "Tags": [
            "app=north_windows",
            "area=north",
            "biz=基础环境智能监控平台windows",
            "cluster=北中心",
            "env=生产",
            "instance=192.168.100.200",
            "job=linux",
            "replica=0",
            "support=v1",
            "tmp_hash=1"
        ],
        "Check": {
            "HTTP": "http://windows-exporter:80/metrics",
            "Interval": "10s",
            "Timeout": "5s"
        }
    }' "$CONSUL_URL/v1/agent/service/register"
    
    if [ $? -eq 0 ]; then
        echo "✅ Windows Exporter 服务注册成功"
    else
        echo "❌ Windows Exporter 服务注册失败"
        return 1
    fi
}

# 注册 Node Exporter 服务（示例）
register_node_exporter() {
    echo "🖥️  注册 Node Exporter 服务..."
    curl -X PUT --data '{
        "Name": "node-exporter",
        "ID": "node-exporter-192.168.100.201-9100",
        "Address": "node-exporter-north",
        "Port": 9100,
        "Tags": [
            "app=north_node",
            "area=north",
            "biz=基础环境智能监控平台linux",
            "cluster=北中心",
            "env=生产",
            "instance=192.168.100.201",
            "job=linux",
            "replica=0",
            "support=v1",
            "tmp_hash=1"
        ],
        "Check": {
            "HTTP": "http://node-exporter-north:9100/metrics",
            "Interval": "10s",
            "Timeout": "5s"
        }
    }' "$CONSUL_URL/v1/agent/service/register"
    
    if [ $? -eq 0 ]; then
        echo "✅ Node Exporter 服务注册成功"
    else
        echo "❌ Node Exporter 服务注册失败"
        return 1
    fi
}

# 显示注册结果
show_registered_services() {
    echo ""
    echo "📋 已注册的服务列表："
    curl -s "$CONSUL_URL/v1/agent/services" | jq -r 'keys[] as $k | "  - \($k): \(.[$k].Service) (\(.[$k].Address):\(.[$k].Port))"'
}

# 主执行流程
main() {
    # 等待 Consul 启动
    if ! wait_for_consul; then
        exit 1
    fi
    
    # 注册服务
    register_prometheus
    register_windows_exporter
    register_node_exporter
    
    # 显示结果
    show_registered_services
    
    echo ""
    echo "🎉 服务初始化完成！"
    echo "📊 Consul UI: http://localhost:8500"
    echo "📈 Prometheus: http://localhost:9090"
}

# 执行主函数
main "$@" 