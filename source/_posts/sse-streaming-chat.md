---
title: SSE流式对话
date: 2026-07-16 10:34:31
categories:
tags:
---

# SSE（Server-Sent Events）流式对话

## 什么是SSE

SSE（Server-Sent Events）是一种基于HTTP的**服务器推送技术**，客户端发起一次请求后，服务器保持连接并持续向客户端发送数据，无需客户端不断轮询。

**一句话：**

> **客户端请求一次，服务器持续推送数据，直到响应结束。**

<!--more-->

---

# 为什么AI对话使用SSE

普通HTTP请求：

```text
用户发送消息
      │
      ▼
等待模型全部生成完成
      │
      ▼
一次返回完整内容
```

SSE流式返回：

```text
用户发送消息
      │
      ▼
服务器开始生成
      │
      ▼
你
你好
你好！
你好！很高兴……
```

前端边接收边渲染，实现类似"打字机"效果，用户体验更好。

---

# SSE通信流程

```text
Browser
    │
    │ POST /chat
    ▼
Server
────────────────────────────────────
保持HTTP连接

data: {"content":"你"}

data: {"content":"好"}

data: {"content":"！"}

data: [DONE]

────────────────────────────────────
连接关闭
```

整个过程中：

* 客户端发送一次请求
* 服务器保持连接持续推送数据
* 前端实时接收并渲染
* 收到`[DONE]`（或服务端约定的结束标识）后结束响应

---

# 服务端实现（关键响应头）

服务端需要设置SSE相关响应头：

```http
Content-Type: text/event-stream
Cache-Control: no-cache
Connection: keep-alive
```

作用：

* **Content-Type: text/event-stream**：声明响应为SSE流。
* **Cache-Control: no-cache**：防止浏览器缓存。
* **Connection: keep-alive**：保持HTTP长连接（HTTP/1.1下常见，HTTP/2下意义较小）。

服务端持续发送数据：

```javascript
res.write(`data: ${JSON.stringify(data)}\n\n`);
```

最后结束：

```javascript
res.write("data: [DONE]\n\n");
res.end();
```

---

# SSE数据格式

服务器返回的数据必须遵循SSE协议。

例如：

```text
data: hello

data: world

```

AI接口通常返回：

```text
data: {"content":"你"}

data: {"content":"好"}

data: {"content":"！"}

data: [DONE]
```

其中：

* `data:`：消息内容
* 空行：表示一条消息结束
* `[DONE]`：流结束标识（由服务端定义，并非SSE协议强制要求）

---

# 前端如何接收SSE

目前主要有两种方式。

## 方式一：EventSource（原生SSE）

```javascript
const es = new EventSource("/chat");

es.onmessage = (e) => {
  console.log(e.data);
};
```

### 优点

* 浏览器原生支持
* 自动重连
* 使用简单

### 缺点

只能支持：

* GET请求

不能支持：

* POST
* Request Body
* 自定义Authorization Header

因此现代AI项目很少直接使用。

---

## 方式二：fetch + ReadableStream（推荐）

现代AI（OpenAI、DeepSeek、Claude等）基本都采用这种方式。

发送请求：

```javascript
const response = await fetch("/chat", {
  method: "POST",
  headers: {
    Authorization: "Bearer xxx",
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    message: "你好",
  }),
});
```

读取流：

```javascript
const reader = response.body.getReader();
const decoder = new TextDecoder();

while (true) {
  const { done, value } = await reader.read();

  if (done) break;

  const text = decoder.decode(value, {
    stream: true,
  });

  console.log(text);
}
```

优势：

* 支持POST
* 支持Token认证
* 支持Request Body
* 支持聊天历史、模型参数等复杂数据
* 完全兼容REST API
* 更符合现代AI接口设计

---

# 为什么AI接口使用POST

AI接口通常需要提交大量参数，例如：

* 用户消息
* 聊天历史（History）
* System Prompt
* Temperature
* Top P
* 最大Token数
* Token认证

因此通常采用：

```text
POST
      +
Request Body
      +
fetch
      +
ReadableStream
```

而不是`EventSource`的GET请求。

---

# ReadableStream

`fetch`返回的响应体是一个`ReadableStream`。

通过：

```javascript
response.body.getReader();
```

获取Reader。

循环读取：

```javascript
reader.read();
```

返回：

```javascript
{
  done: false,
  value: Uint8Array(...)
}
```

其中：

* value：当前数据块（Chunk）
* done：是否读取完成

---

# 什么是Chunk

网络不会一次返回完整数据，而是分成多个**Chunk（数据块）**进行传输。

例如：

```text
Chunk1
↓

Chunk2
↓

Chunk3
↓

......
```

浏览器通过：

```javascript
reader.read();
```

一次读取一个Chunk，因此页面能够边接收边显示。

需要注意的是：

> **Chunk并不等于Token，一个Chunk可能包含一个Token、多个Token，甚至一整段文本，具体由服务端决定。**

---

# TextDecoder

服务器发送的是字节流，而不是字符串。

例如：

```text
228 189 160
```

浏览器读取后得到：

```javascript
Uint8Array(...)
```

需要使用：

```javascript
const decoder = new TextDecoder();

const text = decoder.decode(value);
```

转换成：

```text
你
```

所以：

> **TextDecoder负责将Uint8Array解码成字符串。**

---

# 为什么使用stream: true（重点）

推荐：

```javascript
decoder.decode(value, {
  stream: true,
});
```

原因：

网络数据按Chunk传输，一个中文字符可能被拆成两块。

例如：

```text
第一次：
228 189

第二次：
160
```

如果直接：

```javascript
decoder.decode(value);
```

可能出现乱码：

```text
�
```

使用：

```javascript
decoder.decode(value, {
  stream: true,
});
```

会自动缓存不完整字节，等待下一块数据后一起解码，避免乱码。

---

# 停止生成（AbortController）

AI聊天中的"停止生成"通常通过`AbortController`实现。

```javascript
const controller = new AbortController();

fetch("/chat", {
  signal: controller.signal,
});

// 停止生成
controller.abort();
```

作用：

* 中断HTTP请求
* 关闭SSE连接
* 停止继续接收模型返回的数据

---

# 心跳（了解）

为了避免长连接超时，服务端可能会定时发送心跳包，例如：

```text
:
```

或者：

```text
event: ping
data: ping
```

作用：

* 保持连接不断开
* 防止代理服务器、负载均衡等主动关闭空闲连接

一般由服务端实现，前端通常无需处理。

---

# 完整流程

```text
用户输入问题
      │
      ▼
fetch发送POST请求
      │
      ▼
服务器调用AI模型
      │
      ▼
模型生成内容
      │
      ▼
按多个Chunk持续推送
      │
      ▼
ReadableStream读取Chunk
      │
      ▼
TextDecoder解码
      │
      ▼
解析data:
      │
      ▼
JSON.parse()
      │
      ▼
拼接内容
      │
      ▼
更新页面（流式输出）
```

---

# SSE与WebSocket对比

| 对比项      | SSE             | WebSocket |
| -------- | --------------- | --------- |
| 通信方向     | 单向（服务端→客户端）     | 双向通信      |
| 协议       | HTTP            | WebSocket |
| 建立连接     | 简单              | 需握手       |
| 自动重连     | 支持（EventSource） | 需自行实现     |
| 是否适合流式输出 | ⭐⭐⭐⭐⭐           | ⭐⭐⭐       |
| 聊天室、游戏   | ⭐⭐              | ⭐⭐⭐⭐⭐     |

### 为什么AI更喜欢SSE？

AI对话的通信模式基本都是：

```text
客户端发送一次问题
        │
        ▼
服务器持续返回答案
```

客户端几乎没有持续发送数据的需求，因此SSE更加轻量、简单，也更符合HTTP生态。

---

# SSE的局限性

* 仅支持服务端向客户端单向通信。
* 浏览器连接数受HTTP协议限制（HTTP/2下已明显改善）。
* 不适合聊天室、在线游戏、协同编辑等双向实时通信场景。
* 若需要客户端频繁主动推送数据，更适合使用WebSocket。

---

# 面试高频问题

### ① 什么是SSE？

> SSE（Server-Sent Events）是一种基于HTTP的服务器推送技术，客户端发起一次请求后，服务器保持连接并持续向客户端发送数据，非常适合AI聊天、日志推送、任务进度等单向推送场景。

---

### ② 为什么AI聊天喜欢使用SSE？

* 支持边生成边返回，降低等待时间。
* 实现打字机效果，用户体验更好。
* 基于HTTP，实现简单，兼容现有鉴权、代理和网关体系。
* AI问答主要是单向推送，非常符合SSE使用场景。

---

### ③ 为什么不用EventSource？

因为`EventSource`只能发送GET请求，不支持：

* POST
* Request Body
* Authorization Header

现代AI接口通常需要POST请求和Token认证，因此普遍采用**fetch + ReadableStream**实现流式响应。

---

### ④ ReadableStream是什么？

> `ReadableStream`表示可读数据流，`fetch`返回的响应体就是一个`ReadableStream`。通过`getReader().read()`可以逐块（Chunk）读取服务器返回的数据，实现流式处理。

---

### ⑤ TextDecoder有什么作用？

> `TextDecoder`用于将`Uint8Array`等二进制数据按照UTF-8解码为字符串。在SSE中，浏览器读取到的是字节流，需要通过`TextDecoder.decode()`转换为文本，再解析和渲染。

---

### ⑥ 为什么推荐使用`stream: true`？

> 网络传输按Chunk进行，一个中文字符可能跨多个Chunk。`stream: true`会缓存不完整字节，等待下一块数据后再解码，避免中文乱码。

---

### ⑦ AbortController有什么作用？

> `AbortController`用于取消`fetch`请求。在AI聊天中通常用于实现"停止生成"，调用`abort()`即可中断请求并关闭SSE连接。

---

# 一句话总结

> **现代AI流式对话通常采用`fetch + ReadableStream + TextDecoder + SSE`方案：客户端通过`fetch`发送POST请求，服务器以SSE格式持续推送数据，前端利用`ReadableStream`逐块读取Chunk，再通过`TextDecoder`解码为字符串，解析数据后实时更新页面，实现流式输出的"打字机"效果。**
