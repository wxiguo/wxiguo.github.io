---
title: Apache kafka（一）简介及入门
date: 2018-04-025 9:28:40
updated: 2018-04-025 9:28:40
top: false
categories:
    - Apache Kafka
tags:
    - Apache
    - Kafka
description: Kafka简介及入门
---

### 简介

Kafka是一个分布式流处理平台。Kafka于2009年源自Linkedin，随后于2011年初开源，并于2012年10月23由Apache Incubator孵化出站。该项目的目标是为处理实时数据提供一个统一、高吞吐、低延迟的平台。

#### 流处理平台三个关键功能

* 发布和订阅记录流，类似于消息队列或企业消息传递系统。
* 以容错持久的方式存储记录流。
* 处理记录发生的流。

#### Kafka通常用于两大类应用

* 构建可在系统或应用程序之间可靠获取数据的实时流数据管道
* 构建实时流应用程序，用于转换或相应数据流

#### 几个基本概念

* Kafka作为一个集群运行在一台或多台可以跨越多个数据中心的服务器上。
* Kafka集群在称为主题的类别中存储记录流。
* 每个记录由一个键，一个值和一个时间戳组成。

### Kafka的架构

Kafka架构的主要术语包括Topic、Record和Broker。Topic由Record组成，Record持有不同的信息，而Broker则负责复制消息。

#### 四个核心API

* 生产者API：支持应用发布Record流。
* 消费者API：支持应用程序订阅Topic和处理Record流。
* Stream API：将输入流转换为输出流，并产生结果。
* Connector API：执行可重用的生产者和消费者API，可将Topic链接到现有应用程序。

![Kafka-apis](/images/kafka-apis.png)

### 安装及使用

> 基于Unix平台上使用`bin/`，脚本扩展名为`.sh` 。
>
> WIndows平台上使用`bin\windows\`，并且脚本扩展名为`.bat`。
>
> 以下命令均在Windows平台执行。

#### 第1步：下载代码

[下载](https://www.apache.org/dyn/closer.cgi?path=/kafka/1.1.0/kafka_2.11-1.1.0.tgz) 1.1.0版本并解压它。Windows平台直接解压。

```
>cd kafka_2.11-1.1.0
```

#### 第2步：启动服务器

Kafka使用ZooKeeper，首先启动ZooKeeper服务器，使用Kafka打包在一起的便捷脚本使用单节点的ZooKeeper实例。

```
>bin\windows\zookeeper-server-start.bat config\zookeeper.properties
```

ZooKeeper成功启动，并绑定到端口`2181`。该端口是ZooKeeper的默认端口，可以在`config\zookeeper.properties`中修改`clientPort`来修改监听端口。

启动Kafka服务器：

```
>bin\windows\kafka-server-start.bat config\server.properties
```

#### 第3步：创建一个主题

创建一个名为“HelloWord”的主题：

```
>bin\windows\kafka-topics.bat --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic HelloWord
```

通过运行`list topic`命令查询创建的主题：

```
>bin\windows\kafka-topics.bat --list --zookeeper localhost:2181
```

或者也可以将代理配置设置为发布不存在的主题是自动创建主题。

#### 第4步：启动一个生产者并发送消息

```
>bin\windows\kafka-console-producer.bat --broker-list localhost:9092 --topic HelloWord
This is a message
hello,my is producer
```

#### 第5步：启动一个消费者并接收消息

````
>bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic HelloWord --from-beginning
This is a message
hello,my is producer
````

### 异常及处理

1. 启动Kafka服务，命令窗口提示错误：

```
>bin\windows\kafka-server-start.bat config\server.properties
错误: 找不到或无法加载主类 Files\Java\jdk1.7.0_75\lib\dt.jar;C:\Program
```

网上查找解决办法，修改`kafka-server-satrt.bat`：

```
set COMMAND=%JAVA% %KAFKA_HEAP_OPTS% %KAFKA_JVM_PERFORMANCE_OPTS% %KAFKA_JMX_OPTS% %KAFKA_LOG4J_OPTS% -cp %CLASSPATH% %KAFKA_OPTS% %*
修改为：
set COMMAND=%JAVA% %KAFKA_HEAP_OPTS% %KAFKA_JVM_PERFORMANCE_OPTS% %KAFKA_JMX_OPTS% %KAFKA_LOG4J_OPTS% -cp "%CLASSPATH%" %KAFKA_OPTS% %*
```

给上述代码段的`%CLASSPATH%`添加双引号`""`。

2. 启动生产者时Kafka报错：

```
>bin\windows\kafka-console-producer.bat --broker-list localhost:9092 --topic HelloWord
WARN [Consumer clientId=consumer-1, groupId=console-consumer-950] Connection to node -1 could not be established. Broker may not be available.
```

因为配置文件`conf\server.properties`没有启用`PLAINTEXT`，修改配置文件：

```
#listeners=PLAINTEXT://:9092
listeners=PLAINTEXT://localhost:9092
```

### 相关参考

* [Kafka官网](https://kafka.apache.org)
* [Kafka维基百科](https://zh.wikipedia.org/wiki/Kafka)
* [[Kafka][错误: 找不到或无法加载主类 Files\Java\jdk1.8.0_101\lib\dt.jar;C:\Program]](https://blog.csdn.net/cx2932350/article/details/78870135)
* [WARN [Consumer clientId=consumer-1, groupId=console-consumer-950] Connection to node -1 could not be](https://blog.csdn.net/getyouwant/article/details/79000524)
* [The Log: What every software engineer should know about real-time data's unifying abstraction](https://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying)