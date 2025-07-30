# Thanos Web 界面快速启动指南

本指南介绍如何通过 Thanos Sidecar 和 Query 组件，快速启动 Thanos 的 Web 图形界面。

## 步骤 1：启动 Sidecar，连接 Prometheus

假设 Prometheus API 地址为 `http://192.168.100.100:9090`，数据目录为 `/var/lib/prometheus`，请运行：

```
nohup ./thanos sidecar --prometheus.url "http://192.168.100.100:9090" --tsdb.path "/var/lib/prometheus" > sidecar.log 2>&1 &
```

- `--prometheus.url`：Prometheus 的 HTTP API 地址
- `--tsdb.path`：Prometheus 的本地数据目录

## 步骤 2：启动 Query，连接本地 Sidecar 并开放 Web 界面

```
nohup ./thanos query --endpoint=127.0.0.1:10901 --http-address=0.0.0.0:10903 --grpc-address=0.0.0.0:10911 > query.log 2>&1 &
```

- `--endpoint`：Sidecar 的 gRPC 地址（本地为 127.0.0.1:10901）
- `--http-address`：Web 界面监听端口（如 10903）
- `--grpc-address`：Query 的 gRPC 端口（如 10911，避免与 Sidecar 冲突）

## 访问 Thanos Web 界面

在浏览器中访问：

    http://localhost:10903/

即可进入 Thanos 的图形化界面。

---

**注意事项：**
- 如果 Prometheus 的数据目录不是 `/var/lib/prometheus`，请替换为实际路径。
- 如果 Sidecar 和 Query 不在同一台机器，`--endpoint` 参数需填写 Sidecar 的实际 IP。
- 请确保各组件的 gRPC 端口（如 10901、10911）不冲突。
- 先启动 Sidecar，再启动 Query。
