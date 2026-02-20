#!/bin/bash
set -e

DEST="$HOME/.claude/sounds"
SOURCE_FILE="$DEST/.source"
ENABLED_FILE="$DEST/.enabled"
SETTINGS="$HOME/.claude/settings.json"

cmd_uninstall() {
  echo "Uninstalling claude-sounds..."

  rm -rf "$DEST"
  rm -rf "$HOME/.claude/sounds-repo"
  rm -f "$HOME/.local/bin/claude-sounds"

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
}

cmd_update() {
  if [ ! -f "$SOURCE_FILE" ]; then
    echo "claude-sounds is not installed. Run install.sh first."
    exit 1
  fi

  local source
  source="$(cat "$SOURCE_FILE")"

  if [ ! -d "$source/.git" ]; then
    echo "Source is not a git repo: $source"
    echo "Re-run install.sh to reinstall."
    exit 1
  fi

  echo "Updating claude-sounds..."
  git -C "$source" pull --ff-only
  echo "Updated. New characters (if any) can be enabled with: claude-sounds enable all"
}

# Handle uninstall/update before source validation
case "${1:-}" in
  uninstall) cmd_uninstall; exit 0 ;;
  update)    cmd_update; exit 0 ;;
esac

if [ ! -f "$SOURCE_FILE" ]; then
  echo "claude-sounds is not installed. Run install.sh first."
  exit 1
fi

SOURCE="$(cat "$SOURCE_FILE")"
if [ ! -d "$SOURCE/sounds" ]; then
  echo "Source not found: $SOURCE"
  echo "Re-run install.sh from the cloned repo."
  exit 1
fi

get_available() {
  for f in "$SOURCE"/sounds/*/sounds.json; do
    [ -f "$f" ] && basename "$(dirname "$f")"
  done | sort
}

get_enabled() {
  [ -f "$ENABLED_FILE" ] && cat "$ENABLED_FILE" || true
}

cmd_enable() {
  local char="$1"
  if [ -z "$char" ]; then
    echo "Usage: claude-sounds enable <character|all>"
    exit 1
  fi

  local available
  available=$(get_available)

  if [ "$char" = "all" ]; then
    echo "$available" > "$ENABLED_FILE"
    echo "Enabled all characters"
    return
  fi

  if ! echo "$available" | grep -qx "$char"; then
    echo "Unknown character: $char"
    echo "Available: $(echo "$available" | tr '\n' ' ')"
    exit 1
  fi

  local enabled
  enabled=$(get_enabled)
  if echo "$enabled" | grep -qx "$char"; then
    echo "Already enabled: $char"
    return
  fi

  echo "$char" >> "$ENABLED_FILE"
  echo "Enabled: $char"
}

cmd_disable() {
  local char="$1"
  if [ -z "$char" ]; then
    echo "Usage: claude-sounds disable <character|all>"
    exit 1
  fi

  if [ "$char" = "all" ]; then
    > "$ENABLED_FILE"
    echo "Disabled all characters"
    return
  fi

  if [ -f "$ENABLED_FILE" ]; then
    local tmp
    tmp=$(grep -vx "$char" "$ENABLED_FILE" || true)
    echo "$tmp" > "$ENABLED_FILE"
  fi
  echo "Disabled: $char"
}

cmd_list() {
  local available enabled
  available=$(get_available)
  enabled=$(get_enabled)

  echo "Characters:"
  for char in $available; do
    if echo "$enabled" | grep -qx "$char"; then
      echo "  $char ✓"
    else
      echo "  $char"
    fi
  done
}

cmd_help() {
  echo "Usage: claude-sounds <command> [character]"
  echo ""
  echo "Commands:"
  echo "  enable <character|all>   Enable a character's sounds"
  echo "  disable <character|all>  Disable a character's sounds"
  echo "  list                     Show available characters"
  echo "  update                   Pull latest sounds from repo"
  echo "  uninstall                Uninstall claude-sounds"
  echo "  help                     Show this help"
  echo ""
  echo "Characters: $(get_available | tr '\n' ' ')"
}

case "${1:-help}" in
  enable)  cmd_enable "$2" ;;
  disable) cmd_disable "$2" ;;
  list)    cmd_list ;;
  help)    cmd_help ;;
  *)       cmd_help; exit 1 ;;
esac
