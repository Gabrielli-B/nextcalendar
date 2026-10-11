# 08 — Horários de trabalho (CRUD no estabelecimento próprio)
# Setup próprio: manager + profissional; teardown: apaga os horários criados.

# ── setup: manager + estabelecimento + profissional ─────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "E2E Barbearia 08",
  "email": "e2e08-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "{{phone_08}}",
  "cnpj": "{{cnpj_08}}",
  "cep": "90610010",
  "street": "Rua das Flores",
  "number": "10",
  "neighborhood": "Menino Deus",
  "city": "Porto Alegre",
  "state": "RS"
}
HTTP 201
[Captures]
mgr08_token: jsonpath "$.token"
mgr08_user_id: jsonpath "$.user.id"

GET {{baseUrl}}/api/v1/establishments/owner/{{mgr08_user_id}}
Authorization: Bearer {{mgr08_token}}
HTTP 200
[Captures]
e2e08_est_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals
Content-Type: application/json
Authorization: Bearer {{mgr08_token}}
{
  "name": "Prof-Horarios-{{run_id}}",
  "cpf": "{{cpf_08}}",
  "email": "prof08-{{run_id}}@e2e.test",
  "phone": "51999990401",
  "commission": 30
}
HTTP 201

GET {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/search?name=Prof-Horarios-{{run_id}}
Authorization: Bearer {{mgr08_token}}
HTTP 200
[Captures]
e2e08_prof_id: jsonpath "$.content[0].id"

# ── 1. lista vazia ──────────────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/{{e2e08_prof_id}}/working-hours
Authorization: Bearer {{mgr08_token}}
HTTP 200
[Asserts]
jsonpath "$" isList
jsonpath "$" count == 0

# ── 2. POST segunda (com intervalo) → 201 ───────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/{{e2e08_prof_id}}/working-hours
Content-Type: application/json
Authorization: Bearer {{mgr08_token}}
{"dayOfWeek": "MONDAY", "startTime": "09:00:00", "endTime": "19:00:00", "breakStart": "12:00:00", "breakEnd": "13:00:00"}
HTTP 201
[Captures]
e2e08_wh_id: jsonpath "$.id"
[Asserts]
jsonpath "$.dayOfWeek" == "MONDAY"
jsonpath "$.startTime" == "09:00:00"
jsonpath "$.endTime" == "19:00:00"
jsonpath "$.professionalId" == "{{e2e08_prof_id}}"
jsonpath "$.active" == true

# ── 3. dia duplicado → 400 ──────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/{{e2e08_prof_id}}/working-hours
Content-Type: application/json
Authorization: Bearer {{mgr08_token}}
{"dayOfWeek": "MONDAY", "startTime": "10:00:00", "endTime": "12:00:00"}
HTTP 400
[Asserts]
body contains "Já existe um horário de trabalho cadastrado para MONDAY"

# ── 4. início >= fim → 400 ──────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/{{e2e08_prof_id}}/working-hours
Content-Type: application/json
Authorization: Bearer {{mgr08_token}}
{"dayOfWeek": "TUESDAY", "startTime": "19:00:00", "endTime": "09:00:00"}
HTTP 400
[Asserts]
body contains "início deve ser anterior ao horário de término"

# ── 5. dayOfWeek ausente → 422 (field dayOfWeek) ────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/{{e2e08_prof_id}}/working-hours
Content-Type: application/json
Authorization: Bearer {{mgr08_token}}
{"startTime": "09:00:00", "endTime": "19:00:00"}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "dayOfWeek"

# ── 6. segunda dia (terça, sem intervalo) → 201 ─────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/{{e2e08_prof_id}}/working-hours
Content-Type: application/json
Authorization: Bearer {{mgr08_token}}
{"dayOfWeek": "TUESDAY", "startTime": "08:00:00", "endTime": "12:00:00"}
HTTP 201
[Captures]
e2e08_wh_tue_id: jsonpath "$.id"
[Asserts]
jsonpath "$.breakStart" == null

# ── 7. lista agora tem 2 ────────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/{{e2e08_prof_id}}/working-hours
Authorization: Bearer {{mgr08_token}}
HTTP 200
[Asserts]
jsonpath "$" count == 2
jsonpath "$[*].dayOfWeek" contains "MONDAY"
jsonpath "$[*].dayOfWeek" contains "TUESDAY"

# ── 8. PUT (horário de fim da segunda) → 200 ────────────────────────────────
PUT {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/{{e2e08_prof_id}}/working-hours/{{e2e08_wh_id}}
Content-Type: application/json
Authorization: Bearer {{mgr08_token}}
{"endTime": "18:00:00"}
HTTP 200
[Asserts]
jsonpath "$.endTime" == "18:00:00"

# ── 9. PUT para dia já usado → 400 ──────────────────────────────────────────
PUT {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/{{e2e08_prof_id}}/working-hours/{{e2e08_wh_tue_id}}
Content-Type: application/json
Authorization: Bearer {{mgr08_token}}
{"dayOfWeek": "MONDAY"}
HTTP 400
[Asserts]
body contains "Já existe um horário de trabalho cadastrado para MONDAY"

# ── 10. DELETE terça → 204 → lista com 1 ────────────────────────────────────
DELETE {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/{{e2e08_prof_id}}/working-hours/{{e2e08_wh_tue_id}}
Authorization: Bearer {{mgr08_token}}
HTTP 204

GET {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/{{e2e08_prof_id}}/working-hours
Authorization: Bearer {{mgr08_token}}
HTTP 200
[Asserts]
jsonpath "$" count == 1

# ── 11. DELETE id inexistente → 404 ─────────────────────────────────────────
DELETE {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/{{e2e08_prof_id}}/working-hours/{{missing_uuid}}
Authorization: Bearer {{mgr08_token}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 12. lista de profissional inexistente → 404 ─────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/{{missing_uuid}}/working-hours
Authorization: Bearer {{mgr08_token}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── teardown: apaga o horário restante ──────────────────────────────────────
DELETE {{baseUrl}}/api/v1/establishments/{{e2e08_est_id}}/professionals/{{e2e08_prof_id}}/working-hours/{{e2e08_wh_id}}
Authorization: Bearer {{mgr08_token}}
HTTP 204
