# Kafka Go客户端示例

本文档提供了使用Go语言连接Kafka并进行SASL认证的示例代码和说明。

## 前提条件

1. 已安装Go环境（推荐Go 1.16+）
2. 已启动Kafka服务（使用docker-compose-kafka-kraft.yml）
3. 已创建SCRAM-SHA-512用户凭证

## 安装依赖

```bash
go get github.com/confluentinc/confluent-kafka-go/kafka
```

## 示例文件说明

本目录包含两个示例文件：

1. `kafka_producer_example.go` - Kafka生产者示例，演示如何发送消息
2. `kafka_consumer_example.go` - Kafka消费者示例，演示如何消费消息

## 配置说明

两个示例文件中都包含以下关键配置：

```go
// Kafka配置信息
brokers := []string{
    "127.0.0.1:9094", // 注意：使用SASL认证时应连接9094端口，而不是9092
}
topic := "test_topic" // 默认topic，可根据需要修改
username := "admin"
password := "Ye24_92xMG%iw@vT" // 请替换为您的实际密码

// 创建Kafka配置
config := kafka.ConfigMap{
    "bootstrap.servers":        strings.Join(brokers, ","),
    "security.protocol":       "SASL_PLAINTEXT",
    "sasl.mechanism":          "SCRAM-SHA-512",
    "sasl.username":           username,
    "sasl.password":           password,
    // 其他配置...
}
```

请根据您的实际环境修改以下配置：

- `brokers` - Kafka服务器地址和端口（使用9094端口进行SASL认证）
- `topic` - 要生产/消费的主题名称
- `username` - SASL认证用户名
- `password` - SASL认证密码

## 运行示例

### 运行生产者

```bash
go run kafka_producer_example.go
```

成功运行后，生产者将发送一条消息到指定的主题。

### 运行消费者

```bash
go run kafka_consumer_example.go
```

消费者将开始监听指定的主题，并打印接收到的消息。

## 注意事项

1. 确保已为用户创建了SCRAM-SHA-512凭证：

```bash
# 为admin用户创建SCRAM-SHA-512凭证
docker exec -it kafka-kraft kafka-configs.sh --bootstrap-server localhost:9092 --alter --add-config 'SCRAM-SHA-512=[password=admin123]' --entity-type users --entity-name admin

# 为testuser用户创建SCRAM-SHA-512凭证
docker exec -it kafka-kraft kafka-configs.sh --bootstrap-server localhost:9092 --alter --add-config 'SCRAM-SHA-512=[password=testuser123]' --entity-type users --entity-name testuser
```

2. 使用SASL认证时，请确保连接到正确的端口（9094）

3. 如果遇到认证问题，请检查用户名和密码是否正确

4. 在生产环境中，建议使用环境变量或配置文件存储敏感信息（如密码）

## 故障排除

1. 如果连接失败，请确认Kafka服务是否正常运行：

```bash
docker ps | grep kafka
```

2. 检查SASL认证配置是否正确：

```bash
docker exec -it kafka-kraft cat /opt/bitnami/kafka/config/kafka_jaas.conf
```

3. 尝试使用命令行工具验证连接：

```bash
docker exec -it kafka-kraft bash -c "echo 'security.protocol=SASL_PLAINTEXT\nsasl.mechanism=SCRAM-SHA-512\nsasl.username=admin\nsasl.password=admin123' > /tmp/client-sasl.properties && kafka-topics.sh --list --bootstrap-server localhost:9094 --command-config /tmp/client-sasl.properties"
```