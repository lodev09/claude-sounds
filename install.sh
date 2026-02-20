#!/bin/bash
set -e

REPO_URL="https://github.com/lodev09/claude-sounds.git"
DEST="$HOME/.claude/sounds"
SETTINGS="$HOME/.claude/settings.json"

# Determine repo location
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ "${BASH_SOURCE[0]}" != "bash" ]; then
  CANDIDATE="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
  if [ -d "$CANDIDATE/sounds" ]; then
    SCRIPT_DIR="$CANDIDATE"
  fi
fi

DIM='\033[2m'
GREEN='\033[32m'
RESET='\033[0m'

if [ -n "$SCRIPT_DIR" ]; then
  REPO_DIR="$SCRIPT_DIR"
else
  REPO_DIR="$HOME/.claude/sounds-repo"
  printf "${DIM}Cloning claude-sounds...${RESET}\n"
  rm -rf "$REPO_DIR"
  git clone --depth 1 "$REPO_URL" "$REPO_DIR"
fi

printf "${DIM}Installing claude-sounds...${RESET}\n"

# Set up sounds directory
rm -rf "$DEST"
mkdir -p "$DEST"
cp "$REPO_DIR/bin/play.sh" "$DEST/play.sh"
cp "$REPO_DIR/bin/claude-sounds.sh" "$DEST/claude-sounds.sh"
chmod +x "$DEST/play.sh" "$DEST/claude-sounds.sh"

# Store source path and enable all characters
echo "$REPO_DIR" > "$DEST/.source"
for f in "$REPO_DIR"/sounds/*/sounds.json; do
  [ -f "$f" ] && basename "$(dirname "$f")"
done | sort > "$DEST/.enabled"

# Add shell alias
ALIAS_LINE='alias claude-sounds="bash ~/.claude/sounds/claude-sounds.sh"'
for rcfile in "$HOME/.zshrc" "$HOME/.bashrc"; do
  if [ -f "$rcfile" ] && [ -w "$rcfile" ] && ! grep -qF 'alias claude-sounds=' "$rcfile"; then
    echo "" >> "$rcfile"
    echo "# claude-sounds" >> "$rcfile"
    echo "$ALIAS_LINE" >> "$rcfile"
    printf " ${GREEN}✓${RESET} Added alias to $(basename "$rcfile")\n"
  fi
done

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

printf "\n ${GREEN}✓${RESET} Sounds installed to ${DIM}$DEST${RESET}\n"
printf " ${GREEN}✓${RESET} Hooks added to ${DIM}$SETTINGS${RESET}\n"
printf "\n${DIM}Hooks:${RESET}\n"
printf " SessionStart     ${DIM}→${RESET} ready\n"
printf " UserPromptSubmit ${DIM}→${RESET} work\n"
printf " Stop             ${DIM}→${RESET} done\n"
printf "\n${DIM}To uninstall: claude-sounds uninstall${RESET}\n\n"

bash "$DEST/claude-sounds.sh" select
