---
title: Chrome浏览器插件开发
date: 2024-07-13 16:22:24
categories: 编程
tags: chrome extensions
---

#### 1. 项目目录结构：
* **manifest.json：插件的配置文件**
    1. 每个扩展程序的根目录（必须）中都必须包含一个 manifest.json 文件
    2. 文档：https://developer.chrome.com/docs/extensions/reference/manifest?hl=zh-cn#minimal-manifest
<!--more-->
* **service worker**
    1. 处理和监听浏览器事件，相当于在后台运行的脚本，可以使用浏览器的全部api，但是不能和页面内容直接交互
    2. 文档：https://developer.chrome.com/docs/extensions/get-started/tutorial/service-worker-events?hl=zh-cn
    3. 由于mv3版本的service_worker在五分钟后就会终止进程，其中所有的状态和定时任务都将丢失。所以不要再service_worker中直接定义变量和使用setTimeout、setInterval等定时任务。改用chrome.storage储存需要的变量。使用chrome.alarm来执行定时任务。
* **Content scripts**
    1. 在网页环境中运行的文件。通过使用标准文档对象模型 (DOM)，用户能够读取浏览器所访问网页的详细信息，对这些网页进行更改，并将信息传递给父级扩展程序
    2. 文档：https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts?hl=zh-cn
* **插件的页面**
    1. 浏览器的图标以及点击后的效果，例如popup页面：default_popup
    2. options页面：右键插件图标后，下拉框中点击选项后，弹出的页面：options_page
    3. 除过上述之外的其他插件页面
    4. 注意：所有的插件页面都可以使用浏览器api

#### 2.两种options页面的区别：整页、嵌入式页
* 整页：系统会在新标签页中显示整页options页面。在manifest中的 "options_page" 字段中注册选项 HTML 文件
* 嵌入式：在当前页面以弹窗形式展示options页面。如需声明嵌入式选项，请在manifest中的 "options_ui" 字段下注册 HTML 文件，并将 "open_in_tab" 键设置为 false。但如果open_in_tab设置为true，效果与整页一致。

#### 3.不同script运行的位置：
* service_worker中的script，当启用插件后，运行在整个后台，日志在插件的service_worker检查视图中查看
* 插入的script，运行在网页环境中，日志在具体页面的控制台中查看
    1. 静态注入的content_scripts，只要打开matches中匹配到的网页即可执行
    2. 通过chrome.scripting.executeScript动态注入的，只有在指定动作触发后才执行。例如：通过service_worker监听tab后，动态注入一段脚本
    3. 注意：插入的script，如果不设置其运行环境，默认为"ISOLATED"，运行在该插件的隔离环境中，如果设置 world: "MAIN” ，则该脚本运行在Top中

#### 4.参考文档：
* https://docs.plasmo.com/
* https://developer.chrome.com/docs/extensions/get-started?hl=zh-cn
* 官网源码：https://github.com/GoogleChrome/chrome-extensions-samples/tree/main 
* B站教程源码： https://github.com/tuntun0609/chrome-extension-study
* B站教程文档：https://www.yuque.com/tuntun-nozomi/gurht0