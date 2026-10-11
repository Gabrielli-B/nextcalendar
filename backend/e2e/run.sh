#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Suíte E2E (HURL) do NextCalendar — executa contra o backend REAL.
#
#   ./backend/e2e/run.sh                 # suíte inteira
#   ./backend/e2e/run.sh 02-auth.hurl    # só um arquivo
#
# Opcional:
#   BASE_URL=http://localhost:8080 ./backend/e2e/run.sh
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VARSDIR="$ROOT/vars"
REPORT="$ROOT/report"
BASE_ENV="$VARSDIR/base.env"
GEN_ENV="$VARSDIR/generated.env"

HURL_BIN="${HURL_BIN:-hurl}"
command -v "$HURL_BIN" >/dev/null 2>&1 || HURL_BIN="$HOME/.local/bin/hurl"
if ! command -v "$HURL_BIN" >/dev/null 2>&1; then
  echo "ERRO: HURL não encontrado. Instale: https://hurl.dev/docs/installation.html" >&2
  exit 1
fi

# ── 1. Health check ─────────────────────────────────────────────────────────
if ! curl -sf -m 5 "$BASE_URL/v3/api-docs" -o /dev/null; then
  echo "ERRO: backend em $BASE_URL não respondeu GET /v3/api-docs." >&2
  echo "      Suba o backend antes:  make backend-run" >&2
  echo "      (neste ambiente: DB_URL=jdbc:postgresql://localhost:5433/nextcalendar make backend-run)" >&2
  exit 1
fi

# ── 2. Variáveis dinâmicas ─────────────────────────────────────────────────
mkdir -p "$VARSDIR" "$REPORT"

# Datas (GNU date). O profissional seed (João) atende apenas MONDAY e THURSDAY.
date_next_mon="$(date -d 'next monday' +%F)"
date_next_tue="$(date -d 'next tuesday' +%F)"
date_past="$(date -d '-1 day' +%F)"
# Datas "distantes" (sempre segundas, fora do almoço, folga de teardown >= 2h)
date_far="$(date -d "$date_next_mon +28 days" +%F)"   # blocked-times
date_far_tue="$(date -d "$date_far +1 day" +%F)"      # dia sem expediente (terça)
date_far2="$(date -d "$date_next_mon +35 days" +%F)"  # appointments
date_far3="$(date -d "$date_next_mon +42 days" +%F)"  # orders
date_far4="$(date -d "$date_next_mon +49 days" +%F)"  # photos / technical-sheet
date_far5="$(date -d "$date_next_mon +56 days" +%F)"  # jornada 14
date_far6="$(date -d "$date_next_mon +63 days" +%F)"  # folga para dados residuais

# run_id + datas → generated.env (sobrescrito a cada execução)
cat > "$GEN_ENV" <<EOF
date_next_mon=$date_next_mon
date_next_tue=$date_next_tue
date_past=$date_past
date_far=$date_far
date_far_tue=$date_far_tue
date_far2=$date_far2
date_far3=$date_far3
date_far4=$date_far4
date_far5=$date_far5
date_far6=$date_far6
dt_ok=${date_next_mon}T10:00:00
dt_lunch=${date_next_mon}T12:15:00
dt_outside=${date_next_mon}T07:00:00
dt_past=${date_past}T10:00:00
dt_far=${date_far2}T10:00:00
dt_far_b=${date_far2}T11:00:00
dt_far_r=${date_far2}T16:00:00
dt_block=${date_far}T16:00:00
dt_block_end=${date_far}T17:00:00
dt_far_tue=${date_far_tue}T10:00:00
dt_far_tue_end=${date_far_tue}T11:00:00
dt_block2=${date_far2}T14:00:00
dt_block2_end=${date_far2}T15:00:00
dt_order=${date_far3}T10:00:00
dt_order2=${date_far3}T11:00:00
dt_order3=${date_far3}T14:00:00
dt_order4=${date_far3}T16:00:00
dt_photo=${date_far4}T10:00:00
dt_sheet=${date_far4}T16:00:00
dt_journey=${date_far5}T10:00:00
dt_residual=${date_far6}T10:00:00
fixtureDir=$ROOT/fixtures
EOF

# run_id + CNPJ/CPF válidos (dígitos verificadores) — únicos a cada execução.
# Cada arquivo .hurl tem o próprio estabelecimento: cnpj_NN / cpf_NN por arquivo.
python3 - >> "$GEN_ENV" <<'PY'
import random, uuid

def cnpj():
    b = [random.randint(0, 9) for _ in range(8)] + [0, 0, 0, 1]
    def dv(nums, weights):
        s = sum(n * w for n, w in zip(nums, weights))
        r = s % 11
        return 0 if r < 2 else 11 - r
    d1 = dv(b, [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2])
    d2 = dv(b + [d1], [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2])
    return "".join(map(str, b + [d1, d2]))

def cpf():
    b = [random.randint(0, 9) for _ in range(9)]
    def dv(nums, weights):
        s = sum(n * w for n, w in zip(nums, weights))
        r = s % 11
        return 0 if r < 2 else 11 - r
    d1 = dv(b, [10, 9, 8, 7, 6, 5, 4, 3, 2])
    d2 = dv(b + [d1], [11, 10, 9, 8, 7, 6, 5, 4, 3, 2])
    return "".join(map(str, b + [d1, d2]))

print(f"run_id={uuid.uuid4()}")
# phones de REGISTER são únicos na aplicação ( AuthService valida duplicidade )
import itertools
slots = ["02", "03a", "03b", "03c", "07", "08", "09", "10", "11", "12", "13", "14a", "14b", "15a", "15b", "15c"]
for s in slots:
    print(f'phone_{s}="519{"".join(str(random.randint(0, 9)) for _ in range(8))}"')
# nomes legados usados pelos arquivos 03 e 07
print(f'cnpj_auth="{cnpj()}"')   # 03-establishments
print(f'cnpj_prof="{cnpj()}"')   # 07-professionals
print(f'cpf_prof="{cpf()}"')     # 07-professionals
# um CNPJ/CPF por arquivo restante (08..15)
for n in range(8, 16):
    print(f'cnpj_{n:02d}="{cnpj()}"')
for n in range(8, 15):
    print(f'cpf_{n:02d}="{cpf()}"')
# arquivo 15 cria dois estabelecimentos + um profissional anônimo
print(f'cnpj_15b="{cnpj()}"')
print(f'cpf_15b="{cpf()}"')
print(f'cpf_15c="{cpf()}"')
PY

# ── 3. Executa a suíte ──────────────────────────────────────────────────────
FILES=("$@")
if [ ${#FILES[@]} -eq 0 ]; then
  FILES=("$ROOT"/*.hurl)
fi

echo "→ HURL contra $BASE_URL (${#FILES[@]} arquivo(s))"
"$HURL_BIN" --test \
  --variables-file "$BASE_ENV" \
  --variables-file "$GEN_ENV" \
  --report-html "$REPORT" \
  --report-json "$REPORT/json" \
  --color \
  "${FILES[@]}"
