#!/usr/bin/env bash
set -euo pipefail

# 用法：./setup.sh [--lang en|zh]
#   --lang en  強制英文
#   --lang zh  強制中文
#   (預設依系統 $LANG 自動偵測)

SETTINGS="$HOME/.claude/settings.json"

STOP_CMD='notify-send -i dialog-information -t 10000 "Claude Code" "Claude 已停止，等待你的指示"'
NOTIF_CMD='notify-send -i dialog-question -t 10000 "Claude Code" "Claude 需要你的回應"'

# ── 語系偵測 ───────────────────────────────────────────────

detect_lang() {
    local lang_arg=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --lang) lang_arg="${2:-}"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [[ "$lang_arg" == "en" ]]; then
        echo "en"
    elif [[ "$lang_arg" == "zh" ]]; then
        echo "zh"
    elif [[ "${LANG:-}" == zh* ]]; then
        echo "zh"
    else
        echo "en"
    fi
}

LANG_CODE=$(detect_lang "$@")

# ── 語系字串 ───────────────────────────────────────────────

t() {  # t <zh字串> <en字串>
    if [[ "$LANG_CODE" == "zh" ]]; then
        echo "$1"
    else
        echo "$2"
    fi
}

# ── 依賴安裝 ───────────────────────────────────────────────

install_deps() {
    local installed_something=false

    if ! command -v claude &>/dev/null; then
        echo "==> $(t '安裝 Claude Code CLI...' 'Installing Claude Code CLI...')"
        curl -fsSL https://claude.ai/install.sh | bash
        installed_something=true
    fi

    if ! command -v notify-send &>/dev/null; then
        echo "==> $(t '安裝 libnotify-bin...' 'Installing libnotify-bin...')"
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
    echo "$(t 'Claude Code 通知 Hook 設定' 'Claude Code Notification Hook Settings')"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  1) Stop hook         [$stop_label]  $(t 'Claude 停止時通知' 'Notify when Claude stops')"
    echo "  2) Notification hook [$notif_label]  $(t 'Claude 需要回應時通知' 'Notify when Claude needs a response')"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  q) $(t '離開' 'Quit')"
    echo ""
    printf "%s" "$(t '請按數字切換 [1/2/q]：' 'Press a number to toggle [1/2/q]: ')"
}

menu() {
    while true; do
        show_menu
        read -rn1 choice
        echo ""
        case "$choice" in
            1) toggle "Stop"         "$STOP_CMD"  ;;
            2) toggle "Notification" "$NOTIF_CMD" ;;
            q|Q) echo "$(t '已離開。' 'Bye.')"; break ;;
        esac
    done
}

# ── 主流程 ─────────────────────────────────────────────────

install_deps
menu
