return {
  id = "editor.window-navigation",
  label = "Window navigation",
  description = "Use Ctrl-h/j/k/l to move between windows",
  keys = {
    { lhs = "<C-h>", rhs = "<cmd>wincmd h<cr>", desc = "Window left" },
    { lhs = "<C-j>", rhs = "<cmd>wincmd j<cr>", desc = "Window down" },
    { lhs = "<C-k>", rhs = "<cmd>wincmd k<cr>", desc = "Window up" },
    { lhs = "<C-l>", rhs = "<cmd>wincmd l<cr>", desc = "Window right" },
  },
}
