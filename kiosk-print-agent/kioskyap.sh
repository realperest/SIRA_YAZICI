#!/bin/bash
# ==============================================================================
# kioskyap.sh - SIRAMATIK KIOSK TAM OTOMATIK BASLATMA (BRUTE FORCE FIX)
# Bu script; eski ayarları temizler, yolu sabitler ve Incognito'yu KESİN kapatır.
# ==============================================================================

# Ayarlar
BASE_DIR="/home/alper/apps/SIRA_YAZICI"
URL="https://siramatik.inovathinks.com/kiosk.html"
# Yolu en güvenli (HOME) dizinine sabitliyoruz
LAUNCHER_SCRIPT="$HOME/.siramatik-kiosk-run.sh"
XDG_AUTOSTART_DIR="$HOME/.config/autostart"
XDG_AUTOSTART_FILE="$XDG_AUTOSTART_DIR/siramatik_kiosk.desktop"
WAYFIRE_CONFIG="$HOME/.config/wayfire.ini"
LABWC_AUTOSTART_DIR="$HOME/.config/labwc"
LABWC_AUTOSTART_FILE="$LABWC_AUTOSTART_DIR/autostart"
USER_DATA_DIR="$HOME/.kiosk-profile"

echo "----------------------------------------------------------"
echo "SIRAMATIK KIOSK YAPILANDIRMASI (KESİN ÇÖZÜM MODU) BAŞLIYOR..."
echo "----------------------------------------------------------"

# 1. Eski Kalıntıları Temizle
rm -f "$BASE_DIR/.siramatik-kiosk-run.sh" # Eski/yanlış yoldaki dosyayı sil
echo "   > Eski launcher kayıtları temizlendi."

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
# Çalışan tüm chromium süreçlerini temizle (Eski Incognito oturumları kapatılsın)
pkill -f chromium 2>/dev/null
sleep 2

# Chromium çökme uyarısını temizle
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' ~/.config/chromium/Default/Preferences 2>/dev/null

# Tarayıcıyı Uygulama (App) modunda ve Tam Ekran başlat
# Incognito YOK, Ayarlar USER_DATA_DIR içinde saklanır.
$CHROME_CMD --app="$URL" --start-fullscreen --user-data-dir="$USER_DATA_DIR" --noerrdialogs --disable-infobars --hide-crash-restore-bubble --disk-cache-size=1 --media-cache-size=1 &

# Tam ekran garantisi için sinyal gönder
sleep 15
wtype -k F11
EOF
chmod +x "$LAUNCHER_SCRIPT"
echo "   > Yeni Kiosk başlatıcı oluşturuldu: $LAUNCHER_SCRIPT"

# 5. Autostart Kayıtlarını Güncelle
mkdir -p "$XDG_AUTOSTART_DIR"
cat <<EOF > "$XDG_AUTOSTART_FILE"
[Desktop Entry]
Type=Application
Name=Siramatik Kiosk
Exec=$LAUNCHER_SCRIPT
X-GNOME-Autostart-enabled=true
EOF

# Wayfire/Labwc ayarlarını da bu yeni yola göre güncelle
if [ -f "$WAYFIRE_CONFIG" ]; then
    sed -i "/siramatik_kiosk/d" "$WAYFIRE_CONFIG"
    echo -e "\n[autostart]\nsiramatik_kiosk = $LAUNCHER_SCRIPT" >> "$WAYFIRE_CONFIG"
fi

if [ -d "$LABWC_AUTOSTART_DIR" ]; then
    echo "$LAUNCHER_SCRIPT" > "$LABWC_AUTOSTART_FILE"
    chmod +x "$LABWC_AUTOSTART_FILE"
fi

echo "----------------------------------------------------------"
echo "BAŞARILI! Eski ayarlar ezildi ve yeni yapı kuruldu."
echo "Artık her açılışta Chromium ÖNCE ÖLDÜRÜLECEK, sonra temiz açılacak."
echo "Lütfen son kez: git pull && bash kioskyap.sh"
echo "Sonrasında: sudo reboot"
echo "----------------------------------------------------------"
