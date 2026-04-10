#!/bin/sh
# Ust depoda origin/branch ile fark varsa ff-only pull.
# set -e YOK: her adimda acik cikis; hata = sessizce 1 (boot bunu yutar).
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT" || exit 1
[ -d .git ] || exit 1
git fetch -q origin || exit 1
BR="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || exit 1
[ -n "$BR" ] || exit 1
git rev-parse --verify "origin/${BR}" >/dev/null 2>&1 || exit 1
L="$(git rev-parse HEAD 2>/dev/null)" || exit 1
R="$(git rev-parse "origin/${BR}" 2>/dev/null)" || exit 1
[ "$L" != "$R" ] || exit 1
git pull --ff-only origin "$BR" || exit 2
exit 0
