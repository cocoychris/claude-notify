#!/usr/bin/env bash
set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"

STOP_CMD='notify-send -i dialog-information -t 10000 "Claude Code" "Claude 已停止，等待你的指示"'
NOTIF_CMD='notify-send -i dialog-question -t 10000 "Claude Code" "Claude 需要你的回應"'

# ── 依賴安裝 ──────────────────────────────────────────────

install_deps() {
    local installed_something=false

    if ! command -v claude &>/dev/null; then
        echo "==> 安裝 Claude Code CLI..."
        curl -fsSL https://claude.ai/install.sh | bash
        installed_something=true
    fi

    if ! command -v notify-send &>/dev/null; then
        echo "==> 安裝 libnotify-bin..."
        sudo apt-get install -y libnotify-bin
        installed_something=true
    fi

    mkdir -p "$(dirname "$SETTINGS")"
    [ -f "$SETTINGS" ] || echo "{}" > "$SETTINGS"

    if $installed_something; then echo ""; fi
}

# ── Hook 狀態讀寫（透過環境變數傳遞指令字串，避免引號問題）──

get_status() {  # get_status <hook_name> → "on" | "off"
    python3 - "$SETTINGS" "$1" <<'PY'
import json, sys
try:
    with open(sys.argv[1]) as f:
        s = json.load(f)
    print("on" if s.get("hooks", {}).get(sys.argv[2]) else "off")
except Exception:
    print("off")
PY
}

set_hook() {  # set_hook <hook_name> <on|off>  (HOOK_CMD 由環境變數傳入)
    HOOK_NAME="$1" HOOK_ENABLED="$2" python3 - "$SETTINGS" <<'PY'
import json, sys, os
path = sys.argv[1]
name = os.environ["HOOK_NAME"]
enabled = os.environ["HOOK_ENABLED"] == "on"
cmd = os.environ["HOOK_CMD"]

try:
    with open(path) as f:
        settings = json.load(f)
except Exception:
    settings = {}

settings.setdefault("hooks", {})

if enabled:
    settings["hooks"][name] = [
        {"matcher": "", "hooks": [{"type": "command", "command": cmd}]}
    ]
else:
    settings["hooks"].pop(name, None)

with open(path, "w") as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY
}

toggle() {  # toggle <hook_name> <command>
    local name="$1"
    export HOOK_CMD="$2"
    local current
    current=$(get_status "$name")
    if [ "$current" = "on" ]; then
        set_hook "$name" "off"
    else
        set_hook "$name" "on"
    fi
}

# ── 互動選單 ───────────────────────────────────────────────

show_menu() {
    local stop_st notif_st stop_label notif_label
    stop_st=$(get_status "Stop")
    notif_st=$(get_status "Notification")
    stop_label=$([ "$stop_st"  = "on" ] && echo "ON " || echo "OFF")
    notif_label=$([ "$notif_st" = "on" ] && echo "ON " || echo "OFF")

    clear
    echo "Claude Code 通知 Hook 設定"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  1) Stop hook         [$stop_label]  Claude 停止時通知"
    echo "  2) Notification hook [$notif_label]  Claude 需要回應時通知"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  q) 離開"
    echo ""
    printf "請按數字切換 [1/2/q]："
}

menu() {
    while true; do
        show_menu
        read -rn1 choice
        echo ""
        case "$choice" in
            1) toggle "Stop"         "$STOP_CMD"  ;;
            2) toggle "Notification" "$NOTIF_CMD" ;;
            q|Q) echo "已離開。"; break ;;
        esac
    done
}

# ── 主流程 ─────────────────────────────────────────────────

install_deps
menu
