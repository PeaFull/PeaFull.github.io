---
title: 如何通过url跳转到微信公众号关注页
date: 2018-05-24 10:34:50
categories: 编程
tags: js
---


## 微信端
#### 微信端实现相对比较简单，首先需要获取公众号关注页的url，步骤如下：
1.点击公众号的历史消息
{% asset_img wechat_history.png wechat_history %}
<!--more-->
2.复制链接
{% asset_img wechat_copy_url.png wechat_copy_url %}
3.接下来在微信里直接跳转这个链接即可
```js
window.location.href="https://mp.weixin.qq.com/mp/profile_ext?action=home&__biz=MzAxNjU0MjEyNA==&scene=123&from=singlemessage&isappinstalled=0#wechat_redirect"
```
## 手机QQ
直接跳转这个链接即可唤起微信：
```js
window.location.href = 'weixin://';
```
但是不能在QQ里跳转微信的那个链接，如下图
{% asset_img qq_error.png qq_error %}

## 平台的判断
这里用的到是userAgent，代码如下
```js
let ua = navigator.userAgent.toLowerCase();
if (ua.indexOf("micromessenger") > 0) {
    //微信端
} else if (ua.indexOf("qq") > 0) {
    //手机qq
}
```
