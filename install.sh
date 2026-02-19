#!/bin/bash
set -e

DEST="$HOME/.claude/sounds"
SETTINGS="$HOME/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing claude-sounds..."

# Copy sound files and play script
rm -rf "$DEST"
mkdir -p "$DEST"
cp -r "$SCRIPT_DIR/done" "$SCRIPT_DIR/ready" "$SCRIPT_DIR/work" "$DEST/"
cp "$SCRIPT_DIR/play.sh" "$DEST/play.sh"
chmod +x "$DEST/play.sh"

# Define hooks to inject
HOOKS_JSON=$(cat <<'HOOKS'
{
  "SessionStart": [{"hooks": [{"type": "command", "command": "~/.claude/sounds/play.sh ready", "async": true}]}],
  "Stop": [{"hooks": [{"type": "command", "command": "~/.claude/sounds/play.sh done", "async": true}]}],
  "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "~/.claude/sounds/play.sh work", "async": true}]}]
}
HOOKS
)

# Merge hooks into settings.json
if [ ! -f "$SETTINGS" ]; then
  echo "{\"hooks\": $HOOKS_JSON}" | python3 -m json.tool > "$SETTINGS"
else
  python3 -c "
import json, sys

with open('$SETTINGS') as f:
    settings = json.load(f)

hooks = json.loads('''$HOOKS_JSON''')
existing = settings.get('hooks', {})

for event, value in hooks.items():
    existing[event] = value

settings['hooks'] = existing

with open('$SETTINGS', 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
"
fi

echo "Sounds installed to $DEST"
echo "Hooks added to $SETTINGS"
echo ""
echo "Sounds will play on:"
echo "  SessionStart  → ready (greeting)"
echo "  UserPromptSubmit → work (acknowledged)"
echo "  Stop          → done (task complete)"
echo ""
echo "To uninstall, run: $(dirname "$0")/uninstall.sh"
