-- Run with: NVIM_APPNAME=blak-test nvim --headless -u NONE --cmd 'set loadplugins' --cmd 'lua vim.opt.rtp:prepend(vim.fn.getcwd())' -c 'lua dofile("scripts/smoke.lua")' -c qa
-- This catches actual runtime/plugin-manager regressions in CI.
vim.g.blak_config = {
  ui = { splash = { enabled = false } },
  mason = { automatic_install = false },
}
require("blak").setup()
assert(require("blak.config").get())
assert(vim.fn.exists(":Lazy") == 2, "lazy.nvim command was not registered")
vim.cmd("checkhealth blak")
