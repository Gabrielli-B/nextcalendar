# Plano de Implementação — Testes E2E com HURL

> **Status:** plano (ainda não implementado)
> **Ferramenta:** [HURL](https://hurl.dev) 8.0.1 (instalado em `/usr/bin/hurl`)
> **Alvo:** backend Spring Boot em `http://localhost:8080` (profile default, PostgreSQL + Flyway)

---

## 1. Objetivo

Criar uma suíte de testes ponta a ponta (E2E) em `backend/e2e/` que exercite a **API REST real**
(HTTP, sem MockMvc), cobrindo:

1. Fluxos completos de negócio (jornada do cliente → agendamento → comanda → atendimento);
2. CRUDs de todos os recursos expostos pelos 16 controllers;
3. Matriz de autorização (papéis CUSTOMER / MANAGER / PROFESSIONAL / anônimo);
4. Tratamento de erros (400/403/404/409/422) conforme os contratos documentados nos services.

Os testes rodam contra o backend de **produção real** (`spring-boot:run` ou jar), com o
PostgreSQL do `docker-compose.yml` — não há mock de camada nenhuma.

---

## 2. Pré-requisitos e execução

| Requisito | Detalhe |
|---|---|
| HURL | `>= 8.0` (usa `newUuid`/`newDate`) |
| Backend no ar | `make backend-run` (porta 8080) |
| Banco | `make db-up` (Postgres `nextcalendar-db` healthy) |
| Dados de seed | Flyway `V1` + `V2` aplicados (IDs fixos, ver §4) |

**Comando alvo** (novo, no `Makefile` da raiz):

```make
backend-e2e: ## Roda a suíte E2E (HURL) — exige backend rodando
	hurl --test --glob 'backend/e2e/**/*.hurl' \
	     --variables-file backend/e2e/vars/generated.env \
	     --report-html backend/e2e/report
```

O script `backend/e2e/run.sh` (entrada recomendada) faz:

1. **Health check** — aborta com mensagem amigável se `GET /v3/api-docs` não responder 200;
2. **Gera variáveis dinâmicas** em `backend/e2e/vars/generated.env` (§5): datas futuras,
   CNPJ/CPF únicos e válidos a cada execução;
3. Invoca `hurl --test` com `--variables-file` + `--report-html`;
4. Exit code ≠ 0 se qualquer assert falhar (pronto para CI).

> **Decisão de execução:** arquivos rodam **em paralelo** (`--test` é paralelo por padrão).
> Cada arquivo é autocontido (§4) — nenhum arquivo depende da saída de outro — exceto a
> sequência opcional `10` → `11` documentada em §6. Se o paralelismo causar contenção de
> slots de agendamento, cair para sequencial (`hurl --test --no-parallel`... confirmar flag
> exata na 8.0.1 durante implementação).

---

## 3. Estrutura proposta

```
backend/e2e/
├── README.md                  # como rodar, variáveis, convenções
├── run.sh                     # health check + gera vars + invoca hurl
├── vars/
│   ├── base.env               # baseUrl, valores "fixos" (IDs de seed)
│   └── generated.env          # gerado no runtime (gitignored)
├── fixtures/
│   └── photo.png              # PNG 1×1 (upload multipart e base64)
├── report/                    # saída --report-html (gitignored)
├── 01-health.hurl
├── 02-auth.hurl
├── 03-establishments.hurl
├── 04-services.hurl
├── 05-products.hurl
├── 06-clients.hurl
├── 07-professionals.hurl
├── 08-working-hours.hurl
├── 09-blocked-times.hurl
├── 10-appointments.hurl
├── 11-orders.hurl
├── 12-technical-sheet.hurl
├── 13-photos.hurl
├── 14-attendance-journey.hurl   # jornada completa (flagship)
└── 15-security.hurl             # matriz de autorização
```

---

## 4. Estratégia de dados (crítico para idempotência)

### 4.1 Regra de ouro: **nunca mutar dados de seed**

O Flyway `V2` semeia IDs fixos que toda a suíte (e o frontend) assume:

| Recurso | UUID fixo |
|---|---|
| Estabelecimento | `11111111-1111-1111-1111-111111111111` |
| Profissional (João) | `aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa` |
| Serviços (Corte Degradê / Barba) | `22222222-...-2221` / `...-2222` |
| Produtos (Pomada / Óleo / Shampoo) | `33333333-...-3333` / `...-3334` / `...-3335` |
| Cliente (Maria) | `44444444-4444-4444-4444-444444444444` |
| Agendamento (15/12/2026 14:00) | `55555555-5555-5555-5555-555555555555` |

O agendamento seed **não pode** ser usado nos testes de comanda: `POST .../order/finish`
muda o status para `DONE` permanentemente e a segunda execução da suíte falharia
(`validateOpen` → 400). Cada teste que muta **cria seu próprio registro**.

### 4.2 Autocontenção por arquivo

- Cada `.hurl` cria os dados que precisa (capturando IDs via `[Captures]`) e, quando
  possível, **faz teardown no próprio arquivo** (DELETE/cancel ao final);
- Unicidade garantida por `{{newUuid}}` (e-mails) e pelas variáveis geradas (CNPJ/CPF);
- IDs de seed entram via `--variables-file` (`est_id`, `prof_id`, `service_id`,
  `product_id`, `client_id`, `appt_seed_id`).

### 4.3 Datas dinâmicas

O HURL **não tem aritmética de datas** (só `newUuid` e `newDate`). `run.sh` gera:

| Variável | Cálculo (GNU date) | Uso |
|---|---|---|
| `date_next_mon` | `date -d 'next monday' +%F` | dia com expediente do seed (seg/qui) |
| `date_next_thu` | próxima quinta | alternativa |
| `date_future` | `date -d '+30 days' +%F` | agendamentos distantes |
| `date_past` | `date -d '-1 day' +%F` | asserts de rejeição |
| `dt_ok` | `${date_next_mon}T10:00:00` | criação válida (fora do almoço 12–13) |
| `dt_lunch` | `${date_next_mon}T12:15:00` | rejeição "intervalo de almoço" |
| `dt_outside` | `${date_next_mon}T07:00:00` | rejeição "fora do expediente" |
| `dt_past` | `${date_past}T10:00:00` | rejeição "já passou" |
| `dt_far` | `${date_future}T10:00:00` | cancelamento (≥2h de antecedência, `MIN_CANCEL_HOURS=2`) |

Obs.: o profissional seed só tem expediente **segunda e quinta, 09:00–19:00, almoço
12:00–13:00** (`working_hours`). Slots avançam a cada 15 min (`SLOT_STEP_MINUTES`).

---

## 5. Padrões HURL a adotar

### 5.1 Variáveis e options

```hurl
[Options]
variable: baseUrl=http://localhost:8080
```

Na prática `baseUrl` vem do `--variable baseUrl=...` (permitindo testar outro host).

### 5.2 Captura de token

```hurl
POST {{baseUrl}}/api/v1/auth/register
{
  "name": "Cliente E2E",
  "email": "{{newUuid}}@e2e.test",
  "password": "Senha1234",
  "role": "CUSTOMER",
  "phone": "51999990000"
}
HTTP 201
[Captures]
token: jsonpath "$.token"
user_id: jsonpath "$.user.id"

POST {{baseUrl}}/api/v1/auth/login
{ "email": "...", "password": "..." }
HTTP 200
Authorization: Bearer {{token}}
```

### 5.3 Formatos de erro (contratos confirmados no `GlobalExceptionHandler`)

| Status | Corpo | Assert pattern |
|---|---|---|
| 400 | **texto puro** (BusinessException) | `body contains "Email ou senha inválidos"` |
| 404 | texto puro (EntityNotFound) | `HTTP 404` |
| 409 | texto puro (Duplicate) | `body contains "Email já cadastrado"` |
| 422 | **JSON array** `[{field, message}]` | `jsonpath "$[0].field" == "email"` |
| 403 | texto puro (AccessDenied) **ou** JSON `{status,error,message}` no `MustChangePasswordFilter` | `body contains "..."/ jsonpath "$.message" contains "trocar sua senha"` |

> Atenção: `jsonpath` em resposta `text/plain` falha — usar `body contains` nos 400/404/409/403.

### 5.4 Autenticação

- Rotas de escrita são `permitAll` no `SecurityConfig`; a checagem acontece **nos services**
  (`SecurityUtils`). Anônimo passa nos CRUDs de serviços/produtos/etc. Isso é comportamento
  atual do sistema e deve ser **documentado como teste**, não "consertado" na suíte;
- O `MustChangePasswordFilter` devolve **403 JSON** para usuário com senha pendente em
  qualquer rota fora de `ALLOWED_PATHS` (auth/logout, login, register, change-password,
  swagger-ui, v3/api-docs);
- `GET /api/v1/professionals/me` e endpoints de atendimento exigem token
  (`getRequiredAuthenticatedUser`) → anônimo = 403 "Usuário não autenticado."

---

## 6. Escopo detalhado por arquivo

Legenda de prioridade: **P0** = obrigatório na 1ª entrega; **P1** = segunda passada;
**P2** = opcional/externo.

### `01-health.hurl` — P0
| # | Requisição | Asserts |
|---|---|---|
| 1 | `GET /` | `302`, `header Location` contains `/swagger-ui/index.html` |
| 2 | `GET /api/v1` | `302` |
| 3 | `GET /v3/api-docs` | `200`, `jsonpath "$.openapi" exists`, `jsonpath "$.paths" exists` |
| 4 | `GET /swagger-ui/index.html` | `200` |

### `02-auth.hurl` — P0
Registro, login e troca de senha (usuário CUSTOMER próprio por arquivo).

| # | Cenário | Esperado |
|---|---|---|
| 1 | `POST /auth/register` CUSTOMER (email `{{newUuid}}`) | `201`, token, `role=="CUSTOMER"`, `mustChangePassword==false` |
| 2 | register mesmo email | `409` contains `Email já cadastrado` |
| 3 | register email inválido | `422`, `$[0].field=="email"` |
| 4 | register senha < 6 | `422`, field `password` |
| 5 | register sem phone | `422`, field `phone` |
| 6 | `POST /auth/login` OK | `200`, token, `user.email` |
| 7 | login senha errada | `400` contains `Email ou senha inválidos` |
| 8 | login email inexistente | `400` mesma mensagem (sem vazamento) |
| 9 | login payload inválido | `422` |
| 10 | `POST /auth/change-password` sem token | `400` contains `Token de autenticação ausente` |
| 11 | change-password senha atual errada | `400` contains `Senha atual incorreta` |
| 12 | change-password nova < 8 | `400` contains `mínimo 8` |
| 13 | change-password sem dígito | `400` contains `letra e um número` |
| 14 | change-password igual à atual | `400` contains `não pode ser igual` |
| 15 | change-password OK | `204` → login senha antiga `400` → login nova `200` |

### `03-establishments.hurl` — P0
CNPJ do manager vem de variável gerada (unicidade entre execuções).

| # | Cenário | Esperado |
|---|---|---|
| 1 | `POST /auth/register` **MANAGER** com cnpj+endereço completo | `201` + establishment criado |
| 2 | `GET /establishments/owner/{userId}` | `200`, captura `est_id`, `trialActive==true` |
| 3 | `GET /establishments/{est_id}` | `200`, campos (cnpj, termsAccepted, active…) |
| 4 | `GET /establishments/{uuid-aleatório}` | `404` |
| 5 | `GET /establishments/owner/{uuid-aleatório}` | `404` |
| 6 | `PUT /establishments/{est_id}` (name/phone) | `200` refletido |
| 7 | `PATCH /establishments/{est_id}/terms` | `200`, `termsAccepted==true`, `termsAcceptedAt` not null |
| 8 | `GET /establishments/{est_id}/trial` | `200`, `daysRemaining>=25`, `trialActive==true`, `trialExpired==false` |
| 9 | `POST /establishments` com `termsAccepted:false` | `422` field `termsAccepted` (`@AssertTrue`) |
| 10 | `POST /establishments` sem `address` | `422` field `address` |
| 11 | register MANAGER com CNPJ já usado (seed `00000000000000`) | `409` contains `CNPJ já cadastrado` |
| 12 | `POST /auth/register` MANAGER sem endereço | `400` contains `Endereço completo` |
| 13 | `GET /cep/01310100` | `200` (ViaCEP) — **P2**, rede externa; cobrir com assert tolerante ou `--no-test` no CI offline |
| 14 | `GET /cep/abc` | `422` (CepInvalidException) |
| 15 | `DELETE /establishments/{est_id}` | `204` → `GET` … **confirmar** se `getOrThrow` filtra `active=false` (soft delete) |

### `04-services.hurl` — P0 (seed establishment, criação própria + teardown)
| # | Cenário | Esperado |
|---|---|---|
| 1 | `GET .../services` | `200`, `totalElements >= 2` |
| 2 | `GET .../services/search?name=Corte` | `200`, contém `Corte Degradê` |
| 3 | `POST .../services` nome único (`{{newUuid}}` prefixado) | `201`, captura `service_id` |
| 4 | search pelo nome único | `totalElements==1` |
| 5 | `POST` mesmo nome | `400` contains `Já existe um serviço` |
| 6 | `POST` price `0`/negativo | `422` field `price` |
| 7 | `POST` name com 2 chars | `422` field `name` |
| 8 | `PUT .../services/{id}` (price) | `200` |
| 9 | `DELETE .../services/{id}` (teardown) | `204` → search `totalElements==0` |
| 10 | `DELETE` uuid aleatório | `404` |
| 11 | `GET .../services/{inexistente}` | **não existe GET por id** — cobrir apenas search |

### `05-products.hurl` — P0 (espelho de services)
CRUD + search + `stockQuantity==0` (422) + `price` negativo (422) + `DELETE` 204 +
404 em id aleatório. **Confirmar** comportamento de nome duplicado em produto
(`ProductService.create` — verificar duplicidade ativa) durante a implementação.

### `06-clients.hurl` — P0
| # | Cenário | Esperado |
|---|---|---|
| 1 | `POST /clients` (email único, senha ≥ 8, `dateOfBirth` passado) | `201` |
| 2 | **response não traz `id`** → `GET /clients/search?name=…` para capturar `client_id` | `200`, `content[0].id` |
| 3 | `GET /clients/{id}` | `200`, `active==true` |
| 4 | `GET /clients/search?name=…` | `200` |
| 5 | `GET /clients/by-user/{uuid-aleatório}` | `404` |
| 6 | `PUT /clients/{id}` (notes) | `200` |
| 7 | `POST /clients` email duplicado | `400` contains `já está cadastrado` |
| 8 | `POST` email inválido | `422` field `email` |
| 9 | `POST` senha < 8 | `422` field `password` |
| 10 | `POST` `dateOfBirth` futuro | `422` field `dateOfBirth` |
| 11 | `DELETE /clients/{id}` | `204` → `GET` ainda `200` com `active==false` (soft delete) |

### `07-professionals.hurl` — P0 (fluxo de senha temporária)
CPF único e **válido** (dígitos verificadores!) gerado por `run.sh`.

| # | Cenário | Esperado |
|---|---|---|
| 1 | `POST .../professionals` | `201`, captura `prof_id`, `temporaryPassword` (texto puro) |
| 2 | `GET .../professionals` | `200`, `totalElements >= 1` |
| 3 | `GET .../professionals/{id}` / `/active` / `/search?name=` | `200` |
| 4 | `POST` CPF duplicado | `400` contains `já está cadastrado` |
| 5 | `POST` CPF inválido (ex.: `11111111111`) | `422` field `cpf` (`@CPF`) |
| 6 | `POST` email duplicado | `422`/`400` (confirmar validação) |
| 7 | `POST /auth/login` com senha temporária | `200`, `mustChangePassword==true` |
| 8 | `GET /api/v1/professionals/me` com esse token | **`403` JSON** `message` contains `trocar sua senha` |
| 9 | `POST /auth/change-password` | `204` |
| 10 | `GET /professionals/me` de novo | `200`, dados do perfil |
| 11 | `PUT .../professionals/{id}/admin` (phone) | `200` |
| 12 | `PUT .../professionals/{id}` (self, name) | `200` |
| 13 | `DELETE .../professionals/{id}` (teardown) | `204` → list sem ele (**confirmar** soft/hard) |
| 14 | `GET /professionals/me/appointments` | `200` (lista; pode ser vazia) |
| 15 | `GET /professionals/by-user/{uuid}` | `404` |

### `08-working-hours.hurl` — P0
| # | Cenário | Esperado |
|---|---|---|
| 1 | `GET .../working-hours` (prof seed) | `200`, `length >= 2` (MONDAY, THURSDAY) |
| 2 | `POST` novo dia (ex.: `WEDNESDAY`) | `201`, captura `wh_id` |
| 3 | `PUT .../working-hours/{wh_id}` (horário) | `200` |
| 4 | `DELETE .../working-hours/{wh_id}` | `204` → `GET` `length` volta ao original |
| 5 | `DELETE` id aleatório | `404` |
| 6 | `POST` dia inválido (`"FOO"`) | `400` (enum) — confirmar mapeamento |
| 7 | `POST` profissional inexistente | `404` |

### `09-blocked-times.hurl` — P0
| # | Cenário | Esperado |
|---|---|---|
| 1 | `POST .../blocked-times` (data futura) | `201`, captura `block_id` |
| 2 | `GET .../blocked-times` | `200`, contém o motivo |
| 3 | `POST` sem `startDateTime` | `422` field `startDateTime` |
| 4 | `DELETE .../blocked-times/{block_id}` | `204` → `GET` sem ele |
| 5 | `DELETE` id aleatório | `404` |

### `10-appointments.hurl` — P0 (o mais denso)
| # | Cenário | Esperado |
|---|---|---|
| 1 | `GET .../appointments/available-slots?professionalId&serviceId&date=date_next_mon` | `200`, `serviceName=="Corte Degradê"`, `durationMinutes==40`, `slots` não vazio, captura `slot[0]` |
| 2 | available-slots em dia sem expediente (`date_next_mon + 1 dia`) | `404` |
| 3 | available-slots prof inexistente | `404` |
| 4 | `POST .../appointments` (`dt_ok`, `clientId` seed, `isFitIn:false`) | `201`, `status=="SCHEDULED"`, `endDateTime` = início + 40min, captura `appt_id` |
| 5 | `POST` mesmo horário (sobreposição) | `400` contains `já está ocupado` |
| 6 | `POST dt_past` | `400` contains `já passou` |
| 7 | `POST dt_outside` | `400` contains `fora do expediente` |
| 8 | `POST dt_lunch` | `400` contains `intervalo de almoço` |
| 9 | `POST` dentro de blocked-time (criar bloqueio antes) | `400` contains `bloqueado` |
| 10 | `POST` sem `professionalId` | `422` field `professionalId` |
| 11 | `POST` sem `serviceId` | `422` field `serviceId` |
| 12 | `GET .../appointments?date=…` | `200`, contém `appt_id`; filtro `professionalId` |
| 13 | `GET .../appointments/client/{client_id}` | `200`, contém `appt_id` |
| 14 | `PATCH .../appointments/{appt_id}/cancel` (usar `dt_far`) | `200`, `status=="CANCELLED"` |
| 15 | cancel de novo | `400` contains `já está cancelado` |
| 16 | `PUT .../reschedule` para horário futuro válido | `200`, novo horário, `status=="SCHEDULED"` |
| 17 | reschedule para o passado | `400` contains `já passou` |
| 18 | reschedule de cancelado | `400` contains `cancelado` |
| 19 | cancel/reschedule de uuid aleatório | `404` |
| 20 | cancel com < 2h (agendamento em `dt_ok` se executado no mesmo dia) | `400` contains `horas de antecedência` — **P1**, sensível ao horário da execução |

### `11-orders.hurl` — P0 (comanda completa)
Cria **próprio** agendamento (`dt_far`, `isFitIn:true` p/ ignorar disponibilidade) no
estabelecimento seed; não usa o agendamento seed (§4.1).

| # | Cenário | Esperado |
|---|---|---|
| 1 | `POST .../appointments/{novo}/order` | `200`, `status=="OPEN"`, `items[0].name=="Corte Degradê"`, `subtotal==70`, captura `order_id` e `item0_id` |
| 2 | repetir (idempotência do open) | `200`, **mesmo** `order_id` |
| 3 | `POST .../orders/{id}/items` PRODUT `33333333-…-3333` qty 2 | `200`, `items.length==2`, `subtotal==170` (70 + 2×50) |
| 4 | `POST` item qty `0` | `422` field `quantity` |
| 5 | `POST` item `itemId` aleatório | `404` contains `Serviço/Produto` |
| 6 | `DELETE .../items/{item0_id}` | `200`, `items.length` diminui |
| 7 | `PATCH .../orders/{id}` `{discountAmount: 10, paymentMethod: "PIX"}` | `200` refletido |
| 8 | `PATCH` desconto negativo | `422` field `discountAmount` |
| 9 | `POST .../finish` sem pagamento (novo pedido antes do 7) | `400` contains `forma de pagamento` |
| 10 | `POST .../finish` com itens vazios | `400` contains `ao menos um item` |
| 11 | `POST .../finish` (fluxo do 7) | `200`, `status=="CLOSED"`, `closedAt` not null |
| 12 | `POST .../items` depois de fechada | `400` (validateOpen — **confirmar mensagem**) |
| 13 | `GET .../orders/{order_id}` | `200` |
| 14 | `GET .../orders/{uuid-aleatório}` | `404` |
| 15 | `POST` order em outro `establishmentId` | `404` (cross-tenant) |
| 16 | `POST .../appointments/{cancelado}/order` | `400` contains `cancelado` |

### `12-technical-sheet.hurl` — P0
| # | Cenário | Esperado |
|---|---|---|
| 1 | `GET /clients/{client_seed}/technical-sheet` | `200` (auto-create), `entries==[]` |
| 2 | `PATCH` observations | `200`, persiste |
| 3 | `POST .../entries` com `appointmentId` seed (cliente confere) | `200`, `entries.length==1`, captura `entry_id` |
| 4 | `POST` com agendamento de outro cliente | `400` contains `não pertence` |
| 5 | `POST` agendamento inexistente | `404` |
| 6 | `GET` | `200`, entries 1 |
| 7 | `DELETE .../entries/{entry_id}` (teardown) | `200`, entries 0 |
| 8 | `DELETE` entry aleatória | `404` |
| 9 | visão do profissional (filtra entries alheias) | **P1** — requer token de profissional |

### `13-photos.hurl` — P0
Fixture `fixtures/photo.png`. Upload multipart do HURL:

```hurl
POST {{baseUrl}}/api/v1/appointments/{{appt_id}}/photos
Content-Type: multipart/form-data
Authorization: Bearer {{manager_token}}
file file=backend/e2e/fixtures/photo.png; type=image/png
string type=AFTER
string caption=E2E
HTTP 201
```

| # | Cenário | Esperado |
|---|---|---|
| 1 | upload sem token | `403` (getRequiredAuthenticatedUser) |
| 2 | upload como CUSTOMER | `403` contains `Clientes não têm permissão` |
| 3 | upload como MANAGER (estabelecimento próprio) | `201`, captura `photo_id` |
| 4 | `GET /appointments/{id}/photos` | `200`, contém `photo_id` |
| 5 | `GET /photos/{photo_id}` | `200`, `Content-Type image/png`, bytes |
| 6 | `GET /clients/{id}/photos` | `200` |
| 7 | upload agendamento inexistente | `404` |
| 8 | `DELETE /photos/{photo_id}` | `204` → `GET` `404` |
| 9 | `DELETE` uuid aleatório | `404` |
| 10 | `POST /api/v1/photos` (base64 legado) | `201`, `url` — **P1**, confirmar se exige auth |
| 11 | profissional de outro agendamento | `403` contains `próprios agendamentos` — **P1** |

### `14-attendance-journey.hurl` — P0 (jornada flagship)
Fluxo completo em **um arquivo**, com dados 100% próprios:

```
register MANAGER → establishment capturado
  → POST service (captura service_id)
  → POST professional (captura tempPassword) → login → change-password
  → POST working-hours para o dia de dt_far (7 dias da semana p/ robustez)
  → POST client (captura client_id)
  → POST appointment (dt_far, isFitIn:true)
  → POST order → PATCH pagamento → POST finish  → appointment DONE
  → GET  /api/v1/attendances                       (manager)   → contém, status DONE, orderStatus CLOSED
  → GET  /api/v1/professionals/me/attendances      (prof)      → contém
  → GET  /api/v1/clients/{id}/attendances          (manager)   → contém
  → filtros: ?status=DONE, ?from=&to=, ?clientId=
  → GET  /api/v1/professionals/me/appointments     (prof, com ?from=&to=)
  → negativos: anônimo → 403; CUSTOMER → 403 "Clientes não têm acesso";
               PROFESSIONAL em /api/v1/attendances → 403 "devem acessar seus atendimentos"
```

### `15-security.hurl` — P0
| # | Cenário | Esperado |
|---|---|---|
| 1 | `GET .../services` anônimo | `200` (permitAll documentado) |
| 2 | `GET /professionals/me` anônimo | `403` contains `não autenticado` |
| 3 | token inválido (`Bearer xyz`) em `/me` | `403` (filtro engole exceção → anônimo) |
| 4 | token expirado/lixo em rota com `MustChangePassword` | fluxo normal |
| 5 | PROFESSIONAL cria serviço | `403` contains `não têm permissão para cadastrar` |
| 6 | PROFESSIONAL agenda para outro profissional | `403` contains `para si mesmos` |
| 7 | PROFESSIONAL lê agenda de outro | `403` contains `visualizar agenda` |
| 8 | CUSTOMER em `/api/v1/attendances` | `403` |
| 9 | CUSTOMER upload de foto | `403` |
| 10 | MANAGER cross-establishment (foto/agendamento de outro est) | `403` contains `Acesso negado` |
| 11 | change-password ignora userId do payload (usa token) | `204` mesmo com userId diferente no path — **P1**, confirmar comportamento do `PasswordController` |

---

## 7. Riscos, pendências e decisões em aberto

| # | Item | Ação |
|---|---|---|
| 1 | Serialização `Page<Spring Data>` (shape exato de `content`/`totalElements`) | conferir com um `curl` na implementação |
| 2 | Mensagens exatas de 400 (`validateOpen`, produto duplicado) | ler services ou capturar via curl |
| 3 | `GET /establishments/{id}` após `DELETE` (soft vs 404) | conferir `getOrThrow` |
| 4 | ViaCEP (rede externa) — 422/503/latência | testes P2; marcar para pular em CI offline |
| 5 | Flags de paralelismo/sequencial do HURL 8.0.1 | `hurl --help` na implementação |
| 6 | CPF/CNPJ válidos gerados no `run.sh` | algoritmo de dígito verificador em bash/python |
| 7 | HURL não tem teardown garantido — falha no meio deixa lixo | teardown ao final de cada arquivo; unicidade por `{{newUuid}}` torna resíduo inofensivo |
| 8 | `date-past` no cancelamento sensível a horário (test P0-20 do arquivo 10) | manter como P1 |
| 9 | `professional/me/{userId}/password` pode não validar dono do token | P1, comportamento a confirmar |

---

## 8. Fases de implementação

| Fase | Entregável | Critério de aceite |
|---|---|---|
| **F0 — Infra** | `run.sh`, `vars/base.env`, `fixtures/photo.png`, alvo `backend-e2e` no Makefile, `.gitignore` (`vars/generated.env`, `report/`) | `./backend/e2e/run.sh` falha com mensagem clara se backend estiver fora do ar |
| **F1 — Fundação** | `01-health`, `02-auth`, `03-establishments` | 100% verdes; reexecução imediata sem conflito (unicidade) |
| **F2 — CRUDs** | `04`–`09` | idempotência: 2 execuções seguidas verdes |
| **F3 — Núcleo** | `10-appointments`, `11-orders`, `12-technical-sheet` | fluxo agendamento → comanda → ficha verde |
| **F4 — Jornada** | `13-photos`, `14-attendance-journey`, `15-security` | jornada completa e matriz de autorização verdes |
| **F5 — CI/docs** | HTML report, README do diretório, integração `make backend-e2e` + rodar após `make backend-test` | pipeline roda suíte inteira |

**Estimativa:** F0+F1 meio dia; F2 um dia; F3+F4 um dia; F5 algumas horas.

---

## 9. Referências internas (dúvidas → onde olhar)

| Dúvida | Arquivo |
|---|---|
| Contratos de erro | `exception/GlobalExceptionHandler.java` |
| Regras de disponibilidade/cancelamento | `service/AppointmentService.java` (§validação) |
| Ciclo de vida da comanda | `service/OrderService.java` |
| Papéis e checagens | `config/SecurityUtils.java` + `SecurityConfig.java` |
| Bloqueio de senha pendente | `config/MustChangePasswordFilter.java` |
| Seed (IDs fixos) | `resources/db/migration/V2__seed_default_establishment.sql` |
| Sintaxe HURL (captures, multipart, options) | https://hurl.dev/docs/templates.html / `docs/request.html` |
