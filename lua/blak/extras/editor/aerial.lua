return {
  id = "editor.aerial",
  label = "Aerial",
  description = "Code outline window powered by LSP and Treesitter symbols",
  plugins = {
    {
      "stevearc/aerial.nvim",
      cmd = { "AerialToggle", "AerialOpen", "AerialClose", "AerialNavToggle" },
      dependencies = { "nvim-mini/mini.icons" },
      opts = {},
    },
  },
  keys = {
    { lhs = "<leader>co", rhs = "<cmd>AerialToggle<cr>", desc = "Code outline" },
  },
}
