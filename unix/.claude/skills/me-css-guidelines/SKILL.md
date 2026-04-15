---
name: me-css-guidelines
description: Use when writing or reviewing CSS or Tailwind CSS code. Provides guidelines for layout, spacing, and class usage to avoid common pitfalls.
---

# CSS Guidelines

## レイアウト・スペーシング

### 縦積みレイアウトに `flex flex-col` を安易に使わない

暗黙的に `min-width: auto` が子要素に設定されることで、横幅がはみ出す場合があるため。

**判断基準:**

| ユースケース | 推奨 |
|-------------|------|
| 子要素間にスペースを空けたいだけ | `space-y-*` |
| アイテムを均等配置・stretch したい | `flex flex-col` |
| 子要素が `min-width: 0` 問題を起こす可能性がある | `flex flex-col` + 子に `min-w-0` を明示 |
