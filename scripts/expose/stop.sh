#!/usr/bin/env bash
# Derruba o túnel, o proxy e o Expo web subidos por start.sh.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUN="$ROOT/scripts/expose/run"

for name in expo tunnel proxy; do
  pidfile="$RUN/$name.pid"
  if [ -f "$pidfile" ]; then
    pid="$(cat "$pidfile")"
    if kill -0 "$pid" 2>/dev/null; then
      # o Expo/alias podem ter filhos (Metro) — mata o grupo quando existir
      pkill -P "$pid" 2>/dev/null || true
      kill "$pid" 2>/dev/null || true
      echo "[expose] $name parado (pid $pid)"
    else
      echo "[expose] $name já não rodava"
    fi
    rm -f "$pidfile"
  fi
done
