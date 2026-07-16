#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
用法：publish_hexo_post.sh --title "文章标题" --slug "english-title-slug" --content-file /path/to/body.md [--cwd /path/to/hexo]

参数：
  --title         文章标题，保留为文章标题
  --slug          标题翻译成英文后的文件名/文件夹名 slug，只能包含小写英文字母、数字和连字符
  --content-file 只包含正文 Markdown 的文件
  --cwd          Hexo 项目根目录，默认使用当前目录
USAGE
}

title=""
slug=""
content_file=""
project_dir="$PWD"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)
      title="${2:-}"
      shift 2
      ;;
    --slug)
      slug="${2:-}"
      shift 2
      ;;
    --content-file)
      content_file="${2:-}"
      shift 2
      ;;
    --cwd)
      project_dir="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "未知参数：$1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$title" || -z "$slug" || -z "$content_file" ]]; then
  usage
  exit 2
fi

if [[ ! "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "slug 必须是英文 URL slug，只能包含小写英文字母、数字和单个连字符分隔的单词：$slug" >&2
  exit 2
fi

if [[ ! -f "$content_file" ]]; then
  echo "正文文件不存在：$content_file" >&2
  exit 1
fi

if [[ ! -d "$project_dir" ]]; then
  echo "Hexo 项目目录不存在：$project_dir" >&2
  exit 1
fi

cd "$project_dir"

if [[ ! -f "package.json" || ! -f "_config.yml" ]]; then
  echo "当前目录不像 Hexo 项目根目录：$project_dir" >&2
  exit 1
fi

if ! node -e 'const p=require("./package.json"); process.exit(p.hexo || (p.dependencies && p.dependencies.hexo) || (p.devDependencies && p.devDependencies.hexo) ? 0 : 1)' >/dev/null 2>&1; then
  echo "package.json 中未检测到 hexo 配置或依赖：$project_dir" >&2
  exit 1
fi

before_file="$(mktemp)"
after_file="$(mktemp)"
find source/_posts -type f -name '*.md' -print 2>/dev/null | sort > "$before_file"

npx hexo new "$title" --path "$slug"

find source/_posts -type f -name '*.md' -print 2>/dev/null | sort > "$after_file"
new_post="$(comm -13 "$before_file" "$after_file" | head -n 1)"

rm -f "$before_file" "$after_file"

if [[ -z "$new_post" ]]; then
  echo "无法定位新建文章文件。请检查 npx hexo new 输出。" >&2
  exit 1
fi

python3 - "$new_post" "$content_file" <<'PY'
from pathlib import Path
import sys

post_path = Path(sys.argv[1])
content_path = Path(sys.argv[2])
post_text = post_path.read_text(encoding="utf-8")
body_text = content_path.read_text(encoding="utf-8").strip()

if post_text.startswith("---"):
    marker = post_text.find("\n---", 3)
    if marker != -1:
        front_matter = post_text[: marker + len("\n---")]
        post_path.write_text(front_matter.rstrip() + "\n\n" + body_text + "\n", encoding="utf-8")
        print(post_path)
        sys.exit(0)

post_path.write_text(body_text + "\n", encoding="utf-8")
print(post_path)
PY

npx hexo clean
npx hexo g
npx hexo d

echo "已发布：$new_post"
