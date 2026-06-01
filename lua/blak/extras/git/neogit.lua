-- Snacks ships in core, so it is the picker backend. The diffview integration
-- is auto-detected when the git.diffview extra is also enabled.
return {
  id = "git.neogit",
  label = "Neogit",
  description = "Magit-style interactive Git interface (staging, commit, branch, rebase)",
  treesitter = { "git_config", "git_rebase", "gitcommit", "diff" },
  plugins = {
    {
      "NeogitOrg/neogit",
      cmd = "Neogit",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {
        integrations = {
          snacks = true,
        },
      },
    },
  },
  keys = {
    { lhs = "<leader>gn", rhs = "<cmd>Neogit<cr>", desc = "Neogit" },
  },
}
