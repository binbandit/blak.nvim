return {
  id = "ui.indent",
  label = "Indent guides",
  description = "Enable Snacks indent guides with animated scope highlighting",
  snacks = {
    indent = { enabled = true },
  },
  keys = {
    {
      lhs = "<leader>ug",
      desc = "Toggle indent guides",
      rhs = function()
        require("snacks").toggle.indent():toggle()
      end,
    },
  },
}
