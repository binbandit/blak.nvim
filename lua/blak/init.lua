local M = {}

---@param opts? table
function M.setup(opts)
  if vim.g.blak_loaded or vim.g.blak_loading then
    return
  end
  vim.g.blak_loading = true

  local ok, err = pcall(function()
    local config = require("blak.config").setup(opts)

    vim.g.mapleader = config.leader
    vim.g.maplocalleader = config.localleader

    require("blak.core.options").setup(config)
    require("blak.core.autocmds").setup(config)
    require("blak.core.commands").setup(config)
    require("blak.core.keymaps").setup(config)
    require("blak.core.update").setup(config)
    require("blak.splash").setup(config)
    require("blak.lazy").setup(config)

    vim.api.nvim_exec_autocmds("User", { pattern = "BlakReady", modeline = false })
  end)

  vim.g.blak_loading = false
  if not ok then
    vim.g.blak_loaded = false
    error(err)
  end
  vim.g.blak_loaded = true
end

return M
