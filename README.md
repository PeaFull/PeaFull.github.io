# PeaFull's Notes

这是一个基于 Hexo 的个人博客项目，当前使用 NexT 主题，源码分支为 `hexo-source-code`，静态站点部署到 GitHub Pages。

## 环境准备

建议使用 Node.js 20 或更高版本。当前本机验证过的环境：

```bash
node -v
npm -v
npx hexo version
```

首次拉取项目后安装依赖：

```bash
npm install
```

如果希望严格按照 `package-lock.json` 还原依赖：

```bash
npm ci
```

## 分支说明

这个仓库使用源码分支和部署分支分离的方式：

```text
hexo-source-code  博客源码分支，保存 Markdown、配置、主题、依赖等内容
master            GitHub Pages 部署分支，保存 Hexo 生成后的静态 HTML/CSS/JS
```

日常写文章、改配置、更新主题时，都应该在 `hexo-source-code` 分支进行。

GitHub 仓库默认分支也应该保持为 `hexo-source-code`，方便进入仓库后直接看到源码、配置和项目说明；`master` 只作为 GitHub Pages 的部署分支使用。

部署时不需要手动切到 `master` 分支。执行 `npx hexo deploy` 后，`hexo-deployer-git` 会把 `public/` 里的生成结果提交并推送到远端 `master` 分支。

确认当前源码分支：

```bash
git branch --show-current
```

如果不在源码分支，可以切回：

```bash
git switch hexo-source-code
```

## 本地运行

清理旧生成文件并启动本地服务：

```bash
npx hexo clean
npx hexo server
```

默认访问地址：

```text
http://localhost:4000
```

如果端口被占用，可以换一个端口：

```bash
npx hexo server --port 4001
```

## 创建博客内容

创建一篇新文章：

```bash
npx hexo new "文章标题"
```

这会在 `source/_posts/` 下生成 Markdown 文件。

创建指定布局的文章：

```bash
npx hexo new post "文章标题"
```

创建草稿：

```bash
npx hexo new draft "文章标题"
```

草稿会生成在 `source/_drafts/` 下，本地预览草稿：

```bash
npx hexo server --draft
```

发布草稿：

```bash
npx hexo publish "文章标题"
```

创建独立页面，例如关于页：

```bash
npx hexo new page "about"
```

常见内容目录：

```text
source/_posts/     正式文章
source/_drafts/    草稿
source/about/      关于页
source/tags/       标签页
source/categories/ 分类页
source/uploads/    图片等静态资源
```

## 文章 Front Matter

文章开头通常长这样：

```yaml
---
title: 文章标题
date: 2026-07-07 10:00:00
categories:
  - 编程
tags:
  - Hexo
  - 博客
---
```

常用字段：

```text
title       文章标题
date        发布时间
updated     更新时间
categories 文章分类
tags        文章标签
comments    是否开启评论
```

如果文章需要单独放图片，当前配置开启了 `post_asset_folder: true`，可以把图片放在和文章同名的资源目录里。

## 生成与部署

只生成静态文件：

```bash
npx hexo clean
npx hexo generate
```

生成后的文件在 `public/` 目录。

部署到 GitHub Pages：

```bash
npx hexo deploy
```

生成并部署：

```bash
npx hexo deploy --generate
```

当前部署配置在 `_config.yml`：

```yaml
deploy:
  type: git
  repo: https://github.com/PeaFull/PeaFull.github.io.git
  branch: master
```

这表示：无论当前开发分支是 `hexo-source-code`，部署产物都会发布到远端 `master` 分支。

## Hexo 常用命令速查

```bash
# 查看 Hexo 版本和环境信息
npx hexo version

# 创建新文章
npx hexo new "文章标题"

# 创建新页面
npx hexo new page "页面名"

# 创建草稿
npx hexo new draft "文章标题"

# 发布草稿
npx hexo publish "文章标题"

# 清理缓存和 public 目录
npx hexo clean

# 生成静态文件
npx hexo generate

# 生成静态文件，简写
npx hexo g

# 启动本地预览服务
npx hexo server

# 启动本地预览服务，简写
npx hexo s

# 指定端口启动
npx hexo server --port 4001

# 预览草稿
npx hexo server --draft

# 部署
npx hexo deploy

# 部署，简写
npx hexo d

# 生成并部署
npx hexo deploy --generate

# 显示帮助
npx hexo help
```

## 常见问题

### 本地启动后页面不是最新

先清理再启动：

```bash
npx hexo clean
npx hexo server
```

### 修改配置后没有生效

优先清理缓存：

```bash
npx hexo clean
npx hexo generate
```

### 端口被占用

换端口启动：

```bash
npx hexo server --port 4001
```

### 部署前想确认生成没问题

先只生成，不部署：

```bash
npx hexo clean
npx hexo generate
```

确认没有报错后再执行：

```bash
npx hexo deploy
```

## 项目备注

- 主配置文件是 `_config.yml`。
- NexT 主题配置文件是 `_config.next.yml`。
- 日常源码维护使用 `hexo-source-code` 分支，线上静态页面由 `master` 分支承载。
- 当前主题为 `next`。
- 当前仓库存在未跟踪的 `themes/next/` 目录；如果后续整理仓库，需要确认是继续使用 npm 依赖里的 `hexo-theme-next`，还是把本地主题目录纳入版本管理。
- `_config.yml` 里的 `url` 当前仍是示例值，正式发布前建议改成真实站点地址。
