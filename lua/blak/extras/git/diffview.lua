return {
  id = "git.diffview",
  label = "Diffview",
  description = "Diffview.nvim for richer Git diffs and merge review",
  plugins = {
    {
      "sindrets/diffview.nvim",
      cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    },
  },
  keys = {
    { lhs = "<leader>gD", rhs = "<cmd>DiffviewOpen<cr>", desc = "Diffview" },
    { lhs = "<leader>gH", rhs = "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
  },
}
