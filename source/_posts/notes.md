---
title: 记录一些零散的知识点
date: 2018-08-06 14:56:48
categories: 编程
tags: js html css
---

### 1、JS的for in循环可以用来遍历对象，用在取用对象中不确定的属性名。
```js
var person = {fname:"John", lname:"Doe", age:25};
var text = "";
for (var key in person) {
    console.log(text += person[key] + " ");//John Doe 25
}
```
<!--more-->
### 2、JS中substring与substr的区别
#### 共同点是都有两个参数，第一个参数的含义都一样，区别是第二个参数：substring为截取到第几位，substr是截取几位，如下：
```js
var text = "hello world";
text.substr(1,2)
//el
text.substring(1,2)
//e
```
### 3、Navigator对象的platform和userAgent区别
#### platform用于判断操作系统平台，例如：
```js
var platform = navigator.platform.substr(0, 3);
if (platform === "Win") {
    //windows
} else if (platform === "Mac") {
    //macOS
}else{
    ... ...
}
```
#### UserAgent中文名为用户代理，是Http协议中的一部分，属于头域的组成部分，UserAgent也简称UA。它是一个特殊字符串头，是一种向访问网站提供你所使用的浏览器类型及版本、操作系统及版本、浏览器内核、等信息的标识，一般用于区分用户浏览器的类型及版本，例如：
//判断IE浏览器版本
```js
function IEVersion() {
    var userAgent = navigator.userAgent; //取得浏览器的userAgent字符串  
    var isIE = userAgent.indexOf("compatible") > -1 && userAgent.indexOf("MSIE") > -1; //判断是否IE<11浏览器  
    var isEdge = userAgent.indexOf("Edge") > -1 && !isIE; //判断是否IE的Edge浏览器  
    var isIE11 = userAgent.indexOf('Trident') > -1 && userAgent.indexOf("rv:11.0") > -1;
    if (isIE) {
        var reIE = new RegExp("MSIE (\\d+\\.\\d+);");
        reIE.test(userAgent);
        var fIEVersion = parseFloat(RegExp["$1"]);
        if (fIEVersion == 7) {
            return 7;
        } else if (fIEVersion == 8) {
            return 8;
        } else if (fIEVersion == 9) {
            return 9;
        } else if (fIEVersion == 10) {
            return 10;
        } else {
            return 6;//IE版本<=7
        }
    } else if (isEdge) {
        return 'edge';//edge
    } else if (isIE11) {
        return 11; //IE11  
    } else {
        return -1;//不是ie浏览器
    }
}

```
//区分微信和qq
```js
let ua = navigator.userAgent.toLowerCase();
if (ua.indexOf("micromessenger") > 0) {
    //微信
} else if (ua.indexOf("qq") > 0) {
    //QQ
}
```
### 4、number.toLocaleString()
#### toLocaleString() 方法可把一个 Number 对象转换为本地格式的字符串，常用于数值转化成千分位，如下：
```js
var num = 1231231231;
console.log(num.toLocaleString());//1,231,231,231
```
### 5、P标签中不能嵌套块级标签
### 6、http请求url传参时的中文编码问题
#### 项目中遇到在一个url传参的get请求里，安卓机上中文参数会乱码，ios是好的，使用```encodeURI()```解决了问题，encodeURI() 函数可把字符串作为 URI 进行编码，用法如下：
```
encodeURI(getApp().globalData.hempConfig.agentBasePath+'/sec/school/getAgentSchoolInfo'+strParam)
```
#### 这样就可以保证中文参数的准确性