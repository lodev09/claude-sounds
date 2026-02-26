#!/bin/bash
set -e

DEST="$HOME/.claude/sounds"
SOURCE_FILE="$DEST/.source"
ENABLED_FILE="$DEST/.enabled"
VOLUME_FILE="$DEST/.volume"
SETTINGS="$HOME/.claude/settings.json"

DEFAULT_VOLUME="0.25"

source "$(dirname "${BASH_SOURCE[0]}")/spin.sh"

uninstall_files() {
  rm -rf "$DEST"
  rm -rf "$HOME/.claude/sounds-repo"

  for rcfile in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$rcfile" ] && grep -qF 'alias claude-sounds=' "$rcfile"; then
      sed -i.bak '/# claude-sounds/d;/alias claude-sounds=/d' "$rcfile"
      rm -f "$rcfile.bak"
    fi
  done
}

uninstall_hooks() {
  [ -f "$SETTINGS" ] || return 0
  python3 -c "
import json

with open('$SETTINGS') as f:
    settings = json.load(f)

hooks = settings.get('hooks', {})
for event in ['SessionStart', 'Stop', 'UserPromptSubmit', 'SubagentStart', 'PreToolUse', 'PostToolUse']:
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
}

cmd_uninstall() {
  spin "Removing files" uninstall_files
  spin "Removing hooks" uninstall_hooks
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

  spin "Pulling latest" git -C "$source" pull --ff-only

  local dest="$HOME/.claude/sounds"
  cp "$source/bin/play.sh" "$dest/play.sh"
  cp "$source/bin/claude-sounds.sh" "$dest/claude-sounds.sh"
  cp "$source/bin/spin.sh" "$dest/spin.sh"
  chmod +x "$dest/play.sh" "$dest/claude-sounds.sh"
  info "Scripts updated"
}

# Handle uninstall/update before source validation
case "${1:-}" in
  uninstall) cmd_uninstall; exit 0 ;;
  update)    cmd_update; exit 0 ;;
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
  for f in "$SOURCE"/sounds/*/source.json; do
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
    echo "No sound sources found."
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

    IFS= read -rsn1 key </dev/tty
    case "$key" in
      $'\x1b')
        read -rsn2 -t 0.1 key </dev/tty || true
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
    printf '\033[2mNo sound sources enabled\033[0m\n'
  else
    printf '\033[32mEnabled:\033[0m%s\n' "$selected"
  fi
}

cmd_enable() {
  local char="$1"
  if [ -z "$char" ]; then
    err "Usage: claude-sounds enable <source|all>"
    exit 1
  fi

  local available
  available=$(get_available)

  if [ "$char" = "all" ]; then
    echo "$available" > "$ENABLED_FILE"
    info "Enabled all sound sources"
    return
  fi

  if ! echo "$available" | grep -qx "$char"; then
    err "Unknown sound source: $char"
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
    err "Usage: claude-sounds disable <source|all>"
    exit 1
  fi

  if [ "$char" = "all" ]; then
    > "$ENABLED_FILE"
    info "Disabled all sound sources"
    return
  fi

  if [ -f "$ENABLED_FILE" ]; then
    local tmp
    tmp=$(grep -vx "$char" "$ENABLED_FILE" || true)
    echo "$tmp" > "$ENABLED_FILE"
  fi
  info "Disabled: $char"
}

cmd_sounds() {
  local name="$1"
  if [ -z "$name" ]; then
    cmd_list
    return
  fi

  local source_json="$SOURCE/sounds/$name/source.json"
  if [ ! -f "$source_json" ]; then
    err "Unknown source: $name"
    dim "Available: $(get_available | tr '\n' ' ')"
    exit 1
  fi

  python3 -c "
import json
with open('$source_json') as f:
    data = json.load(f)
events = list(data.items())
for idx, (event, files) in enumerate(events):
    if idx > 0:
        print()
    print(f'\033[32m{event}:\033[0m')
    for name in files:
        print(f'\033[2m{name.rsplit(chr(46), 1)[0]}\033[0m')
"
}

cmd_list() {
  local available enabled
  available=$(get_available)
  enabled=$(get_enabled)

  for char in $available; do
    if echo "$enabled" | grep -qx "$char"; then
      printf "%s \033[32m✓\033[0m\n" "$char"
    else
      printf "\033[2m%s\033[0m\n" "$char"
    fi
  done
}

cmd_volume() {
  local vol="$1"
  if [ -z "$vol" ]; then
    local current
    current=$([ -f "$VOLUME_FILE" ] && cat "$VOLUME_FILE" || echo "$DEFAULT_VOLUME")
    echo "$current"
    return
  fi

  if ! printf '%s' "$vol" | grep -qE '^(0(\.[0-9]+)?|1(\.0+)?)$'; then
    err "Volume must be a number between 0.0 and 1.0"
    exit 1
  fi

  echo "$vol" > "$VOLUME_FILE"
  info "Volume set to $vol"
}

cmd_status() {
  local enabled available remote volume
  enabled=$(get_enabled | tr '\n' ' ' | sed 's/ $//')
  available=$(get_available | wc -l | tr -d ' ')
  remote=$(git -C "$SOURCE" remote get-url origin 2>/dev/null || echo "-")
  volume=$([ -f "$VOLUME_FILE" ] && cat "$VOLUME_FILE" || echo "$DEFAULT_VOLUME")

  printf "${DIM}source${RESET}    %s\n" "$SOURCE"
  printf "${DIM}remote${RESET}    %s\n" "$remote"
  printf "${DIM}enabled${RESET}   %s\n" "${enabled:-none}"
  printf "${DIM}available${RESET} %s\n" "$available"
  printf "${DIM}volume${RESET}    %s\n" "$volume"
}

cmd_help() {
  printf "Usage: ${DIM}claude-sounds${RESET} [command]\n"
  echo ""
  printf "${DIM}Commands:${RESET}\n"
  echo "  (no args)                  Interactive source select"
  echo "  sounds [source]            List sources or show sounds for a source"
  echo "  enable <source|all>        Enable a sound source"
  echo "  disable <source|all>       Disable a sound source"
  echo "  volume [0-1]               Get or set volume"
  echo "  status                     Show install info"
  echo "  update                     Pull latest sounds from repo"
  echo "  uninstall                  Uninstall claude-sounds"
  echo "  --help                     Show this help"
  echo ""
  printf "${DIM}Sources:${RESET} $(get_available | tr '\n' ' ')\n"
}

case "${1:-select}" in
  select)    cmd_select ;;
  list|sounds) cmd_sounds "${2:-}" ;;
  enable)    cmd_enable "${2:-}" ;;
  disable)   cmd_disable "${2:-}" ;;
  volume)    cmd_volume "${2:-}" ;;
  status)    cmd_status ;;
  --help)    cmd_help ;;
  update)    cmd_update ;;
  uninstall) cmd_uninstall ;;
  *)         cmd_help; exit 1 ;;
esac
