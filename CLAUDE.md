# claude-notify

此腳本用於設定 Claude Code 的系統通知 hooks。

## 目的

透過 `setup.sh` 安裝依賴並將 hooks 寫入 `~/.claude/settings.json`，
讓 Claude Code 在停止或需要使用者回應時發送桌面通知（`notify-send`）。
通知標題顯示 session 名稱（優先用 `/rename` 設定的名稱）。

## 檔案結構

- `setup.sh` — 主腳本（安裝依賴 + 互動選單）
- `notify-hook.sh` — 通知 hook（Stop/Notification 事件用，安裝至 `~/.local/bin/`）
- `session-start-hook.sh` — 已棄用（保留作歷史記錄，不再安裝）
- `README.md` — 英文說明
- `README.zh-TW.md` — 中文說明

## 架構

```
setup.sh
  ├─ 安裝 claude / libnotify-bin
  ├─ 複製 notify-hook.sh → ~/.local/bin/claude-notify-hook.sh
  └─ 互動選單：切換 Stop / Notification hook

notify-hook.sh（Stop / Notification 事件）
  ├─ 讀取 stdin，從 HOOK_JSON 環境變數解析 JSON
  ├─ 從 transcript_path JSONL 讀取 session 名稱
  │   ├─ 優先：custom-title 記錄（/rename 設定的名稱）
  │   ├─ 次要：slug 欄位（自動產生的名稱）
  │   └─ fallback：cwd 資料夾名稱
  └─ notify-send 發送通知（標題格式："{session} — Claude Code"）
```

## 重要知識

- Claude Code hooks **即時生效**，不需重啟 session
- Claude Code 官方安裝方式：`curl -fsSL https://claude.ai/install.sh | bash`（npm 已棄用）
- 用 Python3 的 `json` 模組處理 JSON 讀寫，避免引入 `jq` 依賴
- hook 指令字串透過環境變數傳給 Python，避免引號跳脫問題
- `set -e` 環境下，條件判斷要用 `if ...; then ...; fi` 而非 `$var && cmd`
- `pipe | python3 <<'PY'` 中 heredoc 搶走 stdin，`sys.stdin` 讀到空值；改用 `HOOK_JSON="$INPUT" python3 <<'PY'` + `os.environ.get("HOOK_JSON")` 讀取資料
- Hook JSON 包含 `transcript_path`（JSONL 路徑），可從中讀取 session 名稱
- JSONL 中 `{"type":"custom-title","customTitle":"..."}` 是 `/rename` 寫入的 session 名稱，優先於 `slug`
- 語系偵測預設中文：`[[ "$lang" == en* ]] && echo "$2" || echo "$1"`，避免 hook 環境 `$LANG` 未繼承時誤顯英文

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
    "Notification": [
      {
        "matcher": "",
        "hooks": [{"type": "command", "command": "~/.local/bin/claude-notify-hook.sh"}]
      }
    ]
  }
}
```

可用的 hook 事件：`PreToolUse`、`PostToolUse`、`Notification`、`Stop`、`SessionStart`、`SessionEnd` 等

## 多語系

語言偵測優先順序：`--lang` 旗標 > 系統 `$LANG` > 預設中文。
`notify-hook.sh` 偵測 `$LANG`、`$LANGUAGE`、`$LC_ALL`，預設中文。
翻譯透過 `t()` 函式管理：`t '中文' 'English'`。

## 修改通知內容

- 靜態訊息：編輯 `notify-hook.sh` 中的文字，重新執行 `./setup.sh` 重新安裝
- 通知指令（圖示、過期時間）：同上
- 新增 hook 事件：在 `setup.sh` 的 `install_deps()` 後仿照現有 hook 新增設定
