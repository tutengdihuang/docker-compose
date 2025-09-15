package main

import (
	"context"
	"crypto/sha256"
	"crypto/sha512"
	"fmt"
	"hash"
	"log"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"github.com/Shopify/sarama"
	"github.com/xdg-go/scram"
)

func main() {
	// Kafka配置信息
	brokers := []string{
		// "10.28.128.76:9094",
		// "10.28.128.77:9094",
		// "10.28.128.78:9094",
		"localhost:29094", // 使用主机上映射的端口29094
		// 或使用 "kafka-kraft:9094" 如果在同一Docker网络中
	}
	topic := "test_topic" // 默认topic，可根据需要修改
	groupID := "test_topic_test"
	username := "admin"
	password := "admin123"

	// 创建消费者配置
	config := sarama.NewConfig()
	config.Consumer.Return.Errors = true
	config.Consumer.Offsets.Initial = sarama.OffsetOldest // 从最早的消息开始消费
	config.Consumer.Group.Rebalance.Strategy = sarama.BalanceStrategyRoundRobin
	config.Consumer.Group.Session.Timeout = 10 * time.Second   // 10秒
	config.Consumer.Group.Heartbeat.Interval = 3 * time.Second // 3秒

	// 配置SCRAM认证
	config.Net.SASL.Enable = true
	config.Net.SASL.Mechanism = sarama.SASLTypeSCRAMSHA512
	config.Net.SASL.User = username
	config.Net.SASL.Password = password
	config.Net.SASL.SCRAMClientGeneratorFunc = func() sarama.SCRAMClient {
		return &XDGSCRAMClient{HashGeneratorFcn: SHA512}
	}

	// 创建消费者组
	consumer, err := sarama.NewConsumerGroup(brokers, groupID, config)
	if err != nil {
		log.Fatalf("创建消费者组失败: %v", err)
	}
	defer consumer.Close()

	fmt.Printf("Kafka消费者已启动\n")
	fmt.Printf("Brokers: %v\n", brokers)
	fmt.Printf("Topic: %s\n", topic)
	fmt.Printf("Group ID: %s\n", groupID)
	fmt.Printf("认证方式: SCRAM-SHA-256\n")
	fmt.Printf("Offset: first (从最早的消息开始)\n")

	// 创建消费者处理器
	handler := &ConsumerGroupHandler{}

	// 设置信号处理
	sigchan := make(chan os.Signal, 1)
	signal.Notify(sigchan, syscall.SIGINT, syscall.SIGTERM)

	// 启动消费协程
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		defer wg.Done()
		for {
			select {
			case <-sigchan:
				fmt.Println("收到退出信号，正在停止消费者...")
				return
			default:
				// 消费消息
				err := consumer.Consume(context.Background(), []string{topic}, handler)
				if err != nil {
					log.Printf("消费消息时出错: %v", err)
					return
				}
			}
		}
	}()

	// 处理错误
	go func() {
		for err := range consumer.Errors() {
			log.Printf("消费者错误: %v", err)
		}
	}()

	// 等待退出信号
	<-sigchan
	fmt.Println("正在关闭消费者...")
	wg.Wait()
	fmt.Println("消费者已关闭")
}

// ConsumerGroupHandler 实现 sarama.ConsumerGroupHandler 接口
type ConsumerGroupHandler struct{}

// Setup 在消费者组会话开始时调用
func (h *ConsumerGroupHandler) Setup(sarama.ConsumerGroupSession) error {
	fmt.Println("消费者组会话已建立")
	return nil
}

// Cleanup 在消费者组会话结束时调用
func (h *ConsumerGroupHandler) Cleanup(sarama.ConsumerGroupSession) error {
	fmt.Println("消费者组会话已清理")
	return nil
}

// ConsumeClaim 处理消息
func (h *ConsumerGroupHandler) ConsumeClaim(session sarama.ConsumerGroupSession, claim sarama.ConsumerGroupClaim) error {
	for {
		select {
		case message := <-claim.Messages():
			if message == nil {
				return nil
			}

			fmt.Printf("收到消息:\n")
			fmt.Printf("  Topic: %s\n", message.Topic)
			fmt.Printf("  Partition: %d\n", message.Partition)
			fmt.Printf("  Offset: %d\n", message.Offset)
			fmt.Printf("  Key: %s\n", string(message.Key))
			fmt.Printf("  Value: %s\n", string(message.Value))
			fmt.Printf("  Timestamp: %s\n", message.Timestamp.Format("2006-01-02 15:04:05"))
			fmt.Println("---")

			// 标记消息为已处理
			session.MarkMessage(message, "")

		case <-session.Context().Done():
			return nil
		}
	}
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
