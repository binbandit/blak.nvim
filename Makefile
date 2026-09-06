.PHONY: validate smoke smoke-install zip docs docs-dev docs-build docs-install

validate:
	python3 scripts/validate.py
	sh -n install.sh
	sh -n dev-install.sh
	sh -n scripts/smoke.sh
	sh -n scripts/smoke-install.sh

smoke:
	sh scripts/smoke.sh

smoke-install:
	sh scripts/smoke-install.sh

# Documentation site (Astro Starlight)
docs: docs-dev

docs-install:
	cd docs && npm install

docs-dev:
	cd docs && npm run dev

docs-build:
	cd docs && npm run build

zip:
	cd .. && zip -r blak.nvim.zip blak.nvim -x 'blak.nvim/.git/*' -x 'blak.nvim/docs/node_modules/*' -x 'blak.nvim/docs/dist/*'
