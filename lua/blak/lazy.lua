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
  end

  vim.opt.rtp:prepend(lazypath)
end

function M.setup(config)
  if config.package.backend ~= "lazy" then
    error("Blak currently supports package.backend = 'lazy'. The vim.pack adapter is intentionally reserved for a later release.")
  end

  bootstrap_lazy()
  ensure_blak_package_path()

  local specs = require("blak.plugins").specs(config)
  require("lazy").setup(specs, {
    root = require("blak.util").join(vim.fn.stdpath("data"), "lazy"),
    lockfile = require("blak.util").join(vim.fn.stdpath("config"), "lazy-lock.json"),
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
        -- Only dead weight and plugins Blak replaces (netrw -> Oil) are
        -- disabled. matchparen and matchit stay enabled: stock Neovim
        -- highlights matching pairs and extends %, and nothing in core
        -- replaces them.
        disabled_plugins = {
          "gzip",
          "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
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
end

function M.refresh(config)
  if not package.loaded["lazy.core.config"] then
    return
  end

  local ok, err = pcall(function()
    local lazy_config = require("lazy.core.config")
    lazy_config.options.spec = require("blak.plugins").specs(config)
    require("lazy.core.plugin").load()
    require("lazy.core.handler").setup()
    vim.api.nvim_exec_autocmds("User", { pattern = "LazyRender", modeline = false })
    vim.api.nvim_exec_autocmds("User", { pattern = "LazyReload", modeline = false })
  end)
  if not ok then
    require("blak.util").warn("Could not refresh lazy.nvim specs: " .. tostring(err))
  end
end

return M
