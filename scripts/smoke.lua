-- Run with: NVIM_APPNAME=blak-test nvim --headless -u NONE --cmd 'set rtp^=.' -c 'lua dofile("scripts/smoke.lua")' -c qa
-- This catches actual runtime/plugin-manager regressions in CI.
vim.g.blak_config = {
  ui = { splash = { enabled = false } },
  mason = { automatic_install = false },
}
require("blak").setup()
assert(require("blak.config").get())
vim.cmd("checkhealth blak")
