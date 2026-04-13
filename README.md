# claude-sounds

Sound feedback plugin for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Plays Warcraft-style voice lines when Claude starts, receives a prompt, and finishes a task.

## Install

```sh
claude plugin marketplace add lodev09/claude-plugins
claude plugin install claude-sounds@lodev09
```

For CLI access, also install via npm:

```sh
npm install -g claude-sounds
```

## Hook Events

| Event | Sound | Description |
|-------|-------|-------------|
| `SessionStart` | `ready` | Greeting when Claude starts |
| `UserPromptSubmit` | `work` | Acknowledgment when you send a prompt |
| `SubagentStart` | `work` | Sound when a subagent is spawned |
| `EnterPlanMode` | `work` | Sound when plan mode is entered |
| `ExitPlanMode` | `done` | Sound when plan mode is exited |
| `PermissionRequest` | `ask` | Sound when Claude asks for permission |
| `Stop` | `done` | Notification when Claude finishes |

Each event plays a random sound from enabled sources, mapped via `source.json`.

## Available Sources

- [**peon**](sounds/peon/) — Warcraft Orc Peon
- [**peasant**](sounds/peasant/) — Warcraft Human Peasant
- [**bastion**](sounds/bastion/) — Dota 2 Bastion Announcer Pack
- [**ra2**](sounds/ra2/) — Command & Conquer: Red Alert 2

## Usage

Use the `/claude-sounds` slash command inside Claude Code, or run the CLI directly:

```
claude-sounds                    Interactive source select
claude-sounds sounds [source]    List sources or show sounds for a source
claude-sounds enable <source|all>
claude-sounds disable <source|all>
claude-sounds on                 Turn sounds on
claude-sounds off                Turn sounds off
claude-sounds play <event>       Play a sound (ready, work, done, ask)
claude-sounds volume [0-1]       Get or set volume
claude-sounds status             Show install info
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
  "done": ["done.wav"],
  "ask": ["hello.mp3"]
}
```

## Requirements

- `python3`
- Audio player (auto-detected):
  - **macOS** — `afplay` (built-in)
  - **Linux** — `pw-play`, `paplay`, or `ffplay`
  - **Windows** — `ffplay` or PowerShell (built-in)

## Credits

All audio assets are property of their respective owners and included here for personal, non-commercial use.

- [Warcraft](https://www.blizzard.com) by Blizzard Entertainment
- [Dota 2 Bastion Announcer Pack](https://liquipedia.net/dota2/Bastion_Announcer_Pack) by Supergiant Games
- [Command & Conquer: Red Alert 2](https://www.ea.com/games/command-and-conquer) by Westwood Studios / EA

## License

MIT
