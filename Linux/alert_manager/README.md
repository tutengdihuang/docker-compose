# 🚀 三套监控环境 - 自动化部署方案

## 📋 概述

本项目提供了三套完整的监控环境，每套环境都包含完整的监控栈：
- **🟢 North环境** (生产环境) - 8500端口段
- **🟡 South环境** (预发布环境) - 8501端口段  
- **🔵 Test环境** (测试环境) - 8502端口段

当你运行 `docker-compose up -d` 时，系统会自动：
1. 启动三套完整的监控服务
2. 等待每套环境的Consul健康检查通过
3. 自动运行对应的初始化脚本注册服务

## ⚡ 快速开始

```bash
# 一键启动所有三套环境
docker-compose up -d

# 查看各环境初始化日志
docker logs consul-init-north   # North环境初始化日志
docker logs consul-init-south   # South环境初始化日志
docker logs consul-init-test    # Test环境初始化日志
```

## 🌐 服务端口映射

### 🟢 North环境 (生产环境)
| 服务 | 访问地址 | 描述 |
|------|---------|------|
| **Consul** | http://localhost:8500 | 服务发现与配置 |
| **Prometheus** | http://localhost:9090 | 监控数据收集 |
| **Thanos Query** | http://localhost:10903 | 统一查询接口 |
| **Alertmanager** | http://localhost:9093 | 告警管理 |
| **Node Exporter** | :9100 | Linux系统指标 |
| **Windows Exporter** | :6080 | Windows系统指标 |

### 🟡 South环境 (预发布环境)
| 服务 | 访问地址 | 描述 |
|------|---------|------|
| **Consul** | http://localhost:8501 | 服务发现与配置 |
| **Prometheus** | http://localhost:9091 | 监控数据收集 |
| **Thanos Query** | http://localhost:10904 | 统一查询接口 |
| **Alertmanager** | http://localhost:9094 | 告警管理 |
| **Node Exporter** | :9101 | Linux系统指标 |
| **Windows Exporter** | :6081 | Windows系统指标 |

### 🔵 Test环境 (测试环境)
| 服务 | 访问地址 | 描述 |
|------|---------|------|
| **Consul** | http://localhost:8502 | 服务发现与配置 |
| **Prometheus** | http://localhost:9092 | 监控数据收集 |
| **Thanos Query** | http://localhost:10905 | 统一查询接口 |
| **Alertmanager** | http://localhost:9095 | 告警管理 |
| **Node Exporter** | :9102 | Linux系统指标 |
| **Windows Exporter** | :6082 | Windows系统指标 |

## 🔧 架构原理

### 设计特点
- **环境隔离**: 三套环境完全独立，互不干扰
- **端口规律**: 每个环境端口递增，便于管理
- **自动初始化**: 每套环境都有独立的初始化容器
- **一致性配置**: 每套环境配置结构相同，只是端口不同

### 服务依赖关系
```
consul-init-north/south/test (初始化容器)
├── depends_on: consul-{env} (健康检查通过)
├── depends_on: prometheus-{env} (服务启动)
├── depends_on: windows-exporter-{env} (服务启动)
└── depends_on: node-exporter-{env} (服务启动)
```

### 初始化流程
1. **Consul健康检查**: 确保各环境Consul服务完全启动
2. **依赖服务检查**: 确保各环境被监控的服务已启动
3. **自动注册**: 运行对应环境的 `init_services.sh` 注册服务
4. **容器退出**: 初始化完成后，各`consul-init`容器自动退出

## 🔍 验证部署状态

### 1. 检查容器状态
```bash
# 查看所有容器状态
docker ps -a | grep -E "(consul|prometheus|thanos|alert)"

# 检查各环境Consul健康状态
curl -s http://localhost:8500/v1/status/leader  # North
curl -s http://localhost:8501/v1/status/leader  # South  
curl -s http://localhost:8502/v1/status/leader  # Test
```

### 2. 检查Prometheus服务
```bash
# 检查各环境Prometheus就绪状态
curl -s http://localhost:9090/-/ready  # North
curl -s http://localhost:9091/-/ready  # South
curl -s http://localhost:9092/-/ready  # Test
```

### 3. 验证服务注册
```bash
# 查看各环境注册的服务
curl -s http://localhost:8500/v1/agent/services  # North
curl -s http://localhost:8501/v1/agent/services  # South
curl -s http://localhost:8502/v1/agent/services  # Test

# 检查服务健康状态
curl -s http://localhost:8500/v1/health/state/any  # North
curl -s http://localhost:8501/v1/health/state/any  # South
curl -s http://localhost:8502/v1/health/state/any  # Test
```

## 🛠️ 环境管理

### 单独启动某个环境
```bash
# 只启动North环境
docker-compose up -d consul-north prometheus-north thanos-sidecar-north thanos-query-north alertmanager-north node-exporter-north windows-exporter-north consul-init-north

# 只启动South环境  
docker-compose up -d consul-south prometheus-south thanos-sidecar-south thanos-query-south alertmanager-south node-exporter-south windows-exporter-south consul-init-south

# 只启动Test环境
docker-compose up -d consul-test prometheus-test thanos-sidecar-test thanos-query-test alertmanager-test node-exporter-test windows-exporter-test consul-init-test
```

### 重新初始化特定环境
```bash
# 重新初始化North环境
docker-compose up -d --force-recreate consul-init-north

# 重新初始化South环境
docker-compose up -d --force-recreate consul-init-south

# 重新初始化Test环境
docker-compose up -d --force-recreate consul-init-test
```

### 停止特定环境
```bash
# 停止North环境
docker-compose stop consul-north prometheus-north thanos-sidecar-north thanos-query-north alertmanager-north node-exporter-north windows-exporter-north

# 停止South环境
docker-compose stop consul-south prometheus-south thanos-sidecar-south thanos-query-south alertmanager-south node-exporter-south windows-exporter-south

# 停止Test环境
docker-compose stop consul-test prometheus-test thanos-sidecar-test thanos-query-test alertmanager-test node-exporter-test windows-exporter-test
```

## 📂 配置文件结构

```
Linux/alert_manager/
├── consul_config_north/     # North环境Consul配置
│   ├── consul.json         # Consul配置 (8500端口)
│   └── init_services.sh    # 服务注册脚本
├── consul_config_south/     # South环境Consul配置  
│   ├── consul.json         # Consul配置 (8501端口)
│   └── init_services.sh    # 服务注册脚本
├── consul_config_test/      # Test环境Consul配置
│   ├── consul.json         # Consul配置 (8502端口)
│   └── init_services.sh    # 服务注册脚本
├── prometheus_north/        # North环境Prometheus配置
│   ├── prometheus.yml      # 指向consul-north:8500
│   └── alert.rules.yml     # 告警规则
├── prometheus_south/        # South环境Prometheus配置
│   ├── prometheus.yml      # 指向consul-south:8501
│   └── alert.rules.yml     # 告警规则
├── prometheus_test/         # Test环境Prometheus配置
│   ├── prometheus.yml      # 指向consul-test:8502
│   └── alert.rules.yml     # 告警规则
├── docker-compose.yml      # 三套环境定义
└── README.md              # 本文档
```

## 🔧 自定义配置

### 修改特定环境配置
```bash
# 编辑North环境Consul配置
vim Linux/alert_manager/consul_config_north/consul.json

# 编辑South环境初始化脚本
vim Linux/alert_manager/consul_config_south/init_services.sh

# 编辑Test环境配置
vim Linux/alert_manager/consul_config_test/consul.json
```

### 添加新服务到特定环境
1. 在对应环境的 `init_services.sh` 中添加服务注册代码
2. 在 `docker-compose.yml` 中添加对应环境的服务定义
3. 重新启动对应环境的初始化容器

## 🐛 故障排查

### 环境启动失败
```bash
# 检查特定环境容器日志
docker logs consul-north
docker logs prometheus-south  
docker logs thanos-query-test

# 检查端口占用情况
netstat -tulpn | grep -E ":(8500|8501|8502|9090|9091|9092)"
```

### 服务注册问题
```bash
# 检查特定环境初始化日志
docker logs consul-init-north
docker logs consul-init-south
docker logs consul-init-test

# 手动运行初始化脚本
docker-compose exec consul-init-north /tmp/init_services.sh
```

### 网络连通性问题
```bash
# 测试环境间隔离
docker exec consul-north curl -f http://consul-south:8501/v1/status/leader  # 应该失败
docker exec consul-north curl -f http://consul-north:8500/v1/status/leader  # 应该成功
```

## ⚠️ 重要说明

1. **环境隔离**: 三套环境在容器网络层面是隔离的，各自独立运行
2. **端口规划**: 严格按照端口段分配，避免冲突
3. **资源消耗**: 三套环境会消耗较多系统资源，建议在配置较高的机器上运行
4. **数据持久化**: 各环境数据通过Docker volume独立持久化

## 🎯 使用场景

- **开发团队**: 可以同时在不同环境进行开发和测试
- **CI/CD流程**: 支持多环境部署和验证
- **故障演练**: 可以在Test环境模拟各种故障场景
- **性能对比**: 可以在不同环境进行性能对比测试

---

🎉 **现在你可以一键部署三套完整的监控环境！** 