# claude-notify

在 Claude Code 停止或需要回應時，透過系統通知提醒你。如果你還沒安裝 Claude Code 也會幫你裝起來。

[English](README.md)

## 安裝

```bash
./setup.sh
```

腳本會自動：
1. 安裝 Claude Code CLI（若尚未安裝）
2. 安裝 `libnotify-bin`（若尚未安裝）
3. 開啟互動式選單管理 hooks

語言依系統 `$LANG` 自動偵測。手動指定：

```bash
./setup.sh --lang zh   # 強制中文
./setup.sh --lang en   # 強制英文
```

## 互動式選單

安裝後會顯示互動選單，可個別切換每個 hook 的開關：

```
Claude Code 通知 Hook 設定
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  1) Stop hook         [ON ]  Claude 停止時通知
  2) Notification hook [ON ]  Claude 需要回應時通知
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  q) 離開
```

按 `1` 或 `2` 切換對應 hook，變更**即時生效**。

## 觸發時機

| Hook | 時機 |
|------|------|
| `Stop` | Claude 停止執行，等待你輸入 |
| `Notification` | Claude 主動需要你的回應 |

## 注意事項

- 需要桌面環境支援 `notify-send`（如 GNOME、KDE）
- Hooks 設定變更**即時生效**，不需重啟 Claude Code
- 設定存放於 `~/.claude/settings.json`
- 隨時重新執行 `./setup.sh` 來調整 hook 設定
