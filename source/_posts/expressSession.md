---
title: Express Session 认证流程总结
date: 2026-07-07 11:32:03
categories: 编程
tags: nodejs
---

Session 认证的核心特点是：

**登录状态保存在服务端，客户端只保存一个 sessionId。**

客户端通过 cookie 保存 `sid`，服务端通过这个 `sid` 去 MongoDB 中查找对应的 session 数据。

<!--more-->

## 1. 注册

用户注册时，提交账号和明文密码。

服务端不要直接保存明文密码，而是使用 `bcrypt` 对密码进行哈希加密：

```js
const hashedPassword = await bcrypt.hash(password, 10);
```

然后把用户信息和加密后的密码存入 `users` 集合。

需要注意：

**bcrypt 是哈希，不是加密。**

更准确的说法是：

> 使用 bcrypt 对密码进行哈希处理，然后保存哈希后的密码。

因为加密一般可以解密，而哈希不能还原成原密码。

## 2. 登录

用户提交账号和明文密码。

服务端先从 `users` 集合中查询用户，然后使用：

```js
bcrypt.compare(password, user.password);
```

对比用户提交的明文密码和数据库中保存的哈希密码。

如果校验通过，调用：

```js
req.session.regenerate();
```

重新生成新的 `sessionId`，防止 **Session Fixation 攻击**。

然后把必要的用户信息写入 `req.session`：

```js
req.session.user = {
  id: user._id,
  username: user.username,
};
```

之后 `express-session` 会配合 `connect-mongo`，把 session 数据保存到 MongoDB 的 `sessions` 集合中。

## 3. 后续请求

登录成功后，浏览器会自动在请求中携带 cookie，例如：

```txt
Cookie: connect.sid=xxx
```

服务端收到请求后，`express-session` 会：

1. 从 cookie 中读取 `sid`
2. 根据 `sid` 去 MongoDB 的 `sessions` 集合中查询 session
3. 如果查到，就把 session 数据还原到 `req.session`
4. 后续中间件就可以通过 `req.session.user` 判断用户是否登录

鉴权中间件一般这样写：

```js
function auth(req, res, next) {
  if (req.session.user) {
    next();
  } else {
    res.status(401).json({ message: "未登录" });
  }
}
```

判断逻辑：

```txt
req.session.user 存在：已登录
req.session.user 不存在：未登录 / session 过期 / cookie 无效
```

## 4. 登出

登出时，需要销毁服务端 session：

```js
req.session.destroy(() => {
  res.clearCookie("connect.sid");
  res.json({ message: "退出成功" });
});
```

这里有两个动作：

1. `req.session.destroy()`：删除服务端 session
2. `res.clearCookie()`：清除客户端 cookie

否则客户端可能还保留旧的 `sid`。

## 5. 过期清理

session 的过期时间通常由 cookie 的 `maxAge` 和 `connect-mongo` 的 TTL 机制共同控制。

例如：

```js
app.use(
  session({
    secret: "your-secret",
    store: MongoStore.create({
      mongoUrl: "mongodb://localhost:27017/test",
    }),
    cookie: {
      maxAge: 1000 * 60 * 60,
    },
    resave: false,
    saveUninitialized: false,
  }),
);
```

这里表示 session 有效期为 1 小时。

`connect-mongo` 会根据 session 的过期时间，清理 MongoDB 中过期的 session 数据。
