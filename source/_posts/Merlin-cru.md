---
title: 梅林固件编写cru脚本清理高速缓存重启路由
top: false
categories:
  - Merlin
tags:
  - Merlin
  - cru
description: 编写cru脚本定时清理路由高速缓存、每天重启路由
abbrlink: e616b06d
date: 2018-04-08 13:23:10
updated: 2018-04-24 14:20:32
---

## R6300V2_梅林RT-AC68U 定时清理高速缓存、每天重启路由

刷梅林有几个月了，第一次问题出是在连续使用30多天后，发现手机能连接路由器但不能上网，不能访问路由器管理页面。连接不上网络的问题需要手动重启路由器，很麻烦，尤其是人不在家想连接家里的NAS和摄像头没办法远程重启路由器。出门在外，顺子(喵)独自在家不放心。本来想有什么网络监控设备，找了一圈发现可以用路由器脚本定时检测，自动重启解决。暂时没有时间整理编写定时检测监本，先用定时清理高速缓存和每天重启脚本用一段时间看看。

### 使用WinSCP登录路由器

配置路由器开启`SSH链接`：登录路由器管理界面-->`系统管理`-->`系统设置`-->`SSH Daemon`-->`Enable SSH`选择开启`SSH`访问。

使用工具`WinSCP`选择`SCP`访问，端口配置与`SSH`配置相同，使用路由器用户名和密码登录。

### 编写路由器监控脚本

> 下面新建sh文件全部使用utf-8编码，设置文件0755权限

使用`WinSCP`登录路由器后，进入`/jffs/scripts/`目录，使用内置编辑器新建清除缓存文件`clean.sh`，内容如下：

```
#!/bin/sh
sync
echo 3 > /proc/sys/vm/drop_caches
```

新建定时文件`cru.sh`，内容如下：

```
#!/bin/sh
cru a clean "0 */4 * * * /bin/sh /jffs/scripts/clean.sh"
cru a reboot "0 4 * * * /sbin/reboot"
```

上面代码的意思是：

1. 每4小时清理一次缓存。
2. 每天临晨4点重启路由器。

按下图在路由器管理界面Tools-Script里将`cru.sh`添加到开机启动：

![Merlin](/images/Merlin-0.png)

然后重启机器，或者断开WAN后重连。

配置完成后为安全性考虑，请关闭`SSH`访问链接。

### 修改NTP服务器

梅林自带NTP服务器地址`pool.ntp.org`在国内访问并不是很好，经常会有访问不了的情况导致时间不同步，重启后无法链接WAN的问题，修改NTP服务器地址为`time.pool.aliyun.com`，修改后半个多月了，没有发生重启后无法WAN上网的问题。

![Merlin](/images/Merlin-1.png)

### 相关参考
* [梅林系统手动编写cru定时脚本 自动重启/释放内存](http://xow.myds.me:88/emlog/?post=37)
* [OpenWRT路由器中监控网络服务并重启的脚本](https://jamesqi.com/%E5%8D%9A%E5%AE%A2/OpenWRT%E8%B7%AF%E7%94%B1%E5%99%A8%E4%B8%AD%E7%9B%91%E6%8E%A7%E7%BD%91%E7%BB%9C%E6%9C%8D%E5%8A%A1%E5%B9%B6%E9%87%8D%E5%90%AF%E7%9A%84%E8%84%9A%E6%9C%AC)
* [梅林重起后一定几率无法访问Internet，我的解决办法。](http://koolshare.cn/thread-136416-1-1.html)