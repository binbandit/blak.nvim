local function trouble(mode)
  return function()
    local module = require("blak.util").load_plugin("trouble.nvim", "trouble")
    if module then
      module.open(mode)
    end
  end
end

return {
  id = "editor.trouble",
  label = "Trouble",
  description = "Diagnostics, references, symbols, quickfix, and location lists in Trouble",
  plugins = {
    {
      "folke/trouble.nvim",
      cmd = "Trouble",
      dependencies = { "nvim-mini/mini.icons" },
      opts = {},
    },
  },
  keys = {
    { lhs = "<leader>xX", rhs = trouble("diagnostics"), desc = "Trouble diagnostics" },
    { lhs = "<leader>xQ", rhs = trouble("qflist"), desc = "Trouble quickfix" },
    { lhs = "<leader>xL", rhs = trouble("loclist"), desc = "Trouble loclist" },
    { lhs = "<leader>cO", rhs = trouble("symbols"), desc = "Trouble symbols" },
    { lhs = "<leader>cR", rhs = trouble("lsp_references"), desc = "Trouble references" },
  },
}
