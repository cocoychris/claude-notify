# claude-notify

此腳本用於設定 Claude Code 的系統通知 hooks。

## 目的

透過 `setup.sh` 安裝依賴並將 hooks 寫入 `~/.claude/settings.json`，
讓 Claude Code 在停止或需要使用者回應時發送桌面通知（`notify-send`）。
通知顯示專案名稱，並支援點擊切換至對應 Tilix 視窗。

## 檔案結構

- `setup.sh` — 主腳本（安裝依賴 + 互動選單）
- `notify-hook.sh` — 通知 hook（Stop/Notification 事件用，安裝至 `~/.local/bin/`）
- `session-start-hook.sh` — 記錄 X Window ID（SessionStart 事件用，安裝至 `~/.local/bin/`）
- `README.md` — 英文說明
- `README.zh-TW.md` — 中文說明

## 架構

```
setup.sh
  ├─ 安裝 claude / libnotify-bin / wmctrl
  ├─ 複製 notify-hook.sh → ~/.local/bin/claude-notify-hook.sh
  ├─ 複製 session-start-hook.sh → ~/.local/bin/claude-session-start-hook.sh
  ├─ 永遠啟用 SessionStart hook（記錄視窗 ID）
  └─ 互動選單：切換 Stop / Notification hook

notify-hook.sh（Stop / Notification 事件）
  ├─ 從 stdin JSON 取得 cwd（專案名）、message、session_id
  ├─ 查詢 /tmp/claude-sessions/{session_id} 得到 WINDOWID
  ├─ notify-send --action --wait 顯示通知
  └─ 若點擊「切換視窗」→ wmctrl 切換至對應視窗

session-start-hook.sh（SessionStart 事件）
  └─ 將 $WINDOWID 寫入 /tmp/claude-sessions/{session_id}
```

## 重要知識

- Claude Code hooks **即時生效**，不需重啟 session
- Claude Code 官方安裝方式：`curl -fsSL https://claude.ai/install.sh | bash`（npm 已棄用）
- 用 Python3 的 `json` 模組處理 JSON 讀寫，避免引入 `jq` 依賴
- hook 指令字串透過環境變數傳給 Python，避免引號跳脫問題
- `set -e` 環境下，條件判斷要用 `if ...; then ...; fi` 而非 `$var && cmd`
- `$WINDOWID` 由 Tilix 等終端模擬器設定，並透過環境繼承至 Claude 及其子 hook 程序
- 視窗 ID 對應表存於 `/tmp/claude-sessions/`（重開機後會清除）
- `notify-send --action="focus:Label" --wait` 在點擊按鈕時輸出 `focus` 到 stdout

## Hook 設定格式

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [{"type": "command", "command": "~/.local/bin/claude-notify-hook.sh"}]
      }
    ],
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [{"type": "command", "command": "~/.local/bin/claude-session-start-hook.sh"}]
      }
    ]
  }
}
```

可用的 hook 事件：`PreToolUse`、`PostToolUse`、`Notification`、`Stop`、`SessionStart`、`SessionEnd` 等

## 多語系

語言偵測優先順序：`--lang` 旗標 > 系統 `$LANG` > 預設英文。
`notify-hook.sh` 也有相同的 `$LANG` 偵測（無法接受 `--lang` 參數，由系統決定）。
翻譯透過 `t()` 函式管理：`t '中文' 'English'`。

## 修改通知內容

- 靜態訊息：編輯 `notify-hook.sh` 中的文字，重新執行 `./setup.sh` 重新安裝
- 通知指令（圖示、過期時間）：同上
- 新增 hook 事件：在 `setup.sh` 的 `configure_session_hook()` 仿照 SessionStart 新增
