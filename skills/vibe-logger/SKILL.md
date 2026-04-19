---
name: vibe-logger
description: >
  Automatically logs a vibe coding session. Use this skill whenever the user wants
  to record, save, or log what they worked on — even if they don't use the exact phrase
  "vibe log". Trigger on: "log session", "save vibe", "vibe log", "log my session",
  "record session", "wrap up session", "save what I did", "document my work today",
  "I'm done for the day", "that's a wrap". Execute immediately without asking for
  confirmation — just do it and report the result.
---

# VibeLogger

Saves a snapshot of the current coding session as an individual markdown file.
Each session = one file. No appending, no merging.

## Log location

Always write to `./.vibe-logs/` in the current working directory. Create it if it doesn't exist.

## Steps

### 1. Gather context (run in parallel)

```bash
git rev-parse --show-toplevel 2>/dev/null    # confirm project root
git log --oneline -10
git diff --stat HEAD 2>/dev/null
git branch --show-current
date "+%Y-%m-%d_%H-%M"
```

Skip git fields silently if not in a repo.

### 2. Get summary

If the user already described what they did, use that directly.
Otherwise ask once: "What did you work on this session?"

### 3. Build the entry

```markdown
## {DATE}

**Project:** {PROJECT_NAME}
**Branch:** `{BRANCH}`
**Tool:** {AI_TOOL}
**Summary:** {SUMMARY}

### Commits
- {COMMIT_HASH} {COMMIT_MESSAGE}

### Files touched
{GIT_DIFF_STAT}
```

For **Tool**, detect from context: Claude Code / Cursor / Codex / Gemini CLI / Chat.
If unknown, write the tool name the user mentions or leave blank.

### 4. Write the file

- Filename: `YYYY-MM-DD_HH-MM-SS.md`
- Confirm: "Logged → .vibe-logs/YYYY-MM-DD_HH-MM.md ✓" and show the entry.

## Cross-tool usage

This skill works the same way in any AI coding tool:
- **Claude Code**: installed as a skill (this file)
- **Cursor**: paste the Steps section into `.cursorrules`
- **Codex / Gemini CLI**: paste into `AGENTS.md` at project root or global config
- **Chat mode**: manually trigger by saying "log my session" and paste git context

The log format is identical regardless of tool, so all sessions are analyzable together.
