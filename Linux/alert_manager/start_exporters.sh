#!/bin/bash

# Exporter 启动脚本
# 用于启动三环境的所有 Exporter 服务，包含自动健康检查

echo "=== 🚀 启动三环境 Exporter 服务 ==="

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker"
    exit 1
fi

# 停止旧的容器
echo "🛑 停止现有的容器..."
docker-compose down

# 拉取最新镜像
echo "📦 拉取最新镜像..."
docker-compose pull

# 启动所有服务（包含自动健康检查）
echo "🚀 启动所有服务..."
docker-compose up -d

# 等待健康检查完成
echo "⏳ 等待健康检查初始化容器完成..."
echo "   (这可能需要几分钟时间...)"

# 监控健康检查容器状态
check_init_container() {
    local max_wait=300  # 5分钟超时
    local elapsed=0
    local interval=10
    
    while [ $elapsed -lt $max_wait ]; do
        local status=$(docker inspect health-check-init --format='{{.State.Status}}' 2>/dev/null || echo "not_found")
        
        case $status in
            "exited")
                local exit_code=$(docker inspect health-check-init --format='{{.State.ExitCode}}' 2>/dev/null || echo "1")
                if [ "$exit_code" = "0" ]; then
                    echo "✅ 健康检查完成：所有服务正常"
                    return 0
                else
                    echo "⚠️  健康检查完成：部分服务异常 (退出码: $exit_code)"
                    return 1
                fi
                ;;
            "running")
                echo "⏳ 健康检查进行中... (已等待 ${elapsed}s)"
                ;;
            "not_found")
                echo "❌ 健康检查容器未找到"
                return 1
                ;;
            *)
                echo "⚠️  健康检查容器状态: $status"
                ;;
        esac
        
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    
    echo "⏰ 健康检查超时"
    return 1
}

# 执行健康检查监控
if check_init_container; then
    echo ""
    echo "📋 查看详细健康检查日志:"
    echo "   docker logs health-check-init"
else
    echo ""
    echo "📋 查看健康检查日志以了解详情:"
    echo "   docker logs health-check-init"
fi

# 检查服务状态
echo "=== 📊 服务状态检查 ==="

# 检查各环境 Prometheus
echo "🔍 检查 Prometheus 服务:"
curl -s http://localhost:9090/-/ready && echo "✅ North Prometheus (9090): Ready" || echo "❌ North Prometheus (9090): Failed"
curl -s http://localhost:9091/-/ready && echo "✅ South Prometheus (9091): Ready" || echo "❌ South Prometheus (9091): Failed"
curl -s http://localhost:9092/-/ready && echo "✅ Test Prometheus (9092): Ready" || echo "❌ Test Prometheus (9092): Failed"

echo ""
echo "🔍 检查 Node Exporter 服务:"
curl -s http://localhost:9100/metrics > /dev/null && echo "✅ North Node Exporter (9100): Ready" || echo "❌ North Node Exporter (9100): Failed"
curl -s http://localhost:9101/metrics > /dev/null && echo "✅ South Node Exporter (9101): Ready" || echo "❌ South Node Exporter (9101): Failed"
curl -s http://localhost:9102/metrics > /dev/null && echo "✅ Test Node Exporter (9102): Ready" || echo "❌ Test Node Exporter (9102): Failed"

echo ""
echo "🔍 检查 Process Exporter 服务:"
curl -s http://localhost:9256/metrics > /dev/null && echo "✅ North Process Exporter (9256): Ready" || echo "❌ North Process Exporter (9256): Failed"
curl -s http://localhost:9257/metrics > /dev/null && echo "✅ South Process Exporter (9257): Ready" || echo "❌ South Process Exporter (9257): Failed"
curl -s http://localhost:9258/metrics > /dev/null && echo "✅ Test Process Exporter (9258): Ready" || echo "❌ Test Process Exporter (9258): Failed"

echo ""
echo "🔍 检查 Consul 服务:"
curl -s http://localhost:8500/v1/status/leader > /dev/null && echo "✅ North Consul (8500): Ready" || echo "❌ North Consul (8500): Failed"
curl -s http://localhost:8501/v1/status/leader > /dev/null && echo "✅ South Consul (8501): Ready" || echo "❌ South Consul (8501): Failed"
curl -s http://localhost:8502/v1/status/leader > /dev/null && echo "✅ Test Consul (8502): Ready" || echo "❌ Test Consul (8502): Failed"

echo ""
echo "=== 🌐 访问地址 ==="
echo "📊 Prometheus:"
echo "   North (生产北中心): http://localhost:9090"
echo "   South (生产南中心): http://localhost:9091"
echo "   Test (测试中心):   http://localhost:9092"
echo ""
echo "🔍 Thanos Query:"
echo "   North: http://localhost:10903"
echo "   South: http://localhost:10904"
echo "   Test:  http://localhost:10905"
echo ""
echo "🏥 Consul:"
echo "   North: http://localhost:8500"
echo "   South: http://localhost:8501"
echo "   Test:  http://localhost:8502"
echo ""
echo "📈 Exporters:"
echo "   Node Exporters: 9100 (North), 9101 (South), 9102 (Test)"
echo "   Process Exporters: 9256 (North), 9257 (South), 9258 (Test)"
echo "   Windows Exporters: 6080 (North), 6081 (South), 6082 (Test)"

echo ""
echo "✅ 启动完成！"