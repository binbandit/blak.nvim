return {
  id = "editor.snacks-terminal",
  label = "Snacks terminal",
  description = "Use Snacks as the terminal provider",
  snacks = {
    terminal = { enabled = true },
  },
  apply = function(config)
    config.terminal = config.terminal or {}
    config.terminal.provider = "snacks"
  end,
}
