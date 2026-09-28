local config = require("blak.config")
package.loaded["blak.user"] = function(c)
  c.lsp.servers.lua_ls = nil
  c.format.formatters_by_ft.lua = nil
  c.editor.tabstop = 4
end
local c = config.setup({ editor = { tabstop = 8 } })
assert(c.lsp.servers.lua_ls == nil, "config function's deleted LSP default was restored")
assert(c.format.formatters_by_ft.lua == nil, "config function's deleted formatter was restored")
assert(c.editor.tabstop == 8, "setup overrides no longer take precedence")
assert(require("blak.config.defaults").lsp.servers.lua_ls, "user function mutated shared defaults")
package.loaded["blak.user"] = function(c2)
  c2.lsp.servers.lua_ls = nil
  return { editor = { tabstop = 3 } }
end
c = config.setup()
assert(
  c.lsp.servers.lua_ls == nil and c.editor.tabstop == 3,
  "partial return discarded config function mutations"
)

local temp = vim.fn.tempname()
require("blak.util").write_file(
  temp .. "/lua/blak/user.lua",
  [[
return function(config)
  config.lsp.servers.lua_ls = nil
  config.format.formatters_by_ft.lua = nil
end
]]
)
vim.opt.rtp:prepend(temp)
c = config.reload()
assert(
  c.lsp.servers.lua_ls == nil and c.format.formatters_by_ft.lua == nil,
  "file-based reload restored deleted defaults"
)

-- A mode typo must fail while building the config, before reload can replace
-- the accepted config and start clearing/reinstalling active keymaps.
local user_file = temp .. "/lua/blak/user.lua"
for _, mode in ipairs({ '"normal"', '{ "n", "normal" }' }) do
  require("blak.util").write_file(
    user_file,
    'return { leader = ",", keymaps = { { key = "probe", action = "<Nop>", description = "Probe", mode = '
      .. mode
      .. " } } }"
  )
  local ok, err = pcall(config.reload)
  assert(
    not ok and tostring(err):find("keymaps[1].mode", 1, true),
    "invalid keymap mode passed validation"
  )
  assert(config.get() == c, "invalid keymap mode replaced the accepted configuration")
end

for _, mode in ipairs({ "", "n", "v", "x", "s", "o", "i", "l", "c", "t", "!", "ia", "ca", "!a" }) do
  local valid = vim.deepcopy(c)
  valid.keymaps = { { key = "probe", action = "<Nop>", description = "Probe", mode = mode } }
  require("blak.config.schema").validate(valid)
end
vim.opt.rtp:remove(temp)
vim.fn.delete(temp, "rf")

-- nvim-lint's lazy linter lookup throws for an unknown name.
package.loaded.lint = {
  linters = setmetatable({
    blak_broken_linter = function()
      error("broken factory")
    end,
  }, {
    __index = function()
      error("unknown linter")
    end,
  }),
}
c.picker.provider = "snacks"
c.lint.linters_by_ft = { lua = { "blak_unknown_linter", "blak_broken_linter" } }
local warnings, sections = {}, {}
vim.health = {
  start = function(message)
    table.insert(sections, message)
  end,
  ok = function() end,
  info = function() end,
  error = function() end,
  warn = function(message)
    table.insert(warnings, message)
  end,
}
require("blak.core.health").check()
assert(vim.tbl_contains(sections, "Mason tools"), "unknown linter aborted later health checks")
assert(
  table.concat(warnings, "\n"):find("blak_unknown_linter", 1, true),
  "unknown linter was not reported"
)
assert(
  table.concat(warnings, "\n"):find("blak_broken_linter", 1, true),
  "failing linter factory was not reported"
)
print("Config and health checks passed")
