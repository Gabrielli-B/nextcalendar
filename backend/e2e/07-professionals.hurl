# 07 — Profissionais: criação com senha temporária, MustChangePasswordFilter
# Dados próprios: manager + estabelecimento próprios (CNPJ {{cnpj_prof}}).

# ── 1. register MANAGER próprio → 201 ───────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "E2E Barbearia 07",
  "email": "e2e07-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "{{phone_07}}",
  "cnpj": "{{cnpj_prof}}",
  "cep": "90610010",
  "street": "Rua Aurora",
  "number": "500",
  "neighborhood": "Cidade Baixa",
  "city": "Porto Alegre",
  "state": "RS"
}
HTTP 201
[Captures]
mgr07_token: jsonpath "$.token"
mgr07_user_id: jsonpath "$.user.id"

# ── 2. estabelecimento do manager → 200 ─────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/owner/{{mgr07_user_id}}
Authorization: Bearer {{mgr07_token}}
HTTP 200
[Captures]
e2e07_est_id: jsonpath "$.id"
[Asserts]
jsonpath "$.cnpj" == "{{cnpj_prof}}"

# ── 3. POST profissional (senha temporária) → 201 ───────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e07_est_id}}/professionals
Content-Type: application/json
Authorization: Bearer {{mgr07_token}}
{
  "name": "Prof-E2E-{{run_id}}",
  "nickname": "ProfE2E",
  "cpf": "{{cpf_prof}}",
  "email": "prof07-{{run_id}}@e2e.test",
  "phone": "51999990301",
  "gender": "M",
  "commission": 35
}
HTTP 201
[Captures]
temp_password: jsonpath "$.temporaryPassword"
[Asserts]
jsonpath "$.temporaryPassword" isString
jsonpath "$.email" == "prof07-{{run_id}}@e2e.test"

GET {{baseUrl}}/api/v1/establishments/{{e2e07_est_id}}/professionals/search?name=Prof-E2E-{{run_id}}
Authorization: Bearer {{mgr07_token}}
HTTP 200
[Captures]
e2e07_prof_id: jsonpath "$.content[0].id"

# ── 4. listagem contém o novo profissional ──────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e07_est_id}}/professionals
Authorization: Bearer {{mgr07_token}}
HTTP 200
[Asserts]
jsonpath "$.totalElements" >= 1
jsonpath "$.content[*].id" contains "{{e2e07_prof_id}}"

# ── 5. GET por id / active / search ─────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e07_est_id}}/professionals/{{e2e07_prof_id}}
Authorization: Bearer {{mgr07_token}}
HTTP 200
[Asserts]
jsonpath "$.active" == true
# o GET por id não devolve a chave temporaryPassword
jsonpath "$.temporaryPassword" not exists

GET {{baseUrl}}/api/v1/establishments/{{e2e07_est_id}}/professionals/active
Authorization: Bearer {{mgr07_token}}
HTTP 200
[Asserts]
jsonpath "$.content[*].id" contains "{{e2e07_prof_id}}"

GET {{baseUrl}}/api/v1/establishments/{{e2e07_est_id}}/professionals/search?name=Prof-E2E
Authorization: Bearer {{mgr07_token}}
HTTP 200
[Asserts]
jsonpath "$.totalElements" >= 1

# ── 6. CPF duplicado → 400 ──────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e07_est_id}}/professionals
Content-Type: application/json
Authorization: Bearer {{mgr07_token}}
{
  "name": "Duplicado CPF",
  "cpf": "{{cpf_prof}}",
  "email": "prof07b-{{run_id}}@e2e.test",
  "phone": "51999990302"
}
HTTP 400
[Asserts]
body contains "já está cadastrado"

# ── 7. CPF inválido → 422 (field cpf) ───────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e07_est_id}}/professionals
Content-Type: application/json
Authorization: Bearer {{mgr07_token}}
{
  "name": "CPF Invalido",
  "cpf": "11111111111",
  "email": "prof07c-{{run_id}}@e2e.test",
  "phone": "51999990303"
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "cpf"

# ── 8. login com senha temporária → mustChangePassword=true ─────────────────
POST {{baseUrl}}/api/v1/auth/login
Content-Type: application/json
{"email": "prof07-{{run_id}}@e2e.test", "password": "{{temp_password}}"}
HTTP 200
[Captures]
prof07_token: jsonpath "$.token"
[Asserts]
jsonpath "$.user.role" == "PROFESSIONAL"
jsonpath "$.user.mustChangePassword" == true

# ── 9. GET /me com senha pendente → 403 JSON do MustChangePasswordFilter ────
GET {{baseUrl}}/api/v1/professionals/me
Authorization: Bearer {{prof07_token}}
HTTP 403
[Asserts]
jsonpath "$.status" == 403
jsonpath "$.error" == "Forbidden"
jsonpath "$.message" contains "trocar sua senha"

# ── 10. troca de senha → 204 ────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/change-password
Content-Type: application/json
Authorization: Bearer {{prof07_token}}
{"currentPassword": "{{temp_password}}", "newPassword": "SenhaNova123"}
HTTP 204

# ── 11. GET /me depois da troca → 200 ───────────────────────────────────────
GET {{baseUrl}}/api/v1/professionals/me
Authorization: Bearer {{prof07_token}}
HTTP 200
[Captures]
prof07_me_id: jsonpath "$.id"
[Asserts]
jsonpath "$.id" == "{{e2e07_prof_id}}"
jsonpath "$.name" == "Prof-E2E-{{run_id}}"
jsonpath "$.establishmentId" == "{{e2e07_est_id}}"
jsonpath "$.establishmentName" == "E2E Barbearia 07"

# ── 12. PUT /admin (phone) → 200 ────────────────────────────────────────────
PUT {{baseUrl}}/api/v1/establishments/{{e2e07_est_id}}/professionals/{{e2e07_prof_id}}/admin
Content-Type: application/json
Authorization: Bearer {{mgr07_token}}
{
  "name": "Prof-E2E-{{run_id}}",
  "cpf": "{{cpf_prof}}",
  "email": "prof07-{{run_id}}@e2e.test",
  "phone": "51999990399",
  "commission": 40
}
HTTP 200
[Asserts]
jsonpath "$.phone" == "51999990399"
jsonpath "$.commission" == 40

# ── 13. PUT self (name) → 200 ───────────────────────────────────────────────
PUT {{baseUrl}}/api/v1/establishments/{{e2e07_est_id}}/professionals/{{e2e07_prof_id}}
Content-Type: application/json
Authorization: Bearer {{prof07_token}}
{
  "name": "Profissional E2E Renomeado",
  "cpf": "{{cpf_prof}}",
  "email": "prof07-{{run_id}}@e2e.test",
  "phone": "51999990399"
}
HTTP 200
[Asserts]
jsonpath "$.name" == "Profissional E2E Renomeado"
jsonpath "$.temporaryPassword" == null

# ── 14. agenda do próprio profissional → 200 ────────────────────────────────
GET {{baseUrl}}/api/v1/professionals/me/appointments
Authorization: Bearer {{prof07_token}}
HTTP 200
[Asserts]
jsonpath "$" isList

# ── 15. by-user inexistente → 404 ───────────────────────────────────────────
GET {{baseUrl}}/api/v1/professionals/by-user/{{missing_uuid}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 16. DELETE (teardown) → 204 → soft delete ───────────────────────────────
DELETE {{baseUrl}}/api/v1/establishments/{{e2e07_est_id}}/professionals/{{e2e07_prof_id}}
Authorization: Bearer {{mgr07_token}}
HTTP 204

GET {{baseUrl}}/api/v1/establishments/{{e2e07_est_id}}/professionals/{{e2e07_prof_id}}
Authorization: Bearer {{mgr07_token}}
HTTP 200
[Asserts]
jsonpath "$.active" == false

GET {{baseUrl}}/api/v1/establishments/{{e2e07_est_id}}/professionals/active
Authorization: Bearer {{mgr07_token}}
HTTP 200
[Asserts]
jsonpath "$.content[*].id" not contains "{{e2e07_prof_id}}"
