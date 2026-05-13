return {
  id = "ui.zen",
  label = "Zen",
  description = "Enable Snacks zen mode",
  snacks = {
    zen = { enabled = true },
  },
  keys = {
    {
      lhs = "<leader>uz",
      desc = "Zen mode",
      rhs = function()
        require("snacks").zen()
      end,
    },
  },
}
