local function list_equals(list, expected)
  if type(list) ~= "table" or #list ~= #expected then
    return false
  end
  for index, value in ipairs(expected) do
    if list[index] ~= value then
      return false
    end
  end
  return true
end

return {
  id = "lang.python-pro",
  label = "Python Pro",
  description = "BasedPyright, Ruff format/code actions, venv selector, debugpy",
  treesitter = { "python", "requirements" },
  mason = { "debugpy", "ruff" },
  lsp = {
    servers = {
      basedpyright = {},
      ruff = {},
    },
  },
  format = {
    formatters_by_ft = {
      python = { "ruff_organize_imports", "ruff_format" },
    },
  },
  apply = function(config)
    if not (config._extra_applied and config._extra_applied["lang.python"]) then
      return
    end

    if vim.tbl_get(config, "lsp", "servers") then
      config.lsp.servers.pyright = nil
    end
    if list_equals(vim.tbl_get(config, "format", "formatters_by_ft", "python"), { "isort", "black" }) then
      config.format.formatters_by_ft.python = nil
    end
    if list_equals(vim.tbl_get(config, "lint", "linters_by_ft", "python"), { "ruff" }) then
      config.lint.linters_by_ft.python = nil
    end
  end,
  plugins = {
    {
      "linux-cultist/venv-selector.nvim",
      ft = "python",
      cmd = { "VenvSelect", "VenvSelectCache", "VenvSelectLog" },
      opts = {
        options = {
          picker = "snacks",
        },
      },
    },
  },
  keys = {
    { lhs = "<leader>cv", rhs = "<cmd>VenvSelect<cr>", desc = "Python virtualenv" },
  },
}
