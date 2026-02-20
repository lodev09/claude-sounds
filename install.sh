#!/bin/bash
set -e

REPO_URL="https://github.com/lodev09/claude-sounds.git"
DEST="$HOME/.claude/sounds"
SETTINGS="$HOME/.claude/settings.json"
BIN_DIR="$HOME/.local/bin"

# Determine repo location
SCRIPT_DIR="$(cd "$(dirname "$0" 2>/dev/null)" 2>/dev/null && pwd 2>/dev/null || echo "")"

if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/sounds" ]; then
  REPO_DIR="$SCRIPT_DIR"
else
  REPO_DIR="$HOME/.claude/sounds-repo"
  echo "Cloning claude-sounds..."
  rm -rf "$REPO_DIR"
  git clone --depth 1 "$REPO_URL" "$REPO_DIR"
fi

echo "Installing claude-sounds..."

# Set up sounds directory
rm -rf "$DEST"
mkdir -p "$DEST"
cp "$REPO_DIR/bin/play.sh" "$DEST/play.sh"
chmod +x "$DEST/play.sh"

# Store source path and enable all characters
echo "$REPO_DIR" > "$DEST/.source"
for f in "$REPO_DIR"/sounds/*/sounds.json; do
  [ -f "$f" ] && basename "$(dirname "$f")"
done | sort > "$DEST/.enabled"

# Install CLI command
mkdir -p "$BIN_DIR"
cp "$REPO_DIR/bin/claude-sounds.sh" "$BIN_DIR/claude-sounds"
chmod +x "$BIN_DIR/claude-sounds"

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
echo "CLI installed to $BIN_DIR/claude-sounds"
echo "Hooks added to $SETTINGS"
echo ""
echo "Sounds will play on:"
echo "  SessionStart     → ready (greeting)"
echo "  UserPromptSubmit → work (acknowledged)"
echo "  Stop             → done (task complete)"
echo ""
echo "Manage characters:"
echo "  claude-sounds list"
echo "  claude-sounds enable bastion"
echo "  claude-sounds disable orc"
echo ""
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$BIN_DIR"; then
  echo "NOTE: Add $BIN_DIR to your PATH:"
  echo "  export PATH=\"$BIN_DIR:\$PATH\""
  echo ""
fi
echo "To uninstall, run: claude-sounds uninstall"
