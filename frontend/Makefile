.PHONY: help start android ios web install clean reset lint

HELP_PREFIX := \033[36m
HELP_SUFFIX := \033[0m

help:
	@echo "$(HELP_PREFIX)Comandos disponíveis — Frontend:$(HELP_SUFFIX)"
	@echo "  make help             Exibe esta ajuda"
	@echo "  make start            Inicia o Expo (modo interativo)"
	@echo "  make android          Inicia no Android"
	@echo "  make ios              Inicia no iOS"
	@echo "  make web              Inicia no browser"
	@echo "  make install          Instala as dependências (npm install)"
	@echo "  make lint             Executa o linter"
	@echo "  make clean            Remove node_modules"
	@echo "  make reset            Remove node_modules e reinstala"

start:
	@cd frontend && npx expo start

android:
	@cd frontend && npx expo start --android

ios:
	@cd frontend && npx expo start --ios

web:
	@cd frontend && npx expo start --web

install:
	@cd frontend && npm install

lint:
	@cd frontend && npx expo lint

clean:
	@cd frontend && rd /s /q node_modules

reset: clean install
