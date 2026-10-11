# Suíte E2E (HURL)

Testes ponta a ponta contra o **backend real** (Spring Boot + PostgreSQL), escritos em
[HURL](https://hurl.dev). O plano original (cenários, ordem e status esperados) está em
`backend/specs/e2e-tests-plan.md`.

## Pré-requisitos

| Requisito | Como verificar |
|---|---|
| Backend no ar em `http://localhost:8080` | `curl -s localhost:8080/v3/api-docs` |
| Banco de dados (PostgreSQL) | `make db-up` / `make db-status` |
| HURL instalado | `hurl --version` ([instalação](https://hurl.dev/docs/installation.html)) |

Se o backend não responder, o script falha cedo com uma mensagem clara — nada de erros
confusos no meio da suíte.

## Como rodar

```bash
make backend-e2e                        # suíte inteira
make backend-e2e FILES=11-orders.hurl   # só um arquivo
make backend-e2e FILES="02-auth.hurl 14-attendance.hurl"   # vários

./backend/e2e/run.sh                    # mesmo resultado, sem o Make
./backend/e2e/run.sh 14-attendance.hurl # um arquivo pelo caminho completo
BASE_URL=http://localhost:8080 ./backend/e2e/run.sh
```

A suíte é **sequencial** e reexecutável: cada execução gera `run_id`, e-mails, telefones e
CNPJ/CPF únicos, então duas rodadas seguidas no mesmo banco ficam verdes.

## Estrutura

```
backend/e2e/
├── 01-health.hurl … 15-security.hurl  # um arquivo por domínio, na ordem do fluxo
├── run.sh                             # gera variáveis e executa o HURL
├── vars/
│   ├── base.env                       # valores FIXOS (seeds Flyway V2/V3) — versionado
│   └── generated.env                  # run_id + datas + CNPJ/CPF — gerado, ignorado no git
├── fixtures/photo.png                 # upload multipart do arquivo 13
└── report/                            # relatórios HTML/JSON — gerado, ignorado no git
```

### Arquivos

| Arquivo | Cobre |
|---|---|
| `01-health` | redirects do home para o Swagger, `/v3/api-docs` |
| `02-auth` | registro (CUSTOMER), login, troca de senha |
| `03-establishments` | registro MANAGER, CRUD, terms, trial e CEP |
| `04-services` / `05-products` | catálogo do estabelecimento seed |
| `06-clients` / `07-professionals` | CRUD, CPF, senha temporária, `MustChangePasswordFilter` |
| `08-working-hours` / `09-blocked-times` | expediente e bloqueios de agenda |
| `10-appointments` | disponibilidade, conflitos, cancel e reagendamento |
| `11-orders` | comanda: abertura, itens, desconto/pagamento e fechamento |
| `12-technical-sheets` / `13-photos` | ficha técnica e upload de fotos |
| `14-attendance` | consultas agregadas (profissional, gestor, cliente) e filtros |
| `15-security` | autenticação, allowlist de senha e isolamento por estabelecimento |

## Relatórios

Cada execução regenera:

* `backend/e2e/report/index.html` — relatório HTML (abrir no navegador)
* `backend/e2e/report/json/report.json` — mesmo conteúdo em JSON (útil para CI)

## Convenções de contrato

As asserções seguem o formato de erro documentado em
`GlobalExceptionHandler`:

| Status | Corpo | Asserção HURL |
|---|---|---|
| `400` / `403` / `404` / `409` | texto puro | `body contains "…"` |
| `422` | JSON array `[{field, message}]` | `jsonpath "$[0].field" == "campo"` |

Casos especiais já cobertos pela suíte: JSON com valor fora do domínio (ex.: enum
`"role":"HACKER"`) responde `422` com o `field` recuperado do payload; JSON malformado
responde `400` `Corpo da requisição mal formatado.`; datas inválidas nos filtros de
atendimento respondem `400` com `Período inválido: …`. Stack traces nunca aparecem no
corpo do erro (`spring.web.error.include-stacktrace=never`).

Regra prática: usar `jsonpath` apenas em corpo JSON — em `text/plain` ele falha.

## Datas

Os arquivos usam datas calculadas no `run.sh` (`date_far`, `dt_far2` …), sempre segundas
futuras e fora do almoço, porque o profissional seed só atende **segunda e quinta**.
Não fixar datas nos arquivos `.hurl`.
