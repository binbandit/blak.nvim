-- Fast regression checks, run with isolated XDG paths by scripts/smoke.sh.
for _, path in ipairs(vim.fn.glob("lua/**/*.lua", false, true)) do
  assert(loadfile(path))
end

local defaults = require("blak.config.defaults")
local util = require("blak.util")
local function config()
  return vim.deepcopy(defaults)
end

-- Corrupt but valid JSON must not crash startup or leak non-string IDs.
local state_path = util.join(vim.fn.stdpath("state"), "blak", "extras.json")
for _, data in ipairs({ '{"enabled":true}', '{"enabled":[3]}', '{"enabled":{"x":true}}', "null" }) do
  util.write_file(state_path, data)
  assert(
    vim.deep_equal(require("blak.extras.state").read(), {}),
    "invalid extras state accepted: " .. data
  )
end
util.write_file(state_path, '{"enabled":[]}')

for _, case in ipairs({
  { "ui", false, "ui must be table" },
  { "mason", false, "mason must be table" },
  { "performance", false, "performance must be table" },
  { "lsp", { servers = { lua_ls = false } }, "lsp.servers.lua_ls must be table" },
  { "extras", { enabled = { bogus = true } }, "extras.enabled must be a list" },
  { "editor", { tabstop = -1 }, "editor.tabstop must be an integer" },
}) do
  local c = config()
  c[case[1]] = type(case[2]) == "table" and vim.tbl_deep_extend("force", c[case[1]], case[2])
    or case[2]
  local ok, err = pcall(require("blak.config.schema").validate, c)
  assert(
    not ok and tostring(err):find(case[3], 1, true),
    "missing config error: " .. case[3] .. ": " .. tostring(err)
  )
end

local c = config()
local lint_calls = 0
package.loaded.lint = {
  linters = {},
  try_lint = function()
    lint_calls = lint_calls + 1
  end,
}
local linting = require("blak.core.linting")
linting.setup(c)
vim.api.nvim_exec_autocmds("InsertLeave", { modeline = false })
assert(lint_calls == 1)
c.lint.events = {}
linting.setup(c)
vim.api.nvim_exec_autocmds("InsertLeave", { modeline = false })
assert(lint_calls == 1, "disabling lint events left old hooks active")

local keys = require("blak.core.keymaps")
vim.g.mapleader = " "
keys.setup(c)
vim.g.mapleader = ","
keys.setup(c)
assert(vim.fn.maparg(" ff", "n") == "", "leader reload left old shortcuts bound")
assert(vim.fn.maparg(",ff", "n") ~= "", "new leader shortcut missing")
keys.show()
vim.cmd("close")
keys.apply_extra({
  { lhs = "<leader>ff", rhs = "<cmd>echo 'override'<cr>", desc = "Override files" },
})
keys.show()
local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
assert(text:find("<leader>ff%s+Override files"), "showing keymaps corrupted the registry lookup")
vim.cmd("close")

c.keymaps = { { key = "gd", action = "<cmd>echo 'custom'<cr>", description = "Custom definition" } }
keys.setup(c)
vim.api.nvim_exec_autocmds("LspAttach", { buffer = 0, modeline = false, data = { client_id = 1 } })
assert(
  vim.fn.maparg("gd", "n", false, true).desc == "Custom definition",
  "LSP attach shadowed user mapping"
)
c.keymaps = {}
keys.setup(c)
vim.api.nvim_exec_autocmds("LspAttach", { buffer = 0, modeline = false, data = { client_id = 1 } })
c.keymaps = { { key = "gd", disable = true } }
keys.setup(c)
assert(vim.fn.maparg("gd", "n") == "", "reload failed to disable existing buffer-local LSP mapping")

-- Ownership must use the target scope even when another buffer is current.
local other = vim.api.nvim_create_buf(true, false)
c.keymaps = {}
keys.setup(c)
vim.api.nvim_exec_autocmds(
  "LspAttach",
  { buffer = other, modeline = false, data = { client_id = 1 } }
)
c.keymaps = { { key = "gd", disable = true } }
keys.setup(c)
for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(other, "n")) do
  assert(mapping.lhs ~= "gd", "reload left an LSP mapping in a noncurrent buffer")
end
vim.api.nvim_buf_delete(other, { force = true })

-- Reading a hidden buffer must not move the visible buffer's cursor.
require("blak.core.autocmds").setup(c)
local visible = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(visible, 0, -1, false, { "one", "two", "three" })
vim.api.nvim_win_set_cursor(0, { 1, 0 })
other = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_lines(other, 0, -1, false, { "one", "two", "three" })
vim.api.nvim_buf_set_mark(other, '"', 3, 0, {})
vim.api.nvim_exec_autocmds("BufReadPost", { buffer = other, modeline = false })
assert(vim.api.nvim_win_get_cursor(0)[1] == 1, "background read moved the visible cursor")
vim.api.nvim_buf_delete(other, { force = true })

vim.keymap.set("n", ",ff", "<nop>", { buffer = true, desc = "Local files" })
c.keymaps = {}
keys.setup(c)
vim.g.mapleader = ";"
keys.setup(c)
for _, mapping in ipairs(vim.api.nvim_get_keymap("n")) do
  assert(mapping.lhs ~= ",ff", "local mapping hid ownership of the old global leader mapping")
end
assert(
  vim.fn.maparg(",ff", "n", false, true).desc == "Local files",
  "reload deleted a user mapping"
)
vim.keymap.del("n", ",ff", { buffer = true })

local opts = require("blak.core.lsp").mason_opts(c)
assert(
  vim.deep_equal(opts.automatic_enable, { "lua_ls" }),
  "Mason activates unconfigured installed servers"
)
c.mason.automatic_install = false
assert(
  #require("blak.core.lsp").mason_opts(c).ensure_installed == 0,
  "automatic_install=false still installs LSPs"
)
local lsp = require("blak.core.lsp")
c.lsp.servers.lua_ls.settings.Lua.test_removed = true
lsp.setup(c)
c.lsp.servers.lua_ls.settings.Lua.test_removed = nil
lsp.setup(c)
assert(
  vim.lsp.config.lua_ls.settings.Lua.test_removed == nil,
  "LSP reload retained removed settings"
)

require("blak.core.options").setup(c)
c.editor.clipboard = false
require("blak.core.options").setup(c)
assert(
  not vim.o.clipboard:find("unnamed", 1, true),
  "clipboard=false did not undo shared clipboard"
)

-- Every extra must build independently and retain user LSP settings.
for _, extra in ipairs(require("blak.extras").all()) do
  local single = config()
  require("blak.extras").apply_one(single, extra.id)
  require("blak.config.schema").validate(single)
  assert(type(require("blak.plugins").specs(single)) == "table", "invalid specs for " .. extra.id)
end

local custom = config()
custom.lsp.servers.rust_analyzer =
  { settings = { ["rust-analyzer"] = { check = { command = "check" } } } }
require("blak.extras").apply_one(custom, "lang.rust")
assert(
  custom.lsp.servers.rust_analyzer.settings["rust-analyzer"].check.command == "check",
  "extra overwrote user LSP settings"
)
custom.snacks.dim = { enabled = false }
require("blak.extras").apply_one(custom, "ui.dim")
assert(custom.snacks.dim.enabled == false, "extra overwrote explicit Snacks setting")

-- Missing snapshot data must abort before restoring any live file.
local update = require("blak.core.update")
local lock = util.join(vim.fn.stdpath("config"), "lazy-lock.json")
local user = util.join(vim.fn.stdpath("config"), "lua", "blak", "user.lua")
local original_lock = util.read_file(lock)
local original_user = util.read_file(user)
util.write_file(lock, '{"before":true}')
util.write_file(user, "return {}")
local snapshot = update.backup()
util.write_file(lock, '{"after":true}')
util.write_file(user, "return { editor = { clipboard = false } }")
vim.fn.delete(util.join(snapshot, "user.lua"))
local restored = false
vim.api.nvim_create_user_command("Lazy", function()
  restored = true
end, { nargs = "*" })
update.rollback()
assert(not restored, "corrupt snapshot invoked Lazy restore")
assert(util.read_file(lock) == '{"after":true}', "corrupt snapshot partially restored the lockfile")
assert(util.read_file(user):find("clipboard", 1, true), "corrupt snapshot changed user config")

-- A failed backup never creates a usable rollback point or runs an update.
local copy = util.copy_file
util.copy_file = function()
  return false
end
local ok = pcall(update.update)
util.copy_file = copy
assert(not ok and not restored, "failed backup did not abort the update")
if original_lock then
  util.write_file(lock, original_lock)
else
  vim.fn.delete(lock)
end
if original_user then
  util.write_file(user, original_user)
else
  vim.fn.delete(user)
end

-- Reusing the terminal window for editing must not close that editing window.
vim.cmd("only")
local terminal = require("blak.core.terminal")
terminal.toggle_native({ cmd = "cat" })
vim.cmd("stopinsert")
local terminal_buf = vim.api.nvim_get_current_buf()
vim.cmd("enew")
local editing_win = vim.api.nvim_get_current_win()
terminal.toggle_native()
vim.cmd("stopinsert")
assert(vim.api.nvim_win_is_valid(editing_win), "terminal toggle closed a reused editing window")
assert(vim.api.nvim_get_current_buf() == terminal_buf, "terminal buffer was not reused")
vim.api.nvim_buf_delete(terminal_buf, { force = true })

vim.cmd("tabnew")
local tab = vim.api.nvim_get_current_tabpage()
terminal.toggle_native({ cmd = "cat" })
vim.cmd("stopinsert")
terminal_buf = vim.api.nvim_get_current_buf()
vim.cmd("only")
local float_buf = vim.api.nvim_create_buf(false, true)
local float = vim.api.nvim_open_win(float_buf, false, {
  relative = "editor",
  row = 1,
  col = 1,
  width = 10,
  height = 2,
})
terminal.toggle_native()
assert(vim.api.nvim_tabpage_is_valid(tab), "hiding the last terminal window destroyed its tab")
assert(vim.api.nvim_get_current_buf() ~= terminal_buf, "last terminal window was not hidden")
vim.api.nvim_win_close(float, true)
vim.api.nvim_buf_delete(float_buf, { force = true })
vim.api.nvim_buf_delete(terminal_buf, { force = true })
vim.cmd("tabclose")

print("Regression checks passed")
