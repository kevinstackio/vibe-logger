# VibeLogger

Reads your local Claude Code and Codex session transcripts, filters by project, and generates daily logs.

## Logs

```
.vibe-logs/
├── 2026-04-20_kevin.md      ← per-author, safe to commit
├── 2026-04-20_alice.md      ← per-author, safe to commit
└── 2026-04-20_merged.md     ← merged view, gitignore
```

## Install

**Claude Code:**
```bash
mkdir -p ~/.claude/skills/vibe-logger/scripts
curl -fsSL https://raw.githubusercontent.com/kevinstackio/vibe-logger/main/skills/vibe-logger/SKILL.md \
  -o ~/.claude/skills/vibe-logger/SKILL.md
curl -fsSL https://raw.githubusercontent.com/kevinstackio/vibe-logger/main/skills/vibe-logger/scripts/parse_sessions.py \
  -o ~/.claude/skills/vibe-logger/scripts/parse_sessions.py
```

## Commands

| 命令 | 作用 |
|------|------|
| `log daily` | 生成当前项目所有天的日志 |
| `log merge` | 合并当天所有作者日志 |

## .gitignore

```
.vibe-logs/*_merged.md
```
