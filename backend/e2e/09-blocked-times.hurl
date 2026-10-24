# 09 — Bloqueios de agenda (dentro do expediente cadastrado)
# Setup próprio: manager + profissional + expediente de segunda.

# ── setup: manager + estabelecimento + profissional ─────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "E2E Barbearia 09",
  "email": "e2e09-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "{{phone_09}}",
  "cnpj": "{{cnpj_09}}",
  "cep": "90610010",
  "street": "Av. Ipiranga",
  "number": "700",
  "neighborhood": "República",
  "city": "Porto Alegre",
  "state": "RS"
}
HTTP 201
[Captures]
mgr09_token: jsonpath "$.token"
mgr09_user_id: jsonpath "$.user.id"

GET {{baseUrl}}/api/v1/establishments/owner/{{mgr09_user_id}}
Authorization: Bearer {{mgr09_token}}
HTTP 200
[Captures]
e2e09_est_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals
Content-Type: application/json
Authorization: Bearer {{mgr09_token}}
{
  "name": "Prof-Bloqueios-{{run_id}}",
  "cpf": "{{cpf_09}}",
  "email": "prof09-{{run_id}}@e2e.test",
  "phone": "51999990501",
  "commission": 30
}
HTTP 201

GET {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/search?name=Prof-Bloqueios-{{run_id}}
Authorization: Bearer {{mgr09_token}}
HTTP 200
[Captures]
e2e09_prof_id: jsonpath "$.content[0].id"

POST {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/{{e2e09_prof_id}}/working-hours
Content-Type: application/json
Authorization: Bearer {{mgr09_token}}
{"dayOfWeek": "MONDAY", "startTime": "09:00:00", "endTime": "19:00:00", "breakStart": "12:00:00", "breakEnd": "13:00:00"}
HTTP 201
[Captures]
e2e09_wh_id: jsonpath "$.id"

# ── 1. lista vazia ──────────────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/{{e2e09_prof_id}}/blocked-times
Authorization: Bearer {{mgr09_token}}
HTTP 200
[Asserts]
jsonpath "$" count == 0

# ── 2. POST bloqueio dentro do expediente → 201 ─────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/{{e2e09_prof_id}}/blocked-times
Content-Type: application/json
Authorization: Bearer {{mgr09_token}}
{"startDateTime": "{{dt_block}}", "endDateTime": "{{dt_block_end}}", "reason": "Reunião E2E"}
HTTP 201
[Captures]
e2e09_block_id: jsonpath "$.id"
[Asserts]
jsonpath "$.reason" == "Reunião E2E"
jsonpath "$.professionalId" == "{{e2e09_prof_id}}"

# ── 3. sobreposto → 400 ─────────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/{{e2e09_prof_id}}/blocked-times
Content-Type: application/json
Authorization: Bearer {{mgr09_token}}
{"startDateTime": "{{date_far}}T16:30:00", "endDateTime": "{{date_far}}T17:30:00"}
HTTP 400
[Asserts]
body contains "Já existe um bloqueio cadastrado neste horário"

# ── 4. início >= fim → 400 ──────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/{{e2e09_prof_id}}/blocked-times
Content-Type: application/json
Authorization: Bearer {{mgr09_token}}
{"startDateTime": "{{date_far}}T18:00:00", "endDateTime": "{{date_far}}T17:00:00"}
HTTP 400
[Asserts]
body contains "início deve ser anterior ao horário de término"

# ── 5. dia sem expediente (terça) → 400 ─────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/{{e2e09_prof_id}}/blocked-times
Content-Type: application/json
Authorization: Bearer {{mgr09_token}}
{"startDateTime": "{{dt_far_tue}}", "endDateTime": "{{dt_far_tue_end}}"}
HTTP 400
[Asserts]
body contains "não atende neste dia da semana"

# ── 6. fora do expediente (antes das 09:00) → 400 ───────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/{{e2e09_prof_id}}/blocked-times
Content-Type: application/json
Authorization: Bearer {{mgr09_token}}
{"startDateTime": "{{date_far}}T07:00:00", "endDateTime": "{{date_far}}T08:00:00"}
HTTP 400
[Asserts]
body contains "dentro do expediente"

# ── 7. startDateTime ausente → 422 (field startDateTime) ────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/{{e2e09_prof_id}}/blocked-times
Content-Type: application/json
Authorization: Bearer {{mgr09_token}}
{"endDateTime": "{{dt_block_end}}"}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "startDateTime"

# ── 8. lista tem 1 ──────────────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/{{e2e09_prof_id}}/blocked-times
Authorization: Bearer {{mgr09_token}}
HTTP 200
[Asserts]
jsonpath "$" count == 1
jsonpath "$[0].id" == "{{e2e09_block_id}}"

# ── 9. DELETE → 204 → lista vazia ───────────────────────────────────────────
DELETE {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/{{e2e09_prof_id}}/blocked-times/{{e2e09_block_id}}
Authorization: Bearer {{mgr09_token}}
HTTP 204

GET {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/{{e2e09_prof_id}}/blocked-times
Authorization: Bearer {{mgr09_token}}
HTTP 200
[Asserts]
jsonpath "$" count == 0

# ── 10. DELETE id inexistente → 404 ─────────────────────────────────────────
DELETE {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/{{e2e09_prof_id}}/blocked-times/{{missing_uuid}}
Authorization: Bearer {{mgr09_token}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 11. lista de profissional inexistente → 404 ─────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/{{missing_uuid}}/blocked-times
Authorization: Bearer {{mgr09_token}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── teardown: remove o expediente criado ────────────────────────────────────
DELETE {{baseUrl}}/api/v1/establishments/{{e2e09_est_id}}/professionals/{{e2e09_prof_id}}/working-hours/{{e2e09_wh_id}}
Authorization: Bearer {{mgr09_token}}
HTTP 204
