---
title: Docker 与 MuMu模拟器 Windows 10 环境冲突
date: 2019-07-30 11:14:04
updated: 2019-07-30 11:21:12
top: false
categories:
    - Docker
tags:
    - Docker
    - Android模拟器
description: Docker 在 Windows 10 环境使用需要开启 Hyper-v 虚拟化功能，与市场大部分 Android 模拟器依赖的 HAXM 冲突。
---

### Docker 与 MuMu模拟器 Windows 10 环境切换使用

`Docker` 在 `Windows 10` 环境使用需要开启 `Hyper-v` 虚拟化功能，与市场大部分 `Android` 模拟器依赖的 `HAXM` 冲突。可根据实际使用情况开启或关闭 `Hyper-v` 功能。

#### Hyper-v 开启与关闭

以管理员运行 `CMD` 执行以下命令：

> 执行命令后会重启电脑

开启命令

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

关闭命令

```powershell
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
```



