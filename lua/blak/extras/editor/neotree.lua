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
        -- "" follows 'winborder', so dialogs match the rest of Blak's floats.
        popup_border_style = "",
        -- mini.icons' generic file glyph, for files it has no specific icon for.
        default_component_configs = {
          icon = { default = "󰈔" },
        },
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
