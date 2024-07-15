---
title: vscode 代码格式化设置
date: 2024-07-15 09:44:23
categories: 编程
tags: vscode
---

#### 1.设置默认格式化工具

##### cmd+shift+P，筛选“Format Document”，设置 Prettier 为默认

{% asset_img img0.png %}

{% asset_img img1.png %}

#### 2.设置保存自动格式化

- 打开 VSCode，并打开你想要格式化的代码文件。
- 在菜单栏中，选择“文件”>“首选项”>“设置”（快捷键 Ctrl+,）。
- 在搜索框中输入“format on save”，然后点击“编辑 in settings.json”选项。
- 在打开的“settings.json”文件中，找到“editor.formatOnSave”选项，并将其设置为“true”。
- 保存“settings.json”文件，并关闭它。

{% asset_img img2.png %}
