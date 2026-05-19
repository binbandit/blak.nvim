local commands = {
  "ClaudeCode",
  "ClaudeCodeAdd",
  "ClaudeCodeClose",
  "ClaudeCodeDiffAccept",
  "ClaudeCodeDiffDeny",
  "ClaudeCodeFocus",
  "ClaudeCodeOpen",
  "ClaudeCodeSelectModel",
  "ClaudeCodeSend",
  "ClaudeCodeStart",
  "ClaudeCodeStatus",
  "ClaudeCodeStop",
  "ClaudeCodeTreeAdd",
}

return {
  id = "ai.claudecode",
  label = "Claude Code",
  description = "Claude Code CLI integration via claudecode.nvim. Never enabled by default.",
  plugins = function(config)
    return {
      {
        "coder/claudecode.nvim",
        cmd = commands,
        dependencies = { "folke/snacks.nvim" },
        opts = function(_, opts)
          return vim.tbl_deep_extend("force", {
            terminal = {
              provider = "snacks",
            },
          }, opts or {}, vim.tbl_get(config, "ai", "claudecode") or {})
        end,
      },
    }
  end,
  keys = {
    { lhs = "<leader>ac", rhs = "<cmd>ClaudeCode<cr>", desc = "Claude Code toggle" },
    { lhs = "<leader>aF", rhs = "<cmd>ClaudeCodeFocus<cr>", desc = "Claude Code focus" },
    { lhs = "<leader>ar", rhs = "<cmd>ClaudeCode --resume<cr>", desc = "Claude Code resume" },
    { lhs = "<leader>aC", rhs = "<cmd>ClaudeCode --continue<cr>", desc = "Claude Code continue" },
    { lhs = "<leader>am", rhs = "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude Code select model" },
    { lhs = "<leader>ab", rhs = "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude Code add buffer" },
    { lhs = "<leader>as", mode = "x", rhs = "<cmd>ClaudeCodeSend<cr>", desc = "Claude Code send selection" },
    { lhs = "<leader>aA", rhs = "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude Code accept diff" },
    { lhs = "<leader>aD", rhs = "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude Code deny diff" },
  },
}
