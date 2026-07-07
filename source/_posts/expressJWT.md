---
title: express JWT 认证流程总结
date: 2026-07-07 11:30:01
categories: 编程
tags: nodejs
---

JWT 最大的特点是：无状态。
jsonwebtoken 库本身不存储 token，它只负责两件事：

1. 签发 token
2. 验证 token

token 签发后交给客户端保存，服务端不需要像 session 一样存储登录状态。

<!--more-->

## 一、JWT 签发过程

登录成功后，服务端会使用 jsonwebtoken 签发 token。
签发时主要做了几件事：

1. 构造 header
   里面包含 token 类型和签名算法。

2. 构造 payload
   里面一般包含用户信息，例如：

```js
{
  (userId, username, iat, exp);
}
```

其中：

- iat：签发时间
- exp：过期时间

3. 使用 header + payload + secret 计算签名 signature

4. 最终拼接成 token：

```txt
header.payload.signature
```

需要注意：JWT 的 payload 默认不是加密的，只是 Base64URL 编码，所以不要把密码、手机号、身份证号等敏感信息放进去。

## 二、JWT 验证过程

客户端请求接口时，一般会把 accessToken 放到请求头里：

```http
Authorization: Bearer token
```

服务端认证中间件会做以下事情：

1. 从 Authorization 中取出 token

2. 拆分 token，得到：

```txt
header
payload
signature
```

3. 使用同一个 secret 和相同算法，重新计算一个新的签名

4. 将新签名和 token 中原来的 signature 对比

5. 如果签名一致，再判断 token 是否过期

6. 全部通过后，说明 token 合法

7. 将解码后的用户信息挂载到：

```js
req.user;
```

后续接口就可以通过 req.user 获取当前登录用户信息。

## 三、JWT 的核心理解

JWT 的本质是：

服务端签发一个带签名的凭证，客户端保存，后续请求带回来，服务端通过 secret 自行验证这个凭证是否可信。

所以全程最关键的是：

签发时的 secret

只要 secret 没泄露，别人就无法伪造合法 token。

## 四、AccessToken 和 RefreshToken 的常用设计

实际项目中常用的是双令牌机制：

### 1. accessToken

特点：
短时间有效，无状态，自校验

常见有效期：
15分钟

使用方式：
前端放在请求头 Authorization 中

它主要用于访问普通业务接口。

### 2. refreshToken

特点：
长时间有效，服务端需要存储

常见有效期：
7天

使用方式：
存 httpOnly cookie，同时服务端数据库或 Redis 中也保存一份

它主要用于在 accessToken 过期后，重新换取新的 accessToken。

## 五、双令牌认证系统接口流程

以 Express + MongoDB + JWT 为例，可以设计四个核心接口：

### 1. 注册接口

流程：
接收用户名和密码
bcrypt 加密密码
保存用户信息到 users 集合

重点：
数据库中不能保存明文密码

### 2. 登录接口

流程：
校验用户名和密码
bcrypt 对比密码
签发 accessToken
签发 refreshToken
refreshToken 存入数据库
refreshToken 写入 httpOnly cookie
accessToken 放响应体返回

重点：
accessToken 给前端使用
refreshToken 放 cookie，并且服务端存一份

### 3. 刷新令牌接口

流程：
从 cookie 中读取 refreshToken
验证 refreshToken 签名和过期时间
查询数据库中是否存在这个 refreshToken
如果有效，签发新的 accessToken
同时轮换新的 refreshToken
删除旧 refreshToken
保存新 refreshToken
重新写入 cookie

重点：
refreshToken 每次使用后都要换新的，这叫 refreshToken 轮换
这样可以降低 refreshToken 被盗后的风险。

### 4. 登出接口

流程：
从 cookie 中读取 refreshToken
删除数据库中的 refreshToken
清除 cookie

重点：
accessToken 本身无状态，无法直接删除
所以登出主要是让 refreshToken 失效
accessToken 因为有效期很短，一般等它自然过期即可。

## 六、认证中间件流程

认证中间件主要负责保护需要登录后才能访问的接口。

流程：
从 Authorization 请求头中读取 Bearer token
验证 accessToken 签名
判断是否过期
解析 payload
把用户信息挂载到 req.user
放行请求

示例理解：

```js
req.user = {
  userId,
  username,
};
```

后面的接口就可以通过 req.user.userId 判断当前是谁在操作。

## 七、安全要点

需要注意几个关键点：

1. accessToken 有效期要短
   一般设置为 15 分钟左右。

2. refreshToken 有效期可以长一些
   比如 7 天、14 天。

3. refreshToken 要存服务端
   可以存 MongoDB，也可以存 Redis。

4. refreshToken 要轮换
   每次刷新令牌后，旧 refreshToken 作废，生成新的 refreshToken。

5. accessToken 和 refreshToken 的 secret 必须分开

```env
ACCESS_TOKEN_SECRET=xxx
REFRESH_TOKEN_SECRET=yyy
```

payload 中不要放敏感信息
JWT payload 可以被前端解析出来，所以只放必要信息，例如：

```js
{
  (userId, username);
}
```

## 八、一句话总结

JWT 是一种无状态认证方案，服务端通过 secret 对 token 进行签名和验证；实际项目中通常使用 accessToken + refreshToken 双令牌机制，accessToken 负责访问接口，refreshToken 负责续期，而串联整个认证流程的核心是 userId。
