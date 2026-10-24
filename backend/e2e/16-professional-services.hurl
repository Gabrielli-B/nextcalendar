# 16 — Vínculos profissional ↔ serviço (professional-services)
# Setup próprio: manager + estabelecimento + 2 profissionais + 2 serviços.
# Regra do backend: profissional sem vínculos atende tudo; serviço sem vínculos
# aceita tudo; caso contrário exige o par exato. Teardown: apaga os serviços.

# ── setup: manager + estabelecimento ───────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "E2E Barbearia 16",
  "email": "e2e16-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "{{phone_16}}",
  "cnpj": "{{cnpj_16}}",
  "cep": "90610010",
  "street": "Rua das Flores",
  "number": "10",
  "neighborhood": "Menino Deus",
  "city": "Porto Alegre",
  "state": "RS"
}
HTTP 201
[Captures]
mgr16_token: jsonpath "$.token"
mgr16_user_id: jsonpath "$.user.id"

GET {{baseUrl}}/api/v1/establishments/owner/{{mgr16_user_id}}
Authorization: Bearer {{mgr16_token}}
HTTP 200
[Captures]
e2e16_est_id: jsonpath "$.id"

# ── setup: profissionais A e B ─────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professionals
Content-Type: application/json
Authorization: Bearer {{mgr16_token}}
{
  "name": "E2E-Prof-A-{{run_id}}",
  "cpf": "{{cpf_16}}",
  "email": "prof16a-{{run_id}}@e2e.test",
  "phone": "51999991601",
  "commission": 30
}
HTTP 201

GET {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professionals/search?name=E2E-Prof-A-{{run_id}}
Authorization: Bearer {{mgr16_token}}
HTTP 200
[Captures]
e2e16_prof_a: jsonpath "$.content[0].id"

POST {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professionals
Content-Type: application/json
Authorization: Bearer {{mgr16_token}}
{
  "name": "E2E-Prof-B-{{run_id}}",
  "cpf": "{{cpf_16b}}",
  "email": "prof16b-{{run_id}}@e2e.test",
  "phone": "51999991602",
  "commission": 30
}
HTTP 201

GET {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professionals/search?name=E2E-Prof-B-{{run_id}}
Authorization: Bearer {{mgr16_token}}
HTTP 200
[Captures]
e2e16_prof_b: jsonpath "$.content[0].id"

# ── setup: serviços 1 e 2 ──────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/services
Content-Type: application/json
Authorization: Bearer {{mgr16_token}}
{"name": "E2E-Servico-16A-{{run_id}}", "price": 80.00, "duration": 30, "category": "E2E"}
HTTP 201
[Captures]
e2e16_service1: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/services
Content-Type: application/json
Authorization: Bearer {{mgr16_token}}
{"name": "E2E-Servico-16B-{{run_id}}", "price": 120.00, "duration": 60, "category": "E2E"}
HTTP 201
[Captures]
e2e16_service2: jsonpath "$.id"

# ── setup: horários de segunda para os dois ────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professionals/{{e2e16_prof_a}}/working-hours
Content-Type: application/json
Authorization: Bearer {{mgr16_token}}
{"dayOfWeek": "MONDAY", "startTime": "09:00:00", "endTime": "19:00:00", "breakStart": "12:00:00", "breakEnd": "13:00:00"}
HTTP 201

POST {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professionals/{{e2e16_prof_b}}/working-hours
Content-Type: application/json
Authorization: Bearer {{mgr16_token}}
{"dayOfWeek": "MONDAY", "startTime": "09:00:00", "endTime": "19:00:00", "breakStart": "12:00:00", "breakEnd": "13:00:00"}
HTTP 201

# ── 1. lista inicial vazia → 0 pares ───────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professional-services
HTTP 200
[Asserts]
jsonpath "$" isList
jsonpath "$" count == 0

# ── 2. PUT A [svc1, svc2] → 2 pares ────────────────────────────────────────
PUT {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professional-services/{{e2e16_prof_a}}
Content-Type: application/json
["{{e2e16_service1}}", "{{e2e16_service2}}"]
HTTP 200
[Asserts]
jsonpath "$" count == 2
jsonpath "$[*].professionalId" contains "{{e2e16_prof_a}}"
jsonpath "$[*].serviceId" contains "{{e2e16_service1}}"
jsonpath "$[*].serviceId" contains "{{e2e16_service2}}"

# ── 3. GET reflete os pares ────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professional-services
HTTP 200
[Asserts]
jsonpath "$" count == 2
jsonpath "$[*].professionalId" contains "{{e2e16_prof_a}}"
jsonpath "$[*].serviceId" contains "{{e2e16_service2}}"

# ── 4. substituição (não soma): PUT A [svc2] → 1 par ───────────────────────
PUT {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professional-services/{{e2e16_prof_a}}
Content-Type: application/json
["{{e2e16_service2}}"]
HTTP 200
[Asserts]
jsonpath "$" count == 1
jsonpath "$[0].professionalId" == "{{e2e16_prof_a}}"
jsonpath "$[0].serviceId" == "{{e2e16_service2}}"

# ── 5. PUT B com duplicado → dedupe em 1 par ───────────────────────────────
PUT {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professional-services/{{e2e16_prof_b}}
Content-Type: application/json
["{{e2e16_service1}}", "{{e2e16_service1}}"]
HTTP 200
[Asserts]
jsonpath "$" count == 1
jsonpath "$[0].professionalId" == "{{e2e16_prof_b}}"
jsonpath "$[0].serviceId" == "{{e2e16_service1}}"

# ── 6. GET final → 2 pares (A×svc2, B×svc1) ───────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professional-services
HTTP 200
[Asserts]
jsonpath "$" count == 2
jsonpath "$[*].professionalId" contains "{{e2e16_prof_a}}"
jsonpath "$[*].professionalId" contains "{{e2e16_prof_b}}"
jsonpath "$[*].serviceId" contains "{{e2e16_service1}}"
jsonpath "$[*].serviceId" contains "{{e2e16_service2}}"

# ── 7. slots par INVÁLIDO (B × svc2) → 400 ─────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/appointments/available-slots?professionalId={{e2e16_prof_b}}&serviceId={{e2e16_service2}}&date={{date_next_mon}}
HTTP 400
[Asserts]
body contains "não realiza o serviço"

# ── 8. slots par INVÁLIDO (A × svc1) → 400 ─────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/appointments/available-slots?professionalId={{e2e16_prof_a}}&serviceId={{e2e16_service1}}&date={{date_next_mon}}
HTTP 400
[Asserts]
body contains "não realiza o serviço"

# ── 9. slots par VÁLIDO (A × svc2) → 200 com vagas ─────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/appointments/available-slots?professionalId={{e2e16_prof_a}}&serviceId={{e2e16_service2}}&date={{date_next_mon}}
HTTP 200
[Asserts]
jsonpath "$.serviceId" == "{{e2e16_service2}}"
jsonpath "$.date" == "{{date_next_mon}}"
jsonpath "$.slots" isList
jsonpath "$.slots" count >= 1

# ── 10. POST appointment par INVÁLIDO → 400 ────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/appointments
Content-Type: application/json
{
  "professionalId": "{{e2e16_prof_b}}",
  "serviceId": "{{e2e16_service2}}",
  "clientNameFallback": "E2E-Cliente-16-{{run_id}}",
  "startDateTime": "{{date_next_mon}}T10:00:00"
}
HTTP 400
[Asserts]
body contains "não realiza o serviço"

# ── 11. PUT vazio → remove todos os vínculos de A (volta a atender tudo) ───
PUT {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professional-services/{{e2e16_prof_a}}
Content-Type: application/json
[]
HTTP 200
[Asserts]
jsonpath "$" count == 0

GET {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professional-services
HTTP 200
[Asserts]
jsonpath "$" count == 1
jsonpath "$[0].professionalId" == "{{e2e16_prof_b}}"

GET {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/appointments/available-slots?professionalId={{e2e16_prof_a}}&serviceId={{e2e16_service1}}&date={{date_next_mon}}
HTTP 200
[Asserts]
jsonpath "$.slots" isList

# ── 12. 404s ───────────────────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{missing_uuid}}/professional-services
HTTP 404
[Asserts]
body contains "não encontrada"

PUT {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professional-services/{{missing_uuid}}
Content-Type: application/json
["{{e2e16_service1}}"]
HTTP 404
[Asserts]
body contains "não encontrada"

PUT {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professional-services/{{e2e16_prof_a}}
Content-Type: application/json
["{{missing_uuid}}"]
HTTP 404
[Asserts]
body contains "não encontrada"

# ── teardown: zera vínculos e apaga os serviços criados ────────────────────
PUT {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/professional-services/{{e2e16_prof_b}}
Content-Type: application/json
[]
HTTP 200

DELETE {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/services/{{e2e16_service1}}
HTTP 204

DELETE {{baseUrl}}/api/v1/establishments/{{e2e16_est_id}}/services/{{e2e16_service2}}
HTTP 204
