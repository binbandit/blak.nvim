local M = {}

local function parsers(config)
  return config.treesitter and config.treesitter.ensure_installed or {}
end

function M.install(config, opts)
  opts = opts or {}
  local list = parsers(config)
  if #list == 0 then
    return
  end

  if vim.fn.executable("tree-sitter") ~= 1 then
    if opts.notify then
      require("blak.util").warn("tree-sitter CLI is not available yet. Run :BlakToolsInstall, then :BlakTreesitterInstall.")
    end
    return
  end

  local ok_ts, ts = pcall(require, "nvim-treesitter")
  if not ok_ts then
    if opts.notify then
      require("blak.util").warn("nvim-treesitter is not loaded yet. Run :Lazy sync, restart, then retry.")
    end
    return
  end

  local ok_install, result = pcall(ts.install, list)
  if not ok_install then
    require("blak.util").warn("Could not install Treesitter parsers: " .. tostring(result))
    return
  end

  if opts.wait and result and result.wait then
    pcall(result.wait, result, opts.timeout_ms or 300000)
  end
end

function M.setup(config)
  local ts = require("nvim-treesitter")
  ts.setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
  })

  M.install(config)

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("BlakTreesitter", { clear = true }),
    callback = function(event)
      if vim.api.nvim_buf_line_count(event.buf) > config.performance.max_treesitter_lines then
        return
      end
      pcall(vim.treesitter.start, event.buf)
      pcall(function()
        vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end)
    end,
  })
end

return M
