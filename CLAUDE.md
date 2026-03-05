# claude-notify

此腳本用於設定 Claude Code 的系統通知 hooks。

## 目的

透過 `setup.sh` 安裝依賴並將 hooks 寫入 `~/.claude/settings.json`，
讓 Claude Code 在停止或需要使用者回應時發送桌面通知（`notify-send`）。

## 檔案結構

- `setup.sh` — 主安裝腳本
- `README.md` — 使用者說明

## 重要知識

- Claude Code hooks **即時生效**，不需重啟 session
- Claude Code 官方安裝方式：`curl -fsSL https://claude.ai/install.sh | bash`（npm 已棄用）
- Hooks 設定格式寫在 `~/.claude/settings.json` 的 `hooks` 欄位下
- 用 Python3 的 `json` 模組處理 JSON 合併，避免引入 `jq` 依賴

## Hook 設定格式

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "notify-send ... \"訊息\""
          }
        ]
      }
    ]
  }
}
```

可用的 hook 事件：`PreToolUse`、`PostToolUse`、`Notification`、`Stop`

## 修改通知內容

編輯 `setup.sh` 中 Python heredoc 內的 `command` 欄位，然後重新執行 `./setup.sh`。
