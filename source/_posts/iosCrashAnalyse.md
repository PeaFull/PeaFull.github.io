---
title: 分析ios闪退日志的简易方法
date: 2019-05-08 17:40:41
categories: 编程
tags: js
---
1. 首先在打包机上找到dSYM文件，每次发布都会被覆盖为最新的，具体目录为jenkins对应的pipeline下platform/ios/build/device/，拷贝至桌面方便操作；
2. 将设备链接至mac，在xcode的window->devices and simulators->下点击view device logs，在this device下等待所有的日志加载好后点击type排序，在对应的app里找到闪退时间一致的闪退日志，查看日志；
<!--more-->
3. 对比闪退日志和dSYM日志的uuid，确认dSYM文件，在桌面执行命令
```
dwarfdump --uuid SogalNew.app.dSYM
```
解析dSYM文件的uuid，输出结果如下
```
UUID: 89E89BFC-43CE-3BC6-8D16-07C24394B0DB (armv7)
dSYMs/SogalNew.app.dSYM/Contents/Resources/DWARF/SogalNew
UUID: 101C2198-E694-3D3A-9BC6-F7A30D4451EF (arm64)
dSYMs/SogalNew.app.dSYM/Contents/Resources/DWARF/SogalNew
```
在闪退日志里找到如下一行，对比<>里的uuid，在确保都为arm64时如果一致代表dSYM文件可以用
{% asset_img uuid.png uuid %}
4. 在桌面执行如下命令，开始解析闪退日志：
```
/Applications/Xcode.app/Contents/Developer/usr/bin/atos -o SogalNew.app.dSYM/Contents/Resources/DWARF/SogalNew -l 0x100084000 -arch arm64
```
其中0x100084000与
{% asset_img uuid1.png uuid1 %}
及
{% asset_img uuid2.png uuid2 %}
一致
5. 接下来输入闪退日志里前几句{% asset_img uuid3.png uuid3 %}进行解析即可看到大致报错位置。

注：SogalNew指应用名称
