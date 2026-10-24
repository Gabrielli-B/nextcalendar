# 12 — Ficha técnica do cliente: observações, linha do tempo e remoção
# Setup próprio: manager + profissional + expediente + serviço + agendamento concluído.

# ── setup ───────────────────────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "E2E Barbearia 12",
  "email": "e2e12-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "{{phone_12}}",
  "cnpj": "{{cnpj_12}}",
  "cep": "90610010",
  "street": "Rua da República",
  "number": "55",
  "neighborhood": "República",
  "city": "Porto Alegre",
  "state": "RS"
}
HTTP 201
[Captures]
mgr12_token: jsonpath "$.token"
mgr12_user_id: jsonpath "$.user.id"

GET {{baseUrl}}/api/v1/establishments/owner/{{mgr12_user_id}}
Authorization: Bearer {{mgr12_token}}
HTTP 200
[Captures]
e2e12_est_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e12_est_id}}/professionals
Content-Type: application/json
Authorization: Bearer {{mgr12_token}}
{
  "name": "Prof-Ficha-{{run_id}}",
  "cpf": "{{cpf_12}}",
  "email": "prof12-{{run_id}}@e2e.test",
  "phone": "51999990801",
  "commission": 30
}
HTTP 201

GET {{baseUrl}}/api/v1/establishments/{{e2e12_est_id}}/professionals/search?name=Prof-Ficha-{{run_id}}
Authorization: Bearer {{mgr12_token}}
HTTP 200
[Captures]
e2e12_prof_id: jsonpath "$.content[0].id"

POST {{baseUrl}}/api/v1/establishments/{{e2e12_est_id}}/professionals/{{e2e12_prof_id}}/working-hours
Content-Type: application/json
Authorization: Bearer {{mgr12_token}}
{"dayOfWeek": "MONDAY", "startTime": "09:00:00", "endTime": "19:00:00", "breakStart": "12:00:00", "breakEnd": "13:00:00"}
HTTP 201
[Captures]
e2e12_wh_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e12_est_id}}/services
Content-Type: application/json
Authorization: Bearer {{mgr12_token}}
{"name": "E2E-Servico-12-{{run_id}}", "price": 90.00, "duration": 40, "category": "E2E"}
HTTP 201
[Captures]
e2e12_service_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/clients
Content-Type: application/json
{"name": "E2E-Cliente-12-{{run_id}}", "phone": "51999990802", "email": "client12-{{run_id}}@e2e.test", "password": "Senha1234"}
HTTP 201

GET {{baseUrl}}/api/v1/clients/search?name=E2E-Cliente-12-{{run_id}}
HTTP 200
[Captures]
e2e12_client_id: jsonpath "$.content[0].id"

POST {{baseUrl}}/api/v1/establishments/{{e2e12_est_id}}/appointments
Content-Type: application/json
Authorization: Bearer {{mgr12_token}}
{
  "professionalId": "{{e2e12_prof_id}}",
  "serviceId": "{{e2e12_service_id}}",
  "clientId": "{{e2e12_client_id}}",
  "startDateTime": "{{dt_sheet}}"
}
HTTP 201
[Captures]
e2e12_appt_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e12_est_id}}/appointments/{{e2e12_appt_id}}/order
Authorization: Bearer {{mgr12_token}}
HTTP 200
[Captures]
e2e12_order_id: jsonpath "$.id"

PATCH {{baseUrl}}/api/v1/establishments/{{e2e12_est_id}}/orders/{{e2e12_order_id}}
Content-Type: application/json
Authorization: Bearer {{mgr12_token}}
{"discountAmount": 0, "paymentMethod": "PIX"}
HTTP 200

POST {{baseUrl}}/api/v1/establishments/{{e2e12_est_id}}/orders/{{e2e12_order_id}}/finish
Authorization: Bearer {{mgr12_token}}
HTTP 200
[Asserts]
jsonpath "$.status" == "CLOSED"

# ── 1. GET ficha → 200 (criada em memória na primeira leitura) ──────────────
GET {{baseUrl}}/api/v1/clients/{{e2e12_client_id}}/technical-sheet
HTTP 200
[Captures]
e2e12_sheet_id: jsonpath "$.id"
[Asserts]
jsonpath "$.clientId" == "{{e2e12_client_id}}"
jsonpath "$.clientName" == "E2E-Cliente-12-{{run_id}}"
jsonpath "$.entries" isList
jsonpath "$.entries" count == 0

# ── 2. PATCH observações → 200 ──────────────────────────────────────────────
PATCH {{baseUrl}}/api/v1/clients/{{e2e12_client_id}}/technical-sheet
Content-Type: application/json
{"observations": "Prefere máquina 2. Alergia a álcool."}
HTTP 200
[Asserts]
jsonpath "$.observations" == "Prefere máquina 2. Alergia a álcool."

# ── 3. POST entrada na linha do tempo → 200 ─────────────────────────────────
POST {{baseUrl}}/api/v1/clients/{{e2e12_client_id}}/technical-sheet/entries
Content-Type: application/json
{
  "appointmentId": "{{e2e12_appt_id}}",
  "notes": "Degradê baixo, finalizado com pomada.",
  "photoUrls": ["https://exemplo.test/foto-1.jpg", "https://exemplo.test/foto-2.jpg"]
}
HTTP 200
[Captures]
e2e12_entry_id: jsonpath "$.entries[0].id"
[Asserts]
jsonpath "$.entries" count == 1
jsonpath "$.entries[0].appointmentId" == "{{e2e12_appt_id}}"
jsonpath "$.entries[0].professionalId" == "{{e2e12_prof_id}}"
jsonpath "$.entries[0].serviceName" == "E2E-Servico-12-{{run_id}}"
jsonpath "$.entries[0].notes" == "Degradê baixo, finalizado com pomada."
jsonpath "$.entries[0].photos" count == 2
jsonpath "$.entries[0].photos[0].photoUrl" == "https://exemplo.test/foto-1.jpg"

# ── 4. entrada com agendamento inexistente → 404 ────────────────────────────
POST {{baseUrl}}/api/v1/clients/{{e2e12_client_id}}/technical-sheet/entries
Content-Type: application/json
{"appointmentId": "{{missing_uuid}}"}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 5. entrada sem appointmentId → 422 (field appointmentId) ────────────────
POST {{baseUrl}}/api/v1/clients/{{e2e12_client_id}}/technical-sheet/entries
Content-Type: application/json
{"notes": "Sem agendamento"}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "appointmentId"

# ── 6. GET ficha → 1 entrada ────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/clients/{{e2e12_client_id}}/technical-sheet
HTTP 200
[Asserts]
jsonpath "$.entries" count == 1
jsonpath "$.updatedAt" exists

# ── 7. DELETE entrada → 200 (fica vazia) ────────────────────────────────────
DELETE {{baseUrl}}/api/v1/clients/{{e2e12_client_id}}/technical-sheet/entries/{{e2e12_entry_id}}
HTTP 200
[Asserts]
jsonpath "$.entries" count == 0

# ── 8. DELETE entrada inexistente → 404 ─────────────────────────────────────
DELETE {{baseUrl}}/api/v1/clients/{{e2e12_client_id}}/technical-sheet/entries/{{missing_uuid}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 9. cliente inexistente → 404 ────────────────────────────────────────────
GET {{baseUrl}}/api/v1/clients/{{missing_uuid}}/technical-sheet
HTTP 404
[Asserts]
body contains "não encontrada"
