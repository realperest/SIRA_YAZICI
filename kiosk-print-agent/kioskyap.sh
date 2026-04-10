#!/bin/bash
# ==============================================================================
# kioskyap.sh - SIRAMATIK KIOSK TAM OTOMATIK BASLATMA (WAYLAND UYUMLU v5)
# RPi 4 / Bookworm (Wayland/Wayfire/Labwc) için kesin çözüm.
# ==============================================================================

# Ayarlar
BASE_DIR="/home/alper/apps/SIRA_YAZICI"
AGENT_DIR="$BASE_DIR/kiosk-print-agent"
URL="https://siramatik.inovathinks.com/kiosk.html"

# Başlatıcı ve Profil
LAUNCHER_SCRIPT="$AGENT_DIR/siramatik-kiosk-run.sh"
USER_DATA_DIR="$AGENT_DIR/.kiosk-profile"

XDG_AUTOSTART_DIR="$HOME/.config/autostart"
XDG_AUTOSTART_FILE="$XDG_AUTOSTART_DIR/siramatik_kiosk.desktop"
WAYFIRE_CONFIG="$HOME/.config/wayfire.ini"
LABWC_AUTOSTART_DIR="$HOME/.config/labwc"
LABWC_AUTOSTART_FILE="$LABWC_AUTOSTART_DIR/autostart"

echo "----------------------------------------------------------"
echo "SIRAMATIK KIOSK YAPILANDIRMASI (WAYLAND MODU) BAŞLIYOR..."
echo "----------------------------------------------------------"

# 1. Eski Kalıntıları Temizle
rm -f "$HOME/.siramatik-kiosk-run.sh"

# 2. Bağımlılık (wtype) Kontrolü
if ! command -v wtype &> /dev/null; then
    sudo apt-get update && sudo apt-get install wtype -y
fi

# 3. Tarayıcı Tespit
CHROME_CMD="chromium-browser"
if command -v chromium &> /dev/null; then
    CHROME_CMD="chromium"
fi

# 4. LAUNCHER SCRIPT (Wayland Parametreleri Eklendi)
cat <<EOF > "$LAUNCHER_SCRIPT"
#!/bin/bash
# Wayland Display Ortamı (Bookworm İçin Kritik)
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR=/run/user/\$(id -u)

# Chromium süreçlerini temizle
pkill -f chromium 2>/dev/null
sleep 2

# Chromium çökme uyarısını temizle
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' ~/.config/chromium/Default/Preferences 2>/dev/null

# WAYLAND ÖZEL: --ozone-platform-hint=auto (Motoru otomatik tanır)
# --app: Adres çubuğunu gizler
$CHROME_CMD --app="$URL" \\
    --start-fullscreen \\
    --user-data-dir="$USER_DATA_DIR" \\
    --ozone-platform-hint=auto \\
    --force-device-scale-factor=1.00 \\
    --noerrdialogs \\
    --disable-infobars \\
    --hide-crash-restore-bubble \\
    --disk-cache-size=1 \\
    --media-cache-size=1 &

# Tam ekran sinyali gönder
sleep 15
wtype -k F11
EOF
chmod +x "$LAUNCHER_SCRIPT"
echo "   > Wayland uyumlu başlatıcı oluşturuldu: $LAUNCHER_SCRIPT"

# 5. AKILLI OTOMATIK BASLATMA (Motor Tespit Ediliyor)

# A - Standart .desktop kaydı (Hala bazı yöneticiler kullanıyor)
mkdir -p "$XDG_AUTOSTART_DIR"
cat <<EOF > "$XDG_AUTOSTART_FILE"
[Desktop Entry]
Type=Application
Name=Siramatik Kiosk
Exec=$LAUNCHER_SCRIPT
X-GNOME-Autostart-enabled=true
EOF

# B - WAYFIRE (Pi 4 Varsayılanı - Bookworm Early)
if [ -f "$WAYFIRE_CONFIG" ]; then
    # Eğer ayar yoksa ekle
    if ! grep -q "siramatik_kiosk" "$WAYFIRE_CONFIG"; then
        echo -e "\n[autostart]\nsiramatik_kiosk = $LAUNCHER_SCRIPT" >> "$WAYFIRE_CONFIG"
        echo "   > Wayfire otobaslatma kaydı eklendi."
    fi
fi

# C - LABWC (Pi 4 Yeni Varsayılanı - Bookworm Late)
if [ -d "$LABWC_AUTOSTART_DIR" ] || [ -f "/usr/bin/labwc" ]; then
    mkdir -p "$LABWC_AUTOSTART_DIR"
    # Autostart dosyasına ekle (Duplicate kontrolü yaparak)
    if [ ! -f "$LABWC_AUTOSTART_FILE" ] || ! grep -q "$LAUNCHER_SCRIPT" "$LABWC_AUTOSTART_FILE"; then
        echo "$LAUNCHER_SCRIPT" >> "$LABWC_AUTOSTART_FILE"
        chmod +x "$LABWC_AUTOSTART_FILE"
        echo "   > Labwc otobaslatma kaydı eklendi."
    fi
fi

echo "----------------------------------------------------------"
echo "BAŞARILI! Wayland (Bookworm) uyumluluğu sağlandı."
echo "Lütfen son kez Pi'de: git pull && bash kioskyap.sh"
echo "Ardından: sudo reboot"
echo "----------------------------------------------------------"
