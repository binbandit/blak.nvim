return {
  id = "editor.todo-comments",
  label = "TODO comments",
  description = "Highlight and collect TODO, FIX, HACK, and NOTE comments",
  plugins = {
    {
      "folke/todo-comments.nvim",
      event = { "BufReadPost", "BufNewFile" },
      cmd = {
        "TodoQuickFix",
        "TodoLocList",
        "TodoTrouble",
        "TodoTelescope",
        "TodoFzfLua",
        "TodoSnacks",
      },
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {},
    },
  },
  keys = {
    { lhs = "]t", rhs = "<cmd>lua require('todo-comments').jump_next()<cr>", desc = "Next TODO comment" },
    { lhs = "[t", rhs = "<cmd>lua require('todo-comments').jump_prev()<cr>", desc = "Previous TODO comment" },
    { lhs = "<leader>xT", rhs = "<cmd>TodoQuickFix<cr>", desc = "TODO quickfix" },
  },
}
