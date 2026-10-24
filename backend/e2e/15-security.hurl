# 15 — Segurança: autenticação, MustChangePasswordFilter e isolamento por estabelecimento

# ── setup: manager + estabelecimento próprios ───────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "E2E Barbearia 15",
  "email": "e2e15-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "{{phone_15a}}",
  "cnpj": "{{cnpj_15}}",
  "cep": "90610010",
  "street": "Rua Dr. Timóteo",
  "number": "90",
  "neighborhood": "Petrópolis",
  "city": "Porto Alegre",
  "state": "RS"
}
HTTP 201
[Captures]
mgr15_token: jsonpath "$.token"
mgr15_user_id: jsonpath "$.user.id"

GET {{baseUrl}}/api/v1/establishments/owner/{{mgr15_user_id}}
Authorization: Bearer {{mgr15_token}}
HTTP 200
[Captures]
e2e15_est_id: jsonpath "$.id"

# ── 1. sem token: rotas que exigem usuário → 403; POST professionals → 201 ──
GET {{baseUrl}}/api/v1/professionals/me
HTTP 403
[Asserts]
body contains "Usuário não autenticado."

# OBS: a API aceita criação de profissional sem token (furo de segurança —
# o service só restringe quando há usuário autenticado). Documentado aqui.
POST {{baseUrl}}/api/v1/establishments/{{e2e15_est_id}}/professionals
Content-Type: application/json
{
  "name": "Sem Token",
  "cpf": "{{cpf_15b}}",
  "email": "prof15-{{run_id}}@e2e.test",
  "phone": "51999991101"
}
HTTP 201

# ── 2. token malformado/lixo → 403 ──────────────────────────────────────────
GET {{baseUrl}}/api/v1/professionals/me
Authorization: Bearer token-invalido-{{run_id}}
HTTP 403
[Asserts]
body contains "Usuário não autenticado."

GET {{baseUrl}}/api/v1/professionals/me
Authorization: Bearer {{run_id}}
HTTP 403
[Asserts]
body contains "Usuário não autenticado."

# ── 3. MustChangePasswordFilter bloqueia rotas fora da allowlist ────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "E2E Profissional 15",
  "email": "e2e15p-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "{{phone_15b}}",
  "cnpj": "{{cnpj_15b}}",
  "cep": "90610010",
  "street": "Rua Comendador Coruja",
  "number": "12",
  "neighborhood": "Centro Histórico",
  "city": "Porto Alegre",
  "state": "RS"
}
HTTP 201
[Captures]
mgr15b_token: jsonpath "$.token"
mgr15b_user_id: jsonpath "$.user.id"

GET {{baseUrl}}/api/v1/establishments/owner/{{mgr15b_user_id}}
Authorization: Bearer {{mgr15b_token}}
HTTP 200
[Captures]
e2e15b_est_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e15b_est_id}}/professionals
Content-Type: application/json
Authorization: Bearer {{mgr15b_token}}
{
  "name": "Prof-Senha-{{run_id}}",
  "cpf": "{{cpf_15c}}",
  "email": "prof15b-{{run_id}}@e2e.test",
  "phone": "51999991103",
  "commission": 25
}
HTTP 201
[Captures]
temp15_password: jsonpath "$.temporaryPassword"

GET {{baseUrl}}/api/v1/establishments/{{e2e15b_est_id}}/professionals/search?name=Prof-Senha-{{run_id}}
Authorization: Bearer {{mgr15b_token}}
HTTP 200
[Captures]
e2e15b_prof_id: jsonpath "$.content[0].id"

POST {{baseUrl}}/api/v1/auth/login
Content-Type: application/json
{"email": "prof15b-{{run_id}}@e2e.test", "password": "{{temp15_password}}"}
HTTP 200
[Captures]
prof15_token: jsonpath "$.token"
[Asserts]
jsonpath "$.user.mustChangePassword" == true

# rota fora da allowlist → bloqueada com JSON 403
GET {{baseUrl}}/api/v1/establishments/{{e2e15b_est_id}}/professionals/{{e2e15b_prof_id}}/working-hours
Authorization: Bearer {{prof15_token}}
HTTP 403
[Asserts]
jsonpath "$.status" == 403
jsonpath "$.message" contains "trocar sua senha"

# allowlist: change-password e login passam
POST {{baseUrl}}/api/v1/auth/change-password
Content-Type: application/json
Authorization: Bearer {{prof15_token}}
{"currentPassword": "{{temp15_password}}", "newPassword": "SenhaNova123"}
HTTP 204

GET {{baseUrl}}/api/v1/establishments/{{e2e15b_est_id}}/professionals/{{e2e15b_prof_id}}/working-hours
Authorization: Bearer {{prof15_token}}
HTTP 200
[Asserts]
jsonpath "$" isList

# ── 4. role inválido no registro → 422 ──────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "Role Invalida",
  "email": "e2e15r-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "HACKER",
  "phone": "51999991104"
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "role"

# ── 5. profissional não gerencia outro estabelecimento → 403 ────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e15_est_id}}/professionals
Content-Type: application/json
Authorization: Bearer {{prof15_token}}
{
  "name": "Intruso",
  "cpf": "{{cpf_15b}}",
  "email": "intruso-{{run_id}}@e2e.test",
  "phone": "51999991105"
}
HTTP 403
[Asserts]
body contains "Profissionais não têm permissão"

# ── 6. gestor não enxerga comandas de outro estabelecimento → 404 ───────────
GET {{baseUrl}}/api/v1/establishments/{{e2e15b_est_id}}/orders/{{missing_uuid}}
Authorization: Bearer {{mgr15_token}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 7. cliente não acessa fotos → 403 ───────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "Cliente Fotos",
  "email": "e2e15c-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "CUSTOMER",
  "phone": "{{phone_15c}}"
}
HTTP 201
[Captures]
cust15_token: jsonpath "$.token"

GET {{baseUrl}}/api/v1/appointments/{{missing_uuid}}/photos
Authorization: Bearer {{cust15_token}}
HTTP 403
[Asserts]
body contains "Clientes não têm permissão"

GET {{baseUrl}}/api/v1/clients/{{missing_uuid}}/photos
Authorization: Bearer {{cust15_token}}
HTTP 403
[Asserts]
body contains "Clientes não têm permissão"

# ── 8. JSON malformado → 400 ────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/login
Content-Type: application/json
`{"email": "x@y.test", "password":`
HTTP 400

# ── 9. CNPJ inválido no registro MANAGER → 400 ──────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "CNPJ Ruim",
  "email": "e2e15n-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "51999991107",
  "cnpj": "11111111111111",
  "cep": "90610010",
  "street": "Rua X",
  "number": "1",
  "neighborhood": "Centro",
  "city": "Porto Alegre",
  "state": "RS"
}
HTTP 400
[Asserts]
body contains "CNPJ inválido"

# ── 10. endpoints públicos continuam acessíveis sem token ───────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e15_est_id}}/services
HTTP 200
[Asserts]
jsonpath "$.content" isList

GET {{baseUrl}}/v3/api-docs
HTTP 200
