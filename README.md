# claude-sounds

Sound feedback for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) using [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks). Plays Warcraft-style voice lines when Claude starts, receives a prompt, and finishes a task.

## Hook Events

| Event | Sound | Description |
|-------|-------|-------------|
| `SessionStart` | `ready/` | Greeting when Claude starts |
| `UserPromptSubmit` | `work/` | Acknowledgment when you send a prompt |
| `Stop` | `done/` | Notification when Claude finishes |

Each event plays a random sound from its folder.

## Install

```sh
git clone https://github.com/lodev09/claude-sounds.git
cd claude-sounds
./install.sh
```

This copies sounds to `~/.claude/sounds/` and adds hooks to `~/.claude/settings.json`.

## Uninstall

```sh
./uninstall.sh
```

## Customization

Add your own `.wav` or `.mp3` files to any sound folder (`done/`, `ready/`, `work/`), then re-run `./install.sh`.

## Requirements

- macOS (`afplay`)
- `python3` (for settings.json merging)

## License

MIT
