#!/bin/bash

# Docker 初始化健康检查脚本
# 用于在容器启动后自动检查所有服务状态

set -e

echo "=== 🚀 Docker 初始化健康检查开始 ==="

# 等待所有服务启动的函数
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1
    
    echo "⏳ 等待 $service_name 启动..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -sf "$url" > /dev/null 2>&1; then
            echo "✅ $service_name 已就绪"
            return 0
        fi
        echo "   尝试 $attempt/$max_attempts - $service_name 未就绪，等待5秒..."
        sleep 5
        attempt=$((attempt + 1))
    done
    
    echo "❌ $service_name 启动超时"
    return 1
}

# 检查服务可用性的函数
check_service() {
    local url=$1
    local service_name=$2
    
    if curl -sf "$url" > /dev/null 2>&1; then
        echo "✅ $service_name: 正常"
        return 0
    else
        echo "❌ $service_name: 异常"
        return 1
    fi
}

# 等待基础服务启动
echo "=== 📊 等待基础服务启动 ==="

# 等待 Consul 服务
wait_for_service "http://consul-north:8500/v1/status/leader" "North Consul"
wait_for_service "http://consul-south:8501/v1/status/leader" "South Consul" 
wait_for_service "http://consul-test:8502/v1/status/leader" "Test Consul"

# 等待 Prometheus 服务
wait_for_service "http://prometheus-north:9090/-/ready" "North Prometheus"
wait_for_service "http://prometheus-south:9091/-/ready" "South Prometheus"
wait_for_service "http://prometheus-test:9092/-/ready" "Test Prometheus"

# 等待 Node Exporter 服务
wait_for_service "http://node-exporter-north:9100/metrics" "North Node Exporter"
wait_for_service "http://node-exporter-south:9100/metrics" "South Node Exporter"
wait_for_service "http://node-exporter-test:9100/metrics" "Test Node Exporter"

# 等待 Process Exporter 服务 (已禁用)
# wait_for_service "http://process-exporter-north:9256/metrics" "North Process Exporter"
# wait_for_service "http://process-exporter-south:9256/metrics" "South Process Exporter"
# wait_for_service "http://process-exporter-test:9256/metrics" "Test Process Exporter"

echo ""
echo "=== 🔍 最终健康检查 ==="

# 最终状态检查
failed_services=0

# Consul 检查
check_service "http://consul-north:8500/v1/status/leader" "North Consul (8500)" || failed_services=$((failed_services + 1))
check_service "http://consul-south:8501/v1/status/leader" "South Consul (8501)" || failed_services=$((failed_services + 1))
check_service "http://consul-test:8502/v1/status/leader" "Test Consul (8502)" || failed_services=$((failed_services + 1))

# Prometheus 检查
check_service "http://prometheus-north:9090/-/ready" "North Prometheus (9090)" || failed_services=$((failed_services + 1))
check_service "http://prometheus-south:9091/-/ready" "South Prometheus (9091)" || failed_services=$((failed_services + 1))
check_service "http://prometheus-test:9092/-/ready" "Test Prometheus (9092)" || failed_services=$((failed_services + 1))

# Node Exporter 检查
check_service "http://node-exporter-north:9100/metrics" "North Node Exporter (9100)" || failed_services=$((failed_services + 1))
check_service "http://node-exporter-south:9100/metrics" "South Node Exporter (9101)" || failed_services=$((failed_services + 1))
check_service "http://node-exporter-test:9100/metrics" "Test Node Exporter (9102)" || failed_services=$((failed_services + 1))

# Process Exporter 检查 (已禁用)
# check_service "http://process-exporter-north:9256/metrics" "North Process Exporter (9256)" || failed_services=$((failed_services + 1))
# check_service "http://process-exporter-south:9256/metrics" "South Process Exporter (9257)" || failed_services=$((failed_services + 1))
# check_service "http://process-exporter-test:9256/metrics" "Test Process Exporter (9258)" || failed_services=$((failed_services + 1))

# Thanos Query 检查
check_service "http://thanos-query-north:10903/-/ready" "North Thanos Query (10903)" || failed_services=$((failed_services + 1))
check_service "http://thanos-query-south:10903/-/ready" "South Thanos Query (10904)" || failed_services=$((failed_services + 1))
check_service "http://thanos-query-test:10903/-/ready" "Test Thanos Query (10905)" || failed_services=$((failed_services + 1))

echo ""
echo "=== 📈 指标验证 ==="

# 验证关键指标是否可用
echo "🔍 验证 Node Exporter 指标..."
if curl -sf "http://node-exporter-north:9100/metrics" | grep -q "node_cpu_seconds_total"; then
    echo "✅ CPU 指标可用"
else
    echo "❌ CPU 指标不可用"
    failed_services=$((failed_services + 1))
fi

if curl -sf "http://node-exporter-north:9100/metrics" | grep -q "node_memory_MemTotal_bytes"; then
    echo "✅ 内存指标可用"
else
    echo "❌ 内存指标不可用"
    failed_services=$((failed_services + 1))
fi

if curl -sf "http://node-exporter-north:9100/metrics" | grep -q "node_load1"; then
    echo "✅ 负载指标可用"
else
    echo "❌ 负载指标不可用"
    failed_services=$((failed_services + 1))
fi

echo "🔍 验证 Process Exporter 指标..."
if curl -sf "http://process-exporter-north:9256/metrics" | grep -q "namedprocess"; then
    echo "✅ 进程指标可用"
else
    echo "❌ 进程指标不可用"
    failed_services=$((failed_services + 1))
fi

echo ""
echo "=== 🌐 服务访问信息 ==="
echo "📊 Prometheus 访问地址:"
echo "   North (生产北中心): http://localhost:9090"
echo "   South (生产南中心): http://localhost:9091"
echo "   Test (测试中心):   http://localhost:9092"
echo ""
echo "🔍 Thanos Query 访问地址:"
echo "   North: http://localhost:10903"
echo "   South: http://localhost:10904"
echo "   Test:  http://localhost:10905"
echo ""
echo "🏥 Consul 访问地址:"
echo "   North: http://localhost:8500"
echo "   South: http://localhost:8501"
echo "   Test:  http://localhost:8502"

echo ""
if [ $failed_services -eq 0 ]; then
    echo "🎉 所有服务启动成功！"
    echo "✅ 初始化完成，系统就绪"
    exit 0
else
    echo "⚠️  有 $failed_services 个服务启动失败"
    echo "❌ 初始化完成，但部分服务异常"
    exit 1
fi