# claude-notify

Sends desktop notifications when Claude Code stops or needs your response. Also installs Claude Code for you if it isn't already.

[繁體中文](README.zh-TW.md)

## Installation

```bash
./setup.sh
```

The script will automatically:
1. Install Claude Code CLI (if not already installed)
2. Install `libnotify-bin` (if not already installed)
3. Configure hooks in `~/.claude/settings.json`

## When notifications are sent

| Hook | Trigger |
|------|---------|
| `Stop` | Claude has stopped and is waiting for your input |
| `Notification` | Claude actively needs your response |

## Notes

- Requires a desktop environment that supports `notify-send` (e.g. GNOME, KDE)
- Hook changes take effect **immediately** — no need to restart Claude Code
- Settings are stored in `~/.claude/settings.json`
