---
name: vibe-logger
description: >
  Logs vibe coding sessions by reading local JSONL transcripts from Claude Code
  and Codex. Trigger on: "log daily", "vibe log daily", "log merge", "vibe merge".
  Execute immediately without asking for confirmation.
---

# VibeLogger

Reads CC and Codex JSONL session files, filters by current project, generates daily logs.

## log daily

Generate per-day per-author log files for the current project.

### Steps

1. Get author and project path:
   ```bash
   git config user.name 2>/dev/null | tr ' ' '_' || whoami
   pwd
   ```

2. Find all JSONL files from CC and Codex:
   - CC: `~/.claude/projects/*/*.jsonl`
   - Codex: `~/.codex/sessions/**/*.jsonl`

3. For each JSONL file, read it and filter messages where `cwd` matches current `$PWD`:
   - CC: user entries have `"type": "user"` with `"cwd"` field
   - Codex: look for `"type": "turn_context"` with `"payload.cwd"` to confirm project match, then extract `"type": "event_msg"` entries where `payload.type` is `"user_message"` or `"agent_message"`

4. Normalize to unified format per message:
   ```
   timestamp | role (user/assistant) | content | tool (cc/codex)
   ```

5. Group by date (`YYYY-MM-DD` from timestamp). For each date write `.vibe-logs/YYYY-MM-DD_{author}.md`:

   ```markdown
   # YYYY-MM-DD — {project_name} ({author})

   ## HH:MM [cc|codex]
   **user:** {content}
   **assistant:** {content}
   ```

   Group consecutive exchanges under the same time header (minute precision).
   Always overwrite — idempotent.

6. Create `.vibe-logs/` if it doesn't exist.

7. Confirm: `Logged {N} days → .vibe-logs/ ✓`

## log merge

Merge all per-author files for each date into `YYYY-MM-DD_merged.md`.

### Steps

1. Find all per-author files (exclude `_merged`):
   ```bash
   ls .vibe-logs/????-??-??_*.md 2>/dev/null | grep -v '_merged'
   ```

2. Group by date. For each date with multiple author files:
   - Parse all entries with timestamps
   - Sort by timestamp, then by author name alphabetically for ties
   - Write `.vibe-logs/YYYY-MM-DD_merged.md`:

   ```markdown
   # YYYY-MM-DD — {project_name} (merged)

   ## HH:MM [cc|codex] {author}
   **user:** {content}
   **assistant:** {content}
   ```

3. Confirm: `Merged {N} dates → .vibe-logs/ ✓`

## Data sources

| Tool | JSONL location | Project filter field |
|------|---------------|---------------------|
| CC | `~/.claude/projects/*/*.jsonl` | `cwd` in user message |
| Codex | `~/.codex/sessions/**/*.jsonl` | `payload.cwd` in `turn_context` |
