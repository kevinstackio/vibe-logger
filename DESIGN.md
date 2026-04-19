# VibeLogger Design Notes

## 定位

读取 CC / Codex / Gemini CLI 本地 JSONL，按项目筛选，生成每日日志。全部手动触发，无需任何 hook 或外部依赖。

## 指令

| 指令 | 作用 |
|------|------|
| `log today` | 只处理今天，轻量安全 |
| `log merge` | 合并已有 per-author 文件 |

`log daily`（全量历史）暂未实现，因为 token 消耗不可控。

## 各工具存储路径

| 工具 | 路径 | 项目隔离 |
|------|------|---------|
| CC | `~/.claude/projects/{encoded-project-path}/*.jsonl` | ✅ 直接定位 |
| Gemini CLI | `~/.gemini/tmp/{project_hash}/chats/` | ✅ 直接定位 |
| Codex | `~/.codex/sessions/YYYY/MM/DD/*.jsonl` | ❌ 混合，需扫描 cwd |

## 文件命名

```
.vibe-logs/
├── 2026-04-20_kevin.md      ← 个人文件，可提交 git
├── 2026-04-20_alice.md      ← 个人文件，可提交 git
└── 2026-04-20_merged.md     ← 合并文件，gitignore
```

## 已知问题

1. **Codex 无项目索引** — 所有项目混在日期目录下，必须逐个读 `turn_context.cwd` 才能筛出当前项目
2. **token 消耗** — 模型直接读 JSONL，文件多时消耗大；`log today` 通过限定今天的范围控制成本
3. **无外部依赖** — 不引入 Python 脚本、jq 等工具，全靠模型 + bash

## 待决策

- `log daily` 全量历史怎么做（增量？限日期范围？）
- Codex 扫描问题如何优化
- Gemini CLI 支持（格式是 JSON，非 JSONL）
- Cursor 支持
