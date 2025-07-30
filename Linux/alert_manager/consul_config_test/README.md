# Consul 服务发现配置

本目录包含 Consul 服务发现的配置文件和相关脚本。

## 文件说明

- `consul.json` - Consul 主配置文件
- `init_services.sh` - 服务初始化脚本
- `README.md` - 本说明文件

## 快速开始

### 1. 启动服务

#### 方式一：使用 Docker Compose（推荐）

```bash
# 进入 alert_manager 目录
cd Linux/alert_manager

# 启动所有服务
docker-compose up -d

# 初始化 Consul 服务
./consul_config/init_services.sh
```

#### 方式二：手动启动

```bash
# 启动 Consul 容器
docker-compose up -d consul

# 等待服务启动后运行初始化脚本
./consul_config/init_services.sh
```

### 2. 验证服务状态

```bash
# 检查 Consul 服务
curl http://localhost:8500/v1/status/leader

# 查看已注册的服务
curl http://localhost:8500/v1/agent/services

# 访问 Consul UI
# 浏览器打开: http://localhost:8500
```

### 3. 注册服务

#### 自动初始化（推荐）

init_services.sh 脚本会自动注册当前部署的服务，包括：
- Prometheus
- Windows Exporter  
- Node Exporter

#### 手动注册服务

##### 手动注册单个服务

```bash
# 使用 Consul API 注册服务
curl -X PUT --data '{
  "Name": "service-name",
  "ID": "service-id",
  "Address": "service-address",
  "Port": 9999,
  "Tags": ["tag1", "tag2"],
  "Check": {
    "HTTP": "http://service-address:9999/metrics",
    "Interval": "10s",
    "Timeout": "5s"
  }
}' http://localhost:8500/v1/agent/service/register
```

##### 重新初始化所有服务

```bash
# 重新运行初始化脚本
./consul_config/init_services.sh
```

### 4. 查看监控数据

- **Prometheus**: http://localhost:9090
- **Thanos Query**: http://localhost:10903
- **AlertManager**: http://localhost:9093
- **Windows Exporter**: http://localhost:6080
- **Node Exporter**: http://localhost:9100

## 服务发现流程

1. **Consul** 作为服务注册中心，存储所有监控目标的信息
2. **Prometheus** 通过 Consul 服务发现自动发现监控目标
3. **Thanos** 从 Prometheus 获取数据并提供长期存储和查询能力

## 标签说明

所有服务都包含以下标准标签：

- `app` - 应用名称
- `area` - 区域（如：全国）
- `biz` - 业务线
- `cluster` - 集群名称
- `env` - 环境（如：生产、测试）
- `instance` - 实例地址
- `job` - 监控任务名称
- `replica` - 副本编号·
- `support` - 支持版本
- `tmp_hash` - 临时哈希值

## 故障排查

### Consul 连接失败

```bash
# 检查 Consul 容器状态
docker ps | grep consul

# 查看 Consul 日志
docker logs consul

# 检查端口是否开放
netstat -tlnp | grep 8500
```

### 服务注册失败

```bash
# 检查目标服务是否可访问
curl http://localhost:6080/metrics

# 检查 Consul 服务状态
curl http://localhost:8500/v1/status/leader
```

### Prometheus 无法发现服务

```bash
# 检查 Prometheus 配置
docker exec prometheus cat /etc/prometheus/prometheus.yml

# 查看 Prometheus 日志
docker logs prometheus

# 检查服务发现状态
curl http://localhost:9090/api/v1/targets
```

## 常用命令

```bash
# 查看所有注册的服务
curl http://localhost:8500/v1/agent/services

# 取消注册服务
curl -X PUT http://localhost:8500/v1/agent/service/deregister/SERVICE_ID

# 查看服务健康状态
curl http://localhost:8500/v1/health/service/SERVICE_NAME

# 重新加载 Prometheus 配置
curl -X POST http://localhost:9090/-/reload
``` 