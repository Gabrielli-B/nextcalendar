# 02 — Auth: registro (CUSTOMER), login e troca de senha
# Dados próprios: 1 usuário CUSTOMER por execução (email derivado de {{run_id}}).

# ── 1. register CUSTOMER válido → 201 ───────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "Cliente E2E",
  "email": "e2e02-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "CUSTOMER",
  "phone": "{{phone_02}}"
}
HTTP 201
[Captures]
e2e_token: jsonpath "$.token"
e2e_user_id: jsonpath "$.user.id"
[Asserts]
jsonpath "$.token" isString
jsonpath "$.user.id" isUuid
jsonpath "$.user.role" == "CUSTOMER"
jsonpath "$.user.mustChangePassword" == false
jsonpath "$.user.email" == "e2e02-{{run_id}}@e2e.test"

# ── 2. mesmo email → 409 ────────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "Cliente E2E",
  "email": "e2e02-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "CUSTOMER",
  "phone": "{{phone_02}}"
}
HTTP 409
[Asserts]
body contains "Email já cadastrado"

# ── 3. email inválido → 422 (field email) ───────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "Cliente E2E",
  "email": "nao-e-email",
  "password": "Senha1234",
  "role": "CUSTOMER",
  "phone": "51999990002"
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "email"

# ── 4. senha < 6 → 422 (field password) ─────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "Cliente E2E",
  "email": "e2e02b-{{run_id}}@e2e.test",
  "password": "abc",
  "role": "CUSTOMER",
  "phone": "51999990003"
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "password"

# ── 5. sem phone → 422 (field phone) ────────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/register
Content-Type: application/json
{
  "name": "Cliente E2E",
  "email": "e2e02c-{{run_id}}@e2e.test",
  "password": "Senha1234",
  "role": "CUSTOMER"
}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "phone"

# ── 6. login OK → 200 ───────────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/login
Content-Type: application/json
{"email": "e2e02-{{run_id}}@e2e.test", "password": "Senha1234"}
HTTP 200
[Captures]
login_token: jsonpath "$.token"
[Asserts]
jsonpath "$.token" isString
jsonpath "$.user.role" == "CUSTOMER"

# ── 7. senha errada → 400 ───────────────────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/login
Content-Type: application/json
{"email": "e2e02-{{run_id}}@e2e.test", "password": "SenhaErrada1"}
HTTP 400
[Asserts]
body contains "Email ou senha inválidos"

# ── 8. email inexistente → 400 (mesma mensagem, sem vazamento) ──────────────
POST {{baseUrl}}/api/v1/auth/login
Content-Type: application/json
{"email": "e2e-inexistente-{{run_id}}@e2e.test", "password": "Senha1234"}
HTTP 400
[Asserts]
body contains "Email ou senha inválidos"

# ── 9. payload de login inválido → 422 ──────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/login
Content-Type: application/json
{"email": "so-email@e2e.test"}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "password"

# ── 9b. JSON malformado → 400 texto puro, sem trace ──────────────────────────
POST {{baseUrl}}/api/v1/auth/login
Content-Type: application/json
"{email: invalido,"
HTTP 400
[Asserts]
body contains "mal formatado"

# ── 10. change-password sem token → 400 ─────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/change-password
Content-Type: application/json
{"currentPassword": "Senha1234", "newPassword": "NovaSenha123"}
HTTP 400
[Asserts]
body contains "Token de autenticação ausente"

# ── 11. senha atual errada → 400 ────────────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/change-password
Content-Type: application/json
Authorization: Bearer {{e2e_token}}
{"currentPassword": "Errada1234", "newPassword": "NovaSenha123"}
HTTP 400
[Asserts]
body contains "Senha atual incorreta"

# ── 12. nova senha < 8 → 422 (Bean Validation no DTO) ───────────────────────
POST {{baseUrl}}/api/v1/auth/change-password
Content-Type: application/json
Authorization: Bearer {{e2e_token}}
{"currentPassword": "Senha1234", "newPassword": "Ab1"}
HTTP 422
[Asserts]
jsonpath "$[0].field" == "newPassword"

# ── 13. nova senha sem número → 400 ─────────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/change-password
Content-Type: application/json
Authorization: Bearer {{e2e_token}}
{"currentPassword": "Senha1234", "newPassword": "SoLetrasAqui"}
HTTP 400
[Asserts]
body contains "letra e um número"

# ── 14. nova senha igual à atual → 400 ──────────────────────────────────────
POST {{baseUrl}}/api/v1/auth/change-password
Content-Type: application/json
Authorization: Bearer {{e2e_token}}
{"currentPassword": "Senha1234", "newPassword": "Senha1234"}
HTTP 400
[Asserts]
body contains "não pode ser igual"

# ── 15. troca OK → 204; login com senha antiga → 400; com nova → 200 ───────
POST {{baseUrl}}/api/v1/auth/change-password
Content-Type: application/json
Authorization: Bearer {{e2e_token}}
{"currentPassword": "Senha1234", "newPassword": "NovaSenha123"}
HTTP 204

POST {{baseUrl}}/api/v1/auth/login
Content-Type: application/json
{"email": "e2e02-{{run_id}}@e2e.test", "password": "Senha1234"}
HTTP 400
[Asserts]
body contains "Email ou senha inválidos"

POST {{baseUrl}}/api/v1/auth/login
Content-Type: application/json
{"email": "e2e02-{{run_id}}@e2e.test", "password": "NovaSenha123"}
HTTP 200
[Asserts]
jsonpath "$.token" isString
