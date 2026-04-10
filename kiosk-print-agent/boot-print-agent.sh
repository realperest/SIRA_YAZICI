#!/bin/sh
# Tablet/Pi acilisinda: varsa eski main.py durdur, (mumkunse) git pull, sonra kesinlikle main.py.
# Git / ag / fetch hatalarinda servis durmaz; pull basarisiz olsa da agent ayaga kalkar.

# set -e KULLANMA: bir komut hata kodu verse bile main.py calissin.
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

kill_same_agent() {
	pkill -f "${SCRIPT_DIR}/main.py" 2>/dev/null || true
	for pid in $(pgrep -u "$(id -un)" -f "python3 main.py" 2>/dev/null || true); do
		[ -n "${pid:-}" ] || continue
		cwd="$(readlink -f "/proc/$pid/cwd" 2>/dev/null || true)"
		[ "$cwd" = "$SCRIPT_DIR" ] || continue
		kill "$pid" 2>/dev/null || true
	done
	sleep 0.5
}

git_pull_if_behind() {
	# Ayri betik hata kodu donse bile burada yutulur
	if [ -f "${SCRIPT_DIR}/git-pull-if-needed.sh" ]; then
		sh "${SCRIPT_DIR}/git-pull-if-needed.sh" || true
	else
		true
	fi
}

kill_same_agent || true
git_pull_if_behind || true
cd "$SCRIPT_DIR" || exit 1
exec python3 main.py
