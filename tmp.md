# CPU 和内存使用率查询结果

## CPU 使用率查询 (过去七天平均)

查询语句:
```promql
avg_over_time((1 - avg by (instance)(rate(node_cpu_seconds_total{instance="192.168.100.201", mode="idle"}[5m])))[7d:])
```

查询结果:
```json
{"status":"success","data":{"resultType":"vector","result":[{"metric":{"app":"north_node","area":"north","biz":"基础环境智能监控平台linux","cluster":"北中心","cpu":"0","env":"生产","instance":"192.168.100.201","job":"node","mode":"idle","replica":"0","support":"v1","tmp_hash":"1"},"value":[1755659817.526,"0.9730448573994976"]},{"metric":{"app":"north_node","area":"north","biz":"基础环境智能监控平台linux","cluster":"北中心","cpu":"1","env":"生产","instance":"192.168.100.201","job":"node","mode":"idle","replica":"0","support":"v1","tmp_hash":"1"},"value":[1755659817.526,"0.9792204693465069"]},{"metric":{"app":"north_node","area":"north","biz":"基础环境智能监控平台linux","cluster":"北中心","cpu":"2","env":"生产","instance":"192.168.100.201","job":"node","mode":"idle","replica":"0","support":"v1","tmp_hash":"1"},"value":[1755659817.526,"0.9810801706714523"]},{"metric":{"app":"north_node","area":"north","biz":"基础环境智能监控平台linux","cluster":"北中心","cpu":"3","env":"生产","instance":"192.168.100.201","job":"node","mode":"idle","replica":"0","support":"v1","tmp_hash":"1"},"value":[1755659817.526,"0.9805538401078077"]},{"metric":{"app":"north_node","area":"north","biz":"基础环境智能监控平台linux","cluster":"北中心","cpu":"4","env":"生产","instance":"192.168.100.201","job":"node","mode":"idle","replica":"0","support":"v1","tmp_hash":"1"},"value":[1755659817.526,"0.9799924208398861"]},{"metric":{"app":"north_node","area":"north","biz":"基础环境智能监控平台linux","cluster":"北中心","cpu":"5","env":"生产","instance":"192.168.100.201","job":"node","mode":"idle","replica":"0","support":"v1","tmp_hash":"1"},"value":[1755659817.526,"0.9803783965865758"]},{"metric":{"app":"north_node","area":"north","biz":"基础环境智能监控平台linux","cluster":"北中心","cpu":"6","env":"生产","instance":"192.168.100.201","job":"node","mode":"idle","replica":"0","support":"v1","tmp_hash":"1"},"value":[1755659817.526,"0.9813257916011615"]},{"metric":{"app":"north_node","area":"north","biz":"基础环境智能监控平台linux","cluster":"北中心","cpu":"7","env":"生产","instance":"192.168.100.201","job":"node","mode":"idle","replica":"0","support":"v1","tmp_hash":"1"},"value":[1755659817.526,"0.9803082191780729"]}]}}
```

## 内存使用率查询 (过去七天平均)

查询语句:
```promql
avg_over_time((1 - (node_memory_MemAvailable_bytes{instance="192.168.100.201"} / node_memory_MemTotal_bytes{instance="192.168.100.201"}))[7d:])
```

查询结果:
```json
{"status":"success","data":{"resultType":"vector","result":[{"metric":{"__name__":"node_memory_MemAvailable_bytes","app":"north_node","area":"north","biz":"基础环境智能监控平台linux","cluster":"北中心","env":"生产","instance":"192.168.100.201","job":"node","replica":"0","support":"v1","tmp_hash":"1"},"value":[1755659822.868,"6135951360"]}]}}
```

## 当前可用指标

由于复杂的查询语法问题，以下是当前可用的指标数据：

### CPU 指标 (当前值):
```json
{
  "instance": "192.168.100.201",
  "cpu_mode": "idle",
  "cpu_seconds": "57665.24"
}
```

### 内存指标 (当前值):
```json
{
  "instance": "192.168.100.201",
  "memory_total_bytes": "8218316800"
}
```

### 内存使用情况:
```json
{
  "instance": "192.168.100.201",
  "memory_free_bytes": "4880171008"
}
```

## 说明

1. 192.168.100.201 实例有完整的系统监控指标
2. 总内存: 8.2 GB
3. 空闲内存: 4.9 GB
4. CPU 空闲时间: 57665.24 秒
5. 复杂的 PromQL 查询需要调整语法以适应 Thanos 查询接口
