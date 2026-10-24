# NextCalendar — Backend

API REST do NextCalendar (gestão de barbearias/salões): estabelecimentos, profissionais,
serviços, produtos, clientes, horários, agendamentos, comandas, fichas técnicas, fotos e
atendimentos.

## Stack

| Camada | Tecnologia |
|---|---|
| Framework | Spring Boot 4.1.0 (Java 21) |
| Persistência | Spring Data JPA + Hibernate |
| Banco (produção) | PostgreSQL 16 (docker-compose) |
| Banco (testes) | H2 em memória (`create-drop`, Flyway desativado) |
| Migrations | Flyway (`src/main/resources/db/migration`) |
| Segurança | Spring Security + JWT (HS256) |
| Documentação | springdoc-openapi (Swagger UI / OpenAPI 3) |
| Validação | `spring-boot-starter-validation` (Bean Validation) |

## Requisitos

- Java 21+
- Docker + Docker Compose (para o PostgreSQL)
- GNU Make

## Como rodar

```bash
# 1. Sobe o PostgreSQL (container: nextcalendar-db)
make db-up

# 2. Sobe o backend em http://localhost:8080
make backend-run
```

Variáveis de ambiente (opcionais, com defaults locais):

| Variável | Default |
|---|---|
| `DB_URL` | `jdbc:postgresql://localhost:5432/nextcalendar` |
| `DB_USERNAME` | `postgres` |
| `DB_PASSWORD` | `postgres` |
| `jwt.secret` / `jwt.expiration-ms` | definidos em `application.properties` (troque em produção) |

### Outros alvos do Makefile

```bash
make backend-test   # suíte de testes (H2 em memória)
make backend-build  # mvnw clean package
make backend-clean  # mvnw clean
make db-down        # para o PostgreSQL
make db-logs        # logs do container do banco
make db-status      # status dos containers
```

## Endpoints e documentação

- Base: `/api/v1`
- Swagger UI: <http://localhost:8080/swagger-ui/index.html>
- OpenAPI JSON: <http://localhost:8080/v3/api-docs>
- `GET /` e `GET /api/v1` redirecionam para o Swagger

### Autenticação

- `POST /api/v1/auth/register` — cria usuário (`CUSTOMER`, `MANAGER` ou `PROFESSIONAL`).
  `MANAGER` exige CNPJ + endereço completo e cria o estabelecimento; `CUSTOMER` cria o client.
- `POST /api/v1/auth/login` — retorna `{ token, user }` (JWT Bearer).
- `POST /api/v1/auth/change-password` — troca a senha (exige token; usuário com senha
  temporária recebe **403** do `MustChangePasswordFilter` em qualquer outra rota).
- `GET /api/v1/professionals/me`, atendimentos e fotos exigem token.

Observação: o `SecurityConfig` libera as rotas no nível HTTP (`permitAll`) e a
autorização por papel acontece nos services (`SecurityUtils`) — por exemplo, clientes não
accessam atendimentos e profissionais não criam serviços.

## Banco de dados

- **Flyway é a única fonte de verdade do schema** (roda antes do Hibernate);
  `spring.jpa.hibernate.ddl-auto=validate` valida que o JPA bate com o schema migrado.
- `V1__create_schema.sql` — 16 tabelas;
- `V2__seed_default_establishment.sql` — seed idempotente com UUIDs fixos
  (estabelecimento `11111111-...`, profissional `aaaaaaaa-...`, serviços `22222222-...`,
  produtos `33333333-...`, cliente `44444444-...`, agendamento `55555555-...`).
- Nos **testes**, o Flyway fica desabilitado e o schema é gerado pelo Hibernate (`create-drop`);
  os testes criam seus próprios dados e não dependem do seed.

## Estrutura do código

```
src/main/java/com/nextcalendar/
├── config/        # SecurityConfig, JwtAuthenticationFilter, MustChangePasswordFilter,
│                  # SecurityUtils, JacksonConfig, SchedulingConfig
├── controller/    # 16 controllers (auth, establishments, appointments, orders, ...)
├── dto/           # requests/responses
├── entity/        # entidades JPA + enums
├── exception/     # GlobalExceptionHandler (400/403/404/409/422)
├── mapper/        # mappers manuais (DTO <-> entidade)
├── repository/    # Spring Data repositories
├── service/       # regras de negócio (AppointmentService, OrderService, ...)
└── validation/    # validadores de domínio (CnpjValidator)
```

## Testes

```bash
make backend-test
```

- Unitários + integração (`@SpringBootTest`) com H2 em memória — sem Docker.
- Cobrem agendamento (slots/conflitos/cancelamento), comanda, profissionais/segurança e
  atendimentos/fotos.

### Testes E2E (HURL)

```bash
make backend-run            # terminal 1 — backend em http://localhost:8080
make backend-e2e            # terminal 2 — 15 arquivos, 280+ requests
make backend-e2e FILES=14-attendance.hurl
```

- Rodam contra o **backend real** (PostgreSQL): `make db-up` antes.
- Suíte inteira verdes (~5 s); relatório em `backend/e2e/report/index.html`.
- Detalhes em [`e2e/README.md`](e2e/README.md) e plano em [`specs/e2e-tests-plan.md`](specs/e2e-tests-plan.md).
