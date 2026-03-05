# claude-notify

在 Claude Code 停止或需要回應時，透過系統通知提醒你。如果你還沒安裝 Claude Code 也會幫你裝起來。

## 安裝

```bash
./setup.sh
```

腳本會自動：
1. 安裝 Claude Code CLI（若尚未安裝）
2. 安裝 `libnotify-bin`（若尚未安裝）
3. 設定 `~/.claude/settings.json` 中的 hooks

## 觸發時機

| Hook | 時機 |
|------|------|
| `Stop` | Claude 停止執行，等待你輸入 |
| `Notification` | Claude 主動需要你的回應 |

## 注意事項

- 需要桌面環境支援 `notify-send`（如 GNOME、KDE）
- Hooks 設定變更**即時生效**，不需重啟 Claude Code
- 設定存放於 `~/.claude/settings.json`
