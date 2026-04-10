#!/bin/sh
# Siramatik kiosk-print-agent: depo guncelle (manuel veya systemd timer).
#
# One-time: Pi'de tam depo klonlanmali ve GitHub SSH anahtari tanimli olmali:
#   git clone git@github.com:realperest/SIRAMATIK.git ~/SIRAMATIK
#
# Ortam: SIRAMATIK_REPO (varsayilan ~/SIRAMATIK)

set -eu
REPO="${SIRAMATIK_REPO:-${HOME}/SIRAMATIK}"
cd "$REPO"

if ! test -d .git; then
    echo "HATA: Git deposu yok: $REPO" >&2
    echo "  once: git clone git@github.com:realperest/SIRAMATIK.git $REPO" >&2
    exit 1
fi

git pull --ff-only
echo "OK: guncellendi -> $REPO ($(git -C "$REPO" rev-parse --short HEAD))"
