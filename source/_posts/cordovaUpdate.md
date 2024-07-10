---
title: 更新cordova时出现的报错及解决方案
date: 2018-06-08 10:57:43
categories: 编程
tags: npm
---

#### 今天在利用cordova build安卓apk的时候出现了报错，并且提示更新cordova，于是执行以下命令做更新：
```
npm install -g cordova
```
结果出现了报错，如下
```
npm WARN update-linked node_modules\cordova needs updating to 8.0.0 from 6.4.0 but we can't, as it's a symlink
```
<!--more-->
在网上查了半天也没找到原因，于是尝试了先去remove再install，结果成功了，如下
```
npm remove -g cordova
npm install -g cordova
```
至于报错的原因，还有待后面研究下...
