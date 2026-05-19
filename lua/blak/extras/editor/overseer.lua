return {
  id = "editor.overseer",
  label = "Overseer",
  description = "Task runner and job management for project commands",
  plugins = {
    {
      "stevearc/overseer.nvim",
      cmd = {
        "OverseerBuild",
        "OverseerRun",
        "OverseerQuickAction",
        "OverseerTaskAction",
        "OverseerToggle",
      },
      opts = {},
    },
  },
  keys = {
    { lhs = "<leader>oo", rhs = "<cmd>OverseerToggle<cr>", desc = "Tasks" },
    { lhs = "<leader>or", rhs = "<cmd>OverseerRun<cr>", desc = "Run task" },
    { lhs = "<leader>oq", rhs = "<cmd>OverseerQuickAction<cr>", desc = "Task action" },
  },
}
