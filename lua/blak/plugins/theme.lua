return function(config)
  return {
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1200,
      opts = function()
        return require("blak.theme").tokyonight_opts(config)
      end,
      config = function(_, opts)
        require("tokyonight").setup(opts)
        require("blak.theme").load(config)
      end,
    },
  }
end
