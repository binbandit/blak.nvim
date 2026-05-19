local function refactor(name)
  return function()
    local module = require("blak.util").load_plugin("refactoring.nvim", "refactoring")
    if module then
      module.refactor(name)
    end
  end
end

local function debug_action(action)
  return function()
    local module = require("blak.util").load_plugin("refactoring.nvim", "refactoring")
    if module and module.debug and module.debug[action] then
      module.debug[action]({})
    end
  end
end

return {
  id = "editor.refactoring",
  label = "Refactoring",
  description = "Treesitter-powered extract, inline, and print-debug refactors",
  plugins = {
    {
      "ThePrimeagen/refactoring.nvim",
      lazy = true,
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
      },
      opts = {},
    },
  },
  keys = {
    { lhs = "<leader>re", mode = "x", rhs = refactor("Extract Function"), desc = "Extract function" },
    { lhs = "<leader>rf", mode = "x", rhs = refactor("Extract Function To File"), desc = "Extract function to file" },
    { lhs = "<leader>rv", mode = "x", rhs = refactor("Extract Variable"), desc = "Extract variable" },
    { lhs = "<leader>ri", mode = { "n", "x" }, rhs = refactor("Inline Variable"), desc = "Inline variable" },
    { lhs = "<leader>rI", rhs = refactor("Inline Function"), desc = "Inline function" },
    { lhs = "<leader>rp", mode = { "n", "x" }, rhs = debug_action("print_var"), desc = "Print debug variable" },
    { lhs = "<leader>rc", rhs = debug_action("cleanup"), desc = "Cleanup debug prints" },
  },
}
