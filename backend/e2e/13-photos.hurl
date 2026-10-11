# 13 — Fotos: upload multipart (PNG), listagem, download e remoção
# Setup próprio: manager + profissional + expediente + serviço + agendamento com comanda aberta.

# ── setup ───────────────────────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "E2E Barbearia 13",
  "email": "e2e13-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "{{phone_13}}",
  "cnpj": "{{cnpj_13}}",
  "cep": "90610010",
  "street": "Rua Venâncio Aires",
  "number": "300",
  "neighborhood": "Cidade Baixa",
  "city": "Porto Alegre",
  "state": "RS"
}
HTTP 201
[Captures]
mgr13_token: jsonpath "$.token"
mgr13_user_id: jsonpath "$.user.id"

GET {{baseUrl}}/api/v1/establishments/owner/{{mgr13_user_id}}
Authorization: Bearer {{mgr13_token}}
HTTP 200
[Captures]
e2e13_est_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e13_est_id}}/professionals
Content-Type: application/json
Authorization: Bearer {{mgr13_token}}
{
  "name": "Prof-Fotos-{{run_id}}",
  "cpf": "{{cpf_13}}",
  "email": "prof13-{{run_id}}@e2e.test",
  "phone": "51999990901",
  "commission": 30
}
HTTP 201

GET {{baseUrl}}/api/v1/establishments/{{e2e13_est_id}}/professionals/search?name=Prof-Fotos-{{run_id}}
Authorization: Bearer {{mgr13_token}}
HTTP 200
[Captures]
e2e13_prof_id: jsonpath "$.content[0].id"

POST {{baseUrl}}/api/v1/establishments/{{e2e13_est_id}}/professionals/{{e2e13_prof_id}}/working-hours
Content-Type: application/json
Authorization: Bearer {{mgr13_token}}
{"dayOfWeek": "MONDAY", "startTime": "09:00:00", "endTime": "19:00:00", "breakStart": "12:00:00", "breakEnd": "13:00:00"}
HTTP 201
[Captures]
e2e13_wh_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e13_est_id}}/services
Content-Type: application/json
Authorization: Bearer {{mgr13_token}}
{"name": "E2E-Servico-13-{{run_id}}", "price": 80.00, "duration": 40, "category": "E2E"}
HTTP 201
[Captures]
e2e13_service_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/clients
Content-Type: application/json
{"name": "E2E-Cliente-13-{{run_id}}", "phone": "51999990902", "email": "client13-{{run_id}}@e2e.test", "password": "Senha1234"}
HTTP 201

GET {{baseUrl}}/api/v1/clients/search?name=E2E-Cliente-13-{{run_id}}
HTTP 200
[Captures]
e2e13_client_id: jsonpath "$.content[0].id"

# agendamento 1: comanda aberta (permite upload)
POST {{baseUrl}}/api/v1/establishments/{{e2e13_est_id}}/appointments
Content-Type: application/json
Authorization: Bearer {{mgr13_token}}
{
  "professionalId": "{{e2e13_prof_id}}",
  "serviceId": "{{e2e13_service_id}}",
  "clientId": "{{e2e13_client_id}}",
  "startDateTime": "{{dt_photo}}"
}
HTTP 201
[Captures]
e2e13_appt_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e13_est_id}}/appointments/{{e2e13_appt_id}}/order
Authorization: Bearer {{mgr13_token}}
HTTP 200
[Captures]
e2e13_order_id: jsonpath "$.id"

# agendamento 2: sem comanda (upload deve ser bloqueado)
POST {{baseUrl}}/api/v1/establishments/{{e2e13_est_id}}/appointments
Content-Type: application/json
Authorization: Bearer {{mgr13_token}}
{
  "professionalId": "{{e2e13_prof_id}}",
  "serviceId": "{{e2e13_service_id}}",
  "startDateTime": "{{date_far}}T15:00:00",
  "isFitIn": true
}
HTTP 201
[Captures]
e2e13_appt2_id: jsonpath "$.id"

# ── 1. lista vazia ──────────────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/appointments/{{e2e13_appt_id}}/photos
Authorization: Bearer {{mgr13_token}}
HTTP 200
[Asserts]
jsonpath "$" isList
jsonpath "$" count == 0

# ── 2. upload PNG → 201 ─────────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/appointments/{{e2e13_appt_id}}/photos
Authorization: Bearer {{mgr13_token}}
[Multipart]
file: file,fixtures/photo.png;
type: AFTER
caption: Antes e depois E2E
HTTP 201
[Captures]
e2e13_photo_id: jsonpath "$.id"
[Asserts]
jsonpath "$.appointmentId" == "{{e2e13_appt_id}}"
jsonpath "$.clientId" == "{{e2e13_client_id}}"
jsonpath "$.type" == "AFTER"
jsonpath "$.caption" == "Antes e depois E2E"
jsonpath "$.photoUrl" == "/api/v1/photos/{{e2e13_photo_id}}"
jsonpath "$.takenByName" exists

# ── 3. lista tem 1 foto ─────────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/appointments/{{e2e13_appt_id}}/photos
Authorization: Bearer {{mgr13_token}}
HTTP 200
[Asserts]
jsonpath "$" count == 1
jsonpath "$[0].id" == "{{e2e13_photo_id}}"

# ── 4. download dos bytes ───────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/photos/{{e2e13_photo_id}}
Authorization: Bearer {{mgr13_token}}
HTTP 200
[Asserts]
header "Content-Type" contains "image/png"
bytes count >= 10

# ── 5. fotos do cliente → 200 ───────────────────────────────────────────────
GET {{baseUrl}}/api/v1/clients/{{e2e13_client_id}}/photos
Authorization: Bearer {{mgr13_token}}
HTTP 200
[Asserts]
jsonpath "$" count == 1

# ── 6. upload sem comanda/andamento → 400 ───────────────────────────────────
POST {{baseUrl}}/api/v1/appointments/{{e2e13_appt2_id}}/photos
Authorization: Bearer {{mgr13_token}}
[Multipart]
file: file,fixtures/photo.png;
HTTP 400
[Asserts]
body contains "em andamento ou concluídos"

# ── 7. formato não suportado → 400 ──────────────────────────────────────────
POST {{baseUrl}}/api/v1/appointments/{{e2e13_appt_id}}/photos
Authorization: Bearer {{mgr13_token}}
[Multipart]
file: file,fixtures/photo.png; text/plain
HTTP 400
[Asserts]
body contains "Formato de imagem inválido"

# ── 8. agendamento inexistente → 404 ────────────────────────────────────────
GET {{baseUrl}}/api/v1/appointments/{{missing_uuid}}/photos
Authorization: Bearer {{mgr13_token}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 9. DELETE foto → 204 → lista vazia ──────────────────────────────────────
DELETE {{baseUrl}}/api/v1/photos/{{e2e13_photo_id}}
Authorization: Bearer {{mgr13_token}}
HTTP 204

GET {{baseUrl}}/api/v1/appointments/{{e2e13_appt_id}}/photos
Authorization: Bearer {{mgr13_token}}
HTTP 200
[Asserts]
jsonpath "$" count == 0

# ── 10. DELETE foto inexistente → 404 ───────────────────────────────────────
DELETE {{baseUrl}}/api/v1/photos/{{missing_uuid}}
Authorization: Bearer {{mgr13_token}}
HTTP 404
[Asserts]
body contains "não encontrada"
