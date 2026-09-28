-- Exercise real filesystem notifications with disposable XDG paths.
local util = require("blak.util")
local config = require("blak.config")
local reload = require("blak.core.reload")
local path = util.join(vim.fn.stdpath("config"), "lua", "blak", "user.lua")
local original = util.read_file(path)
local notify, warn = util.notify, util.warn
local warnings, successes = 0, 0
util.notify = function() end
util.warn = function()
  warnings = warnings + 1
end

local function write_config(tabstop)
  util.write_file(path .. ".pending", "return { editor = { tabstop = " .. tabstop .. " } }")
  assert(vim.uv.fs_rename(path .. ".pending", path))
end

local function wait_for(predicate, message)
  assert(vim.wait(3000, predicate, 10), message)
end

local ok, err = xpcall(function()
  vim.fn.delete(path)
  util.mkdir(vim.fs.dirname(path))
  package.loaded["blak.user"] = nil
  config.setup({ ui = { colorscheme = "habamax" }, mason = { automatic_install = false } })
  vim.api.nvim_create_autocmd("User", {
    pattern = "BlakConfigReloaded",
    callback = function()
      successes = successes + 1
    end,
  })
  reload.setup()
  -- Give the OS time to register its first directory watch.
  vim.wait(500, function()
    return false
  end)

  write_config(3)
  wait_for(function()
    return config.get().editor.tabstop == 3
  end, "creating user.lua externally did not reload config")

  util.write_file(path .. ".pending", "return { invalid =")
  assert(vim.uv.fs_rename(path .. ".pending", path))
  wait_for(function()
    return warnings > 0
  end, "invalid atomic save was not observed")
  assert(config.get().editor.tabstop == 3, "invalid save discarded the working config")

  write_config(5)
  wait_for(function()
    return config.get().editor.tabstop == 5
  end, "watcher did not recover after correcting an invalid atomic save")

  vim.fn.delete(path)
  wait_for(function()
    return config.get().editor.tabstop == require("blak.config.defaults").editor.tabstop
  end, "deleting user.lua did not reload defaults")
  write_config(7)
  wait_for(function()
    return config.get().editor.tabstop == 7
  end, "recreating user.lua did not recover the watcher")

  local before = successes
  local sibling = util.join(vim.fs.dirname(path), "unrelated.lua")
  util.write_file(sibling, "return {}")
  vim.wait(500, function()
    return false
  end)
  assert(successes == before, "saving a sibling file reloaded user config")
  vim.fn.delete(sibling)

  local unrelated = vim.fn.tempname() .. "/lua/blak/user.lua"
  util.write_file(unrelated, "return {}")
  local buf = vim.fn.bufadd(unrelated)
  vim.api.nvim_exec_autocmds("BufWritePost", { buffer = buf, modeline = false })
  vim.wait(500, function()
    return false
  end)
  assert(successes == before, "saving another project's user.lua reloaded Blak config")
  vim.fn.delete(vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(unrelated))), "rf")

  local linked = vim.fn.tempname()
  assert(vim.uv.fs_symlink(vim.fs.dirname(path), linked))
  local linked_buf = vim.fn.bufadd(linked .. "/user.lua")
  vim.api.nvim_exec_autocmds("BufWritePost", { buffer = linked_buf, modeline = false })
  wait_for(function()
    return successes > before
  end, "saving the active config through a directory symlink was ignored")
  vim.fn.delete(linked)

  -- An unrelated save must not redirect the watch away from the active config.
  write_config(9)
  wait_for(function()
    return config.get().editor.tabstop == 9
  end, "an unrelated save redirected the config watcher")

  before = successes
  local stat = assert(vim.uv.fs_stat(path))
  assert(vim.uv.fs_chmod(path, stat.mode % 512))
  vim.wait(500, function()
    return false
  end)
  assert(successes == before, "an unchanged-file event reloaded user config")

  vim.g.blak_loading = true
  write_config(11)
  vim.wait(500, function()
    return false
  end)
  assert(config.get().editor.tabstop == 9, "config reloaded during startup")
  assert(successes == before, "startup edit emitted a premature reload event")
  vim.g.blak_loading = false
  wait_for(function()
    return config.get().editor.tabstop == 11
  end, "a genuine config edit during startup was discarded")
end, debug.traceback)

vim.g.blak_loading = false
if original then
  util.write_file(path, original)
else
  vim.fn.delete(path)
end
util.notify, util.warn = notify, warn
assert(ok, err)
print("Config filesystem watcher checks passed")
