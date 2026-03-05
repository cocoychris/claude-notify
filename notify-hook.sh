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
    slug = ""
    if transcript_path and os.path.isfile(transcript_path):
        with open(transcript_path) as tf:
            for line in tf:
                try:
                    rec = json.loads(line)
                    if rec.get("slug"):
                        slug = rec["slug"]
                        break
                except Exception:
                    pass
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

TITLE="Claude Code — ${SLUG:-$PROJECT}"

# ── 發送通知 ───────────────────────────────────────────────

notify-send --icon "$ICON" --expire-time 15000 "$TITLE" "$BODY"
