#!/bin/bash
set -e

DEST="$HOME/.claude/sounds"
SETTINGS="$HOME/.claude/settings.json"

echo "Uninstalling claude-sounds..."

# Remove sound files
rm -rf "$DEST"

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
