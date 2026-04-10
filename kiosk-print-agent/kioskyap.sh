#!/bin/bash
# ==============================================================================
# kioskyap.sh - SIRAMATIK KIOSK TAM OTOMATIK BASLATMA (ESGUDUMLU MOD v4)
# Bu script; tüm dosyaları /home/alper/apps/SIRA_YAZICI/kiosk-print-agent
# altında toplar, gizli olmayan bir başlatıcı oluşturur ve senkronu sağlar.
# ==============================================================================

# Ayarlar (ESGUDUMLU YOLLAR)
BASE_DIR="/home/alper/apps/SIRA_YAZICI"
AGENT_DIR="$BASE_DIR/kiosk-print-agent"
URL="https://siramatik.inovathinks.com/kiosk.html"

# Başlatıcı artık GİZLİ DEĞİL ve AGENT_DIR içinde
LAUNCHER_SCRIPT="$AGENT_DIR/siramatik-kiosk-run.sh"
# Profil verileri de burada saklanır
USER_DATA_DIR="$AGENT_DIR/.kiosk-profile"

XDG_AUTOSTART_DIR="$HOME/.config/autostart"
XDG_AUTOSTART_FILE="$XDG_AUTOSTART_DIR/siramatik_kiosk.desktop"
WAYFIRE_CONFIG="$HOME/.config/wayfire.ini"
LABWC_AUTOSTART_DIR="$HOME/.config/labwc"
LABWC_AUTOSTART_FILE="$LABWC_AUTOSTART_DIR/autostart"

echo "----------------------------------------------------------"
echo "SIRAMATIK KIOSK YAPILANDIRMASI (ESGUDUMLU MOD) BAŞLIYOR..."
echo "----------------------------------------------------------"

# 1. ESKİ KALINTILARI TEMİZLE (Kafa karıştıran her şeyi siliyoruz)
rm -f "$HOME/.siramatik-kiosk-run.sh"
echo "   > Ev dizinindeki (~) eski gizli başlatıcı temizlendi."

# 2. Gerekli Bağımlılıkları Kontrol Et (wtype)
if ! command -v wtype &> /dev/null; then
    echo "   > Tuş simülasyonu aracı (wtype) kuruluyor..."
    sudo apt-get update && sudo apt-get install wtype -y
fi

# 3. Tarayıcı İsmini Otomatik Tespit Et
CHROME_CMD="chromium-browser"
if command -v chromium &> /dev/null; then
    CHROME_CMD="chromium"
fi

# 4. LAUNCHER SCRIPT OLUSTUR (Görünür dosya)
cat <<EOF > "$LAUNCHER_SCRIPT"
#!/bin/bash
# Chromium süreçlerini temizle (Hayalet oturumları öldür)
pkill -f chromium 2>/dev/null
sleep 2

# Chromium çökme uyarısını temizle
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' ~/.config/chromium/Default/Preferences 2>/dev/null

# Uygulama Modu (--app) ve Yerel Profil (--user-data-dir) ile başlat
# Gizli Mod (Incognito) tamamen kaldırıldı.
$CHROME_CMD --app="$URL" --start-fullscreen --user-data-dir="$USER_DATA_DIR" --noerrdialogs --disable-infobars --hide-crash-restore-bubble --disk-cache-size=1 --media-cache-size=1 &

# Tam ekran garantisi için sinyal gönder
sleep 15
wtype -k F11
EOF
chmod +x "$LAUNCHER_SCRIPT"
echo "   > Yeni (Görünür) Kiosk başlatıcı oluşturuldu: $LAUNCHER_SCRIPT"

# 5. AUTOSTART KAYITLARINI GÜNCELLE
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
echo "BAŞARILI! Tüm dosyalar artık $AGENT_DIR altında toplandı."
echo "Eşgüdüm sağlandı. Lütfen Pi üzerinde:"
echo "1. git pull && bash kioskyap.sh"
echo "2. sudo reboot"
echo "----------------------------------------------------------"
