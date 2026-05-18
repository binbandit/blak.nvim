local M = {}

local uv = vim.uv or vim.loop
local timer
local watcher
local reloading = false

local function normalize_path(path)
  if not path or path == "" then
    return nil
  end
  return vim.fn.fnamemodify(path, ":p")
end

local function is_user_file(path)
  path = normalize_path(path)
  if not path then
    return false
  end
  return path:gsub("\\", "/"):match("/lua/blak/user%.lua$") ~= nil
end

local function user_files()
  local seen = {}
  local paths = {}
  local function add(path)
    path = normalize_path(path)
    if path and not seen[path] then
      seen[path] = true
      table.insert(paths, path)
    end
  end

  for _, path in ipairs(vim.api.nvim_get_runtime_file("lua/blak/user.lua", false)) do
    add(path)
  end
  add(require("blak.util").join(vim.fn.stdpath("config"), "lua", "blak", "user.lua"))
  return paths
end

local function user_file()
  for _, path in ipairs(user_files()) do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  return nil
end

local function stop_watcher()
  if watcher and not watcher:is_closing() then
    watcher:stop()
    watcher:close()
  end
  watcher = nil
end

local function refresh_runtime(config)
  local util = require("blak.util")
  vim.g.mapleader = config.leader
  vim.g.maplocalleader = config.localleader

  require("blak.core.options").setup(config)
  require("blak.theme").load(config)
  require("blak.core.commands").setup(config)
  require("blak.core.keymaps").setup(config)
  local lsp = package.loaded["blak.core.lsp"] or util.try_require("blak.core.lsp")
  if lsp then
    lsp.setup(config)
  end
  local formatting = package.loaded["blak.core.formatting"] or util.try_require("blak.core.formatting")
  if formatting then
    formatting.refresh(config)
  end
  local lazy = package.loaded["blak.lazy"] or util.try_require("blak.lazy")
  if lazy then
    lazy.refresh(config)
  end
  M.watch_user_file()

  if config.lsp.automatic_enable and vim.lsp.enable then
    local names = util.tbl_keys(config.lsp.servers)
    if #names > 0 then
      pcall(vim.lsp.enable, names)
    end
  end
end

function M.reload(opts)
  opts = opts or {}
  if reloading then
    return false
  end

  reloading = true
  local ok, result = pcall(function()
    local config = require("blak.config").reload()
    refresh_runtime(config)
    vim.api.nvim_exec_autocmds("User", {
      pattern = "BlakConfigReloaded",
      modeline = false,
      data = { path = opts.path or user_file() },
    })
    return config
  end)
  reloading = false

  if ok then
    if opts.notify ~= false then
      require("blak.util").notify("Reloaded lua/blak/user.lua")
    end
    return true, result
  end

  require("blak.util").warn("Could not reload lua/blak/user.lua: " .. tostring(result))
  return false, result
end

function M.schedule(opts)
  opts = opts or {}
  if timer and not timer:is_closing() then
    timer:stop()
  else
    timer = uv.new_timer()
  end
  if not timer then
    return M.reload(opts)
  end

  timer:start(
    opts.delay_ms or 80,
    0,
    vim.schedule_wrap(function()
      M.reload(opts)
    end)
  )
  return true
end

function M.watch_user_file()
  stop_watcher()

  local path = user_file()
  if not path then
    return
  end

  watcher = uv.new_fs_event()
  if not watcher then
    return
  end

  local ok = watcher:start(path, {}, function(err)
    if err then
      vim.schedule(function()
        require("blak.util").warn("Could not watch lua/blak/user.lua: " .. tostring(err))
      end)
      return
    end
    M.schedule({ path = path })
  end)
  if not ok then
    stop_watcher()
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("BlakUserConfig", { clear = true })
  local patterns = user_files()
  table.insert(patterns, "user.lua")
  table.insert(patterns, "*/lua/blak/user.lua")

  vim.api.nvim_create_autocmd({ "BufWritePost", "FileChangedShellPost" }, {
    group = group,
    pattern = patterns,
    callback = function(event)
      local path = normalize_path(vim.api.nvim_buf_get_name(event.buf)) or normalize_path(event.match)
      if is_user_file(path) then
        M.schedule({ path = path })
      end
    end,
  })

  M.watch_user_file()
end

return M
