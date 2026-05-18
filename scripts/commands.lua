-- Run with: NVIM_APPNAME=blak-test nvim --headless -u NONE --cmd 'set loadplugins' --cmd 'lua vim.opt.rtp:prepend(vim.fn.getcwd())' -c 'lua dofile("scripts/commands.lua")' -c qa
-- Exercises every public :Blak command without doing network updates.

local command_names = {
  "Blak",
  "BlakDoctor",
  "BlakKeys",
  "BlakNews",
  "BlakConfig",
  "BlakPick",
  "BlakExtras",
  "BlackExtras",
  "BlakUpdate",
  "BlakUpgrade",
  "BlakRollback",
  "BlakToolsInstall",
  "BlakTreesitterInstall",
  "BlakTerminal",
  "BlakFormat",
  "BlakFormatToggle",
  "BlakSplash",
}

local picker_kinds = {
  "smart",
  "files",
  "grep",
  "buffers",
  "recent",
  "commands",
  "keymaps",
  "help",
  "diagnostics",
  "lsp_symbols",
  "workspace_symbols",
}

local sep = package.config:sub(1, 1)

local function join(...)
  local out = {}
  for _, part in ipairs({ ... }) do
    if part and part ~= "" then
      table.insert(out, (tostring(part):gsub("[/\\]+$", "")))
    end
  end
  return table.concat(out, sep)
end

local function read_file(path)
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end
  local data = fd:read("*a")
  fd:close()
  return data
end

local function write_file(path, data)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local fd = assert(io.open(path, "w"))
  fd:write(data)
  fd:close()
end

local extras_state = join(vim.fn.stdpath("state"), "blak", "extras.json")
local original_extras_state = read_file(extras_state)
vim.fn.delete(extras_state)

vim.g.blak_config = {
  ui = { splash = { enabled = false, animate = false } },
  mason = { automatic_install = false, ensure_installed = {} },
  treesitter = { ensure_installed = {} },
  lsp = { automatic_enable = false, servers = {} },
  format = { enabled = false, formatters_by_ft = {} },
  lint = { events = {}, linters_by_ft = {} },
}

local function restore_file(path, original)
  if original then
    write_file(path, original)
  else
    vim.fn.delete(path)
  end
end

local original_lock
local lockfile
local original_user_file
local user_file

local function fail(message)
  error(message, 2)
end

local function assert_contains(label, text, needle)
  if not text:find(needle, 1, true) then
    fail(label .. " did not contain " .. needle)
  end
end

local function current_text()
  return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
end

local function wipe_current()
  local buf = vim.api.nvim_get_current_buf()
  pcall(vim.api.nvim_buf_delete, buf, { force = true })
end

local function run(label, command)
  local ok, err = pcall(vim.cmd, command)
  if not ok then
    fail(label .. " failed: " .. tostring(err))
  end
end

local function has_value(values, expected)
  for _, value in ipairs(values or {}) do
    if value == expected then
      return true
    end
  end
  return false
end

local function fake_picker()
  local provider = {}
  for _, kind in ipairs(picker_kinds) do
    provider[kind] = function()
      vim.g.blak_command_test_picker_kind = kind
    end
  end
  return provider
end

local function main()
  require("blak").setup()
  vim.opt.rtp:prepend(vim.fn.getcwd())

  local util = require("blak.util")
  lockfile = util.join(vim.fn.stdpath("config"), "lazy-lock.json")
  original_lock = util.read_file(lockfile)
  user_file = util.join(vim.fn.stdpath("config"), "lua", "blak", "user.lua")
  original_user_file = util.read_file(user_file)

  for _, name in ipairs(command_names) do
    assert(vim.fn.exists(":" .. name) == 2, ":" .. name .. " was not registered")
  end

  run("Blak overview", "Blak")
  local overview = current_text()
  for _, name in ipairs(command_names) do
    assert_contains(":Blak overview", overview, ":" .. name)
  end
  wipe_current()

  run("BlakDoctor", "BlakDoctor")

  run("BlakKeys", "BlakKeys")
  assert_contains(":BlakKeys", current_text(), "Blak keymaps")
  assert_contains(":BlakKeys", current_text(), "Terminal")
  wipe_current()

  run("BlakNews", "BlakNews")
  assert_contains(":BlakNews", current_text(), "Blak")
  wipe_current()

  vim.fn.delete(user_file)
  run("BlakConfig", "BlakConfig")
  assert(vim.api.nvim_buf_get_name(0) == user_file, "BlakConfig did not edit lua/blak/user.lua")
  local user_config = util.read_file(user_file) or ""
  assert_contains(":BlakConfig", user_config, "return")
  assert_contains(":BlakConfig", user_config, "blak.UserConfig")
  wipe_current()

  package.loaded["blak.providers.picker.fff"] = nil
  package.preload["blak.providers.picker.fff"] = fake_picker
  for _, kind in ipairs(picker_kinds) do
    vim.g.blak_command_test_picker_kind = nil
    run("BlakPick " .. kind, "BlakPick " .. kind)
    assert(vim.g.blak_command_test_picker_kind == kind, "BlakPick did not dispatch " .. kind)
  end

  run("BlakExtras", "BlakExtras")
  assert(vim.bo.filetype == "blak-extras", "BlakExtras did not open the extras UI")
  assert_contains(":BlakExtras", current_text(), "Enable or disable extras with x")
  wipe_current()

  run("BlakExtras list", "BlakExtras list")
  assert(vim.bo.filetype == "blak-extras", "BlakExtras list did not open the extras UI")
  assert_contains(":BlakExtras list", current_text(), "Enable or disable extras with x")
  assert_contains(":BlakExtras list", current_text(), "lang.rust")
  assert_contains(":BlakExtras list", current_text(), "ui.lualine")
  assert_contains(":BlakExtras list", current_text(), "editor.snacks-explorer")
  wipe_current()

  run("BlackExtras list", "BlackExtras list")
  assert(vim.bo.filetype == "blak-extras", "BlackExtras list did not open the extras UI")
  assert_contains(":BlackExtras list", current_text(), "lang.rust")
  wipe_current()

  run("BlackExtras enable", "BlackExtras enable editor.telescope")
  assert(has_value(require("blak.extras.state").read(), "editor.telescope"), "BlackExtras enable did not persist state")
  local config = require("blak.config").get()
  assert(config.picker.provider == "telescope", "BlakExtras enable did not apply config in-session")

  run("BlakExtras disable", "BlakExtras disable editor.telescope")
  assert(not has_value(require("blak.extras.state").read(), "editor.telescope"), "BlakExtras disable did not persist state")
  config.mason.ensure_installed = {}
  config.treesitter.ensure_installed = {}

  run("BlakExtras enable rust", "BlakExtras enable lang.rust")
  assert(has_value(require("blak.extras.state").read(), "lang.rust"), "BlakExtras enable did not persist lang.rust")
  assert(require("lazy.core.config").plugins["crates.nvim"], "lang.rust did not register crates.nvim")

  run("BlakExtras disable rust", "BlakExtras disable lang.rust")
  assert(not has_value(require("blak.extras.state").read(), "lang.rust"), "BlakExtras disable did not persist lang.rust")
  config.mason.ensure_installed = {}
  config.treesitter.ensure_installed = {}

  local extras = require("blak.extras")
  assert(has_value(extras.complete("en", "BlakExtras en"), "enable"), "BlakExtras action completion missed enable")
  assert(has_value(extras.complete("en", "BlackExtras en"), "enable"), "BlackExtras action completion missed enable")
  assert(has_value(extras.complete("lang.r", "BlakExtras enable lang.r"), "lang.rust"), "BlakExtras id completion missed lang.rust")

  local lazy_calls = {}
  pcall(vim.api.nvim_del_user_command, "Lazy")
  vim.api.nvim_create_user_command("Lazy", function(opts)
    table.insert(lazy_calls, opts.args)
    if opts.args == "update" then
      vim.api.nvim_exec_autocmds("User", { pattern = "LazyUpdatePre", modeline = false })
    end
  end, { nargs = "*", bang = true })

  local backup_dir = util.join(vim.fn.stdpath("state"), "blak", "lockbacks")
  vim.fn.delete(backup_dir, "rf")
  util.write_file(lockfile, '{"plugins":{"before":true}}')

  run("BlakUpdate", "BlakUpdate")
  assert(lazy_calls[#lazy_calls] == "update", "BlakUpdate did not run Lazy update")
  local backups = vim.fn.glob(util.join(backup_dir, "lazy-lock-*.json"), false, true)
  assert(#backups == 1, "BlakUpdate should create exactly one backup")

  run("BlakUpgrade", "BlakUpgrade")
  assert(lazy_calls[#lazy_calls] == "update", "BlakUpgrade did not run Lazy update")
  backups = vim.fn.glob(util.join(backup_dir, "lazy-lock-*.json"), false, true)
  assert(#backups == 2, "BlakUpgrade should create a unique backup")

  util.write_file(lockfile, '{"plugins":{"after":true}}')
  run("BlakRollback", "BlakRollback")
  assert(lazy_calls[#lazy_calls] == "restore", "BlakRollback did not run Lazy restore")
  assert_contains(":BlakRollback lockfile", util.read_file(lockfile) or "", '"before"')

  run("BlakExtras sync", "BlakExtras sync")
  assert(lazy_calls[#lazy_calls] == "sync", "BlakExtras sync did not run Lazy sync")

  run("BlakToolsInstall", "BlakToolsInstall")
  run("BlakTreesitterInstall", "BlakTreesitterInstall")

  local formatted = false
  package.loaded.conform = {
    format = function(opts)
      formatted = opts and opts.lsp_format == "fallback"
    end,
  }
  run("BlakFormat", "BlakFormat")
  assert(formatted, "BlakFormat did not call conform.format")

  vim.b.blak_disable_autoformat = false
  run("BlakFormatToggle", "BlakFormatToggle")
  assert(vim.b.blak_disable_autoformat == true, "BlakFormatToggle did not toggle buffer state")

  vim.g.blak_disable_autoformat = false
  run("BlakFormatToggle!", "BlakFormatToggle!")
  assert(vim.g.blak_disable_autoformat == true, "BlakFormatToggle! did not toggle global state")

  run("BlakTerminal", "BlakTerminal printf blak")
  vim.cmd("stopinsert")
  assert(vim.bo.buftype == "terminal", "BlakTerminal did not open a terminal buffer")
  run("BlakTerminal close", "BlakTerminal")

  run("BlakSplash", "BlakSplash")
  assert(vim.bo.filetype == "blak-splash", "BlakSplash did not open a splash buffer")
  wipe_current()
end

local ok, err = xpcall(main, debug.traceback)

if lockfile then
  restore_file(lockfile, original_lock)
end
if user_file then
  restore_file(user_file, original_user_file)
end
restore_file(extras_state, original_extras_state)

if not ok then
  error(err)
end
