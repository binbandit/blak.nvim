.PHONY: validate smoke smoke-install zip docs docs-dev docs-build docs-install

SMOKE_NVIM_APPNAME ?= blak-test
SMOKE_RTP = lua vim.opt.rtp:prepend(vim.fn.getcwd())
SMOKE_CMD = NVIM_APPNAME=$(SMOKE_NVIM_APPNAME) nvim --headless -u NONE --cmd 'set loadplugins' --cmd '$(SMOKE_RTP)' -c 'lua dofile("scripts/smoke.lua")'
COMMANDS_CMD = NVIM_APPNAME=$(SMOKE_NVIM_APPNAME) nvim --headless -u NONE --cmd 'set loadplugins' --cmd '$(SMOKE_RTP)' -c 'lua dofile("scripts/commands.lua")'
UPDATE_CONTRACT_CMD = NVIM_APPNAME=blak-update-contract nvim --headless -u NONE --cmd 'set loadplugins' --cmd '$(SMOKE_RTP)' -c 'lua dofile("scripts/update-contract.lua")'
SMOKE_DIR_CMD = NVIM_APPNAME=$(SMOKE_NVIM_APPNAME) nvim --headless -u NONE --cmd 'set loadplugins' --cmd '$(SMOKE_RTP)' --cmd 'lua vim.g.blak_config={ui={splash={enabled=false}},mason={automatic_install=false},treesitter={ensure_installed={}}}' --cmd 'runtime init.lua' .

validate:
	python3 scripts/validate.py
	sh -n install.sh
	sh -n scripts/smoke-install.sh

smoke:
	$(SMOKE_CMD) -c '$(SMOKE_RTP)' -c 'Lazy! sync' -c qa
	$(SMOKE_CMD) -c qa
	$(COMMANDS_CMD) -c qa
	$(UPDATE_CONTRACT_CMD) -c qa
	$(SMOKE_DIR_CMD) -c 'lua dofile("scripts/smoke-directory.lua")' -c qa

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
