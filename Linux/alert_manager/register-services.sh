#!/bin/bash

# Wait for Consul to be ready
until curl -s http://localhost:8500/v1/status/leader > /dev/null; do
    echo "Waiting for Consul to start..."
    sleep 5
done

# Register Prometheus service
curl -X PUT -H "Content-Type: application/json" -d '{
  "ID": "prometheus-192.168.100.200-9090",
  "Name": "prometheus",
  "Address": "192.168.100.200",
  "Port": 9090,
  "Tags": [
    "app=20250512",
    "area=全国",
    "biz=基础环境智能监控平台prometheus",
    "cluster=北中心",
    "env=生产",
    "instance=192.168.100.200",
    "job=prometheus",
    "replica=0",
    "support=v1",
    "tmp_hash=1"
  ],
  "Check": {
    "HTTP": "http://prometheus:9090/-/healthy",
    "Interval": "10s"
  }
}' http://localhost:8500/v1/agent/service/register

# Register Windows Exporter service (if needed)
curl -X PUT -H "Content-Type: application/json" -d '{
  "ID": "windows-exporter-192.168.100.200-9182",
  "Name": "windows-exporter",
  "Address": "192.168.100.200",
  "Port": 9182,
  "Tags": [
    "app=None",
    "area=全国",
    "biz=基础环境智能监控平台windows",
    "cluster=北中心",
    "env=生产",
    "instance=192.168.100.200",
    "job=linux_prod",
    "replica=0",
    "support=v1",
    "tmp_hash=1"
  ],
  "Check": {
    "HTTP": "http://windows-exporter:9182/metrics",
    "Interval": "10s"
  }
}' http://localhost:8500/v1/agent/service/register

echo "Services registered in Consul" 