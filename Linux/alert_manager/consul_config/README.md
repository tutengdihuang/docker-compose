# Consul 服务发现配置

本目录包含 Consul 服务发现的配置文件和相关脚本。

## 文件说明

- `consul.json` - Consul 主配置文件
- `register_service.sh` - 单个服务注册脚本
- `batch_register.sh` - 批量服务注册脚本
- `example_services.json` - 示例服务配置文件
- `README.md` - 本说明文件

## 快速开始

### 1. 启动服务

#### 方式一：使用启动脚本（推荐）

```bash
# 进入 alert_manager 目录
cd Linux/alert_manager

# 一键启动 Consul 并初始化服务
./start_consul.sh
```

#### 方式二：使用 Docker Compose

```bash
# 进入 alert_manager 目录
cd Linux/alert_manager

# 启动所有服务
docker-compose up -d
```

#### 方式三：手动启动

```bash
# 启动 Consul
consul agent -dev -ui -client=0.0.0.0 &

# 等待服务启动后运行初始化脚本
./consul_config/init_services.sh
```

### 2. 验证服务状态

```bash
# 检查 Consul 服务
curl http://192.168.100.200:8500/v1/status/leader

# 查看已注册的服务
curl http://192.168.100.200:8500/v1/agent/services

# 访问 Consul UI
# 浏览器打开: http://192.168.100.200:8500
```

### 3. 注册服务

#### 自动初始化（推荐）

启动脚本会自动注册默认服务，包括：
- Prometheus
- Windows Exporter  
- Node Exporter
- MySQL Exporter
- Redis Exporter

#### 手动注册服务

##### 单个服务注册

```bash
# 注册 Windows Exporter
./consul_config/register_service.sh \
  windows-exporter \
  windows-exporter-192.168.100.200-9182 \
  192.168.100.200 \
  9182 \
  '["app=None","area=全国","biz=基础环境智能监控平台windows","cluster=北中心","env=生产","instance=192.168.100.200","job=linux_prod","replica=0","support=v1","tmp_hash=1"]'
```

##### 批量服务注册

```bash
# 使用默认配置文件
./consul_config/batch_register.sh

# 使用自定义配置文件
./consul_config/batch_register.sh my_services.json
```

##### 重新初始化所有服务

```bash
# 重新运行初始化脚本
./consul_config/init_services.sh
```

### 4. 查看监控数据

- **Prometheus**: http://192.168.100.200:9090
- **Thanos Query**: http://192.168.100.200:10903
- **AlertManager**: http://192.168.100.200:9093
- **cAdvisor**: http://192.168.100.200:8080

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
curl http://192.168.100.200:9182/metrics

# 检查 Consul 服务状态
curl http://192.168.100.200:8500/v1/status/leader
```

### Prometheus 无法发现服务

```bash
# 检查 Prometheus 配置
docker exec prometheus cat /etc/prometheus/prometheus.yml

# 查看 Prometheus 日志
docker logs prometheus

# 检查服务发现状态
curl http://192.168.100.200:9090/api/v1/targets
```

## 常用命令

```bash
# 查看所有注册的服务
curl http://192.168.100.200:8500/v1/agent/services

# 取消注册服务
curl -X PUT http://192.168.100.200:8500/v1/agent/service/deregister/SERVICE_ID

# 查看服务健康状态
curl http://192.168.100.200:8500/v1/health/service/SERVICE_NAME

# 重新加载 Prometheus 配置
curl -X POST http://192.168.100.200:9090/-/reload
``` 