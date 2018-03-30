---
title: 使用Travis自动部署Hexo
date: 2018-03-30 16:06:04
updated: 2018-03-30 16:06:04
top: false
categories:
    - Hexo博客
tags:
    - Hexo
    - Travis
description: Travis持续集成自动部署Hexo
---

## Travis配置

### GItHub创建Access Token

登录[GItHub](https://github.com)-->**GitHub用户头像**-->**Setting**-->**Developer settings**-->**Personal access tokens**-->**Generate new token**

![GitHub](/images/GitHubPages-Travis-1.png)

![GitHub](/images/GitHubPages-Travis-2.png)

勾选`repo`及`user:email`点击创建。生成的token只显示一次，所以需要先保存起来后面会用到。

### Travis CI配置

> 配置Travis公共仓库服务：[travis-ci.org](https://travis-ci.org/)，配置Travis私有化仓库服务：[travis-ci.com](https://travis-ci.com/)

这里我们使用公共仓库服务[travis-ci.org](https://travis-ci.org/)

打开[Travis CI](https://travis-ci.org/)网站，使用GItHub账号登录，点击`Sync account`会显示GitHub项目列表。选择博客项目开启Travis支持。

点击项目找到`More options`中的`Setting`开启`Build only if .travis.yml is present`和`Build pushed branches`。

![Travis](/images/GitHubPages-Travis-3.png)

在`Environment Variables`创建环境变量`TravisCIToken`值为在GItHub创建的Access Token的token值。**不要勾选**`Display value in build log`，否则会在日志文件中暴露 `token` 信息。

![Travis](/images/GitHubPages-Travis-4.png)

### 创建.travis.yml文件

> 注意yml文件中不能使用`tab`进行缩进，使用空格缩进，`:`后有一个空格。

Hexo根目录blog文件夹内创建.travis.yml：

```yaml
anguage: node_js
node_js: stable
cache:
    apt: true
    directories:
        - node_modules
before_install:
    - export TZ='Asia/Shanghai'
    - npm install hexo-cli -g
    - chmod +x ./publish-to-gh-pages.sh
install:
    - npm install
script:
    - hexo clean
    - hexo g
after_script:
    - ./publish-to-gh-pages.sh
branches:
    only:
        - hexo
env:
    global:
        - GH_REF: github.com/<yourname>/<yourname>.github.io.git
```

Hexo根目录blog文件夹内创建publish-to-gh-pages.sh：

```sh
#!/bin/bash
set -ev
# get clone master
git clone https://${GH_REF} .deploy_git
cd .deploy_git
git checkout master
cd ../
mv .deploy_git/.git/ ./public/
cd ./public
git config user.name "<yourname>"
git config user.email "<youremail>"
# add commit timestamp
git add .
git commit -m "Travis CI Auto Builder at `date +"%Y-%m-%d %H:%M"`"
git push --force --quiet "https://${TravisCIToken}@${GH_REF}" master:master
```

## 自动部署

* 打开Git Bash

> 以下操作全部在Hexo根目录blog文件夹内执行

* 创建远程分支

```
$ git checkout -b hexo
```

* 初始化本地仓库：

> 删除原来部署时产生的.git文件夹（隐藏文件夹）

```
$ git init
```

* 关联远程仓库

```
$ git remote add origin git@github.com:<yourname>/<yourname>.github.io.git
```

* 推送仓库

```
$ git add . # 添加文件
$ git commit -m "first import" # 编写注释
$ git push -u origin hexo # 推送至远程仓库hexo分支
```

推送成功后可以在[travis-ci.org](https://travis-ci.org/)后台查看自动部署情况。

## 相关参考

* [手把手教从零开始在GitHub上使用Hexo搭建博客教程(三)-使用Travis自动部署Hexo(1)](https://www.jianshu.com/p/7f05b452fd3a)
* [手把手教从零开始在GitHub上使用Hexo搭建博客教程(四)-使用Travis自动部署Hexo(2)](https://www.jianshu.com/p/fff7b3384f46)
* [使用Travis CI自动部署Hexo博客](http://www.itfanr.cc/2017/08/09/using-travis-ci-automatic-deploy-hexo-blogs/)

