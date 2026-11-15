return function(config)
  return {
    {
      "nvim-mini/mini.icons",
      version = false,
      lazy = true,
      -- Snacks pickers and other plugins look for nvim-web-devicons; serve
      -- the mini.icons mock on first require instead of generic file icons.
      init = function()
        package.preload["nvim-web-devicons"] = function()
          require("mini.icons").mock_nvim_web_devicons()
          return package.loaded["nvim-web-devicons"]
        end
      end,
      config = function()
        local icons = require("mini.icons")
        icons.setup()
        pcall(icons.mock_nvim_web_devicons)
      end,
    },
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      opts = {},
    },
    {
      "nvim-treesitter/nvim-treesitter",
      branch = "main",
      event = { "BufReadPre", "BufNewFile" },
      build = ":TSUpdate",
      config = function()
        require("blak.core.treesitter").setup(config)
      end,
    },
    {
      "windwp/nvim-ts-autotag",
      event = { "BufReadPre", "BufNewFile" },
      dependencies = { "nvim-treesitter/nvim-treesitter" },
      opts = {
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false,
        },
      },
    },
    {
      "stevearc/oil.nvim",
      lazy = false,
      opts = {
        default_file_explorer = config.explorer.provider == "oil",
        columns = { "icon" },
        delete_to_trash = false,
        skip_confirm_for_simple_edits = true,
        view_options = {
          show_hidden = false,
          natural_order = true,
        },
        float = {
          padding = 2,
          max_width = 0.9,
          max_height = 0.9,
          border = config.ui.winborder,
        },
      },
    },
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {
        preset = "modern",
        delay = 300,
        -- which-key hides groups without mappings, so prefixes used only by
        -- extras can be named here unconditionally.
        spec = {
          { "<leader>a", group = "ai" },
          { "<leader>b", group = "buffers" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>f", group = "find" },
          { "<leader>g", group = "git" },
          { "<leader>h", group = "harpoon" },
          { "<leader>l", group = "lazy/blak" },
          { "<leader>o", group = "tasks" },
          { "<leader>q", group = "quit/session" },
          { "<leader>r", group = "refactor" },
          { "<leader>s", group = "search" },
          { "<leader>t", group = "terminal" },
          { "<leader>T", group = "test" },
          { "<leader>u", group = "toggle/update" },
          { "<leader>w", group = "windows" },
          { "<leader>x", group = "diagnostics" },
        },
      },
    },
  }
end
