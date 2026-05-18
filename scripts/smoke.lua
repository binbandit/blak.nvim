-- Run with: NVIM_APPNAME=blak-test nvim --headless -u NONE --cmd 'set loadplugins' --cmd 'lua vim.opt.rtp:prepend(vim.fn.getcwd())' -c 'lua dofile("scripts/smoke.lua")' -c qa
-- This catches actual runtime/plugin-manager regressions in CI.
vim.g.blak_config = {
  ui = { splash = { enabled = false } },
  mason = { automatic_install = false },
}
require("blak").setup()
assert(require("blak.config").get())
assert(require("blak.config").get().explorer.provider == "oil", "Oil should be the default explorer provider")
assert(vim.fn.exists(":Lazy") == 2, "lazy.nvim command was not registered")
assert(vim.fn.exists(":BlakTerminal") == 2, "BlakTerminal command was not registered")
assert(vim.fn.maparg("<leader>/", "n", false, true).desc == "Grep", "<leader>/ grep mapping missing")
assert(vim.fn.maparg("<leader>tt", "n", false, true).desc == "Terminal", "<leader>tt terminal mapping missing")
assert(vim.fn.maparg("-", "n") == "", "Blak should leave native - unmapped")
local previous_oil = package.loaded.oil
local called_oil = false
local opened_dir = "unset"
package.loaded.oil = {
  open = function(dir)
    called_oil = true
    opened_dir = dir
  end,
}
vim.fn.maparg("<leader>e", "n", false, true).callback()
package.loaded.oil = previous_oil
assert(called_oil, "<leader>e did not call Oil")
assert(opened_dir == nil, "<leader>e should let Oil choose the current buffer directory")
local previous_snacks = package.loaded.snacks
local called_snacks = false
package.loaded.snacks = {
  explorer = function()
    called_snacks = true
  end,
}
require("blak.core.explorer").open({ explorer = { provider = "snacks" } })
package.loaded.snacks = previous_snacks
assert(called_snacks, "snacks explorer provider did not call Snacks.explorer")
local lazy_plugins = require("lazy.core.config").plugins
assert(lazy_plugins["tokyonight.nvim"], "tokyonight.nvim spec missing")
assert(lazy_plugins["tokyonight.nvim"].lazy == false, "tokyonight.nvim must load eagerly")
assert(
  lazy_plugins["tokyonight.nvim"].priority > lazy_plugins["snacks.nvim"].priority,
  "tokyonight.nvim must load before UI plugins"
)
if lazy_plugins["tokyonight.nvim"]._.loaded then
  assert(vim.g.colors_name == "tokyonight-night", "TokyoNight Night should be the default colorscheme")
end
assert(lazy_plugins["oil.nvim"], "oil.nvim spec missing")
assert(lazy_plugins["oil.nvim"].lazy == false, "oil.nvim must load eagerly for directory args")
assert(lazy_plugins["oil.nvim"].opts.default_file_explorer == true, "oil.nvim must take directory buffers")
vim.cmd("checkhealth blak")
