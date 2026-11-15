return {
  id = "ui.animations",
  label = "Animations",
  description = "Enable Snacks smooth scrolling",
  -- Snacks.animate is a helper library with no `enabled` option; it is always
  -- available and gated only by `vim.g.snacks_animate`.
  snacks = {
    scroll = { enabled = true },
  },
}
