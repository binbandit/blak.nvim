return function(config)
  return {
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      opts = function()
        local splash = require("blak.splash")
        local opts = {
          bigfile = {
            enabled = true,
            size = config.performance.bigfile_size,
          },
          dashboard = config.ui.splash.enabled and {
            enabled = true,
            preset = {
              header = table.concat(splash.header(), "\n"),
              keys = {
                { icon = " ", key = "f", desc = "Find file", action = ":BlakPick files" },
                { icon = " ", key = "r", desc = "Recent files", action = ":BlakPick recent" },
                { icon = "󰱼 ", key = "g", desc = "Grep", action = ":BlakPick grep" },
                { icon = "󰈔 ", key = "n", desc = "New file", action = ":ene | startinsert" },
                {
                  icon = "󰙅 ",
                  key = "e",
                  desc = "Explorer",
                  action = function()
                    require("blak.core.explorer").open(config)
                  end,
                },
                { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
                { icon = "󰊳 ", key = "d", desc = "Doctor", action = ":BlakDoctor" },
                { icon = "󰗼 ", key = "q", desc = "Quit", action = ":qa" },
              },
            },
            sections = {
              { section = "header", padding = 1 },
              { section = "keys", gap = 1, padding = 1 },
              { section = "startup" },
            },
          } or { enabled = false },
          input = { enabled = true },
          notifier = { enabled = config.ui.notify ~= false },
          picker = { enabled = true },
          quickfile = { enabled = true },
          words = { enabled = true },
          indent = { enabled = false },
          scroll = { enabled = false },
        }
        if config.explorer.provider == "snacks" then
          opts.explorer = { enabled = true }
        end
        return vim.tbl_deep_extend("force", opts, config.snacks or {})
      end,
      config = function(_, opts)
        require("snacks").setup(opts)
        require("blak.splash").attach_to_snacks(config)
      end,
    },
  }
end
