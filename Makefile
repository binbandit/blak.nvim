.PHONY: validate smoke zip

SMOKE_NVIM_APPNAME ?= blak-test
SMOKE_RTP = lua vim.opt.rtp:prepend(vim.fn.getcwd())
SMOKE_CMD = NVIM_APPNAME=$(SMOKE_NVIM_APPNAME) nvim --headless -u NONE --cmd 'set loadplugins' --cmd '$(SMOKE_RTP)' -c 'lua dofile("scripts/smoke.lua")'

validate:
	python3 scripts/validate.py

smoke:
	$(SMOKE_CMD) -c '$(SMOKE_RTP)' -c 'Lazy! sync' -c qa
	$(SMOKE_CMD) -c qa

zip:
	cd .. && zip -r blak.nvim.zip blak.nvim -x 'blak.nvim/.git/*'
