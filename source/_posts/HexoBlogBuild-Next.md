---
title: Hexo博客搭建
date: 2018-03-28 16:33:04
updated: 2018-03-28 16:33:04
top: false
categories:
    - Hexo博客
tags:
    - Hexo
    - Next
description: hexo博客搭建及next主题设置
---

## 安装 Git

>已安装过的用户略过

* windows：下载并安装 [git](https://git-scm.com/download/win)


## 安装 Node.js

* windows：下载并安装 [Node.js](https://nodejs.org/en/)

## GitHub仓库配置

### 注册GitHub

### 创建仓库

> GitHub仓库名称必须是 \<yourname>.github.io，

### 配置SSH

## Hexo安装及配置

### 创建博客文件夹

1. 创建博客文件夹，命名为blog

```cmder
> mkdir blog
```

2. 进入blog文件夹

```cmder
> cd blog
```

> 以下操作全部在blog文件夹内执行

### 安装Hexo

```cmder
> npm install -g hexo-cli
```

### 初始化Hexo

```cmder
> hexo init
```

### 安装依赖

```cmder
> npm install
```

### 生成静态页

```cmder
> hexo generate
```

### 启动服务

```cmder
> hexo server
```

启动成功，可以通过浏览器地址栏输入：`http://localhost:4000/` ，看到Hexo的示例页。使用`Ctrl+c`停止预览服务。

### 部署Hexo

1. 编辑Hexo配置文件**_config.yml**，找到下面内容：

```yaml
# Deployment
## Docs: https://hexo.io/docs/deployment.html
deploy:
  type:
```

添加GitHub仓库信息：

```yaml
# Deployment
## Docs: https://hexo.io/docs/deployment.html
deploy:
  type: git
  repo: git@github.com:<yourname>/<yourname>.github.io.git #github仓库地址
  branch: master #github分支
```

2. 安装Git插件

```cmder
> npm install hexo-deployer-git --save
```

3. 部署

```cmder
> hexo deploy
```

部署成功，通过`http://<youtname>.github.io`访问。

### Hexo常用命令

```cmder
> hexo new <title> #新建文章
> hexo generate #生成静态页面 hexo g
> hexo clean #清除生成内容
> hexo server #启动服务 hexo s
> hexo deploy #部署 hexo d
> hexo clean && hexo g -d #清除、生成、部署
```

### Hexo插件

#### 文章置顶

#### 显示版权信息

#### 访问统计功能

#### 显示文章更新时间

#### 添加文章字数统计

更多插件可以查阅[官方插件页](https://hexo.io/plugins/)

## Next安装及配置

### Next主题安装

下载稳定版本：[Next发布页面](https://github.com/iissnan/hexo-theme-next/releases)

解压出文件夹，重命名文件夹名称为next，放在blog/themes内。

### Next主题配置

> Hexo根目录中`_config.yml`为`站点配置文件`，主题包内`_config.yml`为`主题配置文件`。

在`站点配置文件`中找到`theme`修改值为next。

```yaml
## Themes: https://hexo.io/themes/ #主题
theme: next #主题名称 默认landscape
```

详细配置说明：[Next主题设定](https://theme-next.iissnan.com/getting-started.html#theme-settings)

## 相关参考

* [手把手教从零开始在GitHub上使用Hexo搭建博客教程(一)-附GitHub注册及配置]()

