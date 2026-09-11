PORT ?= 4000

.PHONY: serve
serve:
	python3 -m http.server $(PORT)
