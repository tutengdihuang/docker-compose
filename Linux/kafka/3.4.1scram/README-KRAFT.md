# Kafka KRaft 模式配置说明

## KRaft 模式简介

KRaft（Kafka Raft）是 Apache Kafka 从 2.8 版本开始引入的一种新模式，允许 Kafka 在没有 ZooKeeper 的情况下运行。在 3.0 版本后，该功能逐渐成熟，到 3.6.0 版本已经是生产可用的状态。

## KRaft 模式的优势

1. **简化架构**：移除了 ZooKeeper 依赖，减少了部署和维护的复杂性
2. **提高性能**：元数据变更更快，恢复时间更短
3. **降低运维成本**：减少了需要维护的组件数量
4. **更好的扩展性**：集群行为更加可预测
5. **减少故障点**：移除了 ZooKeeper 这一潜在的故障点

## 使用说明

### 启动 KRaft 模式的 Kafka

```bash
# 在当前目录下执行
docker-compose -f docker-compose-kafka-kraft.yml up -d
```

### 验证 Kafka 是否正常启动

```bash
# 查看容器状态
docker ps | grep kafka-kraft

# 查看 Kafka 日志
docker logs kafka-kraft
```

### 创建主题

```bash
docker exec -it kafka-kraft kafka-topics.sh --create --topic test-topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
```

### 查看主题列表

```bash
docker exec -it kafka-kraft kafka-topics.sh --list --bootstrap-server localhost:9092
```

### 使用 Kafka Map 管理界面

访问 http://localhost:9008 即可打开 Kafka Map 管理界面，使用以下凭据登录：

- 用户名：admin
- 密码：123456

## 配置说明

### 关键配置参数

- `KAFKA_ENABLE_KRAFT: "yes"` - 启用 KRaft 模式
- `KAFKA_CFG_PROCESS_ROLES: "broker,controller"` - 设置节点角色为 broker 和 controller
- `KAFKA_CFG_NODE_ID: 1` - 节点 ID，必须唯一
- `KAFKA_CFG_CONTROLLER_QUORUM_VOTERS: "1@kafka-kraft:9093"` - 控制器选举配置
- `KAFKA_KRAFT_CLUSTER_ID: "LelM2dIFQkiUFvXCEcqRWA"` - 集群 ID，必须是 22 字节的字符串

### 监听器配置

- `KAFKA_CFG_LISTENERS: "PLAINTEXT://:9092,CONTROLLER://:9093,SASL_PLAINTEXT://:9094"` - 定义监听器
- `KAFKA_CFG_ADVERTISED_LISTENERS: "PLAINTEXT://localhost:9092,SASL_PLAINTEXT://localhost:9094"` - 对外发布的监听器地址
- `KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP: "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,SASL_PLAINTEXT:SASL_PLAINTEXT"` - 监听器安全协议映射
- `KAFKA_CFG_CONTROLLER_LISTENER_NAMES: "CONTROLLER"` - 控制器监听器名称
- `KAFKA_CFG_INTER_BROKER_LISTENER_NAME: "SASL_PLAINTEXT"` - broker间通信使用的监听器名称
- 19093: Kafka控制器端口（外部映射到内部9093端口）
- 9094: Kafka SASL认证端口

### SASL认证配置

- `KAFKA_CFG_SASL_ENABLED_MECHANISMS: "SCRAM-SHA-512"` - 启用的SASL机制
- `KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL: "SCRAM-SHA-512"` - 代理间通信使用的SASL机制
- `KAFKA_OPTS: "-Djava.security.auth.login.config=/opt/bitnami/kafka/config/kafka_jaas.conf"` - JAAS配置文件路径

### 使用SASL认证连接Kafka

使用Java客户端连接示例：

```java
Properties props = new Properties();
props.put("bootstrap.servers", "localhost:9094");
props.put("security.protocol", "SASL_PLAINTEXT");
props.put("sasl.mechanism", "SCRAM-SHA-512");
props.put("sasl.jaas.config", "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"${kafka.datacenter.consumer.username}\" password=\"${kafka.datacenter.consumer.password}\";")
// 其他配置...
```

使用命令行工具连接示例：

```bash
# 创建主题
docker exec -it kafka-kraft bash -c "echo 'security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="${kafka.datacenter.consumer.username}" password="${kafka.datacenter.consumer.password}";' > /tmp/client-sasl.properties && kafka-topics.sh --create --topic secure-topic --bootstrap-server localhost:9094 --command-config /tmp/client-sasl.properties --partitions 1 --replication-factor 1"
```

# client.properties内容示例：
```properties
security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="${kafka.datacenter.consumer.username}" password="${kafka.datacenter.consumer.password}";
```


## 注意事项

1. 集群 ID 必须是 22 字节的字符串，可以使用 UUID 生成
2. 在生产环境中，应该禁用 `ALLOW_PLAINTEXT_LISTENER` 并配置适当的安全设置
3. 如果需要配置多节点集群，需要调整 `KAFKA_CFG_CONTROLLER_QUORUM_VOTERS` 和其他相关配置
4. SASL认证使用的用户名和密码在kafka_jaas.conf文件中配置，当前配置了admin和testuser两个用户
5. 使用SCRAM-SHA-512认证机制需要为用户创建凭证，可以使用以下命令：

```bash
# 为admin用户创建SCRAM-SHA-512凭证
kafka-configs.sh --bootstrap-server localhost:9092 --alter --add-config 'SCRAM-SHA-512=[password=admin123]' --entity-type users --entity-name admin

# 为testuser用户创建SCRAM-SHA-512凭证
kafka-configs.sh --bootstrap-server localhost:9092 --alter --add-config 'SCRAM-SHA-512=[password=testuser123]' --entity-type users --entity-name testuser
```