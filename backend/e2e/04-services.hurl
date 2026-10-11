# 04 — Catálogo de serviços (CRUD no estabelecimento seed)
# Cria serviço próprio com nome único e apaga ao final (teardown).

# ── 1. listagem → 200 (seed tem 2) ──────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{est_id}}/services
HTTP 200
[Asserts]
jsonpath "$.content" isList
jsonpath "$.totalElements" >= 2
jsonpath "$.content[*].name" contains "Corte Degradê"

# ── 2. search por "Corte" ───────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{est_id}}/services/search?name=Corte
HTTP 200
[Asserts]
jsonpath "$.totalElements" >= 1
jsonpath "$.content[0].name" == "Corte Degradê"
jsonpath "$.content[0].duration" == 40
jsonpath "$.content[0].price" == 70

# ── 3. POST serviço único → 201 ─────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{est_id}}/services
Content-Type: application/json
{
  "name": "E2E-Servico-{{run_id}}",
  "price": 99.90,
  "duration": 30,
  "category": "E2E"
}
HTTP 201
[Captures]
e2e_service_id: jsonpath "$.id"
[Asserts]
jsonpath "$.name" == "E2E-Servico-{{run_id}}"
jsonpath "$.price" == 99.9

# ── 4. search pelo nome único → totalElements == 1 ──────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{est_id}}/services/search?name=E2E-Servico-{{run_id}}
HTTP 200
[Asserts]
jsonpath "$.totalElements" == 1
jsonpath "$.content[0].id" == "{{e2e_service_id}}"

# ── 5. POST nome duplicado → 400 ────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{est_id}}/services
Content-Type: application/json
{
  "name": "E2E-Servico-{{run_id}}",
  "price": 50,
  "duration": 30,
  "category": "E2E"
}
HTTP 400
[Asserts]
body contains "Já existe um serviço com o nome"

# ── 6. POST price 0 → 422 (field price) ─────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{est_id}}/services
Content-Type: application/json
{
  "name": "E2E-Preco-Zero-{{run_id}}",
  "price": 0,
  "duration": 30,
  "category": "E2E"
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "price"

# ── 7. POST name curto → 422 (field name) ───────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{est_id}}/services
Content-Type: application/json
{
  "name": "ab",
  "price": 10,
  "duration": 30,
  "category": "E2E"
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "name"

# ── 8. PUT (preço) → 200 ────────────────────────────────────────────────────
PUT {{baseUrl}}/api/v1/establishments/{{est_id}}/services/{{e2e_service_id}}
Content-Type: application/json
{"name": "E2E-Servico-{{run_id}}", "price": 120.50, "duration": 45, "category": "E2E"}
HTTP 200
[Asserts]
jsonpath "$.price" == 120.5
jsonpath "$.duration" == 45

# ── 9. DELETE (teardown) → 204 → search vazio ───────────────────────────────
DELETE {{baseUrl}}/api/v1/establishments/{{est_id}}/services/{{e2e_service_id}}
HTTP 204

GET {{baseUrl}}/api/v1/establishments/{{est_id}}/services/search?name=E2E-Servico-{{run_id}}
HTTP 200
[Asserts]
jsonpath "$.totalElements" == 0

# ── 10. DELETE id inexistente → 404 ─────────────────────────────────────────
DELETE {{baseUrl}}/api/v1/establishments/{{est_id}}/services/{{missing_uuid}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 11. listagem em estabelecimento inexistente → 404 ───────────────────────
GET {{baseUrl}}/api/v1/establishments/{{missing_uuid}}/services
HTTP 404
[Asserts]
body contains "não encontrada"
