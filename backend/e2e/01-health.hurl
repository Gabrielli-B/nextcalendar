# 01 — Health / documentação
# Esperado: redirects do home para o Swagger e OpenAPI publicado.

GET {{baseUrl}}/
HTTP 302
[Asserts]
header "Location" contains "/swagger-ui/index.html"

GET {{baseUrl}}/api/v1
HTTP 302
[Asserts]
header "Location" contains "/swagger-ui/index.html"

GET {{baseUrl}}/v3/api-docs
HTTP 200
[Asserts]
jsonpath "$.openapi" exists
jsonpath "$.paths" exists
jsonpath "$.info.title" exists

GET {{baseUrl}}/swagger-ui/index.html
HTTP 200
