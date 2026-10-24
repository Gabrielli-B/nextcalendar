# 14 — Atendimentos: consultas agregadas do profissional, gestor e cliente
# Setup próprio: manager + profissional (com login) + expediente + serviço + atendimento concluído.

# ── setup ───────────────────────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "E2E Barbearia 14",
  "email": "e2e14-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "{{phone_14a}}",
  "cnpj": "{{cnpj_14}}",
  "cep": "90610010",
  "street": "Av. Getúlio Vargas",
  "number": "70",
  "neighborhood": "Moinhos de Vento",
  "city": "Porto Alegre",
  "state": "RS"
}
HTTP 201
[Captures]
mgr14_token: jsonpath "$.token"
mgr14_user_id: jsonpath "$.user.id"

GET {{baseUrl}}/api/v1/establishments/owner/{{mgr14_user_id}}
Authorization: Bearer {{mgr14_token}}
HTTP 200
[Captures]
e2e14_est_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e14_est_id}}/professionals
Content-Type: application/json
Authorization: Bearer {{mgr14_token}}
{
  "name": "Prof-Atend-{{run_id}}",
  "cpf": "{{cpf_14}}",
  "email": "prof14-{{run_id}}@e2e.test",
  "phone": "51999991001",
  "commission": 30
}
HTTP 201
[Captures]
temp14_password: jsonpath "$.temporaryPassword"

GET {{baseUrl}}/api/v1/establishments/{{e2e14_est_id}}/professionals/search?name=Prof-Atend-{{run_id}}
Authorization: Bearer {{mgr14_token}}
HTTP 200
[Captures]
e2e14_prof_id: jsonpath "$.content[0].id"

POST {{baseUrl}}/api/v1/establishments/{{e2e14_est_id}}/professionals/{{e2e14_prof_id}}/working-hours
Content-Type: application/json
Authorization: Bearer {{mgr14_token}}
{"dayOfWeek": "MONDAY", "startTime": "09:00:00", "endTime": "19:00:00", "breakStart": "12:00:00", "breakEnd": "13:00:00"}
HTTP 201
[Captures]
e2e14_wh_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e14_est_id}}/services
Content-Type: application/json
Authorization: Bearer {{mgr14_token}}
{"name": "E2E-Servico-14-{{run_id}}", "price": 70.00, "duration": 40, "category": "E2E"}
HTTP 201
[Captures]
e2e14_service_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/clients
Content-Type: application/json
{"name": "E2E-Cliente-14-{{run_id}}", "phone": "51999991002", "email": "client14-{{run_id}}@e2e.test", "password": "Senha1234"}
HTTP 201

GET {{baseUrl}}/api/v1/clients/search?name=E2E-Cliente-14-{{run_id}}
HTTP 200
[Captures]
e2e14_client_id: jsonpath "$.content[0].id"

POST {{baseUrl}}/api/v1/establishments/{{e2e14_est_id}}/appointments
Content-Type: application/json
Authorization: Bearer {{mgr14_token}}
{
  "professionalId": "{{e2e14_prof_id}}",
  "serviceId": "{{e2e14_service_id}}",
  "clientId": "{{e2e14_client_id}}",
  "startDateTime": "{{dt_journey}}"
}
HTTP 201
[Captures]
e2e14_appt_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e14_est_id}}/appointments/{{e2e14_appt_id}}/order
Authorization: Bearer {{mgr14_token}}
HTTP 200
[Captures]
e2e14_order_id: jsonpath "$.id"

PATCH {{baseUrl}}/api/v1/establishments/{{e2e14_est_id}}/orders/{{e2e14_order_id}}
Content-Type: application/json
Authorization: Bearer {{mgr14_token}}
{"discountAmount": 10.00, "paymentMethod": "CREDIT_CARD"}
HTTP 200

POST {{baseUrl}}/api/v1/establishments/{{e2e14_est_id}}/orders/{{e2e14_order_id}}/finish
Authorization: Bearer {{mgr14_token}}
HTTP 200
[Asserts]
jsonpath "$.status" == "CLOSED"

# login do profissional (senha temporária → troca obrigatória)
POST {{baseUrl}}/api/v1/auth/login
Content-Type: application/json
{"email": "prof14-{{run_id}}@e2e.test", "password": "{{temp14_password}}"}
HTTP 200
[Captures]
prof14_token: jsonpath "$.token"
[Asserts]
jsonpath "$.user.mustChangePassword" == true

POST {{baseUrl}}/api/v1/auth/change-password
Content-Type: application/json
Authorization: Bearer {{prof14_token}}
{"currentPassword": "{{temp14_password}}", "newPassword": "SenhaNova123"}
HTTP 204

POST {{baseUrl}}/api/v1/auth/login
Content-Type: application/json
{"email": "prof14-{{run_id}}@e2e.test", "password": "SenhaNova123"}
HTTP 200
[Captures]
prof14_token: jsonpath "$.token"
[Asserts]
jsonpath "$.user.mustChangePassword" == false

# ── 1. atendimentos do profissional → 200 ───────────────────────────────────
GET {{baseUrl}}/api/v1/professionals/me/attendances
Authorization: Bearer {{prof14_token}}
HTTP 200
[Captures]
e2e14_att_id: jsonpath "$.content[0].id"
[Asserts]
jsonpath "$.totalElements" >= 1
jsonpath "$.content[0].id" == "{{e2e14_appt_id}}"
jsonpath "$.content[0].status" == "DONE"
jsonpath "$.content[0].orderStatus" == "CLOSED"
jsonpath "$.content[0].orderId" == "{{e2e14_order_id}}"
jsonpath "$.content[0].totalAmount" == 60
jsonpath "$.content[0].clientName" == "E2E-Cliente-14-{{run_id}}"
jsonpath "$.content[0].serviceName" == "E2E-Servico-14-{{run_id}}"
jsonpath "$.content[0].photosCount" == 0
jsonpath "$.content[0].hasTechnicalSheet" == false

# ── 2. filtro por status ────────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/professionals/me/attendances?status=DONE
Authorization: Bearer {{prof14_token}}
HTTP 200
[Asserts]
jsonpath "$.totalElements" >= 1
jsonpath "$.content[*].status" contains "DONE"

GET {{baseUrl}}/api/v1/professionals/me/attendances?status=SCHEDULED
Authorization: Bearer {{prof14_token}}
HTTP 200
[Asserts]
jsonpath "$.totalElements" == 0

# ── 3. filtro por cliente e período ─────────────────────────────────────────
GET {{baseUrl}}/api/v1/professionals/me/attendances?clientId={{e2e14_client_id}}&from={{date_far5}}&to={{date_far5}}
Authorization: Bearer {{prof14_token}}
HTTP 200
[Asserts]
jsonpath "$.totalElements" == 1

# ── 4. atendimentos do estabelecimento (gestor) → 200 ───────────────────────
GET {{baseUrl}}/api/v1/attendances
Authorization: Bearer {{mgr14_token}}
HTTP 200
[Asserts]
jsonpath "$.totalElements" >= 1
jsonpath "$.content[*].id" contains "{{e2e14_appt_id}}"
jsonpath "$.content[0].establishmentId" == "{{e2e14_est_id}}"

# ── 5. filtro por profissional/período (gestor) ─────────────────────────────
GET {{baseUrl}}/api/v1/attendances?professionalId={{e2e14_prof_id}}&status=DONE&from={{date_far5}}&to={{date_far5}}
Authorization: Bearer {{mgr14_token}}
HTTP 200
[Asserts]
jsonpath "$.totalElements" == 1
jsonpath "$.content[0].professionalId" == "{{e2e14_prof_id}}"

# ── 6. atendimentos do cliente (gestor) → 200 ───────────────────────────────
GET {{baseUrl}}/api/v1/clients/{{e2e14_client_id}}/attendances
Authorization: Bearer {{mgr14_token}}
HTTP 200
[Asserts]
jsonpath "$" isList
jsonpath "$" count == 1
jsonpath "$[0].id" == "{{e2e14_appt_id}}"

# ── 7. cliente não pode consultar atendimentos → 403 ────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "Cliente E2E 14",
  "email": "e2e14c-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "CUSTOMER",
  "phone": "{{phone_14b}}"
}
HTTP 201
[Captures]
cust14_token: jsonpath "$.token"

GET {{baseUrl}}/api/v1/professionals/me/attendances
Authorization: Bearer {{cust14_token}}
HTTP 403
[Asserts]
body contains "Clientes não têm acesso"

GET {{baseUrl}}/api/v1/attendances
Authorization: Bearer {{cust14_token}}
HTTP 403
[Asserts]
body contains "Clientes não têm acesso"

# ── 8. sem token → 403 ──────────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/attendances
HTTP 403
[Asserts]
body contains "não autenticado"

# ── 9. cliente inexistente → 404 ────────────────────────────────────────────
GET {{baseUrl}}/api/v1/clients/{{missing_uuid}}/attendances
Authorization: Bearer {{mgr14_token}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 10. filtro com período inválido → 400 (antes o parâmetro virava null e o
#      Postgres respondia 500 "could not determine data type of parameter") ──
GET {{baseUrl}}/api/v1/attendances?from=nao-e-data
Authorization: Bearer {{mgr14_token}}
HTTP 400
[Asserts]
body contains "Período inválido"
