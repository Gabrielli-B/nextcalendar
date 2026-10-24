# 11 — Comandas: abertura, itens, desconto/pagamento e fechamento
# Setup próprio: manager + profissional + expediente + serviço + produto.

# ── setup ───────────────────────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "E2E Barbearia 11",
  "email": "e2e11-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "MANAGER",
  "phone": "{{phone_11}}",
  "cnpj": "{{cnpj_11}}",
  "cep": "90610010",
  "street": "Rua Andradas",
  "number": "1200",
  "neighborhood": "Centro Histórico",
  "city": "Porto Alegre",
  "state": "RS"
}
HTTP 201
[Captures]
mgr11_token: jsonpath "$.token"
mgr11_user_id: jsonpath "$.user.id"

GET {{baseUrl}}/api/v1/establishments/owner/{{mgr11_user_id}}
Authorization: Bearer {{mgr11_token}}
HTTP 200
[Captures]
e2e11_est_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/professionals
Content-Type: application/json
Authorization: Bearer {{mgr11_token}}
{
  "name": "Prof-Comanda-{{run_id}}",
  "cpf": "{{cpf_11}}",
  "email": "prof11-{{run_id}}@e2e.test",
  "phone": "51999990701",
  "commission": 30
}
HTTP 201

GET {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/professionals/search?name=Prof-Comanda-{{run_id}}
Authorization: Bearer {{mgr11_token}}
HTTP 200
[Captures]
e2e11_prof_id: jsonpath "$.content[0].id"

POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/professionals/{{e2e11_prof_id}}/working-hours
Content-Type: application/json
Authorization: Bearer {{mgr11_token}}
{"dayOfWeek": "MONDAY", "startTime": "09:00:00", "endTime": "19:00:00", "breakStart": "12:00:00", "breakEnd": "13:00:00"}
HTTP 201
[Captures]
e2e11_wh_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/services
Content-Type: application/json
Authorization: Bearer {{mgr11_token}}
{"name": "E2E-Servico-11-{{run_id}}", "price": 100.00, "duration": 40, "category": "E2E"}
HTTP 201
[Captures]
e2e11_service_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/products
Content-Type: application/json
Authorization: Bearer {{mgr11_token}}
{"name": "E2E-Produto-11-{{run_id}}", "category": "E2E", "price": 50.00, "stockQuantity": 10}
HTTP 201
[Captures]
e2e11_product_id: jsonpath "$.id"

POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/appointments
Content-Type: application/json
Authorization: Bearer {{mgr11_token}}
{
  "professionalId": "{{e2e11_prof_id}}",
  "serviceId": "{{e2e11_service_id}}",
  "startDateTime": "{{dt_order}}",
  "clientNameFallback": "Cliente Comanda",
  "clientPhoneFallback": "51999990702"
}
HTTP 201
[Captures]
e2e11_appt_id: jsonpath "$.id"

# ── 1. abrir comanda → 200 (vem com o serviço do agendamento) ───────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/appointments/{{e2e11_appt_id}}/order
Authorization: Bearer {{mgr11_token}}
HTTP 200
[Captures]
e2e11_order_id: jsonpath "$.id"
[Asserts]
jsonpath "$.status" == "OPEN"
jsonpath "$.appointmentId" == "{{e2e11_appt_id}}"
jsonpath "$.clientName" == "Cliente Comanda"
jsonpath "$.items" count == 1
jsonpath "$.items[0].itemType" == "SERVICE"
jsonpath "$.items[0].name" == "E2E-Servico-11-{{run_id}}"
jsonpath "$.items[0].unitPrice" == 100
jsonpath "$.subtotal" == 100
jsonpath "$.totalAmount" == 100
jsonpath "$.paymentMethod" == null

# ── 2. abrir de novo → idempotente (mesma comanda) ──────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/appointments/{{e2e11_appt_id}}/order
Authorization: Bearer {{mgr11_token}}
HTTP 200
[Asserts]
jsonpath "$.id" == "{{e2e11_order_id}}"
jsonpath "$.items" count == 1

# ── 3. GET da comanda → 200 ─────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{e2e11_order_id}}
Authorization: Bearer {{mgr11_token}}
HTTP 200
[Asserts]
jsonpath "$.id" == "{{e2e11_order_id}}"

# ── 4. addItem SERVICE (x2) → 200 ───────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{e2e11_order_id}}/items
Content-Type: application/json
Authorization: Bearer {{mgr11_token}}
{"itemType": "SERVICE", "itemId": "{{e2e11_service_id}}", "quantity": 2}
HTTP 200
[Asserts]
jsonpath "$.items" count == 2
jsonpath "$.subtotal" == 300

# ── 5. addItem PRODUCT (x2) → 200 ───────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{e2e11_order_id}}/items
Content-Type: application/json
Authorization: Bearer {{mgr11_token}}
{"itemType": "PRODUCT", "itemId": "{{e2e11_product_id}}", "quantity": 2}
HTTP 200
[Captures]
e2e11_item_id: jsonpath "$.items[2].id"
[Asserts]
jsonpath "$.items" count == 3
jsonpath "$.items[2].itemType" == "PRODUCT"
jsonpath "$.subtotal" == 400
jsonpath "$.totalAmount" == 400

# ── 6. itemType inválido → 422 (field itemType) ─────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{e2e11_order_id}}/items
Content-Type: application/json
Authorization: Bearer {{mgr11_token}}
{"itemType": "GIFT", "itemId": "{{e2e11_service_id}}", "quantity": 1}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "itemType"

# ── 7. quantity 0 → 422 (field quantity) ────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{e2e11_order_id}}/items
Content-Type: application/json
Authorization: Bearer {{mgr11_token}}
{"itemType": "SERVICE", "itemId": "{{e2e11_service_id}}", "quantity": 0}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "quantity"

# ── 8. item inexistente → 404 ───────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{e2e11_order_id}}/items
Content-Type: application/json
Authorization: Bearer {{mgr11_token}}
{"itemType": "SERVICE", "itemId": "{{missing_uuid}}", "quantity": 1}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 9. remover item → 200 (total volta) ─────────────────────────────────────
DELETE {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{e2e11_order_id}}/items/{{e2e11_item_id}}
Authorization: Bearer {{mgr11_token}}
HTTP 200
[Asserts]
jsonpath "$.items" count == 2
jsonpath "$.subtotal" == 300

# ── 10. remover item inexistente → 404 ──────────────────────────────────────
DELETE {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{e2e11_order_id}}/items/{{missing_uuid}}
Authorization: Bearer {{mgr11_token}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 11. finalizar sem pagamento → 400 ───────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{e2e11_order_id}}/finish
Authorization: Bearer {{mgr11_token}}
HTTP 400
[Asserts]
body contains "Selecione a forma de pagamento"

# ── 12. PATCH desconto negativo → 422 (field discountAmount) ────────────────
PATCH {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{e2e11_order_id}}
Content-Type: application/json
Authorization: Bearer {{mgr11_token}}
{"discountAmount": -5}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "discountAmount"

# ── 13. PATCH desconto + pagamento → 200 ────────────────────────────────────
PATCH {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{e2e11_order_id}}
Content-Type: application/json
Authorization: Bearer {{mgr11_token}}
{"discountAmount": 10.50, "paymentMethod": "CASH"}
HTTP 200
[Asserts]
jsonpath "$.discountAmount" == 10.5
jsonpath "$.paymentMethod" == "CASH"
jsonpath "$.totalAmount" == 289.5

# ── 14. finalizar → 200 (comanda fechada, agendamento DONE) ─────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{e2e11_order_id}}/finish
Authorization: Bearer {{mgr11_token}}
HTTP 200
[Asserts]
jsonpath "$.status" == "CLOSED"
jsonpath "$.closedAt" exists
jsonpath "$.totalAmount" == 289.5

GET {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/appointments?professionalId={{e2e11_prof_id}}&date={{date_far3}}
Authorization: Bearer {{mgr11_token}}
HTTP 200
[Asserts]
jsonpath "$[0].status" == "DONE"

# ── 15. addItem depois de fechada → 400 ─────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{e2e11_order_id}}/items
Content-Type: application/json
Authorization: Bearer {{mgr11_token}}
{"itemType": "SERVICE", "itemId": "{{e2e11_service_id}}", "quantity": 1}
HTTP 400
[Asserts]
body contains "já foi finalizada"

# ── 16. finalizar de novo → 400 ─────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{e2e11_order_id}}/finish
Authorization: Bearer {{mgr11_token}}
HTTP 400
[Asserts]
body contains "já foi finalizada"

# ── 17. comanda em outro estabelecimento → 404 ──────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{missing_uuid}}/orders/{{e2e11_order_id}}
Authorization: Bearer {{mgr11_token}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 18. comanda inexistente → 404 ───────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{e2e11_est_id}}/orders/{{missing_uuid}}
Authorization: Bearer {{mgr11_token}}
HTTP 404
[Asserts]
body contains "não encontrada"
