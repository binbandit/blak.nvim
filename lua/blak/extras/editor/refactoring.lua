-- refactoring.nvim actions are operators: each returns keys such as "g@" that
-- apply the refactor to the visual selection or the following motion, so every
-- mapping below uses expr = true and returns those keys.
local function operator_keys(module, action)
  local refactoring = require("blak.util").load_plugin("refactoring.nvim", module)
  return refactoring and refactoring[action]() or ""
end

local function refactor(action)
  return function()
    return operator_keys("refactoring", action)
  end
end

local function print_var()
  local keys = operator_keys("refactoring.debug", "print_var")
  -- Normal mode prints the word under the cursor; visual mode the selection.
  return keys ~= "" and vim.fn.mode() == "n" and keys .. "iw" or keys
end

local function cleanup()
  local keys = operator_keys("refactoring.debug", "cleanup")
  -- Cleanup needs a range: gg..G covers the buffer and the view is restored.
  return keys ~= "" and "gg" .. keys .. "G" or ""
end

local expr = { expr = true }

return {
  id = "editor.refactoring",
  label = "Refactoring",
  description = "Treesitter-powered extract, inline, and print-debug refactors",
  plugins = {
    {
      "ThePrimeagen/refactoring.nvim",
      cmd = "Refactor",
      -- Neovim 0.13 ships vim.async; 0.12 needs async.nvim.
      dependencies = { "lewis6991/async.nvim" },
      opts = {},
    },
  },
  keys = {
    {
      lhs = "<leader>re",
      mode = "x",
      rhs = refactor("extract_func"),
      desc = "Extract function",
      opts = expr,
    },
    {
      lhs = "<leader>rf",
      mode = "x",
      rhs = refactor("extract_func_to_file"),
      desc = "Extract function to file",
      opts = expr,
    },
    {
      lhs = "<leader>rv",
      mode = "x",
      rhs = refactor("extract_var"),
      desc = "Extract variable",
      opts = expr,
    },
    {
      lhs = "<leader>ri",
      mode = { "n", "x" },
      rhs = refactor("inline_var"),
      desc = "Inline variable",
      opts = expr,
    },
    { lhs = "<leader>rI", rhs = refactor("inline_func"), desc = "Inline function", opts = expr },
    {
      lhs = "<leader>rp",
      mode = { "n", "x" },
      rhs = print_var,
      desc = "Print debug variable",
      opts = expr,
    },
    { lhs = "<leader>rc", rhs = cleanup, desc = "Cleanup debug prints", opts = expr },
  },
}
