#!/usr/bin/env bash
set -euo pipefail

# 安裝 Claude Code CLI 及 libnotify，並設定 Stop hook 發送系統通知

SETTINGS="$HOME/.claude/settings.json"

echo "==> 檢查 claude CLI..."
if ! command -v claude &>/dev/null; then
    echo "    未安裝，透過官方安裝腳本安裝..."
    curl -fsSL https://claude.ai/install.sh | bash
else
    echo "    已安裝：$(claude --version 2>/dev/null || echo '(版本未知)')"
fi

echo "==> 檢查 libnotify-bin (notify-send)..."
if ! command -v notify-send &>/dev/null; then
    echo "    未安裝，透過 apt 安裝 libnotify-bin..."
    sudo apt-get install -y libnotify-bin
else
    echo "    已安裝"
fi

echo "==> 設定 Claude hooks..."

mkdir -p "$(dirname "$SETTINGS")"

# 若 settings.json 不存在則建立空物件
if [ ! -f "$SETTINGS" ]; then
    echo "{}" > "$SETTINGS"
fi

# 用 Python 將 hooks 合併進現有設定（不覆蓋其他欄位）
python3 - "$SETTINGS" <<'EOF'
import json, sys

settings_path = sys.argv[1]

with open(settings_path) as f:
    settings = json.load(f)

settings["hooks"] = {
    "Stop": [
        {
            "matcher": "",
            "hooks": [
                {
                    "type": "command",
                    "command": "notify-send -i dialog-information -t 10000 \"Claude Code\" \"Claude 已停止，等待你的指示\""
                }
            ]
        }
    ],
    "Notification": [
        {
            "matcher": "",
            "hooks": [
                {
                    "type": "command",
                    "command": "notify-send -i dialog-question -t 10000 \"Claude Code\" \"Claude 需要你的回應\""
                }
            ]
        }
    ]
}

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write("\n")
EOF

echo ""
echo "設定完成！"
echo "  - Stop hook：Claude 停止時發送通知"
echo "  - Notification hook：Claude 需要回應時發送通知"
echo "  - 設定檔：$SETTINGS"
