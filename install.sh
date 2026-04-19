#!/bin/bash
set -e

ACTION="${1:-install}"
SETTINGS="$HOME/.claude/settings.json"
PLUGIN_DIR="$HOME/.claude/vibe-logger"
SCRIPT_URL="https://raw.githubusercontent.com/kevinstackio/vibe-logger/main/hooks/session-stop"

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

  # Create settings file if not exists
  if [ ! -f "$SETTINGS" ]; then
    mkdir -p "$(dirname "$SETTINGS")"
    echo '{}' > "$SETTINGS"
  fi

  # Merge hook into settings.json
  SCRIPT_PATH="$PLUGIN_DIR/session-stop"
  python3 - "$SETTINGS" "$SCRIPT_PATH" <<'PYEOF'
import json, sys

settings_path = sys.argv[1]
script_path = sys.argv[2]

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

print("VibeLogger installed ✓")
PYEOF
}

uninstall_vibe_logger() {
  echo "Uninstalling VibeLogger..."

  # Remove hook from settings.json
  if [ -f "$SETTINGS" ]; then
    python3 - "$SETTINGS" <<'PYEOF'
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
  fi

  # Remove plugin files
  rm -rf "$PLUGIN_DIR"
  echo "Removed ~/.claude/vibe-logger"
}

case "$ACTION" in
  install)   install_vibe_logger ;;
  uninstall) uninstall_vibe_logger ;;
  *)
    echo "Usage: curl ... | bash -s [install|uninstall]"
    exit 1
    ;;
esac
