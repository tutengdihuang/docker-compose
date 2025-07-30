#!/bin/bash

# Consul 启动和初始化脚本

echo "🚀 启动 Consul 监控环境..."

# 检查 Consul 是否已安装
if ! command -v consul &> /dev/null; then
    echo "❌ Consul 未安装，请先安装 Consul"
    echo "   安装命令: brew install consul"
    exit 1
fi

# 检查是否已有 Consul 进程运行
if pgrep -x "consul" > /dev/null; then
    echo "⚠️  Consul 已在运行，跳过启动步骤"
else
    echo "📦 启动 Consul 服务..."
    # 启动 Consul 开发模式
    consul agent -dev -ui -client=0.0.0.0 &
    CONSUL_PID=$!
    echo "✅ Consul 已启动 (PID: $CONSUL_PID)"
fi

# 等待 Consul 完全启动
echo "⏳ 等待 Consul 服务就绪..."
sleep 5

# 运行初始化脚本
echo "🔧 运行服务初始化脚本..."
./consul_config/init_services.sh

echo ""
echo "🎉 Consul 环境启动完成！"
echo ""
echo "📊 访问地址："
echo "   Consul UI: http://localhost:8500"
echo "   Prometheus: http://localhost:9090"
echo "   AlertManager: http://localhost:9093"
echo "   cAdvisor: http://localhost:8080"
echo ""
echo "📋 常用命令："
echo "   查看服务: curl http://localhost:8500/v1/agent/services"
echo "   停止 Consul: pkill consul"
echo "   重新初始化: ./consul_config/init_services.sh" 