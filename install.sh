#!/bin/bash
set -e

ACTION="${1:-install}"
SETTINGS="$HOME/.claude/settings.json"
PLUGIN_DIR="$HOME/.claude/vibe-logger"
SKILL_DIR="$HOME/.claude/skills/vibe-logger"
SCRIPT_URL="https://raw.githubusercontent.com/kevinstackio/vibe-logger/main/hooks/session-stop"
SKILL_URL="https://raw.githubusercontent.com/kevinstackio/vibe-logger/main/skills/vibe-logger/SKILL.md"
VERSION_URL="https://raw.githubusercontent.com/kevinstackio/vibe-logger/main/VERSION"

install_vibe_logger() {
  echo "Installing VibeLogger..."

  if grep -q "vibe-logger" "$SETTINGS" 2>/dev/null; then
    echo "VibeLogger is already installed."
    exit 0
  fi

  # Download session-stop script
  mkdir -p "$PLUGIN_DIR"
  curl -fsSL "$SCRIPT_URL" -o "$PLUGIN_DIR/session-stop"
  chmod +x "$PLUGIN_DIR/session-stop"

  # Install skill
  mkdir -p "$SKILL_DIR"
  curl -fsSL "$SKILL_URL" -o "$SKILL_DIR/SKILL.md"

  # Save config with version
  VERSION=$(curl -fsSL "$VERSION_URL" | tr -d '[:space:]')
  echo "{\"version\": \"$VERSION\"}" > "$PLUGIN_DIR/config.json"

  # Create settings file if not exists
  if [ ! -f "$SETTINGS" ]; then
    mkdir -p "$(dirname "$SETTINGS")"
    echo '{}' > "$SETTINGS"
  fi

  # Merge hook into settings.json via temp Python file
  TMPPY=$(mktemp /tmp/vibe-install.XXXXXX.py)
  cat > "$TMPPY" << 'PYEOF'
import json, sys

settings_path = sys.argv[1]
script_path = sys.argv[2]
plugin_dir = sys.argv[3]

with open(settings_path, 'r') as f:
    settings = json.load(f)

hook_entry = {
    "hooks": [
        {
            "type": "command",
            "command": "bash " + script_path + " # vibe-logger"
        }
    ]
}

if 'hooks' not in settings:
    settings['hooks'] = {}
if 'Stop' not in settings['hooks']:
    settings['hooks']['Stop'] = []

settings['hooks']['Stop'].append(hook_entry)

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')

version = open(plugin_dir + "/config.json").read().split('"')[3]
print("VibeLogger v" + version + " installed ✓")
PYEOF
  python3 "$TMPPY" "$SETTINGS" "$PLUGIN_DIR/session-stop" "$PLUGIN_DIR"
  rm -f "$TMPPY"
}

uninstall_vibe_logger() {
  echo "Uninstalling VibeLogger..."

  if [ -f "$SETTINGS" ]; then
    TMPPY=$(mktemp /tmp/vibe-uninstall.XXXXXX.py)
    cat > "$TMPPY" << 'PYEOF'
import json, sys

settings_path = sys.argv[1]

with open(settings_path, 'r') as f:
    settings = json.load(f)

if 'hooks' in settings and 'Stop' in settings['hooks']:
    settings['hooks']['Stop'] = [
        h for h in settings['hooks']['Stop']
        if 'vibe-logger' not in str(h)
    ]
    if not settings['hooks']['Stop']:
        del settings['hooks']['Stop']
    if not settings['hooks']:
        del settings['hooks']

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')

print("VibeLogger uninstalled ✓")
PYEOF
    python3 "$TMPPY" "$SETTINGS"
    rm -f "$TMPPY"
  fi

  rm -rf "$PLUGIN_DIR" "$SKILL_DIR"
  echo "Removed ~/.claude/vibe-logger and ~/.claude/skills/vibe-logger"
}

case "$ACTION" in
  install)   install_vibe_logger ;;
  uninstall) uninstall_vibe_logger ;;
  *)
    echo "Usage: curl ... | bash -s [install|uninstall]"
    exit 1
    ;;
esac
