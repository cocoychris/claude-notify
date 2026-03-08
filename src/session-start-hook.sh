#!/usr/bin/env bash
# 在 Claude session 開始時，記錄此終端視窗的 X Window ID。
# 供 notify-hook.sh 在點擊通知時切換回正確的 Tilix 視窗。
#
# 使用 xdotool getactivewindow 取得當前焦點視窗（相容 Tilix 等 GTK 終端機）。

INPUT=$(cat)
SESSION_ID=$(printf '%s' "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('session_id',''))")

if [[ -n "$SESSION_ID" ]] && command -v xdotool &>/dev/null; then
    WINDOW_ID=$(xdotool getactivewindow 2>/dev/null || true)
    if [[ -n "$WINDOW_ID" ]]; then
        mkdir -p /tmp/claude-sessions
        printf '%s' "$WINDOW_ID" > "/tmp/claude-sessions/$SESSION_ID"
    fi
fi
