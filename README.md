# claude-notify

Sends desktop notifications when Claude Code stops or needs your response. Also installs Claude Code for you if it isn't already.

Notifications include the **project name** so you know which session they're from. Click the **Switch Window** button to jump directly to the right Tilix window.

[繁體中文](README.zh-TW.md)

## Installation

```bash
./setup.sh
```

The script will automatically:
1. Install Claude Code CLI (if not already installed)
2. Install `libnotify-bin` (if not already installed)
3. Install `wmctrl` and `xdotool` for click-to-focus support
4. Copy hook scripts to `~/.local/bin/`
5. Open an interactive menu to manage hooks

The language is auto-detected from your system `$LANG`. To override:

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
| `Stop` | Claude has stopped and is waiting for your input | Project name |
| `Notification` | Claude actively needs your response | Project name + Claude's message |

## Click to focus

When `wmctrl` is installed, a **Switch Window** button appears on each notification. Clicking it brings the corresponding Tilix window to the foreground.

This works by recording the X Window ID at session start (`SessionStart` hook, using `xdotool getactivewindow`) and looking it up when a notification fires.

> **Note:** Click-to-focus activates only for **new** Claude sessions started after running `./setup.sh`. Each new session automatically registers its window.

## Files installed

| File | Location | Purpose |
|------|----------|---------|
| `notify-hook.sh` | `~/.local/bin/claude-notify-hook.sh` | Sends notifications |
| `session-start-hook.sh` | `~/.local/bin/claude-session-start-hook.sh` | Records window ID at session start |

## Notes

- Requires a desktop environment that supports `notify-send` (e.g. GNOME, KDE)
- Hook changes take effect **immediately** — no need to restart Claude Code
- Settings are stored in `~/.claude/settings.json`
- Window ID mapping is stored in `/tmp/claude-sessions/`
