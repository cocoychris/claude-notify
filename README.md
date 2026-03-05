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
3. Open an interactive menu to manage hooks

The language is auto-detected from your system `$LANG`. To override:

```bash
./setup.sh --lang en   # force English
./setup.sh --lang zh   # force Chinese
```

## Interactive menu

After installation, an interactive menu lets you toggle each hook on or off individually:

```
Claude Code 通知 Hook 設定
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  1) Stop hook         [ON ]  Claude 停止時通知
  2) Notification hook [ON ]  Claude 需要回應時通知
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  q) 離開
```

Press `1` or `2` to toggle a hook. Changes take effect immediately.

## When notifications are sent

| Hook | Trigger |
|------|---------|
| `Stop` | Claude has stopped and is waiting for your input |
| `Notification` | Claude actively needs your response |

## Notes

- Requires a desktop environment that supports `notify-send` (e.g. GNOME, KDE)
- Hook changes take effect **immediately** — no need to restart Claude Code
- Settings are stored in `~/.claude/settings.json`
- Re-run `./setup.sh` anytime to adjust hook settings
