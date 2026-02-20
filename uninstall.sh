#!/bin/bash
set -e

DEST="$HOME/.claude/sounds"
SETTINGS="$HOME/.claude/settings.json"

echo "Uninstalling claude-sounds..."

# Remove sound files and cloned repo
rm -rf "$DEST"
rm -rf "$HOME/.claude/sounds-repo"

# Remove shell alias
for rcfile in "$HOME/.zshrc" "$HOME/.bashrc"; do
  if [ -f "$rcfile" ] && grep -qF 'alias claude-sounds=' "$rcfile"; then
    sed -i.bak '/# claude-sounds/d;/alias claude-sounds=/d' "$rcfile"
    rm -f "$rcfile.bak"
  fi
done

# Remove hooks from settings.json
if [ -f "$SETTINGS" ]; then
  python3 -c "
import json

with open('$SETTINGS') as f:
    settings = json.load(f)

hooks = settings.get('hooks', {})
for event in ['SessionStart', 'Stop', 'UserPromptSubmit']:
    entries = hooks.get(event, [])
    hooks[event] = [e for e in entries if not any(
        h.get('command', '').startswith('~/.claude/sounds/')
        for h in e.get('hooks', [])
    )]
    if not hooks[event]:
        del hooks[event]

if not hooks:
    del settings['hooks']

with open('$SETTINGS', 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
"
  echo "Hooks removed from $SETTINGS"
fi

echo "claude-sounds uninstalled."
