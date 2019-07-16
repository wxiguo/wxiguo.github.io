---
title: Apache kafka（二）简单生产者、消费者组示例
date: 2018-04-27 21:31:20
updated: 2019-06-27 20:22:40
top: false
categories:
    - Apache Kafka
tags:
    - Apache
    - Kafka
    - Java
description: Kafka简单生产者、消费者组示例
---

### APIS

Kafka包括五个核心apis：

1. Producer API：允许应用程序将数据流发送到Kafka集群中的主题。
2. Consumer API：允许应用程序从Kafka集群中的主题读取数据流。
3. Streams API：允许将输入主题的数据流转换为输出主题。
4. Connect API：允许实现从某些源系统或应用程序不断拉入Kafka或从Kafka推送到某个接收器系统或应用程序的连接器。
5. AdminClient API：允许管理和检查主题，代理和其他Kafka对象。

Kafka通过独立于语言的协议公开其所有功能，该协议具有许多编程语言的客户端。

### 简单生产者

Producer API允许应用程序将数据流发送到Kafka集群中的主题。

maven依赖：

```xml
<dependency>
    <groupId>org.apache.kafka</groupId>
    <artifactId>kafka-clients</artifactId>
    <version>2.3.0</version>
</dependency>
```

生产者是线程安全的，跨线程共享单个生成器实例通常比拥有多个实例更快。

#### 示例

```java
public static void main(String[] args) {
        Properties props = new Properties();
        props.put("bootstrap.servers","localhost:9092");
        props.put("acks","all");
        props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

        Producer producer = new KafkaProducer<>(props);
        for (int i = 0; i < 100; i++){
            producer.send(new ProducerRecord<>("my-topic", Integer.toString(i), Integer.toString(i)));
        }
        producer.close();
}
```

生产者包含一个缓存控制池，用于保存尚未传输到服务器的记录，以及一个后台 I/O 线程，负责将这些记录转换为请求并将它们传输到集群。 没有在使用后关闭生产者将泄漏这些资源。

`send()` 方法是异步的。 调用时，它会将记录添加到待处理记录发送的缓冲区中并立即返回。 这允许生产者将各个记录一起批处理以提高效率。

`acks` 配置控制认为请求完成的标准。 我们指定的“all”设置将导致完全提交记录时阻塞，这是最慢但最耐用的设置。

#### 生产者可选配置

| No.  | **配置设置**      | **配置说明**                                                 |
| ---- | ----------------- | ------------------------------------------------------------ |
| 1    | client.id         | 标识生产者应用程序                                           |
| 2    | producer.type     | 同步或异步                                                   |
| 3    | acks              | acks 配置表示 producer 发送消息到 broker 上以后的确认值。<br />0：表示 producer 不需要等待 broker 的消息确认。这个选项时延最小但同时风险最大（因为当 server 宕机时，数据将会丢失） 。<br />1：表示 producer 只需要获得 kafka 集群中的 leader 节点确认即可，这个选择时延较小同时确保了 leader 节点确认接收成功。<br />all(-1)：需要 ISR 中所有的 Replica 给予接收确认，速度最慢，安全性最高，但是由于 ISR 可能会缩小到仅包含一个 Replica，所以设置参数为 all 并不能一定避免数据丢失。 |
| 4    | retries           | 如果生产者请求失败，则会自动重试具体值。                     |
| 5    | bootstrap.servers | 经纪人的引导列表。                                           |
| 6    | linger.ms         | 如果要减少请求数，可以将linger.ms设置为大于某值的值。Producer 默认会把两次发送时间间隔内收集到的所有 Requests 进行一次聚合然后再发送，以此提高吞吐量，而 linger.ms 就是为每次发送到 broker 的请求增加一些 delay，以此来聚合更多的 Message 请求。 |
| 7    | key.serializer    | 串行器接口的关键。                                           |
| 8    | value.serializer  | 串行器接口的值。                                             |
| 9    | batch.size        | 缓冲区大小。生产者发送多个消息到 broker 上的同一个分区时，为了减少网络请求带来的性能开销，通过批量的方式来提交消息，可以通过这个参数来控制批量提交的字节数大小，默认大小是 16384byte,也就是 16kb，意味着当一批消息大小达到指定的 batch.size 的时候会统一发送。 |
| 10   | buffer.memory     | 控制生产者可用于缓冲的总内存量。                             |
| 11   | max.request.size  | 设置请求的数据的最大字节数，为了防止发生较大的数据包影响到吞吐量，默认值为 1MB。 |

#### ProducerRecord 类参数

* **String topic** - 创建主题以分配记录
* **K key** - 键记录
* **V value** - 记录内容

#### 单一事务示例

```java
public static void main(String[] args) {
    Properties props = new Properties();
        props.put("bootstrap.servers", "localhost:9092");
        props.put("transactional.id", "my-transactional-id");
        Producer<String, String> producer = new KafkaProducer<>(props, new StringSerializer(), new StringSerializer());

        producer.initTransactions();

        try {
            producer.beginTransaction();
            for (int i = 0; i < 100; i++)
                producer.send(new ProducerRecord<>("my-topic", Integer.toString(i), Integer.toString(i)));
            producer.commitTransaction();
        } catch (ProducerFencedException | OutOfOrderSequenceException | AuthorizationException e) {
            // 异常，关闭生产者
            producer.close();
        } catch (KafkaException e) {
            // 异常，重试
            producer.abortTransaction();
        }
        producer.close();
}
```

每个生产者只能有一个开放交易。 在 `beginTransaction()` 和 `commitTransaction()` 调用之间发送的所有消息都将是单个事务的一部分。 指定 `transactional.id` 时，生产者发送的所有消息都必须是事务的一部分。

### 消费者组

Consumer API允许应用程序从Kafka集群中的主题读取数据流。

maven依赖：

```xml
<dependency>
    <groupId>org.apache.kafka</groupId>
    <artifactId>kafka-clients</artifactId>
    <version>2.3.0</version>
</dependency>
```

Kafka消费者不是线程安全的。 所有网络 I/O 都发生在进行调用的应用程序的线程中。此规则的唯一例外是`wakeup()`，它可以安全地从外部线程用于中断活动操作。 在这种情况下，将从操作的线程阻塞中抛出`WakeupException`。 这可以用于从另一个线程关闭使用者。

#### 示例

##### 自动抵消提交

```java
public static void main(String[] args) {
        Properties props = new Properties();
        props.put("bootstrap.servers", "localhost:9092");
        props.setProperty("group.id", "test");
        props.setProperty("enable.auto.commit", "true");
        props.setProperty("auto.commit.interval.ms", "1000");
        props.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        props.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
        consumer.subscribe(Arrays.asList("my-topic", "foo", "bar"));
        while (true) {
            ConsumerRecords<String, String> records = consumer.poll(Duration.ofMinutes(100));
            for (ConsumerRecord<String, String> record : records) {
                System.out.println(String.format("offset = %d, key = %s, value = %s%n", record.offset(), record.key(), record.value()));
            }
        }
}
```

##### 手动偏移控制

```java
public static void main(String[] args) {
        Properties props = new Properties();
        props.setProperty("bootstrap.servers", "localhost:9092");
        props.setProperty("group.id", "test");
        props.setProperty("enable.auto.commit", "false");
        props.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        props.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
        consumer.subscribe(Arrays.asList("my-topic", "foo", "bar"));
        final int minBatchSize = 200;
        List<ConsumerRecord<String, String>> buffer = new ArrayList<>();
        while (true) {
            ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
            for (ConsumerRecord<String, String> record : records) {
                buffer.add(record);
            }
            if (buffer.size() >= minBatchSize) {
                // 业务处理
//                insertIntoDb(buffer);
                System.out.println(buffer.toString());
                consumer.commitSync();
                buffer.clear();
            }
        }
}
```

上面的示例使用commitSync将所有已接收的记录标记为已提交。 在某些情况下，您可能希望通过明确指定偏移量来更好地控制已提交的记录。 在下面的示例中，我们在完成处理每个分区中的记录后提交偏移量。

```java
public static void main(String[] args) {
        Properties props = new Properties();
        props.setProperty("bootstrap.servers", "localhost:9092");
        props.setProperty("group.id", "test");
        props.setProperty("enable.auto.commit", "false");
        props.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        props.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
        consumer.subscribe(Arrays.asList("my-topic", "foo", "bar"));
        try {
            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(Long.MAX_VALUE));
                for (TopicPartition partition : records.partitions()) {
                    List<ConsumerRecord<String, String>> partitionRecords = records.records(partition);
                    for (ConsumerRecord<String, String> record : partitionRecords) {
                        System.out.println(record.offset() + ": " + record.value());
                    }
                    long lastOffset = partitionRecords.get(partitionRecords.size() - 1).offset();
                    consumer.commitSync(Collections.singletonMap(partition, new OffsetAndMetadata(lastOffset + 1)));
                }
            }
        } finally {
            consumer.close();
        }
}
```

> 注意：提交的偏移量应始终是应用程序将读取的下一条消息的偏移量。 因此，在调用commitSync（偏移量）时，您应该在最后处理的消息的偏移量中添加一个。

#### 消费者配置

| No.  | **配置设置**       | **配置说明**                                                 |
| ---- | ------------------ | ------------------------------------------------------------ |
| 1    | group.id           | 消费组id。不同消费组都可以获取到生产内容，同一消费组内只有一个 consumer 可以消费。 |
| 2    | enable.auto.commit | 消费者消费消息以后自动提交，只有当消息提交以后，该消息才不会被再次接收到，还可以配合 auto.commit.interval.ms 控制自动提交的频率。当然，我们也可以通过 consumer.commitSync()的方式实现手动提交。 |
| 3    | auto.offset.reset  | auto.offset.reset=latest 情况下，新的消费者将会从其他消费者最后消费的offset 处开始消费 Topic 下的消息。<br/>auto.offset.reset= earliest 情况下，新的消费者会从该 topic 最早的消息开始消费。<br/>auto.offset.reset=none 情况下，新的消费者加入以后，由于之前不存在offset，则会直接抛出异常。 |
| 4    | max.poll.records   | 此设置限制每次调用 poll 返回的消息数，这样可以更容易的预测每次 poll 间隔要处理的最大值。通过调整此值，可以减少 poll 间隔。 |

### 相关参考

* [Kafka官网](https://kafka.apache.org)
* [Kafka 2.3 Javadoc](<https://kafka.apache.org/23/javadoc/index.html?org/apache/kafka/clients/producer/KafkaProducer.html>)
* [W3Cschool Apache Kafka 教程](<https://www.w3cschool.cn/apache_kafka/apache_kafka_simple_producer_example.html>)