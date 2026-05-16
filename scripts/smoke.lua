-- Run with: NVIM_APPNAME=blak-test nvim --headless -u NONE --cmd 'set loadplugins' --cmd 'lua vim.opt.rtp:prepend(vim.fn.getcwd())' -c 'lua dofile("scripts/smoke.lua")' -c qa
-- This catches actual runtime/plugin-manager regressions in CI.
vim.g.blak_config = {
  ui = { splash = { enabled = false } },
  mason = { automatic_install = false },
}
require("blak").setup()
assert(require("blak.config").get())
assert(vim.fn.exists(":Lazy") == 2, "lazy.nvim command was not registered")
assert(vim.fn.exists(":BlakTerminal") == 2, "BlakTerminal command was not registered")
assert(vim.fn.maparg("<leader>/", "n", false, true).desc == "Grep", "<leader>/ grep mapping missing")
assert(vim.fn.maparg("<leader>tt", "n", false, true).desc == "Terminal", "<leader>tt terminal mapping missing")
assert(vim.fn.maparg("-", "n") == "", "Blak should leave native - unmapped")
local lazy_plugins = require("lazy.core.config").plugins
assert(lazy_plugins["oil.nvim"], "oil.nvim spec missing")
assert(lazy_plugins["oil.nvim"].lazy == false, "oil.nvim must load eagerly for directory args")
assert(lazy_plugins["oil.nvim"].opts.default_file_explorer == true, "oil.nvim must take directory buffers")
vim.cmd("checkhealth blak")
