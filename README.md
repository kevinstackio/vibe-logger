# VibeLogger

Reads your local Claude Code and Codex session transcripts, filters by project, and generates daily logs.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/kevinstackio/vibe-logger/main/skills/vibe-logger/SKILL.md \
  -o ~/.claude/skills/vibe-logger/SKILL.md
```

## Commands

| 命令        | 作用                     |
| ----------- | ------------------------ |
| `log daily` | 生成当前项目所有天的日志 |
| `log merge` | 合并所有作者日志         |

## Logs

```
.vibe-logs/
├── 2026-04-20_kevin.md      ← per-author, safe to commit
├── 2026-04-20_alice.md      ← per-author, safe to commit
└── 2026-04-20_merged.md     ← merged view, gitignore
```
