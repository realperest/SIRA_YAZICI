#!/bin/bash
# ==============================================================================
# kioskkapat.sh - SIRAMATIK KIOSK OTOMATIK BASLATMAYI TAMAMEN TEMIZLE
# Bu script, tüm başlatma yöntemlerini (Wayfire, XDG, Labwc, Launcher)
# tek seferde temizler ve cihazı normal masaüstüne döndürür.
# ==============================================================================

LAUNCHER_SCRIPT="$HOME/.siramatik-kiosk-run.sh"
XDG_AUTOSTART_FILE="$HOME/.config/autostart/siramatik_kiosk.desktop"
WAYFIRE_CONFIG="$HOME/.config/wayfire.ini"
LABWC_AUTOSTART_FILE="$HOME/.config/labwc/autostart"

echo "----------------------------------------------------------"
echo "SIRAMATIK KIOSK MODU TEMIZLENIYOR (DEVRE DISI BIRAKMA)..."
echo "----------------------------------------------------------"

# 1. Launcher Script'i Sil
if [ -f "$LAUNCHER_SCRIPT" ]; then
    rm "$LAUNCHER_SCRIPT"
    echo "   > Başlatıcı script silindi."
fi

# 2. XDG Autostart'ı Sil
if [ -f "$XDG_AUTOSTART_FILE" ]; then
    rm "$XDG_AUTOSTART_FILE"
    echo "   > XDG (.desktop) kaydı silindi."
fi

# 3. Wayfire Kaydını Temizle
if [ -f "$WAYFIRE_CONFIG" ]; then
    sed -i "/siramatik_kiosk/d" "$WAYFIRE_CONFIG"
    echo "   > Wayfire (Pi 4 Native) kaydı temizlendi."
fi

# 4. Labwc Kaydını Temizle
if [ -f "$LABWC_AUTOSTART_FILE" ]; then
    # Launcher script satırını dosyadan sil
    sed -i "\|\.siramatik-kiosk-run\.sh|d" "$LABWC_AUTOSTART_FILE"
    echo "   > Labwc kaydı temizlendi."
fi

echo "----------------------------------------------------------"
echo "BAŞARILI! Kiosk modu tüm sistemlerden temizlendi."
echo "Cihaz artık açılışta normal masaüstünde kalacaktır."
echo "Tam temizlik için yeniden başlatabilirsiniz: sudo reboot"
echo "----------------------------------------------------------"
