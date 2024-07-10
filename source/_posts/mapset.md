---
title: js中的Map和Set
date: 2018-07-25 10:31:41
categories: 编程
tags: js
---
## 1.Map
#### Map是一组键值对的结构，具有极快的查找速度，如下：
```js
var m = new Map(); // 创建一个空Map
//也可以像这样创建：var m = new Map([['Michael', 95], ['Bob', 75], ['Tracy', 85]]);
m.set('leo', 25); // 添加新的key-value
m.set('Bob', 30);
m.set(10, "john");
m.has('leo'); // 是否存在key 'Adam': true
m.get('leo'); // 25
m.delete('leo'); // 删除key 'leo'
m.get('leo'); // undefined
m.size;// 获取map的长度：2
```
<!--more-->
#### 由于一个key只能对应一个value，所以，多次对一个key放入value，后面的value会把之前的覆盖：
```js
m.set('Bob', 300);
m.get('Bob'); // 300
```
#### 在Map中，key值可以是任何基本类型(String, Number, Boolean, undefined, NaN….)，或者对象(Map, Set, Object, Function , Symbol , null…)
## 2.Set
#### Set和Map类似，也是一组key的集合，但不存储value。由于key不能重复，所以，在Set中，没有重复的key

```js
var s = new Set(); // 创建一个空Set
//也可以像这样创建：var s2 = new Set([1, 2, 3]);
var s = new Set([1, 2, 3, 2, 3, '3']);//重复元素在Set中自动被过滤：{1, 2, 3, "3"}
var s = new Set();//{}
s.add(10);//添加元素
s.add(100);
s.add("10");//{10, 100, "10"}
s.delete(10);//删除：{100, "10"}
s.size;//获取长度：2
```
#### 在Set中，key值可以是任何基本类型(String, Number, Boolean, undefined, NaN….)，或者对象(Map, Set, Object, Function , Symbol , null…)
