#!/bin/bash
set -e

DEST="$HOME/.claude/sounds"
SOURCE_FILE="$DEST/.source"
ENABLED_FILE="$DEST/.enabled"
SETTINGS="$HOME/.claude/settings.json"

DIM='\033[2m'
GREEN='\033[32m'
RED='\033[31m'
RESET='\033[0m'

info() { printf " ${GREEN}✓${RESET} %s\n" "$1"; }
dim() { printf "${DIM}%s${RESET}\n" "$1"; }
err() { printf " ${RED}✗${RESET} %s\n" "$1"; }

cmd_uninstall() {
  dim "Uninstalling claude-sounds..."

  rm -rf "$DEST"
  rm -rf "$HOME/.claude/sounds-repo"

  # Remove shell alias
  for rcfile in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$rcfile" ] && grep -qF 'alias claude-sounds=' "$rcfile"; then
      sed -i.bak '/# claude-sounds/d;/alias claude-sounds=/d' "$rcfile"
      rm -f "$rcfile.bak"
      info "Removed alias from $(basename "$rcfile")"
    fi
  done

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
    info "Removed hooks from settings.json"
  fi

  info "claude-sounds uninstalled"
}

cmd_update() {
  if [ ! -f "$SOURCE_FILE" ]; then
    err "Not installed. Run install.sh first."
    exit 1
  fi

  local source
  source="$(cat "$SOURCE_FILE")"

  if [ ! -d "$source/.git" ]; then
    err "Source is not a git repo: $source"
    dim "Re-run install.sh to reinstall."
    exit 1
  fi

  dim "Updating claude-sounds..."
  git -C "$source" pull --ff-only
  info "Updated"
}

# Handle uninstall/update before source validation
case "${1:-}" in
  --uninstall) cmd_uninstall; exit 0 ;;
  --update)    cmd_update; exit 0 ;;
esac

if [ ! -f "$SOURCE_FILE" ]; then
  err "Not installed. Run install.sh first."
  exit 1
fi

SOURCE="$(cat "$SOURCE_FILE")"
if [ ! -d "$SOURCE/sounds" ]; then
  err "Source not found: $SOURCE"
  dim "Re-run install.sh from the cloned repo."
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

cmd_select() {
  local enabled cursor=0 count=0 i

  # Read items into indexed vars (bash 3.2 compat)
  while IFS= read -r line; do
    eval "items_$count=\$line"
    count=$((count + 1))
  done < <(get_available)

  if [ "$count" -eq 0 ]; then
    echo "No characters found."
    exit 1
  fi

  enabled=$(get_enabled)
  for i in $(seq 0 $((count - 1))); do
    eval "name=\$items_$i"
    if echo "$enabled" | grep -qx "$name"; then
      eval "flags_$i=1"
    else
      eval "flags_$i=0"
    fi
  done

  cleanup() { printf '\033[?25h'; }
  trap cleanup EXIT
  trap 'cleanup; exit 130' INT

  printf '\033[?25l'

  # Reserve space
  printf '\n'
  for i in $(seq 0 $((count - 1))); do
    printf '\n'
  done

  local total_lines=$((count + 1))

  while true; do
    printf '\033[%dA' "$total_lines"

    printf '\033[2K\033[2mUse arrows to move, space to toggle, enter to confirm\033[0m\r\n'
    for i in $(seq 0 $((count - 1))); do
      eval "name=\$items_$i"
      eval "flag=\$flags_$i"
      printf '\033[2K'
      if [ "$flag" -eq 1 ]; then
        local check="\033[32m●\033[0m"
      else
        local check="\033[2m○\033[0m"
      fi
      if [ "$i" -eq "$cursor" ]; then
        printf '%b %s\r\n' "$check" "$name"
      else
        printf '%b \033[2m%s\033[0m\r\n' "$check" "$name"
      fi
    done

    IFS= read -rsn1 key
    case "$key" in
      $'\x1b')
        read -rsn2 -t 0.1 key || true
        case "$key" in
          '[A') [ "$cursor" -gt 0 ] && cursor=$((cursor - 1)) ;;
          '[B') [ "$cursor" -lt $((count - 1)) ] && cursor=$((cursor + 1)) ;;
        esac ;;
      ' ')
        eval "flag=\$flags_$cursor"
        eval "flags_$cursor=$(( 1 - flag ))" ;;
      '') break ;;
    esac
  done

  printf '\033[?25h'

  : > "$ENABLED_FILE"
  local selected=""
  for i in $(seq 0 $((count - 1))); do
    eval "flag=\$flags_$i"
    eval "name=\$items_$i"
    if [ "$flag" -eq 1 ]; then
      echo "$name" >> "$ENABLED_FILE"
      selected="$selected $name"
    fi
  done

  if [ -z "$selected" ]; then
    printf '\033[2mNo characters enabled\033[0m\n'
  else
    printf '\033[32mEnabled:\033[0m%s\n' "$selected"
  fi
}

cmd_enable() {
  local char="$1"
  if [ -z "$char" ]; then
    err "Usage: claude-sounds --enable <character|all>"
    exit 1
  fi

  local available
  available=$(get_available)

  if [ "$char" = "all" ]; then
    echo "$available" > "$ENABLED_FILE"
    info "Enabled all characters"
    return
  fi

  if ! echo "$available" | grep -qx "$char"; then
    err "Unknown character: $char"
    dim "Available: $(echo "$available" | tr '\n' ' ')"
    exit 1
  fi

  local enabled
  enabled=$(get_enabled)
  if echo "$enabled" | grep -qx "$char"; then
    dim "Already enabled: $char"
    return
  fi

  echo "$char" >> "$ENABLED_FILE"
  info "Enabled: $char"
}

cmd_disable() {
  local char="$1"
  if [ -z "$char" ]; then
    err "Usage: claude-sounds --disable <character|all>"
    exit 1
  fi

  if [ "$char" = "all" ]; then
    > "$ENABLED_FILE"
    info "Disabled all characters"
    return
  fi

  if [ -f "$ENABLED_FILE" ]; then
    local tmp
    tmp=$(grep -vx "$char" "$ENABLED_FILE" || true)
    echo "$tmp" > "$ENABLED_FILE"
  fi
  info "Disabled: $char"
}

cmd_list() {
  local available enabled
  available=$(get_available)
  enabled=$(get_enabled)

  for char in $available; do
    if echo "$enabled" | grep -qx "$char"; then
      printf "\033[32m✓\033[0m %s\n" "$char"
    else
      printf "\033[2m  %s\033[0m\n" "$char"
    fi
  done
}

cmd_help() {
  printf "Usage: ${DIM}claude-sounds${RESET} [options]\n"
  echo ""
  printf "${DIM}Options:${RESET}\n"
  echo "  (no args)                  Interactive character select"
  echo "  --list                     List characters and status"
  echo "  --enable <character|all>   Enable a character's sounds"
  echo "  --disable <character|all>  Disable a character's sounds"
  echo "  --update                   Pull latest sounds from repo"
  echo "  --uninstall                Uninstall claude-sounds"
  echo "  --help                     Show this help"
  echo ""
  printf "${DIM}Characters:${RESET} $(get_available | tr '\n' ' ')\n"
}

case "${1:-select}" in
  select)      cmd_select ;;
  --list)      cmd_list ;;
  --enable)    cmd_enable "${2:-}" ;;
  --disable)   cmd_disable "${2:-}" ;;
  --help)      cmd_help ;;
  --update)    cmd_update ;;
  --uninstall) cmd_uninstall ;;
  *)           cmd_help; exit 1 ;;
esac
