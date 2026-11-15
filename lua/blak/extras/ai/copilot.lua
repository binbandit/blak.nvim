local function select(count)
  return function()
    vim.lsp.inline_completion.select({ count = count })
  end
end

return {
  id = "ai.copilot",
  label = "Copilot",
  description = "GitHub Copilot inline suggestions via copilot-language-server and native LSP inline completion. Never enabled by default.",
  -- mason-lspconfig installs copilot-language-server. nvim-lspconfig's
  -- lsp/copilot.lua supplies cmd, init_options and the :LspCopilotSignIn /
  -- :LspCopilotSignOut buffer commands.
  lsp = {
    servers = {
      copilot = {},
    },
  },
  apply = function()
    vim.lsp.inline_completion.enable()
  end,
  keys = {
    {
      lhs = "<M-l>",
      mode = "i",
      rhs = function()
        vim.lsp.inline_completion.get()
      end,
      desc = "Copilot accept suggestion",
    },
    { lhs = "<M-]>", mode = "i", rhs = select(1), desc = "Copilot next suggestion" },
    { lhs = "<M-[>", mode = "i", rhs = select(-1), desc = "Copilot previous suggestion" },
  },
}
