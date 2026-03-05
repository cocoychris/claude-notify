# claude-notify

Sends desktop notifications when Claude Code stops or needs your response. Also installs Claude Code for you if it isn't already.

Notifications include the **session name** (preferring the name set via `/rename`) so you know which session they're from.

[繁體中文](README.zh-TW.md)

## Installation

```bash
./setup.sh
```

The script will automatically:
1. Install Claude Code CLI (if not already installed)
2. Install `libnotify-bin` (if not already installed)
3. Copy hook scripts to `~/.local/bin/`
4. Open an interactive menu to manage hooks

The language is auto-detected from your system `$LANG`, defaulting to Chinese. To override:

```bash
./setup.sh --lang en   # force English
./setup.sh --lang zh   # force Chinese
```

## Interactive menu

After installation, an interactive menu lets you toggle each hook on or off individually:

```
Claude Code Notification Hook Settings
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  1) Stop hook         [ON ]  Notify when Claude stops
  2) Notification hook [ON ]  Notify when Claude needs a response
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  q) Quit
```

Press `1` or `2` to toggle a hook. Changes take effect immediately. Re-run `./setup.sh` anytime to adjust settings.

## When notifications are sent

| Hook | Trigger | Notification content |
|------|---------|----------------------|
| `Stop` | Claude has stopped and is waiting for your input | Session name |
| `Notification` | Claude actively needs your response | Session name + Claude's message |

## Files installed

| File | Location | Purpose |
|------|----------|---------|
| `notify-hook.sh` | `~/.local/bin/claude-notify-hook.sh` | Sends notifications |

## Notes

- Requires a desktop environment that supports `notify-send` (e.g. GNOME, KDE)
- Hook changes take effect **immediately** — no need to restart Claude Code
- Settings are stored in `~/.claude/settings.json`
