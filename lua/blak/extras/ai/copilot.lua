return {
  id = "ai.copilot",
  label = "Copilot",
  description = "Optional GitHub Copilot integration. Never enabled by default.",
  plugins = {
    {
      "zbirenbaum/copilot.lua",
      cmd = "Copilot",
      event = "InsertEnter",
      opts = {
        suggestion = { enabled = false },
        panel = { enabled = false },
      },
    },
  },
}
