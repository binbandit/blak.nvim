local M = {}

local uv = vim.uv or vim.loop
local timer
local watcher
local watched_file
local reloading = false

local function normalize_path(path)
  if not path or path == "" then
    return nil
  end
  return vim.fn.fnamemodify(path, ":p")
end

local function path_identity(path)
  path = normalize_path(path)
  if not path then
    return nil
  end
  return uv.fs_realpath(path)
    or vim.fs.joinpath(
      uv.fs_realpath(vim.fs.dirname(path)) or vim.fs.dirname(path),
      vim.fs.basename(path)
    )
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

local function user_file(paths)
  for _, path in ipairs(paths or user_files()) do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  return nil
end

local function user_target()
  local paths = user_files()
  return user_file(paths) or watched_file or paths[#paths]
end

local function is_user_file(path)
  return path ~= nil and path_identity(path) == path_identity(user_target())
end

local function stop_watcher()
  if watcher and not watcher:is_closing() then
    watcher:stop()
    watcher:close()
  end
  watcher = nil
end

local function file_identity(path)
  local stat = uv.fs_stat(path)
  return stat and { stat.dev, stat.ino, stat.size, stat.mtime.sec, stat.mtime.nsec } or nil
end

local function refresh_runtime(config)
  vim.g.mapleader = config.leader
  vim.g.maplocalleader = config.localleader

  require("blak.core.options").setup(config)
  require("blak.theme").load(config)
  require("blak.core.commands").setup(config)
  require("blak.core.keymaps").setup(config)
  require("blak.lazy").refresh(config)
  if package.loaded["mason-lspconfig"] then
    require("blak.core.lsp").refresh(config)
  elseif package.loaded["blak.core.lsp"] then
    require("blak.core.lsp").setup(config)
  end
  require("blak.core.formatting").refresh(config)
  require("blak.core.completion").refresh(config)
  M.watch_user_file()
end

function M.reload(opts)
  opts = opts or {}
  if vim.g.blak_loading then
    M.schedule(opts)
    return false
  end
  if reloading then
    return false
  end

  reloading = true
  local ok, result = pcall(function()
    local config = require("blak.config").reload()
    refresh_runtime(config)
    require("blak.config").run_hooks(config, "after")
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
    return not vim.g.blak_loading and M.reload(opts) or false
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

local function watch_user_file(path)
  path = path_identity(path)
  if watcher and not watcher:is_closing() and watched_file == path then
    return
  end
  stop_watcher()
  watched_file = path

  -- Watch the directory so atomic saves, failed reloads, and file recreation
  -- keep using the same watch instead of following a replaced file's inode.
  local directory = path and vim.fs.dirname(path)
  if not directory or vim.fn.isdirectory(directory) ~= 1 then
    return
  end
  local name = vim.fs.basename(path)
  local observed = file_identity(path)

  watcher = uv.new_fs_event()
  if not watcher then
    return
  end

  local ok = watcher:start(directory, {}, function(err, filename)
    if err then
      vim.schedule(function()
        require("blak.util").warn("Could not watch lua/blak/user.lua: " .. tostring(err))
      end)
      return
    end
    if filename == nil or filename == name then
      local current = file_identity(path)
      -- Directory watches may deliver events queued before registration.
      -- Ignore unchanged files, including sibling/metadata-only events.
      if not vim.deep_equal(observed, current) then
        observed = current
        M.schedule({ path = path })
      end
    end
  end)
  if not ok then
    stop_watcher()
  end
end

function M.watch_user_file()
  watch_user_file(user_target())
end

function M.setup()
  local group = vim.api.nvim_create_augroup("BlakUserConfig", { clear = true })
  local paths = user_files()
  local patterns = vim.deepcopy(paths)
  for _, path in ipairs(paths) do
    table.insert(patterns, path_identity(path))
  end
  table.insert(patterns, "user.lua")
  table.insert(patterns, "*/lua/blak/user.lua")

  vim.api.nvim_create_autocmd({ "BufWritePost", "FileChangedShellPost" }, {
    group = group,
    pattern = patterns,
    callback = function(event)
      local path = normalize_path(vim.api.nvim_buf_get_name(event.buf))
        or normalize_path(event.match)
      if is_user_file(path) then
        M.schedule({ path = path })
      end
    end,
  })

  watch_user_file(user_file(paths) or watched_file or paths[#paths])
end

return M
