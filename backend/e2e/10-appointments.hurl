# 10 — Agendamentos: disponibilidade, criação, conflitos, cancel e reagendamento
# Setup próprio: manager + profissional + expediente (segunda) + serviço + cliente.

# ── setup ───────────────────────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "E2E Barbearia 10",
  "email": "e2e10-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "{{phone_10}}",
  "cnpj": "{{cnpj_10}}",
  "cep": "90610010",
  "street": "Rua São Luís",
  "number": "25",
  "neighborhood": "Rio Branco",
  "city": "Porto Alegre",
  "state": "RS"
}
HTTP 201
[Captures]
mgr10_token: jsonpath "$.token"
mgr10_user_id: jsonpath "$.user.id"

GET {{baseUrl}}/api/v1/establishments/owner/{{mgr10_user_id}}
Authorization: Bearer {{mgr10_token}}
HTTP 200
[Captures]
e2e10_est_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/professionals
Content-Type: application/json
Authorization: Bearer {{mgr10_token}}
{
  "name": "Prof-Agenda-{{run_id}}",
  "cpf": "{{cpf_10}}",
  "email": "prof10-{{run_id}}@e2e.test",
  "phone": "51999990601",
  "commission": 30
}
HTTP 201

GET {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/professionals/search?name=Prof-Agenda-{{run_id}}
Authorization: Bearer {{mgr10_token}}
HTTP 200
[Captures]
e2e10_prof_id: jsonpath "$.content[0].id"

POST {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/professionals/{{e2e10_prof_id}}/working-hours
Content-Type: application/json
Authorization: Bearer {{mgr10_token}}
{"dayOfWeek": "MONDAY", "startTime": "09:00:00", "endTime": "19:00:00", "breakStart": "12:00:00", "breakEnd": "13:00:00"}
HTTP 201
[Captures]
e2e10_wh_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/services
Content-Type: application/json
Authorization: Bearer {{mgr10_token}}
{"name": "E2E-Servico-10-{{run_id}}", "price": 100.00, "duration": 40, "category": "E2E"}
HTTP 201
[Captures]
e2e10_service_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/clients
Content-Type: application/json
{"name": "E2E-Cliente-10-{{run_id}}", "phone": "51999990602", "email": "client10-{{run_id}}@e2e.test", "password": "Senha1234"}
HTTP 201

GET {{baseUrl}}/api/v1/clients/search?name=E2E-Cliente-10-{{run_id}}
HTTP 200
[Captures]
e2e10_client_id: jsonpath "$.content[0].id"

# ── 1. slots livres na segunda → 200 ────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments/available-slots?professionalId={{e2e10_prof_id}}&serviceId={{e2e10_service_id}}&date={{date_far2}}
HTTP 200
[Captures]
e2e10_slot: jsonpath "$.slots[0]"
[Asserts]
jsonpath "$.date" == "{{date_far2}}"
jsonpath "$.durationMinutes" == 40
jsonpath "$.slots" isList
jsonpath "$.slots" count > 5
jsonpath "$.slots" not contains "12:00:00"

# ── 2. agendamento válido (cliente real) → 201 ──────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments
Content-Type: application/json
{
  "professionalId": "{{e2e10_prof_id}}",
  "serviceId": "{{e2e10_service_id}}",
  "clientId": "{{e2e10_client_id}}",
  "startDateTime": "{{dt_far}}",
  "notes": "E2E appointment 1"
}
HTTP 201
[Captures]
e2e10_appt1: jsonpath "$.id"
[Asserts]
jsonpath "$.status" == "SCHEDULED"
jsonpath "$.professionalId" == "{{e2e10_prof_id}}"
jsonpath "$.clientName" == "E2E-Cliente-10-{{run_id}}"
jsonpath "$.endDateTime" exists

# ── 3. conflito no mesmo horário → 400 ──────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments
Content-Type: application/json
{
  "professionalId": "{{e2e10_prof_id}}",
  "serviceId": "{{e2e10_service_id}}",
  "clientId": "{{e2e10_client_id}}",
  "startDateTime": "{{dt_far}}"
}
HTTP 400
[Asserts]
body contains "já está ocupado"

# ── 4. isFitIn=true força o encaixe → 201 ───────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments
Content-Type: application/json
{
  "professionalId": "{{e2e10_prof_id}}",
  "serviceId": "{{e2e10_service_id}}",
  "startDateTime": "{{dt_far}}",
  "isFitIn": true,
  "clientNameFallback": "Cliente Avulso",
  "clientPhoneFallback": "51999990603"
}
HTTP 201
[Captures]
e2e10_appt2: jsonpath "$.id"
[Asserts]
jsonpath "$.clientName" == "Cliente Avulso"

# ── 5. em cima do almoço → 400 ──────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments
Content-Type: application/json
{
  "professionalId": "{{e2e10_prof_id}}",
  "serviceId": "{{e2e10_service_id}}",
  "startDateTime": "{{date_far}}T12:15:00"
}
HTTP 400
[Asserts]
body contains "intervalo de almoço"

# ── 6. fora do expediente → 400 ─────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments
Content-Type: application/json
{
  "professionalId": "{{e2e10_prof_id}}",
  "serviceId": "{{e2e10_service_id}}",
  "startDateTime": "{{date_far}}T07:00:00"
}
HTTP 400
[Asserts]
body contains "fora do expediente"

# ── 7. dia sem expediente (terça) → 400 ─────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments
Content-Type: application/json
{
  "professionalId": "{{e2e10_prof_id}}",
  "serviceId": "{{e2e10_service_id}}",
  "startDateTime": "{{dt_far_tue}}"
}
HTTP 400
[Asserts]
body contains "não atende neste dia"

# ── 8. data/hora no passado → 400 ───────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments
Content-Type: application/json
{
  "professionalId": "{{e2e10_prof_id}}",
  "serviceId": "{{e2e10_service_id}}",
  "startDateTime": "{{dt_past}}"
}
HTTP 400
[Asserts]
body contains "já passou"

# ── 9. professionalId ausente → 422 (field professionalId) ──────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments
Content-Type: application/json
{
  "serviceId": "{{e2e10_service_id}}",
  "startDateTime": "{{dt_far_r}}"
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "professionalId"

# ── 10. serviceId ausente → 422 (field serviceId) ───────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments
Content-Type: application/json
{
  "professionalId": "{{e2e10_prof_id}}",
  "startDateTime": "{{dt_far_r}}"
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "serviceId"

# ── 11. profissional de outro estabelecimento → 404 ─────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments
Content-Type: application/json
{
  "professionalId": "{{missing_uuid}}",
  "serviceId": "{{e2e10_service_id}}",
  "startDateTime": "{{dt_far_r}}"
}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 12. listagem por data/dia do profissional → 200 ─────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments?professionalId={{e2e10_prof_id}}&date={{date_far2}}
HTTP 200
[Asserts]
jsonpath "$" isList
jsonpath "$" count == 2
jsonpath "$[*].id" contains "{{e2e10_appt1}}"

# ── 13. listagem por cliente → 200 ──────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments/client/{{e2e10_client_id}}
HTTP 200
[Asserts]
jsonpath "$" count == 1
jsonpath "$[0].id" == "{{e2e10_appt1}}"

# ── 14. cancelar (encaixe) → 200 ────────────────────────────────────────────
PATCH {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments/{{e2e10_appt2}}/cancel
HTTP 200
[Asserts]
jsonpath "$.status" == "CANCELLED"

# ── 15. cancelar de novo → 400 ──────────────────────────────────────────────
PATCH {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments/{{e2e10_appt2}}/cancel
HTTP 400
[Asserts]
body contains "já está cancelado"

# ── 16. reagendar para horário livre → 200 ──────────────────────────────────
PUT {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments/{{e2e10_appt1}}/reschedule
Content-Type: application/json
{"newStartDateTime": "{{dt_far_r}}"}
HTTP 200
[Asserts]
jsonpath "$.startDateTime" == "{{dt_far_r}}"
jsonpath "$.status" == "SCHEDULED"

# ── 17. reagendar para o passado → 400 ──────────────────────────────────────
PUT {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments/{{e2e10_appt1}}/reschedule
Content-Type: application/json
{"newStartDateTime": "{{dt_past}}"}
HTTP 400
[Asserts]
body contains "reagendar para uma data/horário que já passou"

# ── 18. slots refletem o reagendamento (10:00 volta a ficar livre) ──────────
GET {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments/available-slots?professionalId={{e2e10_prof_id}}&serviceId={{e2e10_service_id}}&date={{date_far2}}
HTTP 200
[Asserts]
jsonpath "$.slots" contains "10:00:00"
jsonpath "$.slots" not contains "16:00:00"

# ── 19. reagendar cancelado → 400 ───────────────────────────────────────────
PUT {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments/{{e2e10_appt2}}/reschedule
Content-Type: application/json
{"newStartDateTime": "{{dt_far_r}}"}
HTTP 400
[Asserts]
body contains "reagendar um agendamento cancelado"

# ── 20. agendamento inexistente → 404 ───────────────────────────────────────
PATCH {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments/{{missing_uuid}}/cancel
HTTP 404
[Asserts]
body contains "não encontrada"

# ── teardown: cancela o agendamento restante ────────────────────────────────
PATCH {{baseUrl}}/api/v1/establishments/{{e2e10_est_id}}/appointments/{{e2e10_appt1}}/cancel
HTTP 200
[Asserts]
jsonpath "$.status" == "CANCELLED"
