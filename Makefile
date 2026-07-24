.PHONY: help run dev \
        backend-run backend-test backend-build backend-clean \
        frontend-start frontend-android frontend-ios frontend-web frontend-install frontend-lint frontend-clean frontend-reset

HELP_PREFIX := \033[36m
HELP_SUFFIX := \033[0m

help:
	@echo "$(HELP_PREFIX)Comandos disponíveis:$(HELP_SUFFIX)"
	@echo ""
	@echo "  $(HELP_PREFIX)Atalhos$(HELP_SUFFIX)"
	@echo "  make help                Exibe esta ajuda"
	@echo "  make run                 Inicia o backend (alias para backend-run)"
	@echo "  make dev                 Inicia backend + frontend juntos"
	@echo ""
	@echo "  $(HELP_PREFIX)Backend$(HELP_SUFFIX)"
	@echo "  make backend-run         Roda a aplicação Spring Boot"
	@echo "  make backend-test        Executa os testes do backend"
	@echo "  make backend-build       Compila e empacota o backend"
	@echo "  make backend-clean       Remove os artefatos de build"
	@echo ""
	@echo "  $(HELP_PREFIX)Frontend$(HELP_SUFFIX)"
	@echo "  make frontend-start      Inicia o Expo (modo interativo)"
	@echo "  make frontend-android    Inicia no Android"
	@echo "  make frontend-ios        Inicia no iOS"
	@echo "  make frontend-web        Inicia no browser"
	@echo "  make frontend-install    Instala as dependências (npm install)"
	@echo "  make frontend-lint       Executa o linter"
	@echo "  make frontend-clean      Remove node_modules"
	@echo "  make frontend-reset      Remove node_modules e reinstala"

# ── Atalhos ──────────────────────────────────────────────────────────────────

run: backend-run

# Sobe backend e frontend em paralelo (use Ctrl+C para encerrar ambos)
dev:
	@echo "\033[36mIniciando backend e frontend...\033[0m"
	@start cmd /k "cd backend && mvnw spring-boot:run"
	@cd frontend && npx expo start

# ── Backend ───────────────────────────────────────────────────────────────────

backend-run:
	@cd backend && ./mvnw spring-boot:run

backend-test:
	@cd backend && ./mvnw test

backend-build:
	@cd backend && ./mvnw package -DskipTests

backend-clean:
	@cd backend && ./mvnw clean

# ── Frontend ──────────────────────────────────────────────────────────────────

frontend-start:
	@cd frontend && npx expo start

frontend-android:
	@cd frontend && npx expo start --android

frontend-ios:
	@cd frontend && npx expo start --ios

frontend-web:
	@cd frontend && npx expo start --web

frontend-install:
	@cd frontend && npm install

frontend-lint:
	@cd frontend && npx expo lint

frontend-clean:
	@cd frontend && rd /s /q node_modules

frontend-reset: frontend-clean frontend-install
