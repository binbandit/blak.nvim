return {
  id = "editor.fzf-lua",
  label = "fzf-lua",
  description = "Use fzf-lua as the picker provider",
  apply = function(config)
    config.picker.provider = "fzf_lua"
  end,
  plugins = {
    {
      "ibhagwan/fzf-lua",
      cmd = "FzfLua",
      dependencies = { "nvim-mini/mini.icons" },
      opts = {},
    },
  },
}
