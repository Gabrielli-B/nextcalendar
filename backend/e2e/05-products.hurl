# 05 — Produtos (CRUD no estabelecimento seed)
# Cria produto próprio com nome único e apaga ao final (teardown).

# ── 1. listagem → 200 (seed tem 3) ──────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{est_id}}/products
HTTP 200
[Asserts]
jsonpath "$.content" isList
jsonpath "$.totalElements" >= 3
jsonpath "$.content[*].name" contains "Pomada Modeladora"

# ── 2. search ───────────────────────────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{est_id}}/products/search?name=Pomada
HTTP 200
[Asserts]
jsonpath "$.content[0].name" == "Pomada Modeladora"
jsonpath "$.content[0].stockQuantity" == 20
jsonpath "$.content[0].price" == 50

# ── 3. POST produto único → 201 ─────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{est_id}}/products
Content-Type: application/json
{
  "name": "E2E-Produto-{{run_id}}",
  "category": "E2E",
  "price": 33.30,
  "stockQuantity": 7
}
HTTP 201
[Captures]
e2e_product_id: jsonpath "$.id"
[Asserts]
jsonpath "$.name" == "E2E-Produto-{{run_id}}"
jsonpath "$.stockQuantity" == 7

# ── 4. search pelo nome único → 1 ───────────────────────────────────────────
GET {{baseUrl}}/api/v1/establishments/{{est_id}}/products/search?name=E2E-Produto-{{run_id}}
HTTP 200
[Asserts]
jsonpath "$.totalElements" == 1
jsonpath "$.content[0].id" == "{{e2e_product_id}}"

# ── 5. POST nome duplicado → 400 ────────────────────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{est_id}}/products
Content-Type: application/json
{
  "name": "E2E-Produto-{{run_id}}",
  "category": "E2E",
  "price": 10,
  "stockQuantity": 1
}
HTTP 400
[Asserts]
body contains "Já existe um produto com o nome"

# ── 6. POST price negativo → 422 (field price) ──────────────────────────────
POST {{baseUrl}}/api/v1/establishments/{{est_id}}/products
Content-Type: application/json
{
  "name": "E2E-Preco-Negativo-{{run_id}}",
  "category": "E2E",
  "price": -5,
  "stockQuantity": 1
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "price"

# ── 7. POST stockQuantity negativo → 422 (field stockQuantity) ──────────────
POST {{baseUrl}}/api/v1/establishments/{{est_id}}/products
Content-Type: application/json
{
  "name": "E2E-Estoque-Negativo-{{run_id}}",
  "category": "E2E",
  "price": 10,
  "stockQuantity": -1
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "stockQuantity"

# ── 8. PUT (preço/estoque) → 200 ────────────────────────────────────────────
PUT {{baseUrl}}/api/v1/establishments/{{est_id}}/products/{{e2e_product_id}}
Content-Type: application/json
{"name": "E2E-Produto-{{run_id}}", "category": "E2E", "price": 44.40, "stockQuantity": 12}
HTTP 200
[Asserts]
jsonpath "$.price" == 44.4
jsonpath "$.stockQuantity" == 12

# ── 9. DELETE (teardown) → 204 → search vazio ───────────────────────────────
DELETE {{baseUrl}}/api/v1/establishments/{{est_id}}/products/{{e2e_product_id}}
HTTP 204

GET {{baseUrl}}/api/v1/establishments/{{est_id}}/products/search?name=E2E-Produto-{{run_id}}
HTTP 200
[Asserts]
jsonpath "$.totalElements" == 0

# ── 10. DELETE id inexistente → 404 ─────────────────────────────────────────
DELETE {{baseUrl}}/api/v1/establishments/{{est_id}}/products/{{missing_uuid}}
HTTP 404
[Asserts]
body contains "não encontrada"

# ── 11. listagem em estabelecimento inexistente → 404 ───────────────────────
GET {{baseUrl}}/api/v1/establishments/{{missing_uuid}}/products
HTTP 404
[Asserts]
body contains "não encontrada"
