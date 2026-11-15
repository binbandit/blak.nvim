local M = {}

local function ensure_blak_package_path()
  local source = debug.getinfo(1, "S").source
  if source:sub(1, 1) ~= "@" then
    return
  end

  local lua_dir = vim.fn.fnamemodify(source:sub(2), ":p:h:h")
  local patterns = {
    lua_dir .. "/?.lua",
    lua_dir .. "/?/init.lua",
  }

  for index = #patterns, 1, -1 do
    local pattern = patterns[index]
    if not package.path:find(pattern, 1, true) then
      package.path = pattern .. ";" .. package.path
    end
  end
end

-- The checkout's lazy-lock.json holds Blak's shipped pins: every plugin that
-- core or an extra can install, at the commit the release was tested with.
-- The user's own lockfile lives in stdpath("state"), so updates never modify
-- the checkout and `git pull` stays clean.
function M.shipped_lockfile()
  return require("blak.util").join(vim.fn.stdpath("config"), "lazy-lock.json")
end

function M.lockfile()
  return require("blak.util").join(vim.fn.stdpath("state"), "blak", "lazy-lock.json")
end

local function read_lock(path)
  local ok, lock = pcall(vim.json.decode, require("blak.util").read_file(path) or "")
  return ok and type(lock) == "table" and lock or nil
end

-- Same layout as lazy.nvim's own writer, so its later writes stay small diffs.
local function write_lock(path, lock)
  local names = vim.tbl_keys(lock)
  table.sort(names)
  local lines = {}
  for _, name in ipairs(names) do
    local pin = lock[name]
    table.insert(
      lines,
      string.format('  %q: { "branch": %q, "commit": %q }', name, pin.branch, pin.commit)
    )
  end
  require("blak.util").write_file(path, "{\n" .. table.concat(lines, ",\n") .. "\n}\n")
end

---Add shipped pins for plugins the user's lockfile has no entry for, so every
---plugin is first installed at the commit Blak ships. Existing entries (the
---user's updates and rollbacks) always win. lazy.nvim drops entries for
---plugins without a spec whenever it writes, so this runs before every install.
---@return boolean created the user lockfile did not exist before
function M.seed_lockfile()
  local util = require("blak.util")
  local path = M.lockfile()
  local shipped = read_lock(M.shipped_lockfile()) or {}
  local existed = util.file_exists(path)
  local user = existed and read_lock(path) or nil
  if existed and not user then
    -- Leave an unreadable lockfile alone; lazy.nvim reports it on its own.
    return false
  end
  user = user or {}

  local added = false
  for name, pin in pairs(shipped) do
    if user[name] == nil and type(pin) == "table" and pin.commit then
      user[name] = pin
      added = true
    end
  end
  if added or not existed then
    write_lock(path, user)
  end

  -- lazy.nvim also caches the lockfile per session; fill the same gaps there.
  local cache = package.loaded["lazy.manage.lock"]
  if cache and cache._loaded then
    for name, pin in pairs(shipped) do
      if cache.lock[name] == nil and type(pin) == "table" and pin.commit then
        cache.lock[name] = vim.deepcopy(pin)
      end
    end
  end
  return not existed
end

local function locked_lazy_commit()
  local lock = read_lock(M.lockfile()) or read_lock(M.shipped_lockfile()) or {}
  local commit = vim.tbl_get(lock, "lazy.nvim", "commit")
  return type(commit) == "string" and commit:match("^%x+$") and commit or nil
end

local function bootstrap_lazy()
  local util = require("blak.util")
  local lazypath = util.join(vim.fn.stdpath("data"), "lazy", "lazy.nvim")

  if not util.file_exists(lazypath) then
    local repo = "https://github.com/folke/lazy.nvim.git"
    local output = vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=stable",
      repo,
      lazypath,
    })
    if vim.v.shell_error ~= 0 then
      error("Failed to clone lazy.nvim:\n" .. output)
    end
    -- Start from the pinned commit; otherwise the first lockfile write records
    -- whatever the stable tag points at. If the pin is unreachable the stable
    -- checkout stays and :Lazy restore can fix it.
    local commit = locked_lazy_commit()
    if commit then
      vim.fn.system({ "git", "-C", lazypath, "checkout", "--quiet", commit })
    end
  end

  vim.opt.rtp:prepend(lazypath)
end

-- lazy.nvim opens its full-screen backdrop float without a border, so it
-- inherits 'winborder' and draws a frame around the whole editor.
local function borderless_backdrop()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("BlakLazyBackdrop", { clear = true }),
    pattern = "lazy_backdrop",
    callback = function(event)
      local win = vim.fn.bufwinid(event.buf)
      if win ~= -1 then
        vim.api.nvim_win_set_config(win, { border = "none" })
      end
    end,
  })
end

local function waits_for_very_lazy(plugin)
  local events = plugin.event
  return vim.tbl_contains(type(events) == "table" and events or { events }, "VeryLazy")
end

-- Plugins installed for an extra enabled in this session need two things that
-- lazy.nvim only does on its startup install: the module loader must forget
-- the empty directory it indexed before the install, and plugins waiting for
-- VeryLazy must load because that event has already fired.
local function load_after_install()
  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("BlakLazyInstalled", { clear = true }),
    pattern = "LazyInstall",
    callback = function()
      local cache = require("lazy.core.cache")
      local pending = {}
      for _, plugin in pairs(require("lazy.core.config").plugins) do
        if plugin._.installed then
          cache.reset(plugin.dir)
          if not plugin._.loaded and plugin._.cond ~= false and waits_for_very_lazy(plugin) then
            table.insert(pending, plugin.name)
          end
        end
      end
      if vim.v.vim_did_enter == 1 and #pending > 0 then
        require("lazy").load({ plugins = pending })
      end
    end,
  })
end

function M.setup(config)
  if config.package.backend ~= "lazy" then
    error(
      "Blak currently supports package.backend = 'lazy'. The vim.pack adapter is intentionally reserved for a later release."
    )
  end

  local created_lockfile = M.seed_lockfile()
  bootstrap_lazy()
  ensure_blak_package_path()
  borderless_backdrop()
  load_after_install()

  local specs = require("blak.plugins").specs(config)
  require("lazy").setup(specs, {
    root = require("blak.util").join(vim.fn.stdpath("data"), "lazy"),
    lockfile = M.lockfile(),
    defaults = {
      lazy = true,
      version = false,
    },
    install = {
      colorscheme = { config.ui.colorscheme, "habamax" },
    },
    checker = {
      enabled = config.package.check_updates,
      notify = false,
    },
    change_detection = {
      enabled = true,
      notify = false,
    },
    performance = {
      rtp = {
        -- Disable only the directory handler replaced by Blak's explorer.
        -- Keep native archive/compression support and Tutor.
        disabled_plugins = {
          "netrwPlugin",
        },
      },
    },
    pkg = {
      sources = { "lazy" },
    },
    ui = {
      border = config.ui.winborder,
    },
  })

  if created_lockfile then
    -- First start with a state lockfile, either a new install or one whose
    -- lockfile used to live in the checkout: record what is installed now,
    -- then restore the shipped pins lazy.nvim drops for plugins without specs.
    pcall(function()
      require("lazy.manage.lock").update()
    end)
    M.seed_lockfile()
  end
end

-- Use the same merged options as initial plugin setup, including user specs.
function M.plugin_opts(name, fallback)
  local lazy_config = package.loaded["lazy.core.config"]
  local plugin = lazy_config and lazy_config.plugins[name]
  if plugin then
    return require("lazy.core.plugin").values(plugin, "opts", false)
  end
  return fallback
end

function M.refresh(config)
  if not package.loaded["lazy.core.config"] then
    return
  end

  local ok, err = pcall(function()
    local lazy_config = require("lazy.core.config")
    lazy_config.options.spec = require("blak.plugins").specs(config)
    require("lazy.core.plugin").load()
    -- Lazy preserves loaded-plugin state, including values from the old specs.
    for _, plugin in pairs(lazy_config.plugins) do
      plugin._.cache = nil
    end
    require("lazy.core.handler").setup()
    vim.api.nvim_exec_autocmds("User", { pattern = "LazyRender", modeline = false })
    vim.api.nvim_exec_autocmds("User", { pattern = "LazyReload", modeline = false })
  end)
  if not ok then
    require("blak.util").warn("Could not refresh lazy.nvim specs: " .. tostring(err))
  end
end

return M
