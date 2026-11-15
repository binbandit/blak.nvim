-- diffview-plus.nvim is the maintained fork of sindrets/diffview.nvim, which
-- has had no commits since June 2024. It keeps the `diffview` module and the
-- :Diffview* commands, so Neogit's diffview integration still detects it.
return {
  id = "git.diffview",
  label = "Diffview",
  description = "Diffview (maintained diffview-plus fork) for richer Git diffs and merge review",
  plugins = {
    {
      "dlyongemallo/diffview-plus.nvim",
      -- Follow tagged releases, as upstream recommends.
      version = "*",
      cmd = {
        "DiffviewOpen",
        "DiffviewClose",
        "DiffviewToggle",
        "DiffviewFileHistory",
        "DiffviewDiffFiles",
        "DiffviewLog",
      },
      -- mini.icons provides the nvim-web-devicons shim Diffview needs for file icons.
      dependencies = { "nvim-mini/mini.icons" },
    },
  },
  keys = {
    { lhs = "<leader>gD", rhs = "<cmd>DiffviewOpen<cr>", desc = "Diffview" },
    { lhs = "<leader>gH", rhs = "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
  },
}
