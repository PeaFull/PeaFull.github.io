---
name: hexo-publish-post
description: 根据用户提供的文章标题和 Markdown 正文创建新的 Hexo 博客文章，并执行完整发布流程。用于用户希望在 Hexo 站点中发布或部署新文章，且需要执行相当于 `npx hexo new`、`npx hexo clean`、`npx hexo g` 和 `npx hexo d` 的流程。
---

# Hexo 发布文章

## 工作流程

仅当用户同时提供文章标题和正文内容，并且希望直接发布或部署时，使用此 skill。

1. 除非用户指定其他 Hexo 目录，否则从 Hexo 项目根目录运行。
2. 将文章标题翻译成英文 URL slug，用于生成 Markdown 文件名和匹配的文章资源目录名。文章标题本身保留原语言，但生成的文件名和目录名不能包含中文字符。
   - 使用小写英文单词，并用单个连字符分隔。
   - 只能使用 `a-z`、`0-9` 和 `-`。
   - 当可以自然翻译成英文时，不要使用拼音。
   - 示例：`如何使用 Codex 发布博客` -> `how-to-publish-a-blog-with-codex`。
3. 在写入临时 Markdown 文件前，先整理文章正文：
   - 如果用户没有提供 `<!--more-->`，插入且只插入一个 `<!--more-->` 标记。
   - 将它放在自然的摘要截断位置，通常位于文章前半部分，紧跟在能够概括整体主题、并给读者提供代表性预览的段落或小节之后。
   - 不要在文章还没有足够上下文形成有效首页摘要前插入。
   - 除非用户明确要求，否则临时正文中不要包含 YAML front matter。
4. 执行 skill 自带脚本：

```bash
/path/to/skill/scripts/publish_hexo_post.sh --title "文章标题" --slug "english-title-slug" --content-file /path/to/body.md --cwd /path/to/hexo-project
```

5. 让脚本执行必需流程：
   - `npx hexo new "文章标题" --path "english-title-slug"`
   - 保留 Hexo 生成的 front matter，并替换生成文章的正文
   - `npx hexo clean`
   - `npx hexo g`
   - `npx hexo d`

## 安全检查

- 运行脚本前，确认工作目录是 Hexo 项目。
- 不要硬编码凭据、部署密钥、token 或远程仓库敏感信息。
- 如果用户要求立即发布，并且已经提供标题和正文，不要再次请求确认；部署命令正是此 skill 的用途。
- 如果缺少标题或正文，先询问缺失内容，再执行部署。
- 始终传入英文 `--slug`；脚本会拒绝缺失或非英文 slug，避免生成的文章路径包含中文字符。

## 说明

- 脚本会保留 Hexo 生成的 YAML front matter，只替换正文内容。
- 脚本通过比较执行 `npx hexo new` 前后的 `source/_posts/*.md` 文件列表来识别新建文章。
- 首页摘要由 `<!--more-->` 控制；保留已有标记，避免重复插入。
- 如果 `npx hexo d` 失败，报告命令输出，不要盲目重试。
