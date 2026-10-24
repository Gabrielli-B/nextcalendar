# ─────────────────────────────────────────────────────────────────────────────
# Frontend (Expo) — atalhos
#
# Execute a partir de frontend/: `make start`, `make help`, etc.
# Para os atalhos gerais do monorepo, use o Makefile da raiz do projeto.
# ─────────────────────────────────────────────────────────────────────────────

.DEFAULT_GOAL := help

C_CYAN  := \033[36m
C_RESET := \033[0m

# Detecta Windows (GNU Make define OS=Windows_NT nas plataformas Windows)
ifeq ($(OS),Windows_NT)
  RM_DIR := rd /s /q
else
  RM_DIR := rm -rf
endif

.PHONY: help start android ios web install clean reset lint

help:
	@printf '%b\n' \
	  "$(C_CYAN)Comandos disponíveis — Frontend:$(C_RESET)" \
	  "  make help             Exibe esta ajuda" \
	  "  make start            Inicia o Expo (modo interativo)" \
	  "  make android          Inicia no Android" \
	  "  make ios              Inicia no iOS" \
	  "  make web              Inicia no browser" \
	  "  make install          Instala as dependências (npm install)" \
	  "  make lint             Executa o linter" \
	  "  make clean            Remove node_modules" \
	  "  make reset            Remove node_modules e reinstala"

start:
	@npm start

android:
	@npm run android

ios:
	@npm run ios

web:
	@npm run web

install:
	@npm install

lint:
	@npm run lint

clean:
	@$(RM_DIR) node_modules

reset: clean install
