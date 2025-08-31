
---

### Plik 2: `install.sh`

(To jest właściwy skrypt instalacyjny. Jest dobrze skomentowany, abyś wiedział, co robi każda jego część.)

```bash
#!/bin/bash

# ==============================================================================
#                 AI FORTRESS - SKRYPT INSTALACYJNY
# Ten skrypt instaluje permanentną, samonaprawiającą się blokadę AI.
# OSTRZEŻENIE: Nie ma prostej opcji deinstalacji.
# ==============================================================================

# Sprawdzenie, czy skrypt jest uruchomiony jako root
if [ "$(id -u)" -ne 0 ]; then
  echo "BŁĄD: Ten skrypt musi być uruchomiony z uprawnieniami roota. Użyj 'sudo'."
  exit 1
fi

# --- Konfiguracja ---
# Tutaj możesz dodać lub usunąć domeny do zablokowania.
# Skrypt automatycznie doda wersje z 'www.' i bez.
# Dodano również podwójne blokowanie dla IPv4 (0.0.0.0) i IPv6 (::1).
AI_DOMAINS=(
    # OpenAI
    "openai.com" "chat.openai.com" "api.openai.com" "platform.openai.com" "gpt.openai.com" "cdn.openai.com" "files.openai.com" "chatgpt.com"
    # Google
    "claude.ai" "aistudio.google.com" "gemini.google.com" "bard.google.com" "ai.google.dev" "generativeai.google" "makersuite.google.com"
    # Microsoft
    "copilot.microsoft.com" "bing.com"
    # Inni
    "grok.x.com" "meta.ai" "imagine.meta.com" "deepseek.com" "qwen.aliyun.com" "tongyi.aliyun.com" "perplexity.ai" "mistral.ai" "huggingface.co" "poe.com" "character.ai" "you.com" "groq.com" "pi.ai" "inflection.ai"
)

# Ścieżki i nazwy (używamy mylących nazw systemowych dla utrudnienia identyfikacji)
HOSTS_FILE="/etc/hosts"
GUARDIAN_SCRIPT_PATH="/usr/lib/systemd/systemd-network-flusher"
SERVICE_NAME="network-flush.service"
SERVICE_FILE_PATH="/etc/systemd/system/$SERVICE_NAME"


# --- Główna logika skryptu ---

echo ">>> Rozpoczynanie budowy Fortecy AI..."
sleep 2

# Krok 1: Dodawanie reguł do /etc/hosts
echo ">>> Wznoszenie Muru Obronnego (/etc/hosts)..."
{
    echo ""
    echo "# [PERMANENT AI LOCKDOWN - IRREVERSIBLE BY DESIGN]"
    for domain in "${AI_DOMAINS[@]}"; do
        echo "0.0.0.0 $domain"
        echo "0.0.0.0 www.$domain"
        echo "::1 $domain"
        echo "::1 www.$domain"
    done
    echo "# [END OF LOCKDOWN]"
} >> "$HOSTS_FILE"
echo "Mur wzniesiony."

# Krok 2: Ustawianie atrybutu niezmienności (immutable)
echo ">>> Wzmacnianie Bramy (chattr +i)..."
chattr +i "$HOSTS_FILE"
echo "Brama zamknięta i wzmocniona."

# Krok 3: Tworzenie Demona-Strażnika
echo ">>> Powoływanie Nieustannego Strażnika (demon systemd)..."
cat > "$GUARDIAN_SCRIPT_PATH" << EOF
#!/bin/bash
while true; do
    # 1. Pilnuj, czy /etc/hosts jest niezmienny
    if ! lsattr /etc/hosts | grep -q -- 'i'; then
        /usr/bin/chattr +i /etc/hosts
    fi

    # 2. Pilnuj, czy nasza własna usługa nie jest zamaskowana lub wyłączona
    if [ -L "$SERVICE_FILE_PATH" ] || ! /usr/bin/systemctl is-enabled "$SERVICE_NAME" > /dev/null; then
        /usr/bin/rm -f "$SERVICE_FILE_PATH"
        /usr/bin/systemctl daemon-reload
        /usr/bin/systemctl enable --now "$SERVICE_NAME" > /dev/null
    fi
    sleep 10
done
EOF
chmod +x "$GUARDIAN_SCRIPT_PATH"

# Krok 4: Tworzenie i rejestracja usługi systemd dla strażnika
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

# Krok 5: Aktywacja Strażnika
echo ">>> Strażnik obejmuje wartę..."
systemctl daemon-reload
systemctl enable --now "$SERVICE_NAME"

echo ""
echo "✅ Forteca AI została wzniesiona i jest strzeżona."
echo "Proces instalacji zakończony."

exit 0
