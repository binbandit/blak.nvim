return function(config)
  return {
    {
      "lewis6991/gitsigns.nvim",
      event = { "BufReadPre", "BufNewFile" },
      opts = {
        signs_staged_enable = true,
        preview_config = { border = config.ui.winborder },
      },
    },
  }
end
