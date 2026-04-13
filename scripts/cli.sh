#!/bin/bash
# CLI wrapper — delegates to the marketplace-installed plugin
set -e

PLUGIN_DIR="$HOME/.claude/plugins/cache/lodev09/sounds"

if [ ! -d "$PLUGIN_DIR" ]; then
  echo "claude-sounds plugin not installed." >&2
  echo "Run: claude plugin install sounds@lodev09" >&2
  exit 1
fi

# Use the latest version directory
ROOT=$(ls -d "$PLUGIN_DIR"/*/ 2>/dev/null | sort -V | tail -1)
if [ -z "$ROOT" ] || [ ! -f "$ROOT/scripts/claude-sounds.sh" ]; then
  echo "claude-sounds plugin is corrupted. Reinstall:" >&2
  echo "Run: claude plugin install sounds@lodev09" >&2
  exit 1
fi

exec bash "$ROOT/scripts/claude-sounds.sh" "$@"
