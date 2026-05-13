return {
  id = "git.lazygit",
  label = "LazyGit",
  description = "Open LazyGit in a Snacks float",
  snacks = {
    lazygit = { enabled = true },
  },
  keys = {
    {
      lhs = "<leader>gg",
      desc = "LazyGit",
      rhs = function()
        require("snacks").lazygit()
      end,
    },
  },
}
