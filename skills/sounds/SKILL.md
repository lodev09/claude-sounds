---
name: sounds
description: Manage Claude Code sound feedback — select, enable/disable sound packs, adjust volume, mute/unmute, play test sounds, and view status. Supports packs like Warcraft Peon, Dota 2 Bastion, etc.
user_invocable: true
---

# Instructions

Resolve the plugin root first (use the latest installed version):

```
ROOT=$(ls -d "$HOME/.claude/plugins/cache/lodev09/sounds"/*/ 2>/dev/null | sort -V | tail -1)
```

## With arguments

Pass user arguments directly to the CLI script. Do NOT interpret or reimplement the commands.

- `/sounds status` → `bash "$ROOT/scripts/claude-sounds.sh" status`
- `/sounds volume 0.5` → `bash "$ROOT/scripts/claude-sounds.sh" volume 0.5`
- `/sounds enable peon` → `bash "$ROOT/scripts/claude-sounds.sh" enable peon`

## Without arguments (`/sounds`)

The interactive select requires a TTY. Instead, use native Claude user input:

1. Run `bash "$ROOT/scripts/claude-sounds.sh" sounds` to get available packs and their enabled state
2. Ask the user which packs to enable/disable using a numbered list
3. Run the corresponding `enable` / `disable` commands based on user selection
