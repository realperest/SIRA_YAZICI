#!/bin/sh
# ~/apps/SIRA_YAZICI deposunu yeniden klonlar; son 3 yedek tutar.
#
# - En guncel onceki kopya: SIRA_YAZICI_yedek_1
# - Daha eski: yedek_2, yedek_3 (4. surada olan silinir)
# - Eski sema (SIRA_YAZICI_eski, SIRA_YAZICI_eski_*): ilk calistirmada temizlenir
#
# Kullanim:
#   chmod +x refresh-sira-yazici-apps.sh
#   ./refresh-sira-yazici-apps.sh
#
# Baska URL:
#   SIRA_YAZICI_GIT_URL='git@github.com:realperest/SIRA_YAZICI.git' ./refresh-sira-yazici-apps.sh

set -eu
APPS="${HOME}/apps"
LIVE="${APPS}/SIRA_YAZICI"
REPO_URL="${SIRA_YAZICI_GIT_URL:-git@github.com:realperest/SIRA_YAZICI.git}"

mkdir -p "$APPS"
cd "$APPS"

# Onceki tek/tarihli yedek isimleri (rotasyonla karismasin diye kaldirilir)
for d in SIRA_YAZICI_eski SIRA_YAZICI_eski_*; do
	[ -d "$d" ] || continue
	rm -rf "$d"
done

rm -rf SIRA_YAZICI_yedek_3
[ -d SIRA_YAZICI_yedek_2 ] && mv SIRA_YAZICI_yedek_2 SIRA_YAZICI_yedek_3
[ -d SIRA_YAZICI_yedek_1 ] && mv SIRA_YAZICI_yedek_1 SIRA_YAZICI_yedek_2
if [ -d "$LIVE" ]; then
	mv "$LIVE" SIRA_YAZICI_yedek_1
fi

git clone "$REPO_URL" SIRA_YAZICI
printf 'OK: %s (son 3 yedek: %s/SIRA_YAZICI_yedek_1 .. _3)\n' "$LIVE" "$APPS"
