package main

import (
	"crypto/sha256"
	"crypto/sha512"
	"fmt"
	"hash"
	"log"
	"time"

	"github.com/Shopify/sarama"
	"github.com/xdg-go/scram"
)

func main() {
	// Kafka配置信息
	brokers := []string{
		// "10.28.128.76:9092",
		// "10.28.128.77:9092",
		// "10.28.128.78:9092",
		"localhost:29094", // 使用主机上映射的端口29094
		// 或使用 "kafka-kraft:9094" 如果在同一Docker网络中
	}
	topic := "test_topic" // 默认topic，可根据需要修改
	username := "admin"
	// password := "Ye24_92xMG%iw@vT"
	password := "admin123"
	// 创建生产者配置
	config := sarama.NewConfig()
	config.Producer.Return.Successes = true
	config.Producer.RequiredAcks = sarama.WaitForAll
	config.Producer.Retry.Max = 3
	config.Producer.Retry.Backoff = 100 * time.Millisecond

	// 配置SCRAM认证
	config.Net.SASL.Enable = true
	config.Net.SASL.Mechanism = sarama.SASLTypeSCRAMSHA512
	config.Net.SASL.User = username
	config.Net.SASL.Password = password
	config.Net.SASL.SCRAMClientGeneratorFunc = func() sarama.SCRAMClient {
		return &XDGSCRAMClient{HashGeneratorFcn: SHA512}
	}

	// 创建生产者
	producer, err := sarama.NewSyncProducer(brokers, config)
	if err != nil {
		log.Fatalf("创建生产者失败: %v", err)
	}
	defer producer.Close()

	fmt.Printf("Kafka生产者已启动，连接到brokers: %v\n", brokers)
	fmt.Printf("Topic: %s\n", topic)
	fmt.Printf("认证方式: SCRAM-SHA-512\n")

	// 发送消息
	fmt.Println("开始发送消息...")
	for i := 0; i < 1000000000; i++ {
		message := fmt.Sprintf("测试消息 %d - 时间: %s", i+1, time.Now().Format("2006-01-02 15:04:05"))

		msg := &sarama.ProducerMessage{
			Topic: topic,
			Value: sarama.StringEncoder(message),
		}

		fmt.Printf("正在发送消息 %d...\n", i+1)
		partition, offset, err := producer.SendMessage(msg)
		if err != nil {
			log.Printf("发送消息失败: %v", err)
		} else {
			fmt.Printf("消息发送成功 - Partition: %d, Offset: %d, Message: %s\n",
				partition, offset, message)
		}

		time.Sleep(3 * time.Second)
	}

	fmt.Println("生产者任务完成")
}

// XDGSCRAMClient 实现SCRAM客户端
type XDGSCRAMClient struct {
	*scram.Client
	*scram.ClientConversation
	scram.HashGeneratorFcn
}

// Begin 开始SCRAM认证
func (x *XDGSCRAMClient) Begin(userName, password, authzID string) (err error) {
	x.Client, err = x.HashGeneratorFcn.NewClient(userName, password, authzID)
	if err != nil {
		return err
	}
	x.ClientConversation = x.Client.NewConversation()
	return nil
}

// Step 执行SCRAM认证步骤
func (x *XDGSCRAMClient) Step(challenge string) (response string, err error) {
	response, err = x.ClientConversation.Step(challenge)
	return
}

// Done 完成SCRAM认证
func (x *XDGSCRAMClient) Done() bool {
	return x.ClientConversation.Done()
}

// SHA256 哈希生成器
var SHA256 scram.HashGeneratorFcn = func() hash.Hash { return sha256.New() }

// SHA512 哈希生成器
var SHA512 scram.HashGeneratorFcn = func() hash.Hash { return sha512.New() }
