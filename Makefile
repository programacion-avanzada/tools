PORT ?= 4000

.DEFAULT_GOAL := help

.PHONY: help serve status deploy

help:
	@echo "Uso: make [target]"
	@echo ""
	@echo "  serve   Servidor local en http://localhost:$(PORT) (ej: make serve PORT=8080)"
	@echo "  status  Estado del working tree y de la rama vs remoto"
	@echo "  deploy  Pushea los commits y avisa si quedan cambios sin commitear"

serve:
	python3 -m http.server $(PORT)

status:
	@git status --short --branch

deploy:
	@echo "== Pre-push: esto está pendiente y NO se desplega =="
	@git status --short --branch
	@git push
	@if [ -n "$$(git status --porcelain)" ]; then echo "ATENCIÓN: quedaron cambios sin commitear (NO se desplegaron)."; else echo "Todo desplegado, working tree limpio."; fi
