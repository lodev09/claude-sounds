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

source "$(dirname "${BASH_SOURCE[0]}")/bin/spin.sh"

clone_repo() {
  rm -rf "$REPO_DIR"
  git clone --depth 1 "$REPO_URL" "$REPO_DIR"
}

install_files() {
  rm -rf "$DEST"
  mkdir -p "$DEST"
  cp "$REPO_DIR/bin/play.sh" "$DEST/play.sh"
  cp "$REPO_DIR/bin/claude-sounds.sh" "$DEST/claude-sounds.sh"
  cp "$REPO_DIR/bin/spin.sh" "$DEST/spin.sh"
  chmod +x "$DEST/play.sh" "$DEST/claude-sounds.sh"

  echo "$REPO_DIR" > "$DEST/.source"
  for f in "$REPO_DIR"/sounds/*/source.json; do
    [ -f "$f" ] && basename "$(dirname "$f")"
  done | sort > "$DEST/.enabled"

  ALIAS_LINE='alias claude-sounds="bash ~/.claude/sounds/claude-sounds.sh"'
  for rcfile in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$rcfile" ] && [ -w "$rcfile" ] && ! grep -qF 'alias claude-sounds=' "$rcfile"; then
      echo "" >> "$rcfile"
      echo "# claude-sounds" >> "$rcfile"
      echo "$ALIAS_LINE" >> "$rcfile"
    fi
  done
}

install_hooks() {
  HOOKS_JSON=$(cat <<'HOOKS'
{
  "SessionStart": [{"hooks": [{"type": "command", "command": "~/.claude/sounds/play.sh ready", "async": true}]}],
  "Stop": [{"hooks": [{"type": "command", "command": "~/.claude/sounds/play.sh done", "async": true}]}],
  "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "~/.claude/sounds/play.sh work", "async": true}]}],
  "SubagentStart": [{"hooks": [{"type": "command", "command": "~/.claude/sounds/play.sh work", "async": true}]}],
  "PreToolUse": [{"matcher": "EnterPlanMode", "hooks": [{"type": "command", "command": "~/.claude/sounds/play.sh work", "async": true}]}],
  "PostToolUse": [{"matcher": "ExitPlanMode", "hooks": [{"type": "command", "command": "~/.claude/sounds/play.sh done", "async": true}]}]
}
HOOKS
)

  if [ ! -f "$SETTINGS" ]; then
    echo "{\"hooks\": $HOOKS_JSON}" | python3 -m json.tool > "$SETTINGS"
  else
    python3 -c "
import json, sys

SOUNDS_PREFIX = '~/.claude/sounds/play.sh'

with open('$SETTINGS') as f:
    settings = json.load(f)

hooks = json.loads('''$HOOKS_JSON''')
existing = settings.get('hooks', {})

for event, new_entries in hooks.items():
    current = existing.get(event, [])
    current = [
        entry for entry in current
        if not any(
            h.get('command', '').startswith(SOUNDS_PREFIX)
            for h in entry.get('hooks', [])
        )
    ]
    current.extend(new_entries)
    existing[event] = current

settings['hooks'] = existing

with open('$SETTINGS', 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
"
  fi
}

if [ -n "$SCRIPT_DIR" ]; then
  REPO_DIR="$SCRIPT_DIR"
else
  REPO_DIR="$HOME/.claude/sounds-repo"
  spin "Cloning claude-sounds" clone_repo
fi

spin "Installing sounds" install_files
spin "Configuring hooks" install_hooks

printf "\n${DIM}Hooks:${RESET}\n"
printf " SessionStart     ${DIM}→${RESET} ready\n"
printf " UserPromptSubmit ${DIM}→${RESET} work\n"
printf " SubagentStart    ${DIM}→${RESET} work\n"
printf " EnterPlanMode    ${DIM}→${RESET} work\n"
printf " ExitPlanMode     ${DIM}→${RESET} done\n"
printf " Stop             ${DIM}→${RESET} done\n"
printf "\n${DIM}To uninstall: claude-sounds uninstall${RESET}\n\n"

bash "$DEST/claude-sounds.sh" select
