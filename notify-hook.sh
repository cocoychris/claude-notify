#!/usr/bin/env bash
# Claude Code 通知 hook 腳本
# 從 stdin 讀取 Claude hook JSON，發送含有專案名稱的桌面通知。
# 若安裝了 wmctrl，點擊通知上的「切換視窗」按鈕可跳回對應的 Tilix 視窗。

set -euo pipefail

INPUT=$(cat)

# ── 解析 JSON ─────────────────────────────────────────────

eval "$(printf '%s' "$INPUT" | python3 <<'PY'
import json, sys, os, shlex
data = json.load(sys.stdin)
cwd        = data.get("cwd", "")
project    = os.path.basename(cwd.rstrip("/")) or "Claude Code"
event      = data.get("hook_event_name", "")
message    = data.get("message", "")
session_id = data.get("session_id", "")
print(f"PROJECT={shlex.quote(project)}")
print(f"EVENT={shlex.quote(event)}")
print(f"MESSAGE={shlex.quote(message)}")
print(f"SESSION_ID={shlex.quote(session_id)}")
PY
)"

# ── 語系偵測 ───────────────────────────────────────────────

t() {  # t <zh> <en>
    [[ "${LANG:-}" == zh* ]] && echo "$1" || echo "$2"
}

# ── 通知內容 ───────────────────────────────────────────────

if [[ "$EVENT" == "Notification" && -n "$MESSAGE" ]]; then
    BODY="$MESSAGE"
    ICON="dialog-question"
else
    BODY="$(t 'Claude 已停止，等待你的指示' 'Claude has stopped and is waiting for your input')"
    ICON="dialog-information"
fi

TITLE="Claude Code — $PROJECT"

# ── 查詢視窗 ID（由 session-start-hook.sh 儲存）────────────

WINDOW_ID=""
SESSION_FILE="/tmp/claude-sessions/${SESSION_ID:-}"
if [[ -n "${SESSION_ID:-}" && -f "$SESSION_FILE" ]]; then
    WINDOW_ID=$(cat "$SESSION_FILE")
fi

# ── 視窗切換 ───────────────────────────────────────────────

focus_window() {
    if [[ -n "$WINDOW_ID" ]]; then
        wmctrl -i -a "$WINDOW_ID" 2>/dev/null && return
    fi
    wmctrl -a tilix 2>/dev/null || true
}

# ── 發送通知 ───────────────────────────────────────────────

if command -v wmctrl &>/dev/null; then
    ACTION=$(notify-send \
        --icon "$ICON" \
        --expire-time 15000 \
        --action="focus:$(t '切換視窗' 'Switch Window')" \
        --wait \
        "$TITLE" "$BODY" 2>/dev/null || true)
    [[ "$ACTION" == "focus" ]] && focus_window
else
    notify-send --icon "$ICON" --expire-time 15000 "$TITLE" "$BODY"
fi
