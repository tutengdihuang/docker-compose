#!/bin/bash
# Kafka 实时日志查看脚本

LOG_DIR="./logs"

echo "=== Kafka 日志查看工具 ==="
echo "1. 查看 Docker 容器日志（实时）"
echo "2. 查看最新的日志文件"
echo "3. 查看所有日志文件列表"
echo "4. 收集所有日志"
echo ""

read -p "请选择操作 [1-4]: " choice

case $choice in
    1)
        echo "正在显示 Kafka 容器实时日志（按 Ctrl+C 退出）..."
        docker logs -f kafka
        ;;
    2)
        echo "最新的日志文件："
        ls -lht "$LOG_DIR"/*.log 2>/dev/null | head -5
        echo ""
        read -p "输入要查看的文件名（或按回车查看最新的）: " logfile
        if [ -z "$logfile" ]; then
            logfile=$(ls -t "$LOG_DIR"/*.log 2>/dev/null | head -1)
        fi
        if [ -f "$logfile" ]; then
            tail -100 "$logfile"
        else
            echo "文件不存在: $logfile"
        fi
        ;;
    3)
        echo "所有日志文件："
        ls -lh "$LOG_DIR"/*.log 2>/dev/null
        ;;
    4)
        ./collect-logs.sh
        ;;
    *)
        echo "无效选择"
        exit 1
        ;;
esac

