# Kafka 生产者和消费者示例

这个项目包含了使用 Go 和 sarama 库实现的 Kafka 生产者和消费者。

## 配置信息

- **Brokers**: 10.28.128.76:9092, 10.28.128.77:9092, 10.28.128.78:9092
- **Group**: monitor_sync
- **Topic**: test-topic (可在代码中修改)
- **Offset**: first (从最早的消息开始消费)
- **认证方式**: SCRAM-SHA-256
- **用户名**: admin
- **密码**: Ye24_92xMG%iw@vT

## 项目结构

```
kafka_test/
├── go.mod
├── producer/
│   └── main.go          # Kafka 生产者
├── consumer/
│   └── main.go          # Kafka 消费者
└── README.md
```

## 使用方法

### 1. 安装依赖

```bash
go mod tidy
```

### 2. 运行生产者

```bash
cd producer
go run main.go
```

生产者会发送10条测试消息到 `test-topic` topic。

### 3. 运行消费者

```bash
cd consumer
go run main.go
```

消费者会从 `test-topic` topic 消费消息，并显示消息的详细信息。

### 4. 停止消费者

使用 `Ctrl+C` 来优雅地停止消费者。

## 功能特性

### 生产者
- 使用 SCRAM-SHA-256 认证
- 同步发送消息
- 自动重试机制
- 显示发送结果（分区和偏移量）

### 消费者
- 使用消费者组模式
- 从最早的消息开始消费
- 优雅关闭处理
- 显示消息的详细信息（topic、分区、偏移量、时间戳等）

## 修改配置

如果需要修改 topic 名称或其他配置，请编辑相应的 `main.go` 文件中的配置变量。

## 注意事项

- 确保 Kafka 集群正在运行
- 确保网络可以访问指定的 broker 地址
- 确保认证信息正确
- 如果 topic 不存在，Kafka 可能会自动创建（取决于配置）
