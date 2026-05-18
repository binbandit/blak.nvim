return {
  id = "editor.snacks-explorer",
  label = "Snacks explorer",
  description = "Use Snacks as the file explorer",
  snacks = {
    explorer = { enabled = true },
  },
  apply = function(config)
    config.explorer.provider = "snacks"
  end,
}
