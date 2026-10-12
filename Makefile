# ─────────────────────────────────────────────────────────────────────────────
# NextCalendar — atalhos de desenvolvimento
#
# Uso: `make help` para listar os comandos.
# Funciona em Linux, macOS e Windows (GNU Make + shell compatível com POSIX).
# ─────────────────────────────────────────────────────────────────────────────

.DEFAULT_GOAL := help

C_CYAN  := \033[36m
C_GREEN := \033[32m
C_RESET := \033[0m

BACKEND_DIR   := backend
FRONTEND_DIR  := frontend
BARBEARIA_DIR := AgenteBarbearia

# Detecta Windows (GNU Make define OS=Windows_NT nas plataformas Windows)
ifeq ($(OS),Windows_NT)
  WRAPPER := mvnw.cmd
  RM_DIR  := rd /s /q
else
  WRAPPER := ./mvnw
  RM_DIR  := rm -rf
endif

# O Maven Wrapper só funciona se .mvn/wrapper/maven-wrapper.properties existir;
# caso contrário, usa o Maven instalado no sistema.
ifneq ($(wildcard $(BACKEND_DIR)/.mvn/wrapper/maven-wrapper.properties),)
  MVN := $(WRAPPER)
else
  MVN := mvn
endif

.PHONY: help run dev \
        db-up db-down db-logs db-status \
        backend-run backend-test backend-e2e backend-openapi-dump backend-build backend-clean \
        frontend-start frontend-android frontend-ios frontend-web \
        frontend-install frontend-lint frontend-clean frontend-reset \
        frontend-api-check frontend-test-integration frontend-e2e-ui \
        barbearia-db-up barbearia-db-down barbearia-api barbearia-bridge

# ── Ajuda ─────────────────────────────────────────────────────────────────────

help:
	@printf '%b\n' \
	  "$(C_CYAN)Comandos disponíveis:$(C_RESET)" \
	  "" \
	  "  $(C_CYAN)Atalhos$(C_RESET)" \
	  "  make help                 Exibe esta ajuda" \
	  "  make run                  Inicia o backend" \
	  "  make dev                  Inicia backend + frontend juntos" \
	  "" \
	  "  $(C_CYAN)Banco de dados (PostgreSQL via Docker)$(C_RESET)" \
	  "  make db-up                Sobe o PostgreSQL" \
	  "  make db-down              Para o PostgreSQL" \
	  "  make db-logs              Exibe os logs do PostgreSQL" \
	  "  make db-status            Mostra o status dos containers" \
	  "" \
	  "  $(C_CYAN)Backend (Spring Boot)$(C_RESET)" \
	  "  make backend-run          Roda a aplicação Spring Boot" \
	  "  make backend-test         Executa os testes do backend" \
	  "  make backend-e2e          Roda a suíte E2E (backend precisa estar no ar)" \
	  "  make backend-openapi-dump Atualiza backend/specs/openapi.json (backend no ar)" \
	  "  make backend-build        Compila e empacota o backend" \
	  "  make backend-clean        Remove os artefatos de build" \
	  "" \
	  "  $(C_CYAN)Frontend (Expo)$(C_RESET)" \
	  "  make frontend-start       Inicia o Expo" \
	  "  make frontend-android     Inicia no Android" \
	  "  make frontend-ios         Inicia no iOS" \
	  "  make frontend-web         Inicia no browser" \
	  "  make frontend-install     Instala as dependências" \
	  "  make frontend-lint        Executa o linter" \
	  "  make frontend-api-check   Valida endpoints dos services vs OpenAPI" \
	  "  make frontend-test-integration  Testes de integração (backend no ar)" \
	  "  make frontend-e2e-ui      E2E de UI (Playwright + Expo web)" \
	  "  make frontend-clean       Remove node_modules" \
	  "  make frontend-reset       Remove node_modules e reinstala" \
	  "" \
	  "  $(C_CYAN)Agente de Barbearia$(C_RESET)" \
	  "  make barbearia-db-up      Sobe MongoDB + Evolution API (Docker)" \
	  "  make barbearia-db-down    Para os serviços do Docker" \
	  "  make barbearia-api        Roda a API .NET do agente" \
	  "  make barbearia-bridge     Roda o bridge do WhatsApp (Node.js)"

# ── Atalhos ───────────────────────────────────────────────────────────────────

run: backend-run

# Sobe backend (em background) e frontend (em primeiro plano).
# Ao encerrar (Ctrl+C ou fim do frontend), o backend também é finalizado.
dev:
	@printf '%b\n' "$(C_GREEN)Iniciando backend (background) + frontend...$(C_RESET)"
ifeq ($(OS),Windows_NT)
	@start "NextCalendar Backend" cmd /k "$(MVN) -f $(BACKEND_DIR)/pom.xml spring-boot:run"
	@$(MAKE) --no-print-directory frontend-start
else
	@cd $(BACKEND_DIR) && $(MVN) spring-boot:run & \
	  backend_pid=$$!; \
	  trap 'kill $$backend_pid 2>/dev/null || true' EXIT INT TERM; \
	  $(MAKE) --no-print-directory frontend-start
endif

# ── Banco de dados ────────────────────────────────────────────────────────────

db-up:
	@docker compose up -d

db-down:
	@docker compose down

db-logs:
	@docker compose logs -f postgres

db-status:
	@docker compose ps

# ── Backend ───────────────────────────────────────────────────────────────────

backend-run:
	@cd $(BACKEND_DIR) && $(MVN) spring-boot:run

backend-test:
	@cd $(BACKEND_DIR) && $(MVN) test

# Suíte E2E (HURL) contra o backend JÁ RODANDO em http://localhost:8080.
#   make backend-e2e                        # suíte inteira
#   make backend-e2e FILES=11-orders.hurl   # só um arquivo (vários: FILES="a.hurl b.hurl")
# Relatório HTML: backend/e2e/report/index.html
backend-e2e:
	@$(BACKEND_DIR)/e2e/run.sh $(addprefix $(BACKEND_DIR)/e2e/,$(FILES))

# Regenera o snapshot do OpenAPI usado pelo check de contrato do frontend.
backend-openapi-dump:
	@curl -sf http://localhost:8080/v3/api-docs -o $(BACKEND_DIR)/specs/openapi.json
	@echo "✓ backend/specs/openapi.json atualizado"

backend-build:
	@cd $(BACKEND_DIR) && $(MVN) package -DskipTests

backend-clean:
	@cd $(BACKEND_DIR) && $(MVN) clean

# ── Frontend ──────────────────────────────────────────────────────────────────

frontend-start:
	@cd $(FRONTEND_DIR) && npm start

frontend-android:
	@cd $(FRONTEND_DIR) && npm run android

frontend-ios:
	@cd $(FRONTEND_DIR) && npm run ios

frontend-web:
	@cd $(FRONTEND_DIR) && npm run web

frontend-install:
	@cd $(FRONTEND_DIR) && npm install

frontend-lint:
	@cd $(FRONTEND_DIR) && npm run lint

# Contrato estático: paths/métodos dos services contra backend/specs/openapi.json
frontend-api-check:
	@cd $(FRONTEND_DIR) && npm run check:api

# Integração: services do frontend chamando o backend REAL (precisa estar no ar).
frontend-test-integration:
	@cd $(FRONTEND_DIR) && npm run test:integration

# E2E de UI: Playwright sobe o Expo web sozinho (backend precisa estar no ar).
frontend-e2e-ui:
	@cd $(FRONTEND_DIR) && npm run test:e2e

frontend-clean:
	@cd $(FRONTEND_DIR) && $(RM_DIR) node_modules

frontend-reset: frontend-clean frontend-install

# ── Agente de Barbearia ───────────────────────────────────────────────────────

barbearia-db-up:
	@cd $(BARBEARIA_DIR) && docker compose up -d

barbearia-db-down:
	@cd $(BARBEARIA_DIR) && docker compose down

barbearia-api:
	@cd $(BARBEARIA_DIR)/AgenteBarbearia.Api && dotnet run

barbearia-bridge:
	@cd $(BARBEARIA_DIR)/whatsapp-bridge && node index.js
