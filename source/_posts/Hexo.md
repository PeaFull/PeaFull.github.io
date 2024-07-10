---
title: Hexo使用小记
date: 2018-05-04 10:41:01
categories: 编程
tags: Hexo
---

### 1.  关于部署到github时用户名密码报错的问题
刚开始部署的配置如下
```
deploy:   
    type: git   
    repo: https://github.com/{yourname}/{yourname}.github.io.git   
    branch: master

```
结果会报没有用户名密码的错误，大致如下
```
fatal: could not read Username for 'GitHub · Where software is built': No error
FATAL Something's wrong. Maybe you can find the solution here: Troubleshooting
Error: bash: /dev/tty: No such device or address
error: failed to execute prompt script (exit code 1)
fatal: could not read Username for 'GitHub · Where software is built': No erro
```
解决办法为修改配置为如下：
```
deploy:    
    type: git   
    repo: https://{yourname}:{yourpassword}@github.com/{yourname}/{yourname}.github.io.git
    branch: master
```
转自：[有关使用 Hexo 和 GitHub 搭建博客，出现 hexo -d 报错如何解决？](https://www.zhihu.com/question/38219432)

### 2.  配置文件一定要指明language
<!--more-->
### 3.  集成disqus评论功能

进入disqus官网，点击红色框中链接，给自己的网站添加disqus，如下图
{% asset_img disqus_create_new.png disqus_create_new %}
接着输入你的网址，选择类别，生成shortname
{% asset_img disqus_form.png disqus_form %}
拿到shortname，分别添加到站点配置文件的disqus_shortname和主题配置文件的disqus中的shortname，并且将主题配置文件disqus的enable设为true



### ~~4.  如何给文章的md文件中插入图片~~
<s>
把站点配置文件的post_asset_folder设置为true；

接着执行命令，来自[hexo-asset-image](https://github.com/CodeFalling/hexo-asset-image)；
```
$ npm install hexo-asset-image --save
```

安装好之后，在用`hexo n xxx`创建新文档的时候，/source/_posts文件夹内除了xxx.md文件还会有一个同名的文件夹，这个文件夹就是用来存放图片的；

最后在xxx.md中想引入图片时先，先把图片复制到xxx文件夹中，接下来直接在xxx.md中按照markdown的格式引入图片：`![你想输入的替代文字](xxxx/图片名.jpg)`即可

转自：[hexo生成博文插入图片](https://blog.csdn.net/sugar_rainbow/article/details/57415705)
</s>

### 5.  设置阅读全文
根据文章的内容，自己在合适的位置添加 &lt;!--more--&gt;标签，使用灵活，也是Hexo推荐的方法

### 6.  使用local_search为站点增加搜索功能
安装 hexo-generator-search，在站点的根目录下执行以下命令：
```
$ npm install hexo-generator-search --save
```
安装 hexo-generator-searchdb，在站点的根目录下执行以下命令：
```
$ npm install hexo-generator-searchdb --save
```
编辑 站点配置文件，新增以下内容到任意位置：
```
search:
  path: search.xml
  field: post
  format: html
  limit: 10000
```
修改主题配置文件中local_search的enable为true即可

转自：[hexo博客添加搜索功能](https://blog.csdn.net/qq_40265501/article/details/80030627)

### 持续补充中。。。
