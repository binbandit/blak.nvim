local function neotest(action)
  return function()
    local module = require("blak.util").load_plugin("neotest", "neotest")
    if not module then
      return
    end
    action(module)
  end
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
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
      },
      opts = {
        adapters = {},
      },
    },
  },
  keys = {
    { lhs = "<leader>Tn", rhs = neotest(function(nt) nt.run.run() end), desc = "Test nearest" },
    { lhs = "<leader>Tf", rhs = neotest(function(nt) nt.run.run(vim.fn.expand("%")) end), desc = "Test file" },
    { lhs = "<leader>Td", rhs = neotest(function(nt) nt.run.run({ strategy = "dap" }) end), desc = "Debug nearest test" },
    { lhs = "<leader>Ts", rhs = neotest(function(nt) nt.summary.toggle() end), desc = "Test summary" },
    { lhs = "<leader>To", rhs = neotest(function(nt) nt.output.open({ enter = true, auto_close = true }) end), desc = "Test output" },
    { lhs = "<leader>TO", rhs = neotest(function(nt) nt.output_panel.toggle() end), desc = "Test output panel" },
  },
}
