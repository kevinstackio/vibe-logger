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

1. Get context:
   ```bash
   git config user.name 2>/dev/null | tr ' ' '_' || whoami
   pwd
   ```

2. Run the parser:
   ```bash
   python3 ~/.claude/skills/vibe-logger/scripts/parse_sessions.py "$PWD"
   ```
   Output is JSON: `{ "YYYY-MM-DD": [ {timestamp, role, content, tool} ] }`

3. For each date in the output, write `.vibe-logs/YYYY-MM-DD_{author}.md`:

   ```markdown
   # YYYY-MM-DD — {project_name} ({author})

   ## {HH:MM} [{tool}]
   **user:** {content}
   **assistant:** {content}

   ## {HH:MM} [{tool}]
   ...
   ```

   Group consecutive user+assistant exchanges under the same timestamp header.
   Always overwrite — `log daily` is idempotent.

4. Create `.vibe-logs/` if it doesn't exist.

5. Confirm: `Logged {N} days → .vibe-logs/ ✓`

## log merge

Merge all per-author files for each date into `YYYY-MM-DD_merged.md`.

### Steps

1. Find all per-author files:
   ```bash
   ls .vibe-logs/????-??-??_*.md 2>/dev/null | grep -v '_merged'
   ```

2. Group by date. For each date that has files:
   - Read all author files for that date
   - Parse each entry with its timestamp
   - Sort all entries by timestamp, then by author name alphabetically for ties
   - Write `.vibe-logs/YYYY-MM-DD_merged.md`:

   ```markdown
   # YYYY-MM-DD — {project_name} (merged)

   ## {HH:MM} [{tool}] {author}
   **user:** {content}
   **assistant:** {content}

   ## {HH:MM} [{tool}] {author}
   ...
   ```

3. Confirm: `Merged {N} dates → .vibe-logs/ ✓`

## Notes

- Parser script: `~/.claude/skills/vibe-logger/scripts/parse_sessions.py`
- CC sessions: `~/.claude/projects/*/` filtered by `cwd`
- Codex sessions: `~/.codex/sessions/**/` filtered by `turn_context.cwd`
- Individual files (`YYYY-MM-DD_{author}.md`) can be committed to git
- Merged files (`YYYY-MM-DD_merged.md`) should be gitignored
