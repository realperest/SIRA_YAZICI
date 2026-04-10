#!/bin/bash
# ==============================================================================
# kioskyap.sh - SIRAMATIK KIOSK TAM OTOMATIK BASLATMA (Garantili Mod)
# Bu script; wtype kurulumunu, tarayıcı ismini, cache temizliğini ve
# tam ekran (start-fullscreen) modunu tek seferde yapılandırır.
# ==============================================================================

# Ayarlar
URL="https://siramatik.inovathinks.com/kiosk.html"
LAUNCHER_SCRIPT="$HOME/.siramatik-kiosk-run.sh"
XDG_AUTOSTART_DIR="$HOME/.config/autostart"
XDG_AUTOSTART_FILE="$XDG_AUTOSTART_DIR/siramatik_kiosk.desktop"
WAYFIRE_CONFIG="$HOME/.config/wayfire.ini"
LABWC_AUTOSTART_DIR="$HOME/.config/labwc"
LABWC_AUTOSTART_FILE="$LABWC_AUTOSTART_DIR/autostart"

echo "----------------------------------------------------------"
echo "SIRAMATIK KIOSK YAPILANDIRMASI (FULL OTOMASYON) BAŞLIYOR..."
echo "----------------------------------------------------------"

# 1. Gerekli Bağımlılıkları Kontrol Et (wtype)
if ! command -v wtype &> /dev/null; then
    echo "   > Tuş simülasyonu aracı (wtype) bulunamadı, kuruluyor..."
    sudo apt-get update && sudo apt-get install wtype -y
else
    echo "   > Tuş simülasyonu aracı (wtype) zaten yüklü."
fi

# 2. Tarayıcı İsmini Otomatik Tespit Et (chromium vs chromium-browser)
CHROME_CMD="chromium-browser"
if command -v chromium &> /dev/null; then
    CHROME_CMD="chromium"
fi
echo "   > Tespit edilen tarayıcı: $CHROME_CMD"

# 3. Launcher Script Oluştur (Asıl işi yapan dosya)
cat <<EOF > "$LAUNCHER_SCRIPT"
#!/bin/bash
# Chromium çökme uyarısını temizle
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' ~/.config/chromium/Default/Preferences 2>/dev/null

# Tarayıcıyı Tam Ekran modunda başlat (start-fullscreen)
# Parametreler: incognito ve cache engelleyiciler eklendi.
$CHROME_CMD --start-fullscreen --noerrdialogs --disable-infobars --hide-crash-restore-bubble --incognito --disk-cache-size=1 --media-cache-size=1 "$URL"
EOF
chmod +x "$LAUNCHER_SCRIPT"
echo "   > Kiosk başlatıcı oluşturuldu: $LAUNCHER_SCRIPT"

# 4. XDG Autostart (.desktop) - Standart Masaüstü için
mkdir -p "$XDG_AUTOSTART_DIR"
cat <<EOF > "$XDG_AUTOSTART_FILE"
[Desktop Entry]
Type=Application
Name=Siramatik Kiosk
Exec=$LAUNCHER_SCRIPT
X-GNOME-Autostart-enabled=true
EOF
echo "   > XDG Autostart kaydı eklendi."

# 5. Wayfire (Pi 4 Native) - Wayland modu için
if [ -f "$WAYFIRE_CONFIG" ]; then
    if ! grep -q "\[autostart\]" "$WAYFIRE_CONFIG"; then
        echo -e "\n[autostart]\nsiramatik_kiosk = $LAUNCHER_SCRIPT" >> "$WAYFIRE_CONFIG"
    else
        sed -i "/siramatik_kiosk/d" "$WAYFIRE_CONFIG"
        sed -i "/\[autostart\]/a siramatik_kiosk = $LAUNCHER_SCRIPT" "$WAYFIRE_CONFIG"
    fi
    echo "   > Wayfire (Pi 4 Native) kaydı güncellendi."
fi

# 6. Labwc (Alternatif) - Labwc modu için
if [ -d "$LABWC_AUTOSTART_DIR" ]; then
    if [ ! -f "$LABWC_AUTOSTART_FILE" ]; then
        echo "$LAUNCHER_SCRIPT" > "$LABWC_AUTOSTART_FILE"
    else
        grep -q "$LAUNCHER_SCRIPT" "$LABWC_AUTOSTART_FILE" || echo "$LAUNCHER_SCRIPT" >> "$LABWC_AUTOSTART_FILE"
    fi
    chmod +x "$LABWC_AUTOSTART_FILE"
    echo "   > Labwc Autostart kaydı eklendi."
fi

echo "----------------------------------------------------------"
echo "BAŞARILI! Kiosk sistemi 'Tam Ekran' modunda yapılandırıldı."
echo "Artık butona basıldığında tarayıcı kapanmadan masaüstü görülebilecektir."
echo "Sistemi test etmek için: sudo reboot"
echo "----------------------------------------------------------"
