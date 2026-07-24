---
title: JSBridge
date: 2026-07-24 15:27:29
categories:
tags:
---

## JSBridge是什么

JSBridge是一种让**Web页面里的JavaScript**与**原生应用代码**相互通信的机制。

常见场景：

* App中嵌入H5页面
* JavaScript调用原生能力
* 原生代码主动通知H5页面

例如，H5页面本身不能直接访问手机通讯录、相机、定位、支付等能力，就需要通过JSBridge让原生端代为执行。

<!--more-->

---

## 基本通信过程

以H5调用相机为例：

```text
H5 JavaScript
    ↓ 调用Bridge方法
JSBridge
    ↓ 传递方法名和参数
Android/iOS原生代码
    ↓ 调用相机
执行完成
    ↓ 返回结果
JSBridge
    ↓
JavaScript回调或Promise
```

H5侧可能这样调用：

```js
window.JSBridge.invoke('openCamera', {
  quality: 0.8
}).then(result => {
  console.log(result.imageUrl);
});
```

原生端接收到：

```json
{
  "method": "openCamera",
  "params": {
    "quality": 0.8
  }
}
```

执行完成后，再把结果返回给JavaScript。

---

## JSBridge能做什么

常见能力包括：

* 获取设备信息
* 获取定位
* 调用相机和相册
* 扫码
* 文件上传和下载
* 分享
* 支付
* 设置导航栏
* 关闭当前WebView
* 获取登录用户信息
* 原生页面跳转
* 原生向H5推送事件

---

## 两个通信方向

### JavaScript调用原生

例如H5调用扫码：

```js
bridge.invoke('scanQRCode', {
  type: 'qr'
});
```

原生端根据`scanQRCode`找到对应处理方法并执行。

### 原生调用JavaScript

原生端可以直接执行WebView中的JavaScript：

```js
window.onNetworkChange({
  type: 'wifi'
});
```

H5提前注册方法：

```js
window.onNetworkChange = function (data) {
  console.log('网络发生变化', data);
};
```

实际项目中通常会封装成事件机制：

```js
bridge.on('networkChange', data => {
  console.log(data);
});
```

---

## 常见实现方式

### Android

Android WebView常见方式：

```java
webView.addJavascriptInterface(
    new NativeBridge(),
    "NativeBridge"
);
```

JavaScript调用：

```js
window.NativeBridge.openCamera();
```

也可以通过拦截URL、`postMessage`等方式通信。

### iOS

iOS的WKWebView常使用：

```js
window.webkit.messageHandlers.nativeBridge.postMessage({
  method: 'openCamera'
});
```

iOS原生端监听`nativeBridge`并处理消息。

### React Native

React Native的WebView通常使用：

```js
window.ReactNativeWebView.postMessage(
  JSON.stringify({
    method: 'openCamera'
  })
);
```

React Native侧通过`onMessage`接收。

---

## 实际项目中的统一封装

为了屏蔽Android、iOS之间的差异，前端一般不会直接调用底层API，而是统一封装：

```js
class JSBridge {
  constructor() {
    this.callbacks = new Map();
    this.callbackId = 0;
  }

  invoke(method, params = {}) {
    return new Promise((resolve, reject) => {
      const callbackId = `callback_${++this.callbackId}`;

      this.callbacks.set(callbackId, {
        resolve,
        reject
      });

      const message = {
        method,
        params,
        callbackId
      };

      this.send(message);
    });
  }

  send(message) {
    const data = JSON.stringify(message);

    if (window.webkit?.messageHandlers?.nativeBridge) {
      window.webkit.messageHandlers.nativeBridge.postMessage(message);
      return;
    }

    if (window.ReactNativeWebView) {
      window.ReactNativeWebView.postMessage(data);
      return;
    }

    if (window.NativeBridge?.postMessage) {
      window.NativeBridge.postMessage(data);
      return;
    }

    throw new Error('当前环境不支持JSBridge');
  }

  handleCallback(callbackId, result, error) {
    const callback = this.callbacks.get(callbackId);

    if (!callback) return;

    if (error) {
      callback.reject(error);
    } else {
      callback.resolve(result);
    }

    this.callbacks.delete(callbackId);
  }
}
```

调用：

```js
const bridge = new JSBridge();

bridge.invoke('getLocation').then(location => {
  console.log(location);
});
```

原生执行完成后调用：

```js
bridge.handleCallback(
  'callback_1',
  {
    latitude: 34.34,
    longitude: 108.94
  }
);
```

---

## 为什么需要callbackId

调用原生能力通常是异步的，而且可能同时发起多个请求：

```js
bridge.invoke('getLocation');
bridge.invoke('openCamera');
bridge.invoke('getDeviceInfo');
```

因此每次调用都生成唯一的`callbackId`：

```json
{
  "method": "getLocation",
  "params": {},
  "callbackId": "callback_1"
}
```

原生返回时携带相同的`callbackId`：

```json
{
  "callbackId": "callback_1",
  "result": {
    "latitude": 34.34
  }
}
```

JSBridge根据它找到对应的Promise或回调函数。

---

## JSBridge的本质

JSBridge本质上就是一个**消息协议和调用映射机制**：

```text
方法名 + 参数 + 请求ID
```

请求格式：

```json
{
  "method": "openCamera",
  "params": {},
  "callbackId": "callback_1"
}
```

响应格式：

```json
{
  "callbackId": "callback_1",
  "success": true,
  "data": {}
}
```

所以JSBridge并不是某个固定框架，而是一套Web与原生之间约定好的通信方案。

---

## 实际开发需要注意

### 安全控制

不能允许H5随意调用所有原生方法，应设置白名单：

```js
const allowedMethods = [
  'getDeviceInfo',
  'openCamera',
  'scanQRCode'
];
```

还要校验当前H5页面的域名，防止恶意网页调用支付、登录信息等敏感能力。

### 参数校验

原生端不能完全信任前端参数：

```json
{
  "method": "openCamera",
  "params": {
    "quality": "错误类型"
  }
}
```

双方都需要约定参数类型和必填字段。

### 超时处理

原生端可能没有返回结果，需要设置超时：

```js
Promise.race([
  bridge.invoke('getLocation'),
  timeout(5000)
]);
```

### 版本兼容

新版本App可能增加Bridge方法，而旧版本没有，因此通常需要能力判断：

```js
bridge.supports('openCamera');
```

或者维护版本号：

```js
bridge.getVersion();
```

### 页面销毁时清理

页面关闭后，应清理未完成的回调和事件监听，避免内存泄漏。

---

## 和普通Ajax的区别

| 对比项    | JSBridge         | Ajax/Fetch |
| ------ | ---------------- | ---------- |
| 通信对象   | JavaScript与原生App | 浏览器与服务器    |
| 通信范围   | 当前WebView和App    | HTTP网络     |
| 主要用途   | 调用设备和App能力       | 请求后端数据     |
| 是否一定联网 | 不一定              | 通常需要       |
| 常见能力   | 相机、定位、支付、页面跳转    | 查询、提交业务数据  |

---
