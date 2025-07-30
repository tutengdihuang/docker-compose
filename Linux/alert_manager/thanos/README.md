# Thanos 配置说明

## 架构说明

Thanos 采用 Sidecar + Query 的架构：

1. **Thanos Sidecar**: 连接到 Prometheus，提供数据访问接口
2. **Thanos Query**: 提供 Web 界面，查询多个数据源

## 服务配置

### Thanos Sidecar
- **镜像**: quay.io/thanos/thanos:v0.32.5
- **Prometheus URL**: http://prometheus:9090 (容器内地址)
- **TSDB 路径**: /prometheus
- **HTTP 端口**: 10902
- **gRPC 端口**: 10901

### Thanos Query
- **镜像**: quay.io/thanos/thanos:v0.32.5
- **Sidecar 端点**: thanos-sidecar:10901 (容器内地址)
- **HTTP 端口**: 10903 (Web界面)
- **gRPC 端口**: 10911

## 访问地址

- **Thanos Query Web界面**: http://192.168.100.200:10903
- **Thanos Sidecar 指标**: http://192.168.100.200:10902/metrics
- **Prometheus**: http://192.168.100.200:9090
- **Consul**: http://192.168.100.200:8500

## 功能特性

- 统一查询多个 Prometheus 实例
- 长期数据存储支持
- 高可用性查询
- 数据去重和合并 