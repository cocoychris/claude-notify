# claude-notify

此腳本用於設定 Claude Code 的系統通知 hooks。

## 目的

透過 `setup.sh` 安裝依賴並將 hooks 寫入 `~/.claude/settings.json`，
讓 Claude Code 在停止或需要使用者回應時發送桌面通知（`notify-send`）。
提供互動式選單讓使用者隨時個別切換各 hook。

## 檔案結構

- `setup.sh` — 主腳本（安裝依賴 + 互動選單）
- `README.md` — 英文說明
- `README.zh-TW.md` — 中文說明

## 重要知識

- Claude Code hooks **即時生效**，不需重啟 session
- Claude Code 官方安裝方式：`curl -fsSL https://claude.ai/install.sh | bash`（npm 已棄用）
- 用 Python3 的 `json` 模組處理 JSON 讀寫，避免引入 `jq` 依賴
- hook 指令字串透過環境變數傳給 Python，避免引號跳脫問題
- `set -e` 環境下，條件判斷要用 `if ...; then ...; fi` 而非 `$var && cmd`（後者在 var=false 時會觸發 set -e）

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

編輯 `setup.sh` 頂部的 `STOP_CMD` / `NOTIF_CMD` 變數，然後重新執行 `./setup.sh`。
