#!/bin/bash
# ==============================================================================
# kioskyap.sh - SIRAMATIK KIOSK TAM OTOMATIK BASLATMA (YOL DUZELTME v3)
# Bu script; tüm dosyaları /home/alper/apps/SIRA_YAZICI/kiosk-print-agent
# altında toplar ve yapılandırır.
# ==============================================================================

# Ayarlar (TAM YOLLAR GÜNCELLENDİ)
BASE_DIR="/home/alper/apps/SIRA_YAZICI"
AGENT_DIR="$BASE_DIR/kiosk-print-agent"
URL="https://siramatik.inovathinks.com/kiosk.html"

# Başlatıcı ve Profil artık AGENT_DIR içinde
LAUNCHER_SCRIPT="$AGENT_DIR/.siramatik-kiosk-run.sh"
USER_DATA_DIR="$AGENT_DIR/.kiosk-profile"

XDG_AUTOSTART_DIR="$HOME/.config/autostart"
XDG_AUTOSTART_FILE="$XDG_AUTOSTART_DIR/siramatik_kiosk.desktop"
WAYFIRE_CONFIG="$HOME/.config/wayfire.ini"
LABWC_AUTOSTART_DIR="$HOME/.config/labwc"
LABWC_AUTOSTART_FILE="$LABWC_AUTOSTART_DIR/autostart"

echo "----------------------------------------------------------"
echo "SIRAMATIK KIOSK YAPILANDIRMASI (AGENT_DIR MODU) BAŞLIYOR..."
echo "----------------------------------------------------------"

# 1. Eski Kalıntıları Temizle (Gereksiz katmanları siler)
rm -f "$HOME/.siramatik-kiosk-run.sh"
echo "   > Eski /home/alper altındaki launcher temizlendi."

# 2. Gerekli Bağımlılıkları Kontrol Et (wtype)
if ! command -v wtype &> /dev/null; then
    sudo apt-get update && sudo apt-get install wtype -y
fi

# 3. Tarayıcı İsmini Otomatik Tespit Et
CHROME_CMD="chromium-browser"
if command -v chromium &> /dev/null; then
    CHROME_CMD="chromium"
fi

# 4. Launcher Script Oluştur (Garantili Başlatıcı)
cat <<EOF > "$LAUNCHER_SCRIPT"
#!/bin/bash
# Chromium süreçlerini temizle
pkill -f chromium 2>/dev/null
sleep 2

# Tarayıcıyı Uygulama (App) modunda ve Tam Ekran başlat
# User Data bu klasörün içindeki .kiosk-profile dizinine yazılır.
$CHROME_CMD --app="$URL" --start-fullscreen --user-data-dir="$USER_DATA_DIR" --noerrdialogs --disable-infobars --hide-crash-restore-bubble --disk-cache-size=1 --media-cache-size=1 &

# Tam ekran garantisi için sinyal gönder
sleep 15
wtype -k F11
EOF
chmod +x "$LAUNCHER_SCRIPT"
echo "   > Kiosk başlatıcı yolu: $LAUNCHER_SCRIPT"

# 5. Autostart Kayıtlarını Güncelle
mkdir -p "$XDG_AUTOSTART_DIR"
cat <<EOF > "$XDG_AUTOSTART_FILE"
[Desktop Entry]
Type=Application
Name=Siramatik Kiosk
Exec=$LAUNCHER_SCRIPT
X-GNOME-Autostart-enabled=true
EOF

if [ -f "$WAYFIRE_CONFIG" ]; then
    sed -i "/siramatik_kiosk/d" "$WAYFIRE_CONFIG"
    echo -e "\n[autostart]\nsiramatik_kiosk = $LAUNCHER_SCRIPT" >> "$WAYFIRE_CONFIG"
fi

if [ -d "$LABWC_AUTOSTART_DIR" ]; then
    echo "$LAUNCHER_SCRIPT" > "$LABWC_AUTOSTART_FILE"
    chmod +x "$LABWC_AUTOSTART_FILE"
fi

echo "----------------------------------------------------------"
echo "BAŞARILI! Her şey artık $AGENT_DIR altında toplandı."
echo "Lütfen son kez: git pull && bash kioskyap.sh"
echo "Sonrasında: sudo reboot"
echo "----------------------------------------------------------"
