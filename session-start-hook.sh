#!/usr/bin/env bash
# 在 Claude session 開始時，記錄此終端視窗的 X Window ID。
# 供 notify-hook.sh 在點擊通知時切換回正確的 Tilix 視窗。
#
# 需要終端模擬器設定 $WINDOWID（Tilix、GNOME Terminal 等預設已設定）。

INPUT=$(cat)
SESSION_ID=$(printf '%s' "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('session_id',''))")

if [[ -n "$SESSION_ID" && -n "${WINDOWID:-}" ]]; then
    mkdir -p /tmp/claude-sessions
    printf '%s' "$WINDOWID" > "/tmp/claude-sessions/$SESSION_ID"
fi
