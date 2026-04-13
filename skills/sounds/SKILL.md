---
name: sounds
description: Manage sound packs, volume, and audio feedback settings
user_invocable: true
---

# Sound Manager Skill Overview

The `/sounds` command manages audio feedback for Claude Code sessions. Here's what this skill provides:

## Core Capabilities

The tool handles sound pack management, volume control, and event-based audio feedback using Warcraft-style voice lines.

## Key Commands

- `/sounds` — Interactive source select
- `/sounds sounds [source]` — List sources or show sounds for a source
- `/sounds enable <source|all>` / `/sounds disable <source|all>`
- `/sounds on` / `/sounds off`
- `/sounds play <event>` — Play a test sound
- `/sounds volume <0.0-1.0>`
- `/sounds status`

## Technical Details

The implementation interacts with a configuration file stored at `$CLAUDE_PLUGIN_ROOT/config.json`. Sound packs are housed in the `$CLAUDE_PLUGIN_ROOT/sounds/` directory. The CLI is accessible at `$CLAUDE_PLUGIN_ROOT/scripts/claude-sounds.sh`.

## Available Sound Packs

- **peon** — Warcraft Orc Peon
- **bastion** — Dota 2 Bastion Announcer Pack
- **peasant** — Warcraft Human Peasant
- **ra2** — Command & Conquer: Red Alert 2

## Sound Events

- `ready` — Session start greeting
- `work` — Acknowledgment on prompt/task
- `done` — Task completion
- `ask` — Permission request
