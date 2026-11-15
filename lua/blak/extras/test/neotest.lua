local function neotest(action)
  return function()
    local module = require("blak.util").load_plugin("neotest", "neotest")
    if not module then
      return
    end
    action(module)
  end
end

-- Without an adapter neotest only says "No tests found", which reads like a
-- problem with the tests rather than the missing setup. Adapters added after
-- neotest loaded, by an extra enabled in this session, need a restart.
-- `args` returns the neotest.run.run() argument at keypress time.
local function run(args)
  return neotest(function(nt)
    local config = require("neotest.config")
    if #config.adapters == 0 and next(config.projects) == nil then
      local added = false
      for _, adapter in pairs(require("blak.lazy").plugin_opts("neotest", {}).adapters or {}) do
        added = added or adapter ~= false
      end
      require("blak.util").warn(
        added and "Neotest loaded before its adapters were added. Run :restart to load them."
          or "Neotest has no adapters. Enable lang.go or lang.python, or add an adapter in plugins.specs (see the test.neotest docs)."
      )
      return
    end
    local value = args and args()
    if type(value) == "table" and value.strategy == "dap" and not pcall(require, "dap") then
      require("blak.util").warn(
        "Debugging tests needs nvim-dap. Enable debug.dap, then install it."
      )
      return
    end
    nt.run.run(value)
  end)
end

return {
  id = "test.neotest",
  label = "Neotest",
  description = "Extensible test runner framework for language-specific adapters",
  plugins = {
    {
      "nvim-neotest/neotest",
      lazy = true,
      dependencies = {
        "nvim-neotest/nvim-nio",
        -- neotest itself no longer needs plenary, but adapters such as
        -- neotest-golang still require it without declaring it.
        "nvim-lua/plenary.nvim",
      },
      -- Language extras add adapters by module name with their options, such
      -- as `["neotest-golang"] = {}`, so an adapter is set up once however
      -- many extras ask for it, and user specs can merge options or drop it
      -- with `false`. List entries are adapter objects and are kept as is.
      opts = {
        adapters = {},
      },
      config = function(_, opts)
        local adapters = vim.list_slice(opts.adapters)
        local names = vim.tbl_filter(function(key)
          return type(key) == "string"
        end, vim.tbl_keys(opts.adapters))
        table.sort(names)
        for _, name in ipairs(names) do
          if opts.adapters[name] then
            table.insert(adapters, require(name)(opts.adapters[name]))
          end
        end
        require("neotest").setup(vim.tbl_extend("force", opts, { adapters = adapters }))
      end,
    },
  },
  keys = {
    { lhs = "<leader>Tn", rhs = run(), desc = "Test nearest" },
    {
      lhs = "<leader>Tf",
      rhs = run(function()
        return vim.fn.expand("%")
      end),
      desc = "Test file",
    },
    {
      lhs = "<leader>Td",
      rhs = run(function()
        return { strategy = "dap" }
      end),
      desc = "Debug nearest test",
    },
    {
      lhs = "<leader>Ts",
      rhs = neotest(function(nt)
        nt.summary.toggle()
      end),
      desc = "Test summary",
    },
    {
      lhs = "<leader>To",
      rhs = neotest(function(nt)
        nt.output.open({ enter = true, auto_close = true })
      end),
      desc = "Test output",
    },
    {
      lhs = "<leader>TO",
      rhs = neotest(function(nt)
        nt.output_panel.toggle()
      end),
      desc = "Test output panel",
    },
  },
}
