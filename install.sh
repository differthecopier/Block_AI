# ==============================================================================
#                 system-lock-ai :: INSTALLER
# WARNING: This script installs a permanent, self-repairing AI block.
# There is no corresponding uninstallation script. Proceed with caution.
# ==============================================================================

# Must be run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: This script must be run as root. Use 'sudo'." >&2
  exit 1
fi

# --- Configuration: Blocklist ---
AI_DOMAINS=(
    # OpenAI
    "openai.com" "chat.openai.com" "api.openai.com" "platform.openai.com" "gpt.openai.com" "cdn.openai.com" "files.openai.com" "chatgpt.com"
    # Google
    "claude.ai" "aistudio.google.com" "gemini.google.com" "bard.google.com" "ai.google.dev" "generativeai.google" "makersuite.google.com"
    # Microsoft
    "copilot.microsoft.com" "bing.com"
    # Other Major Players
    "grok.x.com" "meta.ai" "imagine.meta.com" "deepseek.com" "qwen.aliyun.com" "tongyi.aliyun.com" "perplexity.ai" "mistral.ai" "huggingface.co" "poe.com" "character.ai" "you.com" "groq.com" "pi.ai" "inflection.ai"
)

# --- System Paths & Names (obfuscated to look like system components) ---
HOSTS_FILE="/etc/hosts"
GUARDIAN_SCRIPT_PATH="/usr/lib/systemd/systemd-network-flusher"
SERVICE_NAME="network-flush.service"
SERVICE_FILE_PATH="/etc/systemd/system/$SERVICE_NAME"

# --- Installation Logic ---

echo ">>> Initializing system lock for AI services..."
sleep 1

# Step 1: Modify /etc/hosts
echo "--> Writing block rules to $HOSTS_FILE..."
{
    echo ""
    echo "# [SYSTEM-LOCK-AI :: DO NOT MODIFY]"
    for domain in "${AI_DOMAINS[@]}"; do
        echo "0.0.0.0 $domain www.$domain"
        echo "::1 $domain www.$domain"
    done
    echo "# [END OF BLOCK]"
} >> "$HOSTS_FILE"

# Step 2: Set immutable attribute
echo "--> Applying immutable lock to $HOSTS_FILE..."
chattr +i "$HOSTS_FILE"

# Step 3: Create guardian daemon script
echo "--> Installing persistent guardian daemon..."
cat > "$GUARDIAN_SCRIPT_PATH" << EOF
#!/bin/bash
while true; do
    # 1. Enforce immutable lock on hosts file
    if ! lsattr /etc/hosts | grep -q -- 'i'; then
        /usr/bin/chattr +i /etc/hosts
    fi

    # 2. Enforce self-preservation of the systemd service
    if [ -L "$SERVICE_FILE_PATH" ] || ! /usr/bin/systemctl is-enabled "$SERVICE_NAME" > /dev/null; then
        /usr/bin/rm -f "$SERVICE_FILE_PATH"
        /usr/bin/systemctl daemon-reload
        /usr/bin/systemctl enable --now "$SERVICE_NAME" > /dev/null 2>&1
    fi
    sleep 10
done
EOF
chmod +x "$GUARDIAN_SCRIPT_PATH"

# Step 4: Create and register systemd service
cat > "$SERVICE_FILE_PATH" << EOF
[Unit]
Description=Periodically flushes network state and routing caches
DefaultDependencies=no
After=local-fs.target

[Service]
ExecStart=$GUARDIAN_SCRIPT_PATH
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Step 5: Enable and start the guardian service
echo "--> Activating guardian service..."
systemctl daemon-reload
systemctl enable --now "$SERVICE_NAME"

echo ""
echo "✅ System lock is now active. The commitment has been made."
exit 0
