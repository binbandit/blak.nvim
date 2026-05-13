return {
  id = "editor.neotree",
  label = "Neo-tree",
  description = "Tree explorer for people who prefer a sidebar over Oil",
  plugins = {
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      cmd = "Neotree",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-mini/mini.icons",
        "MunifTanjim/nui.nvim",
      },
      opts = {
        filesystem = {
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
        },
      },
    },
  },
  keys = {
    {
      lhs = "<leader>E",
      desc = "Neo-tree",
      rhs = "<cmd>Neotree toggle<cr>",
    },
  },
}
