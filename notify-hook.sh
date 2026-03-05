#!/usr/bin/env bash
# Claude Code 通知 hook 腳本
# 從 stdin 讀取 Claude hook JSON，發送含有 session 名稱的桌面通知。

set -euo pipefail

INPUT=$(cat)

# ── 解析 JSON（失敗時使用安全預設值）─────────────────────

eval "$(HOOK_JSON="$INPUT" python3 <<'PY'
import json, os, shlex
try:
    data            = json.loads(os.environ.get("HOOK_JSON", "{}"))
    cwd             = data.get("cwd", "")
    project         = os.path.basename(cwd.rstrip("/")) or "Claude Code"
    event           = data.get("hook_event_name", "")
    message         = data.get("message", "")
    transcript_path = data.get("transcript_path", "")
    # 從 transcript JSONL 讀取 session 名稱：
    # 優先用 custom-title（/rename 設定的名稱），fallback 用 slug（自動產生）
    slug = ""
    custom_title = ""
    if transcript_path and os.path.isfile(transcript_path):
        with open(transcript_path) as tf:
            for line in tf:
                try:
                    rec = json.loads(line)
                    if rec.get("type") == "custom-title" and rec.get("customTitle"):
                        custom_title = rec["customTitle"]
                    elif not slug and rec.get("slug"):
                        slug = rec["slug"]
                except Exception:
                    pass
    slug = custom_title or slug
except Exception:
    project = "Claude Code"
    event   = ""
    message = ""
    slug    = ""
print(f"PROJECT={shlex.quote(project)}")
print(f"EVENT={shlex.quote(event)}")
print(f"MESSAGE={shlex.quote(message)}")
print(f"SLUG={shlex.quote(slug)}")
PY
)"

# ── 語系偵測（預設中文，明確偵測到英文才切換）──────────────

t() {  # t <zh> <en>
    local lang="${LANG:-${LANGUAGE:-${LC_ALL:-}}}"
    [[ "$lang" == en* ]] && echo "$2" || echo "$1"
}

# ── 通知內容 ───────────────────────────────────────────────

if [[ "$EVENT" == "Notification" && -n "$MESSAGE" ]]; then
    BODY="$MESSAGE"
    ICON="dialog-question"
else
    BODY="$(t 'Claude 已停止，等待你的指示' 'Claude has stopped and is waiting for your input')"
    ICON="dialog-information"
fi

TITLE="${SLUG:-$PROJECT} — Claude Code"

# ── 發送通知 ───────────────────────────────────────────────

notify-send --icon "$ICON" --expire-time 15000 "$TITLE" "$BODY"
