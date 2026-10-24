# 03 — Estabelecimentos: registro MANAGER, CRUD, terms, trial e CEP
# Dados próprios: 1 manager por execução (CNPJ {{cnpj_auth}}).

# ── 1. register MANAGER com CNPJ + endereço → 201 ───────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "E2E Estabelecimento",
  "email": "e2e03-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "{{phone_03a}}",
  "whatsapp": "51999990100",
  "cnpj": "{{cnpj_auth}}",
  "cep": "90610010",
  "street": "Rua Voluntários da Pátria",
  "number": "1230",
  "neighborhood": "Santana",
  "city": "Porto Alegre",
  "state": "RS"
}
HTTP 201
[Captures]
mgr03_token: jsonpath "$.token"
mgr03_user_id: jsonpath "$.user.id"
[Asserts]
jsonpath "$.user.role" == "MANAGER"

# ── 2. establishment do owner → 200 ─────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/owner/{{mgr03_user_id}}
Authorization: Bearer {{mgr03_token}}
HTTP 200
[Captures]
e2e_est_id: jsonpath "$.id"
[Asserts]
jsonpath "$.ownerId" == "{{mgr03_user_id}}"
jsonpath "$.name" == "E2E Estabelecimento"
jsonpath "$.cnpj" == "{{cnpj_auth}}"
jsonpath "$.trialActive" == true
jsonpath "$.termsAccepted" == true
jsonpath "$.active" == true

# ── 3. GET por id → 200 ─────────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e_est_id}}
HTTP 200
[Asserts]
jsonpath "$.id" == "{{e2e_est_id}}"
jsonpath "$.address.cep" exists
jsonpath "$.address.city" exists

# ── 4. GET id inexistente → 404 ─────────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{missing_uuid}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 5. GET owner inexistente → 404 ──────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/owner/{{missing_uuid}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 6. PUT (name/phone) → 200 ───────────────────────────────────────────────
PUT {{baseUrl}}/api/v1/establishments/{{e2e_est_id}}
Content-Type: application/json
{"name": "E2E Estabelecimento Renomeado", "phone": "(51) 3333-4444"}
HTTP 200
[Asserts]
jsonpath "$.name" == "E2E Estabelecimento Renomeado"
jsonpath "$.phone" == "(51) 3333-4444"
jsonpath "$.cnpj" == "{{cnpj_auth}}"

# ── 7. PATCH terms → 200 ────────────────────────────────────────────────────
PATCH {{baseUrl}}/api/v1/establishments/{{e2e_est_id}}/terms
HTTP 200
[Asserts]
jsonpath "$.termsAccepted" == true
jsonpath "$.termsAcceptedAt" exists

# ── 8. GET trial → 200 ──────────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e_est_id}}/trial
HTTP 200
[Asserts]
jsonpath "$.establishmentId" == "{{e2e_est_id}}"
jsonpath "$.daysRemaining" >= 25
jsonpath "$.trialActive" == true
jsonpath "$.trialExpired" == false

# ── 9. POST sem aceitar termos → 422 (field termsAccepted) ──────────────────
POST {{baseUrl}}/api/v1/establishments
Content-Type: application/json
{
  "ownerId": "{{mgr03_user_id}}",
  "legalName": "Outra LTDA",
  "name": "Outra Empresa",
  "cnpj": "11222333000181",
  "phone": "11999999999",
  "email": "outra-{{run_id}}@e2e.test",
  "address": {"cep": "01310100", "number": "100"},
  "termsAccepted": false
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "termsAccepted"

# ── 10. POST sem endereço → 422 (field address) ─────────────────────────────
POST {{baseUrl}}/api/v1/establishments
Content-Type: application/json
{
  "ownerId": "{{mgr03_user_id}}",
  "legalName": "Outra LTDA",
  "name": "Outra Empresa",
  "cnpj": "11222333000182",
  "phone": "11999999999",
  "email": "outrab-{{run_id}}@e2e.test",
  "termsAccepted": true
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "address"

# ── 11. register MANAGER com CNPJ do seed → 409 ─────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "Duplicado CNPJ",
  "email": "e2e03b-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "{{phone_03b}}",
  "cnpj": "{{seed_cnpj}}",
  "cep": "90610010",
  "street": "Rua X",
  "number": "10",
  "neighborhood": "Centro",
  "city": "Porto Alegre",
  "state": "RS"
}
HTTP 409
[Asserts]
body contains "CNPJ já cadastrado"

# ── 12. register MANAGER sem endereço → 400 ─────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "Sem Endereco",
  "email": "e2e03c-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "{{phone_03c}}",
  "cnpj": "{{cnpj_prof}}",
  "cep": "90610010"
}
HTTP 400
[Asserts]
body contains "Endereço completo é obrigatório"

# ── 13. GET /cep válido → 200 (ViaCEP, rede externa) ────────────────────────
GET {{baseUrl}}/api/v1/cep/{{valid_cep}}
HTTP 200
[Asserts]
jsonpath "$.cep" exists
jsonpath "$.localidade" exists

# ── 14. GET /cep inválido → 422 ─────────────────────────────────────────────
GET {{baseUrl}}/api/v1/cep/abc
HTTP 422
[Asserts]
body contains "CEP inválido"

# ── 15. DELETE (teardown) → 204 ─────────────────────────────────────────────
DELETE {{baseUrl}}/api/v1/establishments/{{e2e_est_id}}
HTTP 204
