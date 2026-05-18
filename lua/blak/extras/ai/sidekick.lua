local function sidekick(module)
  return function()
    return require("blak.util").load_plugin("sidekick.nvim", module)
  end
end

local cli = sidekick("sidekick.cli")
local picker = sidekick("sidekick.cli.picker.snacks")

local function with_cli(action, opts)
  return function()
    local module = cli()
    if module and module[action] then
      return module[action](opts)
    end
  end
end

return {
  id = "ai.sidekick",
  label = "Sidekick",
  description = "Snacks-integrated AI CLI terminals via sidekick.nvim. Never enabled by default.",
  snacks = {
    picker = {
      actions = {
        sidekick_send = function(...)
          local module = picker()
          if module and module.send then
            return module.send(...)
          end
        end,
      },
    },
  },
  plugins = function(config)
    return {
      {
        "folke/sidekick.nvim",
        cmd = "Sidekick",
        opts = function(_, opts)
          return vim.tbl_deep_extend("force", {
            nes = { enabled = false },
            cli = {
              picker = "snacks",
            },
          }, opts or {}, vim.tbl_get(config, "ai", "sidekick") or {})
        end,
      },
    }
  end,
  keys = {
    { lhs = "<C-.>", mode = { "n", "i", "t", "x" }, rhs = with_cli("focus"), desc = "Sidekick focus" },
    { lhs = "<leader>aa", rhs = with_cli("toggle"), desc = "Sidekick toggle CLI" },
    { lhs = "<leader>as", rhs = with_cli("select"), desc = "Sidekick select CLI" },
    { lhs = "<leader>ad", rhs = with_cli("close"), desc = "Sidekick detach CLI" },
    { lhs = "<leader>af", rhs = with_cli("send", { msg = "{file}" }), desc = "Sidekick send file" },
    { lhs = "<leader>at", mode = { "n", "x" }, rhs = with_cli("send", { msg = "{this}" }), desc = "Sidekick send this" },
    { lhs = "<leader>av", mode = "x", rhs = with_cli("send", { msg = "{selection}" }), desc = "Sidekick send selection" },
    { lhs = "<leader>ap", mode = { "n", "x" }, rhs = with_cli("prompt"), desc = "Sidekick prompt" },
  },
}
