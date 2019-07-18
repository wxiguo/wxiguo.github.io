---
title: Hexo博客搭建
top: false
categories:
  - Hexo博客
tags:
  - Hexo
  - Next
description: hexo博客搭建及next主题设置
abbrlink: b8f4bd70
date: 2018-03-28 16:33:04
updated: 2018-03-28 16:33:04
---

## 安装 Git

>已安装过的用户略过

* windows：下载并安装 [Git](https://git-scm.com/download/win)


## 安装 Node.js

* windows：下载并安装 [Node.js](https://nodejs.org/en/)

## GitHub仓库配置

### 创建仓库

> GitHub仓库名称必须是 <yourname\>.github.io

### 配置SSH

1. 打开**GitBash**终端，设置`user.name`和`user.email`


```
$ git config --global user.name "你的GitHub用户名"
$ git config --global user.email "你的GitHub注册邮箱"
```

2. 生成ssh密钥：

```
$ ssh-keygen -t rsa -C "你的GitHub注册邮箱"
```

一路回车，创建的文件windows 10系统在`C:\Users\windows用户\.ssh`，里面有新创建的私钥：**id_rsa**和公钥：**id_rsa.pub**。

3. 点击**GitHub用户头像**-->**Setting**-->**SSH and GPG keys**-->**New SSH key**，将公钥 **id_rsa.pub** 中的内容复制到**key**文本框中点击保存。
4. 测试SSH：

```
$ ssh -T git@github.com
```

会出现确认信息，确认无误输入`yes`后回车。配置完成。


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

安装node插件

```
$ npm uninstall hexo-generator-index --save
$ npm install hexo-generator-index-pin-top --save
```

在需要顶置的文章的`Front-matter`中加`top: true`。

#### 显示版权信息

修改`主题配置文件`中`enable: false`为`enable: true`。

修改`站点配置文件`中`url: `为`url: http://<yourwebsite>`。

```yaml
# Declare license on posts
post_copyright:
  enable: false
  license: CC BY-NC-SA 3.0
  license_url: https://creativecommons.org/licenses/by-nc-sa/3.0/
```

#### 访问统计功能

修改`主题配置文件`中`busuanzi_count:` 部分。

```yaml
# Show PV/UV of the website/page with busuanzi.
# Get more information on http://ibruce.info/2015/04/04/busuanzi/
busuanzi_count:
  # count values only if the other configs are false
  # 全局开关
  enable: true
  # custom uv span for the whole site
  # 页面底部显示站点的UV值
  site_uv: true
  site_uv_header: 访客数 <i class="fa fa-user"></i>
  site_uv_footer: 人次
  # custom pv span for the whole site
  # 页面底部显示站点的PV值
  site_pv: true
  site_pv_header: 访问量 <i class="fa fa-eye"></i>
  site_pv_footer: 次
  # custom pv span for one page only
  # 文章页面的标题下显示该页面的PV值
  page_pv: true
  page_pv_header: 阅读量 <i class="fa fa-file-o"></i>
  page_pv_footer: 次
```

#### 显示文章更新时间

修改`主题配置文件`中`post_meta`部分的`updated_at: false`为`updated_at: true`。

```yaml
# Post meta display settings
post_meta:
  item_text: true
  created_at: true
  updated_at: false
  categories: tru
```

在需要顶置的文章的`Front-matter`中加`updated:  `。

#### 添加文章字数统计

安装插件：

```
$ npm i hexo-wordcount --save
```

修改`主题配置文件`中`post_wordcount`部分：

```yaml
# Post wordcount display settings
# Dependencies: https://github.com/willin/hexo-wordcount
post_wordcount:
  item_text: true   //底部是否显示“总字数”字样
  wordcount: true  //文章字数统计 默认false
  min2read: false  //文章预计阅读时长（分钟）
  totalcount: true  //网站总字数，位于底部 默认false
  separated_meta: true //是否将文章的字数统计信息换行显示
```

更多插件可以查阅[官方插件页](https://hexo.io/plugins/)

## Next安装及配置

### Next主题安装

下载稳定版本：[Next发布页面](https://github.com/iissnan/hexo-theme-next/releases)

解压出文件夹，重命名文件夹名称为`next`，放在`blog/themes`内。

### Next主题配置

> Hexo根目录中`_config.yml`为`站点配置文件`，主题包内`_config.yml`为`主题配置文件`。

在`站点配置文件`中找到`theme`修改值为`next`。

```yaml
## Themes: https://hexo.io/themes/ #主题
theme: next #主题名称 默认landscape
```

详细配置说明：[Next主题设定](https://theme-next.iissnan.com/getting-started.html#theme-settings)

## 相关参考

* [手把手教从零开始在GitHub上使用Hexo搭建博客教程(一)-附GitHub注册及配置](https://www.jianshu.com/p/f4cc5866946b)
* [手把手教从零开始在GitHub上使用Hexo搭建博客教程(二)-Hexo参数设置](https://www.jianshu.com/p/dd9ef08b12df)
* [使用GitHub搭建Hexo静态博客](http://www.itfanr.cc/2016/09/24/use-github-to-build-hexo-static-blog/)
* [Hexo博客功能优化](http://www.itfanr.cc/2017/12/06/hexo-blog-optimization/)
* [Hexo官方中文文档](https://hexo.io/zh-cn/docs/)

