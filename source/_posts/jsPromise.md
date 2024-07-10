---
title: js promise简例及一些注意点
date: 2018-05-11 10:30:41
categories: 编程
tags: js
---

#### 无论promise中的执行结果是什么，它总会给你返回一个状态，成功或者失败
```javaScript
//封装promise
function getURL(URL) {
    return new Promise(function (resolve, reject) {
        var req = new XMLHttpRequest();
        req.open('GET', URL, true);
        req.onload = function () {
            if (req.status === 200) {
                resolve(req.responseText);
            } else {
                reject(new Error(req.statusText));
            }
        };
        req.onerror = function () {
            reject(new Error(req.statusText));
        };
        req.send();
    });
}

//执行
var URL = "http:***";
getURL(URL).then(function(value) {
    console.log(value);
}).catch(function(error) {
    console.error(error);
});
//也可以这样写
//getURL(URL).then(function(value) {
//    console.log(value);
//}, function(error){
//    console.error(error);
//})
```
<!--more-->
#### 在angularjs中可以通过$q实现异步操作：

通过调用  $q.defer() 可以构建一个新的 deffered 实例,deffered 对象用来将 Promise 实例与 标记任务状态(执行成功还是不成功)的 API 相关联，
deffered 对象的方法
>- resolve(value) ——成功，如果 value 是一个通过 $q.reject 构造的拒绝对象(rejection) , 该promise 将被拒绝。
>- reject(reason) ——失败，这相当于通过 $q.reject构造的拒绝对象(rejection)作为参数传递给 resolve。
>- notify(value)  ——在 promise 执行的过程中提供状态更新。 这在 promise 被解决或拒绝之前可能会被多次调用。

例子如下：

```javaScript
//封装promise
function asyncGreet(name) {
    var deferred = $q.defer();
    setTimeout(function () {
        deferred.notify('即将问候 ' + name + '.');
        if (okToGreet(name)) {
            deferred.resolve('你好, ' + name + '!');
        } else {
            deferred.reject('拒绝问候 ' + name + ' .');
        }
    }, 1000);
    return deferred.promise;
}
//执行
var promise = asyncGreet('***');
promise.then(function (res) {

}, function (error) {

}, function (update) {

});  
```
