---
name: sounds
description: Manage Claude Code sound feedback — select, enable/disable sound packs, adjust volume, mute/unmute, play test sounds, and view status. Supports packs like Warcraft Peon, Dota 2 Bastion, etc.
user_invocable: true
---

# Instructions

When this skill is invoked, run the CLI script and display its output. Do NOT interpret, reimplement, or manually execute the commands yourself.

## How to run

Resolve the plugin root first (use the latest installed version):

```
ROOT=$(ls -d "$HOME/.claude/plugins/cache/lodev09/sounds"/*/ 2>/dev/null | sort -V | tail -1)
```

Then pass user arguments directly to the script:

- `/sounds` → `bash "$ROOT/scripts/claude-sounds.sh"`
- `/sounds status` → `bash "$ROOT/scripts/claude-sounds.sh" status`
- `/sounds volume 0.5` → `bash "$ROOT/scripts/claude-sounds.sh" volume 0.5`
- `/sounds enable peon` → `bash "$ROOT/scripts/claude-sounds.sh" enable peon`

The script handles ALL logic. Just run it and show the output. Nothing else.
