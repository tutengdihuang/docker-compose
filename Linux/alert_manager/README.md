# 🚀 自动初始化 Consul 服务配置

## 📋 概述

现在，当你运行 `docker-compose up -d` 时，系统会自动：
1. 启动所有监控服务
2. 等待 Consul 健康检查通过
3. 自动运行 `init_services.sh` 脚本注册服务

## ⚡ 快速开始

```bash
# 一键启动所有服务并自动初始化
docker-compose up -d

# 查看初始化日志
docker logs consul-init
```

## 🔧 工作原理

### 服务依赖关系
```
consul-init (初始化容器)
├── depends_on: consul (健康检查通过)
├── depends_on: prometheus (服务启动)
├── depends_on: windows-exporter (服务启动)
└── depends_on: node-exporter (服务启动)
```

### 初始化流程
1. **Consul健康检查**: 确保Consul服务完全启动并可用
2. **依赖服务检查**: 确保所有被监控的服务已启动
3. **自动注册**: 运行 `init_services.sh` 注册所有服务到Consul
4. **容器退出**: 初始化完成后，`consul-init`容器会自动退出

## 📊 自动注册的服务

| 服务名称 | 地址 | 端口 | 健康检查 |
|---------|------|------|---------|
| **prometheus** | prometheus:9090 | 9090 | `/-/ready` |
| **windows-exporter** | windows-exporter:80 | 80 | `/metrics` |
| **node-exporter** | node-exporter:9100 | 9100 | `/metrics` |

## 🔍 验证自动初始化

### 1. 检查容器状态
```bash
# 查看所有容器状态
docker ps -a

# consul-init 应该显示为 "Exited (0)" 状态
```

### 2. 检查初始化日志
```bash
# 查看初始化过程日志
docker logs consul-init

# 应该看到：
# ✅ Consul 服务已启动
# ✅ Prometheus 服务注册成功  
# ✅ Windows Exporter 服务注册成功
# ✅ Node Exporter 服务注册成功
# 🎉 服务初始化完成！
```

### 3. 验证服务注册
```bash
# 查看Consul中注册的服务
curl -s http://localhost:8500/v1/agent/services

# 查看服务健康状态
curl -s http://localhost:8500/v1/health/state/any
```

### 4. 访问监控界面
- **Consul UI**: http://localhost:8500
- **Prometheus**: http://localhost:9090
- **Thanos Query**: http://localhost:10903
- **AlertManager**: http://localhost:9093

## 🛠️ 自定义配置

### 修改初始化脚本
```bash
# 编辑初始化脚本
vim Linux/alert_manager/consul_config/init_services.sh

# 重新启动以应用更改
docker-compose up -d --force-recreate consul-init
```

### 环境变量配置
初始化脚本会自动使用容器内网络：
- `CONSUL_URL`: 默认为 `http://consul:8500`
- 服务地址: 使用容器名称而不是localhost

## 🔄 重新初始化

如果需要重新运行初始化：
```bash
# 方法1: 重新创建初始化容器
docker-compose up -d --force-recreate consul-init

# 方法2: 手动运行初始化脚本
docker-compose exec consul-init /tmp/init_services.sh

# 方法3: 完全重启
docker-compose down && docker-compose up -d
```

## ⚠️ 注意事项

1. **依赖关系**: `consul-init` 只有在Consul健康检查通过后才会启动
2. **一次性运行**: 初始化容器运行一次后会自动退出（`restart: "no"`）
3. **网络配置**: 脚本使用容器内网络地址，不是localhost
4. **权限问题**: 脚本被复制到 `/tmp/` 目录以避免只读文件系统问题

## 🐛 故障排查

### 初始化失败
```bash
# 查看初始化容器日志
docker logs consul-init

# 检查Consul是否健康
curl http://localhost:8500/v1/status/leader

# 手动运行初始化
docker-compose exec consul-init /tmp/init_services.sh
```

### 服务健康检查失败
```bash
# 检查具体服务状态
curl http://localhost:8500/v1/health/service/SERVICE_NAME

# 测试服务连通性
docker exec consul curl http://windows-exporter:80/metrics
```

---

🎉 **现在你可以一键启动完整的监控系统！** 