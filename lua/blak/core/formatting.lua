local M = {}

local stylua_project_configs = { ".stylua.toml", "stylua.toml", ".editorconfig" }

local function has_stylua_config(dirname)
  if vim.fs.find(stylua_project_configs, { path = dirname, upward = true })[1] then
    return true
  end
  -- StyLua falls back to a global config when no project config is found.
  local config_home = vim.env.XDG_CONFIG_HOME or vim.fs.joinpath(vim.env.HOME or "", ".config")
  for _, path in ipairs({ "stylua/stylua.toml", "stylua/.stylua.toml", ".stylua.toml" }) do
    if vim.uv.fs_stat(vim.fs.joinpath(config_home, path)) then
      return true
    end
  end
  return false
end

-- StyLua indents with tabs unless a config says otherwise. Without one, follow
-- the buffer's indent settings, as Conform's shfmt definition does.
local function stylua_indent_args(_, ctx)
  if has_stylua_config(ctx.dirname) then
    return {}
  end
  return {
    "--indent-type",
    vim.bo[ctx.buf].expandtab and "Spaces" or "Tabs",
    "--indent-width",
    tostring(ctx.shiftwidth),
  }
end

function M.conform_opts(config)
  return {
    formatters = {
      stylua = { prepend_args = stylua_indent_args },
    },
    formatters_by_ft = config.format.formatters_by_ft,
    default_format_opts = {
      timeout_ms = config.format.timeout_ms,
      lsp_format = config.format.lsp_format,
    },
    format_on_save = function(bufnr)
      if
        not config.format.enabled
        or vim.g.blak_disable_autoformat
        or vim.b[bufnr].blak_disable_autoformat
      then
        return nil
      end
      -- Conform resolves per-filetype options before these global defaults.
      return {}
    end,
  }
end

function M.refresh(config)
  local conform = package.loaded.conform
  if conform and conform.setup then
    local opts = require("blak.lazy").plugin_opts("conform.nvim", M.conform_opts(config))
    -- Conform.setup merges these tables, so removed filetypes otherwise linger.
    conform.formatters_by_ft = vim.deepcopy(opts.formatters_by_ft or {})
    conform.default_format_opts = vim.deepcopy(opts.default_format_opts or {})
    conform.setup(opts)
  end

  if package.loaded.lint then
    require("blak.core.linting").setup(config)
  end
end

return M
