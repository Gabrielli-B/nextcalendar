#!/usr/bin/env bash
# Sobe o projeto na internet: proxy same-origin + túnel Cloudflare (quick tunnel)
# e o Expo web já apontando a API para a URL pública.
#
#   ./scripts/expose/start.sh      sobe tudo
#   ./scripts/expose/stop.sh       derruba tudo
#
# Artefatos em scripts/expose/run/ (logs, pids e urls.txt com a URL pública).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
EXP="$ROOT/scripts/expose"
RUN="$EXP/run"
BIN="$EXP/bin/cloudflared"
mkdir -p "$RUN"

EXPOSE_PORT="${EXPOSE_PORT:-8085}"
WEB_PORT="${WEB_PORT:-8081}"
BACKEND_PORT="${BACKEND_PORT:-8080}"

log() { printf '[expose] %s\n' "$*"; }

alive() { [ -f "$1" ] && kill -0 "$(cat "$1")" 2>/dev/null; }

port_pid() { ss -ltnp 2>/dev/null | grep -E "[:.]$1\s" | grep -oE 'pid=[0-9]+' | head -1 | cut -d= -f2 || true; }

# ── 1. proxy ────────────────────────────────────────────────────────────────
if alive "$RUN/proxy.pid"; then
  log "proxy já rodando (pid $(cat "$RUN/proxy.pid"))"
else
  setsid nohup node "$EXP/proxy.mjs" > "$RUN/proxy.log" 2>&1 < /dev/null &
  echo $! > "$RUN/proxy.pid"
  log "proxy subiu em :$EXPOSE_PORT (pid $(cat "$RUN/proxy.pid"))"
fi

# ── 2. cloudflared ──────────────────────────────────────────────────────────
if [ ! -x "$BIN" ]; then
  arch="$(uname -m)"
  case "$arch" in
    x86_64) asset=cloudflared-linux-amd64 ;;
    aarch64|arm64) asset=cloudflared-linux-arm64 ;;
    *) echo "arquitetura não suportada: $arch" >&2; exit 1 ;;
  esac
  log "baixando cloudflared ($asset)..."
  curl -fsSL -o "$BIN" "https://github.com/cloudflare/cloudflared/releases/latest/download/$asset"
  chmod +x "$BIN"
fi

# ── 3. túnel ────────────────────────────────────────────────────────────────
PUBLIC_URL=""
if alive "$RUN/tunnel.pid" && [ -f "$RUN/public.url" ]; then
  PUBLIC_URL="$(cat "$RUN/public.url")"
  log "túnel já rodando: $PUBLIC_URL"
else
  setsid nohup "$BIN" tunnel --url "http://127.0.0.1:$EXPOSE_PORT" --no-autoupdate \
    > "$RUN/tunnel.log" 2>&1 < /dev/null &
  echo $! > "$RUN/tunnel.pid"
  for _ in $(seq 1 60); do
    PUBLIC_URL="$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' "$RUN/tunnel.log" | head -1 || true)"
    [ -n "$PUBLIC_URL" ] && break
    sleep 1
  done
  if [ -z "$PUBLIC_URL" ]; then
    echo "não consegui ler a URL do túnel — veja $RUN/tunnel.log" >&2
    exit 1
  fi
  printf '%s' "$PUBLIC_URL" > "$RUN/public.url"
  log "túnel pronto: $PUBLIC_URL"
fi

# ── 4. Expo web apontando a API para a URL pública ──────────────────────────
API_URL="$PUBLIC_URL/api/v1"
WEB_LISTENER="$(port_pid "$WEB_PORT")"
need_start=1
if [ -n "$WEB_LISTENER" ]; then
  cmdline="$(tr '\0' ' ' < "/proc/$WEB_LISTENER/cmdline" 2>/dev/null || true)"
  case "$cmdline" in
    *expo*)
      log "Expo web já está em :$WEB_PORT — reiniciando com EXPO_PUBLIC_API_URL=$API_URL"
      kill "$WEB_LISTENER" 2>/dev/null || true
      sleep 3
      ;;
    *)
      echo "porta $WEB_PORT ocupada por outro processo (pid $WEB_LISTENER); abortando." >&2
      exit 1
      ;;
  esac
fi

if [ "$need_start" = 1 ]; then
  ( cd "$ROOT/frontend" && setsid nohup env CI=1 EXPO_NO_TELEMETRY=1 EXPO_PUBLIC_API_URL="$API_URL" \
      npx expo start --web --port "$WEB_PORT" > "$RUN/expo.log" 2>&1 < /dev/null & echo $! > "$RUN/expo.pid" )
  log "subindo Expo web em :$WEB_PORT (log: $RUN/expo.log)"
  for _ in $(seq 1 60); do
    code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "http://localhost:$WEB_PORT" || true)"
    [ "$code" = 200 ] && break
    sleep 3
  done
fi

{
  echo "URL_PUBLICA=$PUBLIC_URL"
  echo "URL_WEB=$PUBLIC_URL"
  echo "API_URL=$API_URL"
  echo "PROXY=http://localhost:$EXPOSE_PORT"
  echo "WEB=http://localhost:$WEB_PORT"
  echo "BACKEND=http://localhost:$BACKEND_PORT"
} > "$RUN/urls.txt"

echo
log "tudo no ar."
log "  público  : $PUBLIC_URL"
log "  API      : $API_URL"
log "  local    : http://localhost:$WEB_PORT (app) / http://localhost:$EXPOSE_PORT (proxy)"
log "pares: scripts/expose/stop.sh"
