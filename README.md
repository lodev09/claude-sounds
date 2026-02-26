# claude-sounds

Sound feedback for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) using [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks). Plays Warcraft-style voice lines when Claude starts, receives a prompt, and finishes a task.

## Hook Events

| Event | Sound | Description |
|-------|-------|-------------|
| `SessionStart` | `ready` | Greeting when Claude starts |
| `UserPromptSubmit` | `work` | Acknowledgment when you send a prompt |
| `SubagentStart` | `work` | Sound when a subagent is spawned |
| `EnterPlanMode` | `work` | Sound when plan mode is entered |
| `ExitPlanMode` | `done` | Sound when plan mode is exited |
| `Stop` | `done` | Notification when Claude finishes |

Each event plays a random sound from enabled sources, mapped via `source.json`.

## Available Sources

- [**peon**](sounds/peon/) — Warcraft Orc Peon
- [**peasant**](sounds/peasant/) — Warcraft Human Peasant
- [**bastion**](sounds/bastion/) — Dota 2 Bastion Announcer Pack
- [**ra2**](sounds/ra2/) — Command & Conquer: Red Alert 2

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/lodev09/claude-sounds/main/install.sh | bash
```

Or clone and install locally:

```sh
git clone https://github.com/lodev09/claude-sounds.git
cd claude-sounds
./install.sh
```

This adds hooks to `~/.claude/settings.json` and installs the `claude-sounds` CLI.

## Usage

```
claude-sounds                    Interactive source select
claude-sounds sounds [source]    List sources or show sounds for a source
claude-sounds enable <source|all>
claude-sounds disable <source|all>
claude-sounds volume [0-1]       Get or set volume
claude-sounds status             Show install info
claude-sounds update             Pull latest from repo
claude-sounds uninstall
```

## Customization

Create a new folder under `sounds/` with a `source.json` mapping events to audio files:

```
sounds/my-source/
├── source.json
├── hello.mp3
└── done.wav
```

```json
{
  "ready": ["hello.mp3"],
  "work": ["hello.mp3"],
  "done": ["done.wav"]
}
```

Then re-run `./install.sh`.

## Requirements

- macOS (`afplay`)
- `python3` (for settings.json merging)

## Credits

All audio assets are property of their respective owners and included here for personal, non-commercial use.

- [Warcraft](https://www.blizzard.com) by Blizzard Entertainment
- [Dota 2 Bastion Announcer Pack](https://liquipedia.net/dota2/Bastion_Announcer_Pack) by Supergiant Games
- [Command & Conquer: Red Alert 2](https://www.ea.com/games/command-and-conquer) by Westwood Studios / EA

## License

MIT
