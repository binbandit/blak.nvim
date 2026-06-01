return {
  id = "editor.scratch",
  label = "Scratch",
  description = "Snacks scratch buffers: persistent, context-aware throwaway notepads",
  keys = {
    {
      lhs = "<leader>.",
      desc = "Toggle scratch buffer",
      rhs = function()
        require("snacks").scratch()
      end,
    },
    {
      lhs = "<leader>S",
      desc = "Select scratch buffer",
      rhs = function()
        require("snacks").scratch.select()
      end,
    },
  },
}
