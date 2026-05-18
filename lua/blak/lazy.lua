local M = {}

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
        disabled_plugins = {
          "gzip",
          "matchit",
          "matchparen",
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
