return {
  id = "ui.lualine",
  label = "Lualine",
  description = "Add lualine.nvim statusline",
  plugins = function(config)
    return {
      {
        "nvim-lualine/lualine.nvim",
        lazy = false,
        dependencies = { "nvim-mini/mini.icons" },
        opts = {
          options = {
            theme = "auto",
            icons_enabled = config.ui.icons ~= false,
            component_separators = { left = "|", right = "|" },
            section_separators = { left = "", right = "" },
            globalstatus = true,
            disabled_filetypes = {
              statusline = { "dashboard", "snacks_dashboard" },
            },
          },
          sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff", "diagnostics" },
            lualine_c = { { "filename", path = 1 } },
            lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" },
          },
          extensions = { "lazy", "mason", "oil", "quickfix" },
        },
        config = function(_, opts)
          vim.opt.showmode = false
          require("lualine").setup(opts)
        end,
      },
    }
  end,
}
