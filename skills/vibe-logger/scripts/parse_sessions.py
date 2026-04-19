#!/usr/bin/env python3
"""
Parse CC and Codex JSONL session files, filter by project, output unified JSON.

Usage: python3 parse_sessions.py [project_path]
Output: JSON grouped by date { "2026-04-20": [ {timestamp, role, content, tool} ] }
"""

import json
import os
import sys
import glob
from datetime import datetime, timezone
from pathlib import Path


def parse_cc_sessions(project_path):
    """Parse ~/.claude/projects/ JSONL files filtered by project cwd."""
    messages = []
    projects_dir = Path.home() / ".claude" / "projects"
    if not projects_dir.exists():
        return messages

    for jsonl_file in projects_dir.glob("*/*.jsonl"):
        try:
            with open(jsonl_file) as f:
                lines = f.readlines()

            # Check if this file belongs to our project
            project_match = False
            for line in lines:
                try:
                    obj = json.loads(line)
                    if obj.get("type") == "user" and obj.get("cwd") == project_path:
                        project_match = True
                        break
                except Exception:
                    continue

            if not project_match:
                continue

            for line in lines:
                try:
                    obj = json.loads(line)
                    msg_type = obj.get("type")
                    ts = obj.get("timestamp", "")

                    if msg_type == "user":
                        content = obj.get("message", {}).get("content", "")
                        if isinstance(content, list):
                            content = " ".join(
                                c.get("text", "") for c in content if isinstance(c, dict)
                            )
                        if content and content.strip():
                            messages.append({
                                "timestamp": ts,
                                "role": "user",
                                "content": content.strip(),
                                "tool": "cc"
                            })

                    elif msg_type == "assistant":
                        content_blocks = obj.get("message", {}).get("content", [])
                        if isinstance(content_blocks, list):
                            text = " ".join(
                                b.get("text", "") for b in content_blocks
                                if isinstance(b, dict) and b.get("type") == "text"
                            )
                        else:
                            text = str(content_blocks)
                        if text.strip():
                            messages.append({
                                "timestamp": ts,
                                "role": "assistant",
                                "content": text.strip(),
                                "tool": "cc"
                            })
                except Exception:
                    continue

        except Exception:
            continue

    return messages


def parse_codex_sessions(project_path):
    """Parse ~/.codex/sessions/ JSONL files filtered by project cwd."""
    messages = []
    sessions_dir = Path.home() / ".codex" / "sessions"
    if not sessions_dir.exists():
        return messages

    for jsonl_file in sessions_dir.glob("**/*.jsonl"):
        try:
            with open(jsonl_file) as f:
                lines = f.readlines()

            # Check if this file belongs to our project
            project_match = False
            for line in lines:
                try:
                    obj = json.loads(line)
                    if (obj.get("type") == "turn_context" and
                            obj.get("payload", {}).get("cwd") == project_path):
                        project_match = True
                        break
                except Exception:
                    continue

            if not project_match:
                continue

            for line in lines:
                try:
                    obj = json.loads(line)
                    if obj.get("type") != "event_msg":
                        continue

                    payload = obj.get("payload", {})
                    payload_type = payload.get("type")
                    ts = obj.get("timestamp", "")

                    if payload_type == "user_message":
                        content = payload.get("message", "").strip()
                        if content:
                            messages.append({
                                "timestamp": ts,
                                "role": "user",
                                "content": content,
                                "tool": "codex"
                            })

                    elif payload_type == "agent_message":
                        content = payload.get("message", "").strip()
                        if content:
                            messages.append({
                                "timestamp": ts,
                                "role": "assistant",
                                "content": content,
                                "tool": "codex"
                            })
                except Exception:
                    continue

        except Exception:
            continue

    return messages


def group_by_date(messages):
    """Group messages by date string YYYY-MM-DD."""
    grouped = {}
    for msg in messages:
        ts = msg.get("timestamp", "")
        try:
            dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))
            date = dt.strftime("%Y-%m-%d")
        except Exception:
            date = "unknown"

        if date not in grouped:
            grouped[date] = []
        grouped[date].append(msg)

    # Sort messages within each date by timestamp, then by role alpha for ties
    for date in grouped:
        grouped[date].sort(key=lambda m: (m.get("timestamp", ""), m.get("role", "")))

    return grouped


def main():
    project_path = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()

    cc_messages = parse_cc_sessions(project_path)
    codex_messages = parse_codex_sessions(project_path)
    all_messages = cc_messages + codex_messages

    grouped = group_by_date(all_messages)
    print(json.dumps(grouped, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
