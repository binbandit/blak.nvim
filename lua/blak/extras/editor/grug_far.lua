local function search(visual)
  return function()
    local module = require("blak.util").load_plugin("grug-far.nvim", "grug-far")
    if not module then
      return
    end
    if visual then
      module.with_visual_selection()
    else
      module.open()
    end
  end
end

return {
  id = "editor.grug-far",
  label = "Find & replace (grug-far)",
  description = "Buffer-based project-wide find and replace powered by ripgrep",
  plugins = {
    {
      "MagicDuck/grug-far.nvim",
      cmd = { "GrugFar", "GrugFarWithin" },
      opts = {},
    },
  },
  keys = {
    { lhs = "<leader>sr", rhs = search(false), desc = "Search and replace" },
    { lhs = "<leader>sr", mode = "x", rhs = search(true), desc = "Search and replace (selection)" },
  },
}
