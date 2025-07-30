# 🚀 三套监控环境 - 完整部署与配置指南

## 📋 概述

本项目提供了三套完整的监控环境，每套环境都包含完整的监控栈，并配置了自动化健康检查、Exporter 配置和初始化容器：

- **🟢 North环境** (生产北中心) - 8500端口段
- **🟡 South环境** (生产南中心) - 8501端口段  
- **🔵 Test环境** (测试中心) - 8502端口段

当你运行 `docker-compose up -d` 时，系统会自动：
1. 启动三套完整的监控服务（包含 Consul、Prometheus、Thanos、Alertmanager、Node Exporter、Process Exporter）
2. 等待每套环境的 Consul 健康检查通过
3. 自动运行对应的初始化脚本注册服务
4. 执行完整的健康检查验证

## ⚡ 快速开始

### 🚀 方法一：使用启动脚本（推荐）
```bash
cd Linux/alert_manager
./start_exporters.sh
```

**特点**：
- ✅ 自动停止旧容器
- ✅ 拉取最新镜像  
- ✅ 启动所有服务
- ✅ 实时监控健康检查进度
- ✅ 显示详细状态信息

### 🚀 方法二：直接使用 Docker Compose
```bash
cd Linux/alert_manager
docker-compose up -d
```

**查看健康检查状态**：
```bash
# 查看初始化容器日志
docker logs health-check-init

# 查看环境初始化日志
docker logs consul-init-north   # North环境初始化日志
docker logs consul-init-south   # South环境初始化日志
docker logs consul-init-test    # Test环境初始化日志
```

## 🌐 服务端口映射

| 服务类型 | North | South | Test | 说明 |
|---------|-------|-------|------|------|
| **Consul** | 8500 | 8501 | 8502 | 服务发现与配置 |
| **Prometheus** | 9090 | 9091 | 9092 | 监控数据收集 |
| **Thanos Query** | 10903 | 10904 | 10905 | 统一查询接口 |
| **Alertmanager** | 9093 | 9094 | 9095 | 告警管理 |
| **Node Exporter** | 9100 | 9101 | 9102 | Linux系统指标 |
| **Process Exporter** | 9256 | 9257 | 9258 | 进程指标 |
| **Windows Exporter** | 6080 | 6081 | 6082 | Windows指标 |

### 🌐 访问地址

#### 🟢 North环境 (生产北中心)
- **Consul**: http://localhost:8500
- **Prometheus**: http://localhost:9090
- **Thanos Query**: http://localhost:10903
- **Alertmanager**: http://localhost:9093

#### 🟡 South环境 (生产南中心)
- **Consul**: http://localhost:8501
- **Prometheus**: http://localhost:9091
- **Thanos Query**: http://localhost:10904
- **Alertmanager**: http://localhost:9094

#### 🔵 Test环境 (测试中心)
- **Consul**: http://localhost:8502
- **Prometheus**: http://localhost:9092
- **Thanos Query**: http://localhost:10905
- **Alertmanager**: http://localhost:9095

## 🐳 自动化健康检查

### 🎯 健康检查功能

系统包含一个 **自动初始化健康检查容器** (`health-check-init`)，它会在所有服务启动后自动执行：

1. **服务可用性检查**：验证所有服务的 HTTP 端点
2. **指标验证**：确认关键指标（CPU、内存、负载、进程）可用
3. **连通性测试**：验证服务间网络连接
4. **配置验证**：确保服务配置正确加载

### 📋 依赖关系

初始化容器会等待以下服务就绪：
- ✅ Consul 服务 (North/South/Test)
- ✅ Prometheus 服务 (North/South/Test)  
- ✅ Node Exporter 服务 (North/South/Test)
- ✅ Process Exporter 服务 (North/South/Test)
- ✅ Thanos Query 服务 (North/South/Test)
- ✅ Consul 初始化脚本完成

### 📊 检查结果
- **退出码 0**：✅ 所有服务正常
- **退出码 1**：❌ 部分服务异常

## 📁 Exporter 配置结构

```
Linux/alert_manager/
├── exporter/                   # Exporter 配置集中目录
│   ├── node-exporter_north/
│   │   └── node-exporter.yml  # 北中心 Node Exporter 配置
│   ├── node-exporter_south/
│   │   └── node-exporter.yml  # 南中心 Node Exporter 配置
│   ├── node-exporter_test/
│   │   └── node-exporter.yml  # 测试环境 Node Exporter 配置
│   ├── windows-exporter_north/
│   │   └── config.yml         # 北中心 Windows Exporter 配置
│   ├── windows-exporter_south/
│   │   └── config.yml         # 南中心 Windows Exporter 配置
│   ├── windows-exporter_test/
│   │   └── config.yml         # 测试环境 Windows Exporter 配置
│   ├── process-exporter_north/
│   │   └── config.yml         # 北中心 Process Exporter 配置
│   ├── process-exporter_south/
│   │   └── config.yml         # 南中心 Process Exporter 配置
│   ├── process-exporter_test/
│   │   └── config.yml         # 测试环境 Process Exporter 配置
│   ├── windows-metrics/        # Windows Exporter 模拟数据
│   └── process-exporter/       # Process Exporter 通用配置│   └── node-exporter.yml      # 北中心 Node Exporter 配置
├── node-exporter_south/
├── consul_config_north/        # North环境Consul配置
│   ├── consul.json            # Consul配置 (8500端口)
│   └── init_services.sh       # 服务注册脚本
├── consul_config_south/        # South环境Consul配置
│   ├── consul.json            # Consul配置 (8501端口)
│   └── init_services.sh       # 服务注册脚本
├── consul_config_test/         # Test环境Consul配置
│   ├── consul.json            # Consul配置 (8502端口)
│   └── init_services.sh       # 服务注册脚本
├── prometheus_north/           # North环境Prometheus配置
├── prometheus_south/           # South环境Prometheus配置
├── prometheus_test/            # Test环境Prometheus配置
├── docker-compose.yml         # 完整三套环境定义
├── start_exporters.sh         # 启动脚本
├── init-health-check.sh       # 健康检查脚本
└── README.md                  # 本文档
```

## 📊 指标查询说明

### 🌐 环境配置对应关系

| 环境 | Job名称 | Instance地址 | Prometheus端口 | 描述 |
|------|---------|-------------|---------------|------|
| North | `linux_prod` | `192.168.100.201` | `9090` | 生产北中心 |
| South | `linux_prod` | `192.168.100.201` | `9091` | 生产南中心 |
| Test | `linux_test` | `192.168.100.201` | `9092` | 测试中心 |

### CPU 相关指标
```go
// 平均 CPU 使用率
avgCpuQuery = `(1-avg(irate(node_cpu_seconds_total{mode="idle",job="linux_prod",instance="192.168.100.201"}[5m])) by (instance)) * 100`

// 最大 CPU 使用率  
maxCpuQuery = `max_over_time(((1-avg(irate(node_cpu_seconds_total{mode="idle",job="linux_prod",instance="192.168.100.201"}[5m])) by (instance)) * 100)[1h:])`

// CPU 核心数
cpuTotalQuery = `count(node_cpu_seconds_total{mode="idle", job="linux_prod",instance="192.168.100.201"}) by (instance)`
```

### 内存相关指标
```go
// 内存总量
memTotalQuery = `node_memory_MemTotal_bytes{job="linux_prod",instance="192.168.100.201"}`

// 空闲内存
memFreeQuery = `node_memory_MemFree_bytes{job="linux_prod",instance="192.168.100.201"}`

// 缓冲区内存
memBufferQuery = `node_memory_Buffers_bytes{job="linux_prod",instance="192.168.100.201"}`

// 缓存内存
memCachedQuery = `node_memory_Cached_bytes{job="linux_prod",instance="192.168.100.201"}`

// 内存使用率
avgMemQuery = `((node_memory_MemTotal_bytes{job="linux_prod",instance="192.168.100.201"}-node_memory_MemFree_bytes{job="linux_prod",instance="192.168.100.201"}-node_memory_Buffers_bytes{job="linux_prod",instance="192.168.100.201"}-node_memory_Cached_bytes{job="linux_prod",instance="192.168.100.201"})/node_memory_MemTotal_bytes{job="linux_prod",instance="192.168.100.201"}*100)`
```

### 系统负载指标
```go
// 1分钟负载
load1Query = `node_load1{job="linux_prod",instance="192.168.100.201"}`

// 5分钟负载
load5Query = `node_load5{job="linux_prod",instance="192.168.100.201"}`

// 15分钟负载
load15Query = `node_load15{job="linux_prod",instance="192.168.100.201"}`
```

### 进程/线程指标
```go
// 进程数 (使用 process-exporter)
processQuery = `namedprocess_namegroup_num_procs{job="process-exporter"}`

// 线程数 (使用 process-exporter)  
threadQuery = `namedprocess_namegroup_num_threads{job="process-exporter"}`
```

### 📈 监控指标对应表

| Go 变量名 | Prometheus 指标 | 数据源 | 说明 |
|-----------|----------------|--------|------|
| `avgCpuQuery` | `node_cpu_seconds_total` | Node Exporter | CPU平均使用率 |
| `memTotalQuery` | `node_memory_MemTotal_bytes` | Node Exporter | 内存总量 |
| `load1Query` | `node_load1` | Node Exporter | 1分钟负载 |
| `processQuery` | `namedprocess_namegroup_num_procs` | Process Exporter | 进程数量 |
| `threadQuery` | `namedprocess_namegroup_num_threads` | Process Exporter | 线程数量 |

## 🔧 架构原理

### 设计特点
- **环境隔离**: 三套环境完全独立，互不干扰
- **端口规律**: 每个环境端口递增，便于管理
- **自动初始化**: 每套环境都有独立的初始化容器
- **一致性配置**: 每套环境配置结构相同，只是端口和标签不同
- **健康检查**: 自动验证所有服务状态和指标可用性

### 服务依赖关系
```
health-check-init (全局健康检查容器)
├── depends_on: consul-{env} (健康检查通过)
├── depends_on: prometheus-{env} (服务启动)
├── depends_on: node-exporter-{env} (服务启动)
├── depends_on: process-exporter-{env} (服务启动)
├── depends_on: thanos-query-{env} (服务启动)
└── depends_on: consul-init-{env} (初始化完成)

consul-init-{env} (环境初始化容器)
├── depends_on: consul-{env} (健康检查通过)
├── depends_on: prometheus-{env} (服务启动)
├── depends_on: windows-exporter-{env} (服务启动)
└── depends_on: node-exporter-{env} (服务启动)
```

## 🔍 验证部署状态

### 1. 检查容器状态
```bash
# 查看所有容器状态
docker ps -a | grep -E "(consul|prometheus|thanos|alert|exporter)"

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

### 3. 验证指标可用性
```bash
# 检查 Node Exporter 指标
curl -s http://localhost:9100/metrics | grep node_cpu_seconds_total

# 检查 Process Exporter 指标  
curl -s http://localhost:9256/metrics | grep namedprocess

# 检查 Prometheus 中的指标
curl -s 'http://localhost:9090/api/v1/query?query=up'
```

### 4. 验证标签配置
```bash
# 检查环境标签
curl -s 'http://localhost:9090/api/v1/query?query=node_memory_MemTotal_bytes' | jq '.data.result[].metric'
```

### 5. 验证服务注册
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

## 📝 使用示例

### 启动并监控
```bash
# 启动所有服务
./start_exporters.sh

# 查看健康检查进度
docker logs -f health-check-init

# 检查服务状态
docker-compose ps
```

### 重启特定环境
```bash
# 重启 North 环境
docker-compose restart prometheus-north node-exporter-north consul-north

# 重新运行健康检查
docker-compose up -d health-check-init
```

### 调试问题
```bash
# 查看所有容器状态
docker-compose ps

# 查看特定服务日志
docker logs prometheus-north
docker logs node-exporter-north
docker logs consul-north

# 查看健康检查详情
docker logs health-check-init
```

## 🛠️ 环境管理

### 单独启动某个环境
```bash
# 只启动North环境
docker-compose up -d consul-north prometheus-north thanos-sidecar-north thanos-query-north alertmanager-north node-exporter-north windows-exporter-north process-exporter-north consul-init-north

# 只启动South环境  
docker-compose up -d consul-south prometheus-south thanos-sidecar-south thanos-query-south alertmanager-south node-exporter-south windows-exporter-south process-exporter-south consul-init-south

# 只启动Test环境
docker-compose up -d consul-test prometheus-test thanos-sidecar-test thanos-query-test alertmanager-test node-exporter-test windows-exporter-test process-exporter-test consul-init-test
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
docker-compose stop consul-north prometheus-north thanos-sidecar-north thanos-query-north alertmanager-north node-exporter-north windows-exporter-north process-exporter-north

# 停止South环境
docker-compose stop consul-south prometheus-south thanos-sidecar-south thanos-query-south alertmanager-south node-exporter-south windows-exporter-south process-exporter-south

# 停止Test环境
docker-compose stop consul-test prometheus-test thanos-sidecar-test thanos-query-test alertmanager-test node-exporter-test windows-exporter-test process-exporter-test
```

## 🔧 配置修改说明

### 1. Node Exporter 配置
- 配置文件位置：`node-exporter_{env}/node-exporter.yml`
- 主要配置项：
  - `collectors.enabled`: 启用的收集器列表
  - `filesystem.mount-points-exclude`: 文件系统过滤规则
  - `netdev.device-exclude`: 网络设备过滤规则
  - `environment`: 环境标识标签

### 2. Windows Exporter 配置  
- 配置文件位置：`windows-exporter_{env}/config.yml`
- 主要配置项：
  - `collectors.enabled`: 启用的收集器列表
  - `collector.process`: 进程监控配置
  - `collector.service`: 服务监控配置
  - `global_labels`: 全局标签

### 3. Process Exporter 配置
- 配置文件位置：`process-exporter_{env}/config.yml`
- 主要配置项：
  - `process_names`: 进程匹配规则
  - `metrics`: 指标收集配置
  - `environment`: 环境标识

### 修改特定环境配置
```bash
# 编辑North环境Consul配置
vim Linux/alert_manager/consul_config_north/consul.json

# 编辑South环境初始化脚本
vim Linux/alert_manager/consul_config_south/init_services.sh

# 编辑Test环境配置
vim Linux/alert_manager/consul_config_test/consul.json

# 编辑Node Exporter配置
vim Linux/alert_manager/exporter/node-exporter_north/node-exporter.yml
```

### 添加新服务到特定环境
1. 在对应环境的 `init_services.sh` 中添加服务注册代码
2. 在 `docker-compose.yml` 中添加对应环境的服务定义
3. 重新启动对应环境的初始化容器

## 🔧 自定义健康检查配置

### 修改健康检查超时
编辑 `init-health-check.sh`：
```bash
# 修改等待超时时间（秒）
local max_attempts=30  # 默认30次，每次5秒 = 150秒
```

### 添加新的检查项
在 `init-health-check.sh` 中添加：
```bash
# 检查自定义服务
check_service "http://my-service:8080/health" "My Custom Service"
```

### 跳过特定检查
注释掉不需要的检查：
```bash
# check_service "http://process-exporter-north:9256/metrics" "North Process Exporter"
```

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

### 健康检查问题

1. **初始化容器一直运行**
   ```bash
   # 检查依赖服务状态
   docker-compose ps
   # 查看初始化日志
   docker logs health-check-init
   ```

2. **健康检查失败**
   ```bash
   # 查看具体错误
   docker logs health-check-init
   # 手动测试服务
   curl http://localhost:9090/-/ready
   ```

3. **服务启动缓慢**
   ```bash
   # 增加启动等待时间
   # 编辑 docker-compose.yml 中的 start_period
   ```

### 网络连通性问题
```bash
# 测试环境间隔离
docker exec consul-north curl -f http://consul-south:8501/v1/status/leader  # 应该失败
docker exec consul-north curl -f http://consul-north:8500/v1/status/leader  # 应该成功
```

## 🚨 注意事项

1. **进程指标**: `node_processes_pids` 和 `node_processes_threads` 指标在某些版本的 node-exporter 中可能不可用，建议使用 process-exporter 获取详细的进程信息

2. **权限要求**: Process Exporter 需要 `privileged: true` 和 `pid: host` 权限才能访问主机进程

3. **时间窗口**: 查询中的 `[1d]` 时间窗口在新启动的环境中可能没有足够数据，建议使用 `[5m]` 或 `[1h]` 进行测试

4. **网络隔离**: 所有服务都在 `monitoring` 网络中，容器间通过服务名称通信

5. **环境隔离**: 三套环境在容器网络层面是隔离的，各自独立运行

6. **端口规划**: 严格按照端口段分配，避免冲突

7. **资源消耗**: 三套环境会消耗较多系统资源，建议在配置较高的机器上运行

8. **数据持久化**: 各环境数据通过Docker volume独立持久化

## 📈 性能优化

- **并行检查**：健康检查脚本支持并行验证多个服务
- **智能等待**：只等待必要的依赖服务就绪
- **早期退出**：一旦检测到问题立即报告
- **资源友好**：初始化完成后自动退出，不占用资源

## 🎯 使用场景

- **开发团队**: 可以同时在不同环境进行开发和测试
- **CI/CD流程**: 支持多环境部署和验证
- **故障演练**: 可以在Test环境模拟各种故障场景
- **性能对比**: 可以在不同环境进行性能对比测试
- **监控系统开发**: 完整的指标查询和监控数据支持

---

🎉 **现在你可以一键部署三套完整的监控环境，包含自动化健康检查和完整的 Exporter 配置！**

**📝 最后更新**: 2024-07-30
**🔧 维护者**: 系统管理团队