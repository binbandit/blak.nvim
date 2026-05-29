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

  local ts = require("blak.util").load_plugin("nvim-treesitter", "nvim-treesitter")
  if not ts then
    if opts.notify then
      require("blak.util").warn("nvim-treesitter is not installed yet. Run :Lazy sync, restart, then retry.")
    end
    return
  end

  -- nvim-treesitter (main) periodically drops parsers whose upstream grammar is
  -- unmaintained; `jsonc` is now served by the `json` parser, for instance.
  -- Asking it to install a parser it no longer ships makes the download fail on
  -- every startup, so only request parsers this nvim-treesitter actually knows.
  if type(ts.get_available) == "function" then
    local ok_available, available = pcall(ts.get_available)
    if ok_available and type(available) == "table" and #available > 0 then
      local known = {}
      for _, name in ipairs(available) do
        known[name] = true
      end
      local wanted, skipped = {}, {}
      for _, name in ipairs(list) do
        if known[name] then
          table.insert(wanted, name)
        else
          table.insert(skipped, name)
        end
      end
      if opts.notify and #skipped > 0 then
        require("blak.util").warn("Skipping Treesitter parsers nvim-treesitter no longer ships: " .. table.concat(skipped, ", "))
      end
      list = wanted
    end
  end

  if #list == 0 then
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
