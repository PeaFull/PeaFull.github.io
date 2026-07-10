---
title: 线上性能监控方案
date: 2026-07-07 10:50:36
categories: 编程
tags: 前端性能
---

## 一、监控目标

前端性能监控的核心目的不是单纯看页面快不快，而是：

1. 发现页面加载慢、白屏、卡顿等问题；
2. 定位是网络、资源、接口、渲染还是 JS 执行导致；
3. 量化用户真实体验；
4. 为性能优化提供数据依据；
5. 线上出现性能劣化时能及时报警。

<!--more-->

## 二、核心监控指标

### 1. 页面加载性能指标

常见指标包括：

| 指标             | 含义                                   |
| ---------------- | -------------------------------------- |
| FP               | First Paint，首次绘制                  |
| FCP              | First Contentful Paint，首次内容绘制   |
| LCP              | Largest Contentful Paint，最大内容绘制 |
| DOMContentLoaded | DOM 解析完成时间                       |
| Load             | 页面资源完全加载时间                   |
| TTFB             | 首字节时间，反映服务端响应速度         |
| DNS              | DNS 查询耗时                           |
| TCP              | TCP 连接耗时                           |
| SSL              | HTTPS 握手耗时                         |
| Resource Timing  | JS、CSS、图片等资源加载耗时            |

面试里重点说：

> 我们会重点关注 FCP、LCP、TTFB、资源加载耗时和接口耗时，这些指标可以比较直观地反映页面首屏体验和网络链路问题。

### 2. 用户体验指标

除了加载速度，还要关注用户交互体验。

| 指标      | 含义                           |
| --------- | ------------------------------ |
| CLS       | 页面布局偏移                   |
| INP       | 用户交互响应延迟               |
| Long Task | 超过 50ms 的长任务             |
| FPS       | 页面帧率                       |
| 卡顿率    | 页面是否频繁掉帧               |
| 白屏时间  | 从打开页面到首屏内容出现的时间 |

可以这样讲：

> 如果页面资源加载很快，但 JS 执行时间长、主线程被阻塞，用户仍然会感觉页面卡顿，所以还需要监控 Long Task、INP、FPS 等交互体验指标。

### 3. 接口性能指标

接口性能是前端体验的重要组成部分。

需要监控：

1. 接口 URL；
2. 请求方法；
3. 请求耗时；
4. 状态码；
5. 成功 / 失败；
6. 错误信息；
7. 慢接口；
8. 超时接口；
9. 重试次数；
10. 业务错误码。

实现方式：

- 重写 `XMLHttpRequest`；
- 劫持 `fetch`；
- 在 Axios 拦截器中统一埋点；
- 记录请求开始时间、结束时间、状态码和错误信息。

### 4. 静态资源性能

需要监控：

1. JS 文件加载耗时；
2. CSS 文件加载耗时；
3. 图片加载耗时；
4. 字体加载耗时；
5. 资源加载失败；
6. 大资源文件；
7. CDN 命中情况；
8. 缓存命中情况。

资源监控可以通过：

```js
performance.getEntriesByType("resource");
```

获取资源加载信息。

### 5. 前端异常监控

性能监控一般会和异常监控结合起来做。

常见异常包括：

1. JS 运行时错误；
2. Promise 未捕获异常；
3. 资源加载失败；
4. 接口异常；
5. 框架错误，比如 React Error Boundary；
6. 白屏异常；
7. 页面崩溃；
8. 内存泄漏。

常见采集方式：

```js
window.onerror = function (message, source, lineno, colno, error) {};

window.addEventListener("unhandledrejection", function (event) {});

window.addEventListener("error", function (event) {}, true);
```

## 三、性能数据采集方式

### 1. 使用 Performance API

浏览器提供了原生的性能 API。

常用 API：

```js
performance.timing;
performance.getEntriesByType("navigation");
performance.getEntriesByType("resource");
performance.getEntriesByType("paint");
```

现代项目中更推荐：

```js
performance.getEntriesByType("navigation");
```

而不是老的 `performance.timing`。

### 2. 使用 PerformanceObserver

用于监听性能指标，比如 FCP、LCP、Long Task、CLS 等。

示例：

```js
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    console.log(entry);
  }
});

observer.observe({
  type: "largest-contentful-paint",
  buffered: true,
});
```

前端页面通过 PerformanceObserver 采集性能指标，然后经过上报模块，使用 sendBeacon 或 fetch 把数据发送到监控服务器。服务器记录性能日志后，进入数据分析与可视化阶段，最后通过报表、告警等方式反馈给前端团队，用来指导性能优化。

| 层级       | 作用                                  |
| ---------- | ------------------------------------- |
| 前端采集层 | 监听 LCP、FID、CLS 等性能指标         |
| 传输层     | 使用 `sendBeacon` 或 `fetch` 上报数据 |
| 存储层     | 记录前端性能日志                      |
| 分析层     | 生成可视化报表，并配置阈值告警        |
| 反馈层     | 根据监控结果指导前端性能优化          |

### 3. 接口请求劫持

如果项目中用 Axios，可以在拦截器中做统计：

```js
axios.interceptors.request.use((config) => {
  config.metadata = {
    startTime: Date.now(),
  };
  return config;
});

axios.interceptors.response.use(
  (response) => {
    const duration = Date.now() - response.config.metadata.startTime;

    report({
      type: "api",
      url: response.config.url,
      method: response.config.method,
      status: response.status,
      duration,
    });

    return response;
  },
  (error) => {
    const config = error.config || {};
    const duration = Date.now() - config.metadata?.startTime;

    report({
      type: "api_error",
      url: config.url,
      method: config.method,
      status: error.response?.status,
      duration,
      message: error.message,
    });

    return Promise.reject(error);
  },
);
```

### 4. 白屏检测

白屏监控一般可以通过关键点采样实现。

思路：

1. 页面加载一段时间后；
2. 在屏幕中心区域取多个点；
3. 使用 `document.elementFromPoint` 判断这些点是否都是空节点；
4. 如果大部分点都是 `html`、`body`、空容器，则认为可能白屏；
5. 同时结合 JS 错误、资源加载失败、接口失败一起判断。

示例：

```js
function checkWhiteScreen() {
  const points = [
    [window.innerWidth / 2, window.innerHeight / 2],
    [window.innerWidth / 2, window.innerHeight / 4],
    [window.innerWidth / 2, (window.innerHeight * 3) / 4],
    [window.innerWidth / 4, window.innerHeight / 2],
    [(window.innerWidth * 3) / 4, window.innerHeight / 2],
  ];

  const emptyElements = ["html", "body", "#app", "#root"];

  let emptyCount = 0;

  points.forEach(([x, y]) => {
    const element = document.elementFromPoint(x, y);
    if (element && emptyElements.includes(element.tagName.toLowerCase())) {
      emptyCount++;
    }
  });

  if (emptyCount >= 4) {
    report({
      type: "white_screen",
      url: location.href,
    });
  }
}

setTimeout(checkWhiteScreen, 3000);
```

## 四、数据上报方案

### 1. 上报时机

常见上报时机：

1. 页面加载完成后；
2. 页面隐藏时；
3. 页面卸载前；
4. 接口请求结束后；
5. 发生错误时；
6. 达到一定缓存数量后批量上报。

推荐：

```js
navigator.sendBeacon();
```

适合页面关闭、跳转时上报，不容易丢数据。

```js
navigator.sendBeacon("/monitor/report", JSON.stringify(data));
```

也可以使用图片打点：

```js
new Image().src = `/monitor/report?data=${encodeURIComponent(JSON.stringify(data))}`;
```

或者使用普通 `fetch` 上报。

### 2. 上报策略

为了避免影响业务性能，需要注意：

1. 批量上报，不要每条数据都立即上报；
2. 设置采样率，例如 10% 用户上报；
3. 区分普通用户、灰度用户、内部用户；
4. 错误数据优先上报；
5. 页面卸载时使用 `sendBeacon`；
6. 上报接口不能阻塞主业务；
7. 上报失败可以做简单重试，但不能无限重试。

### 3. 上报数据结构

可以设计成这样：

```js
{
  type: 'performance',
  appId: 'admin-system',
  userId: 'xxx',
  sessionId: 'xxx',
  pageUrl: location.href,
  route: '/dashboard',
  timestamp: Date.now(),
  device: {
    userAgent: navigator.userAgent,
    screen: `${screen.width}x${screen.height}`,
    network: navigator.connection?.effectiveType
  },
  metrics: {
    fcp: 1200,
    lcp: 2500,
    ttfb: 300,
    domReady: 1800,
    load: 3500
  }
}
```

## 五、后端与平台能力

前端只负责采集和上报，完整方案还需要后端和监控平台支持。

### 1. 后端接收数据

后端需要提供上报接口：

```txt
POST /monitor/report
```

主要负责：

1. 接收前端上报数据；
2. 数据清洗；
3. 数据入库；
4. 数据聚合；
5. 异常告警；
6. 提供查询接口。

### 2. 数据存储

可以根据数据量选择：

| 类型       | 方案                  |
| ---------- | --------------------- |
| 小规模     | MySQL / PostgreSQL    |
| 日志型数据 | Elasticsearch         |
| 时序数据   | Prometheus / InfluxDB |
| 大数据分析 | ClickHouse            |
| 日志采集   | Kafka + Flink         |

前端面试里不用讲太深，可以说：

> 数据量小可以先落库，数据量大时可以走日志系统，比如 Kafka + ClickHouse / Elasticsearch 做查询分析。

### 3. 可视化看板

监控平台需要展示：

1. 页面平均加载时间；
2. FCP / LCP / TTFB 趋势；
3. 慢页面排行；
4. 慢接口排行；
5. 资源加载失败排行；
6. 不同浏览器性能对比；
7. 不同地区性能对比；
8. 不同版本性能对比；
9. 错误率趋势；
10. 白屏率趋势。

### 4. 告警机制

可以设置阈值：

1. LCP 超过 4s；
2. 页面白屏率超过 1%；
3. JS 错误率突然升高；
4. 接口错误率超过 5%；
5. 某接口平均耗时超过 2s；
6. 某版本性能明显劣化。

告警渠道：

1. 企业微信；
2. 钉钉；
3. 飞书；
4. 邮件；
5. 电话告警。

## 六、项目中可以怎么落地

实际项目中可以分三层做：

### 第一层：基础 SDK

封装一个前端监控 SDK。

负责：

1. 初始化配置；
2. 自动采集性能指标；
3. 自动采集错误；
4. 自动采集接口耗时；
5. 自动采集资源加载失败；
6. 数据缓存；
7. 数据上报；
8. 采样控制。

示例：

```js
monitor.init({
  appId: "digital-human-admin",
  env: "production",
  userId: getUserId(),
  reportUrl: "/api/monitor/report",
  sampleRate: 0.1,
});
```

### 第二层：业务埋点

对于关键业务链路，可以手动埋点。

比如：

1. AI 试衣任务创建耗时；
2. 任务轮询成功耗时；
3. 图片生成结果加载耗时；
4. 数字人播报加载耗时；
5. 后台列表查询耗时；
6. 表单提交耗时。

示例：

```js
monitor.track("tryon_task_created", {
  taskId,
  duration,
  status,
});
```

### 第三层：分析治理

监控不是为了“有数据”，而是为了持续优化。

常见治理方式：

1. 慢页面专项优化；
2. 慢接口推动后端优化；
3. 大资源拆分和压缩；
4. 首屏资源按需加载；
5. 路由懒加载；
6. 图片懒加载；
7. CDN 和缓存优化；
8. 长任务拆分；
9. 降低重复渲染；
10. 定期性能巡检。
