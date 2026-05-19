local function enable_manual_snacks(opts)
  for _, name in ipairs({ "dim" }) do
    if vim.tbl_get(opts, name, "enabled") then
      local ok, module = pcall(function()
        return require("snacks")[name]
      end)
      if ok and module.enable then
        pcall(module.enable)
      end
    end
  end
end

local function enable_snacks_explorer(opts)
  opts.explorer = vim.tbl_deep_extend("force", opts.explorer or {}, { enabled = true })
  opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
    sources = {
      explorer = {
        auto_close = true,
      },
    },
  })
end

return function(config)
  local splash_enabled = vim.tbl_get(config, "ui", "splash", "enabled") == true
  local snacks_event = splash_enabled and nil or "VeryLazy"

  return {
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = not splash_enabled,
      event = snacks_event,
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
                { icon = " ", key = "c", desc = "Config", action = ":BlakConfig" },
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
          enable_snacks_explorer(opts)
        end
        return vim.tbl_deep_extend("force", opts, config.snacks or {})
      end,
      config = function(_, opts)
        require("snacks").setup(opts)
        enable_manual_snacks(opts)
        require("blak.splash").attach_to_snacks(config)
      end,
    },
  }
end
