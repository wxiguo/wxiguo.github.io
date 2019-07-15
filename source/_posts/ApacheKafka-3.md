---
title: Apache kafka（三）Kafka与Spring整合
date: 2018-05-10 22:11:21
updated: 2019-06-28 21:52:33
top: false
categories:
    - Apache Kafka
tags:
    - Apache
    - Kafka
    - Java
    - Spring
description: Kafka与Spring整合
---

### Kafka与Spring整合

`maven`依赖：

```xml
	...
	<dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
        <version>2.1.6.RELEASE</version>
    </dependency>
    <dependency>
        <groupId>org.springframework.kafka</groupId>
        <artifactId>spring-kafka</artifactId>
        <version>2.2.7.RELEASE</version>
    </dependency>
	...
```

#### 生产者

##### 基于配置

`application-Kafka.xml`

```xml
	<!-- 定义producer的参数 -->
    <bean id="producerProperties" class="java.util.HashMap">
        <constructor-arg>
            <map>
                <entry key="bootstrap.servers" value="localhost:9092"/>
                <entry key="client.id" value="KafkaProducer"/>
                <entry key="acks" value="all"/>
                <entry key="key.serializer" value="org.apache.kafka.common.serialization.StringSerializer"/>
                <entry key="value.serializer" value="org.apache.kafka.common.serialization.StringSerializer"/>
            </map>
        </constructor-arg>
    </bean>

    <!-- 创建kafkatemplate需要使用的producerfactory bean -->
    <bean id="producerFactory" class="org.springframework.kafka.core.DefaultKafkaProducerFactory">
        <constructor-arg ref="producerProperties"/>
    </bean>

    <!-- 创建kafkatemplate bean，使用的时候，只需要注入这个bean，即可使用template的send消息方法 -->
    <bean id="producerTemplate" class="org.springframework.kafka.core.KafkaTemplate">
        <constructor-arg ref="producerFactory"/>
        <constructor-arg name="autoFlush" value="true"/>
    </bean>
```

`ProducerController.java`

```java
@RestController
public class ProducerController {
    
    @Autowired
    KafkaTemplate kafkaTemplate;

    @GetMapping("/test")
    public String doTest() {
        kafkaTemplate.send("my-topic", "Hello World");
        return "success";
    }
}
```

##### 基于注解

`application.properties`

```properties
# Kafka configs
spring.kafka.bootstrap-servers=localhost:9092
spring.kafka.client-id=KafkaProducer
spring.kafka.acks=all
app.topic.foo=my-topic
```

`SenderConfig.java`

```java
@Configuration
@EnableKafka
public class SenderConfig {

    @Value("${spring.kafka.bootstrap-servers}")
    private String bootstrapServers;
    @Value("${spring.kafka.client-id}")
    private String clientId;
    @Value("${spring.kafka.acks}")
    private String acks;

    @Bean
    public Map<String, Object> producerConfigs() {
        Map<String, Object> props = new HashMap<>();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ProducerConfig.CLIENT_ID_CONFIG, clientId);
        props.put(ProducerConfig.ACKS_CONFIG, acks);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        return props;
    }

    @Bean
    public ProducerFactory<String, String> producerFactory() {
        return new DefaultKafkaProducerFactory<>(producerConfigs());
    }

    @Bean
    public KafkaTemplate<String, String> kafkaTemplate() {
        return new KafkaTemplate<>(producerFactory());
    }
}
```

`Sender.java`

```java
@RestController
public class Sender {

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    @Value("${app.topic.foo}")
    private String topic;

    @GetMapping("test")
    public String send() {
        kafkaTemplate.send(topic, "topic_key", "Hello Word!");
        return "success";
    }
}
```

#### 消费者

##### 基于配置

`application-Kafka.xml`

```xml
	<context:component-scan base-package="com.example.listener"/>

    <!-- 定义consumer的参数 -->
    <bean id="consumerProperties" class="java.util.HashMap">
        <constructor-arg>
            <map>
                <entry key="bootstrap.servers" value="localhost:9092"/>
                <entry key="group.id" value="KafkaConsumer"/>
                <entry key="enable.auto.commit" value="true"/>
                <entry key="auto.commit.interval.ms" value="1000"/>
                <entry key="key.deserializer" value="org.apache.kafka.common.serialization.StringDeserializer"/>
                <entry key="value.deserializer" value="org.apache.kafka.common.serialization.StringDeserializer"/>
            </map>
        </constructor-arg>
    </bean>

    <!-- 实际执行消息消费的类 -->
    <bean id="registryListener" class="com.example.listener.RegistryServers"/>

    <!-- 创建consumerFactory bean -->
    <bean id="consumerFactory" class="org.springframework.kafka.core.DefaultKafkaConsumerFactory">
        <constructor-arg ref="consumerProperties"/>
    </bean>

    <!-- 消费者容器配置信息 -->
    <bean id="containerProperties" class="org.springframework.kafka.listener.ContainerProperties">
        <constructor-arg name="topics" value="my-topic"/>
        <property name="messageListener" ref="registryListener"/>
    </bean>

    <!-- 消费者并发消息监听容器，执行doStart()方法 -->
    <bean id="messageListenerContainer" class="org.springframework.kafka.listener.KafkaMessageListenerContainer"
          init-method="doStart">
        <constructor-arg ref="consumerFactory"/>
        <constructor-arg ref="containerProperties"/>
    </bean>
```

`RegistryServers.java`

```java
public class RegistryServers implements MessageListener<String, String> {

    @Override
    public void onMessage(ConsumerRecord record) {
        System.out.println("接收到消息：");
        System.out.println(record.value());
    }
}
```

##### 基于注解

`application.properties`

```properties
# Kafka configs
spring.kafka.bootstrap-servers=localhost:9092
spring.kafka.group-id=KafkaConsumer
spring.kafka.enable-auto-commit=true
spring.kafka.auto-commit-interval-ms=1000
spring.kafka.auto-offset-reset=earliest
app.topic.foo=my-topic
```

`ReceiverConfig.java`

```java
@Configuration
@EnableKafka
public class ReceiverConfig {

    @Value("${spring.kafka.bootstrap-servers}")
    private String bootstrapServers;
    @Value("${spring.kafka.group-id}")
    private String groupId;
    @Value("${spring.kafka.enable-auto-commit}")
    private String enableAutoCommit;
    @Value("${spring.kafka.auto-commit-interval-ms}")
    private String autoCommitIntervalMs;
    @Value("${spring.kafka.auto-offset-reset}")
    private String autoOffsetReset;

    @Bean
    public Map<String, Object> consumerConfigs() {
        Map<String, Object> props = new HashMap<>();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, groupId);
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, enableAutoCommit);
        props.put(ConsumerConfig.AUTO_COMMIT_INTERVAL_MS_CONFIG, autoCommitIntervalMs);
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, autoOffsetReset);
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        return props;
    }

    @Bean
    public ConsumerFactory consumerFactory() {
        return new DefaultKafkaConsumerFactory<>(consumerConfigs());
    }

    @Bean
    public KafkaListenerContainerFactory<ConcurrentMessageListenerContainer<String, String>> kafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<String, String> factory = new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory());
        return factory;
    }
}
```

`Receiver.java`

```java
@Service
public class Receiver {

    @KafkaListener(topics = "${app.topic.foo}")
    public void listen(ConsumerRecord record) {
        System.out.println(String.format("key: %s and value: %s", record.key(), record.value()));
    }
}
```

### 相关参考

* [Spring for Apache Kafka](<https://spring.io/projects/spring-kafka>)