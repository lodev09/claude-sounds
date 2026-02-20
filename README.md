# claude-sounds

Sound feedback for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) using [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks). Plays Warcraft-style voice lines when Claude starts, receives a prompt, and finishes a task.

## Hook Events

| Event | Sound | Description |
|-------|-------|-------------|
| `SessionStart` | `ready` | Greeting when Claude starts |
| `UserPromptSubmit` | `work` | Acknowledgment when you send a prompt |
| `Stop` | `done` | Notification when Claude finishes |

Each event plays a random sound from enabled characters, mapped via `sounds.json`.

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

```sh
claude-sounds                         # interactively toggle characters
claude-sounds --enable <character>    # enable a character
claude-sounds --disable <character>   # disable a character
claude-sounds --enable all            # enable all characters
claude-sounds --update                # pull latest sounds from repo
claude-sounds --uninstall             # remove claude-sounds
```

## Customization

Create a new folder under `sounds/` with a `sounds.json` mapping events to audio files:

```
sounds/my-character/
├── sounds.json
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

## License

MIT
