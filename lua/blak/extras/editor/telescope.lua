return {
  id = "editor.telescope",
  label = "Telescope",
  description = "Use Telescope as the picker provider",
  apply = function(config)
    config.picker.provider = "telescope"
  end,
  plugins = {
    {
      "nvim-telescope/telescope.nvim",
      cmd = "Telescope",
      dependencies = { "nvim-lua/plenary.nvim", "nvim-mini/mini.icons" },
      opts = {
        defaults = {
          prompt_prefix = "BLAK › ",
          selection_caret = "  ",
        },
      },
    },
  },
}
