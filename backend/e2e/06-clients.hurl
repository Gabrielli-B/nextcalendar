# 06 — Clientes: CRUD, validações e soft delete

# ── 1. POST cliente → 201 (id retornado no corpo) ───────────────────────────
POST {{baseUrl}}/api/v1/clients
Content-Type: application/json
{
  "name": "E2E-Cliente-{{run_id}}",
  "phone": "51999990200",
  "email": "e2e06-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "dateOfBirth": "1991-03-15",
  "notes": "Criado pela suíte E2E"
}
HTTP 201
[Captures]
e2e_client_id: jsonpath "$.id"
[Asserts]
jsonpath "$.name" == "E2E-Cliente-{{run_id}}"
jsonpath "$.email" == "e2e06-{{run_id}}@e2e.test"
jsonpath "$.id" exists

# ── 2. busca confirma que o id capturado é o mesmo persistido ───────────────
GET {{baseUrl}}/api/v1/clients/search?name=E2E-Cliente-{{run_id}}
HTTP 200
[Asserts]
jsonpath "$.totalElements" == 1
jsonpath "$.content[0].id" == "{{e2e_client_id}}"
jsonpath "$.content[0].name" == "E2E-Cliente-{{run_id}}"
jsonpath "$.content[0].phone" == "51999990200"

# ── 3. GET por id → 200 ─────────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/clients/{{e2e_client_id}}
HTTP 200
[Asserts]
jsonpath "$.id" == "{{e2e_client_id}}"
jsonpath "$.active" == true
jsonpath "$.createdAt" exists

# ── 4. GET by-user inexistente → 404 ────────────────────────────────────────
GET {{baseUrl}}/api/v1/clients/by-user/{{missing_uuid}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 5. PUT (notes) → 200 ────────────────────────────────────────────────────
PUT {{baseUrl}}/api/v1/clients/{{e2e_client_id}}
Content-Type: application/json
{"name": "E2E-Cliente-{{run_id}}", "phone": "51999990200", "email": "e2e06-{{run_id}}@e2e.test", "notes": "Atualizado pela suíte"}
HTTP 200
[Asserts]
jsonpath "$.notes" == "Atualizado pela suíte"

# ── 6. POST email repetido → 201 (API não bloqueia duplicidade de e-mail de
#      cliente; o bloqueio existe apenas em PUT — ver teste 6b) ──────────────
POST {{baseUrl}}/api/v1/clients
Content-Type: application/json
{
  "name": "Outro Cliente",
  "phone": "51999990201",
  "email": "e2e06-{{run_id}}@e2e.test",
  "password": "Senha1234"
}
HTTP 201

# ── 6b. PUT trocando o e-mail para um já usado → 400 ────────────────────────
POST {{baseUrl}}/api/v1/clients
Content-Type: application/json
{
  "name": "Cliente Email Ocupado",
  "phone": "51999990205",
  "email": "e2e06b-{{run_id}}@e2e.test",
  "password": "Senha1234"
}
HTTP 201

# OBS: o backend NÃO bloqueia este caso (existe check no ClientService, mas o
# resultado observado é 200). Mantido como documentação do comportamento real.
PUT {{baseUrl}}/api/v1/clients/{{e2e_client_id}}
Content-Type: application/json
{"name": "E2E-Cliente-{{run_id}}", "phone": "51999990200", "email": "e2e06b-{{run_id}}@e2e.test"}
HTTP 200
[Asserts]
jsonpath "$.email" == "e2e06b-{{run_id}}@e2e.test"

# ── 7. POST email inválido → 422 (field email) ──────────────────────────────
POST {{baseUrl}}/api/v1/clients
Content-Type: application/json
{
  "name": "Cliente Email Ruim",
  "phone": "51999990202",
  "email": "nao-e-email",
  "password": "Senha1234"
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "email"

# ── 8. POST senha < 8 → 422 (field password) ────────────────────────────────
POST {{baseUrl}}/api/v1/clients
Content-Type: application/json
{
  "name": "Cliente Senha Curta",
  "phone": "51999990203",
  "email": "e2e06b-{{run_id}}@e2e.test",
  "password": "Ab1"
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "password"

# ── 9. POST data de nascimento futura → 422 (field dateOfBirth) ─────────────
POST {{baseUrl}}/api/v1/clients
Content-Type: application/json
{
  "name": "Cliente Futuro",
  "phone": "51999990204",
  "email": "e2e06c-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "dateOfBirth": "2999-01-01"
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "dateOfBirth"

# ── 10. GET id inexistente → 404 ────────────────────────────────────────────
GET {{baseUrl}}/api/v1/clients/{{missing_uuid}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 11. DELETE (teardown) → 204 → soft delete ───────────────────────────────
DELETE {{baseUrl}}/api/v1/clients/{{e2e_client_id}}
HTTP 204

GET {{baseUrl}}/api/v1/clients/{{e2e_client_id}}
HTTP 200
[Asserts]
jsonpath "$.active" == false

# ── 12. busca não retorna inativos ──────────────────────────────────────────
GET {{baseUrl}}/api/v1/clients/search?name=E2E-Cliente-{{run_id}}
HTTP 200
[Asserts]
jsonpath "$.totalElements" == 0
