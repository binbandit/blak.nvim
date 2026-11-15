return {
  id = "editor.aerial",
  label = "Aerial",
  description = "Code outline window powered by LSP and Treesitter symbols",
  plugins = {
    {
      "stevearc/aerial.nvim",
      cmd = {
        "AerialToggle",
        "AerialOpen",
        "AerialOpenAll",
        "AerialClose",
        "AerialCloseAll",
        "AerialNext",
        "AerialPrev",
        "AerialGo",
        "AerialInfo",
        "AerialNavToggle",
        "AerialNavOpen",
        "AerialNavClose",
      },
      dependencies = { "nvim-mini/mini.icons" },
      opts = {},
    },
  },
  keys = {
    { lhs = "<leader>co", rhs = "<cmd>AerialToggle<cr>", desc = "Code outline" },
  },
}
