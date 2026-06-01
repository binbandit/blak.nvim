local function flash(action)
  return function()
    local module = require("blak.util").load_plugin("flash.nvim", "flash")
    if module then
      module[action]()
    end
  end
end

-- The s/S/r/R mappings deliberately shadow native motions; this extra is
-- opt-in and the mappings are visible in :BlakKeys. The <C-s> mapping is
-- command-line mode only, so it does not clash with the core <C-s> save.
--
-- Flash's `char` mode (which silently overlays f/t/F/T with jump labels) is
-- disabled so the only behavior this extra changes is the explicit mappings
-- below. f/t/F/T stay native, and the / search integration is opt-in per
-- search through <C-s>.
return {
  id = "editor.flash",
  label = "Flash",
  description = "Label-based jump motions and Treesitter selection",
  plugins = {
    {
      "folke/flash.nvim",
      lazy = true,
      opts = {
        modes = {
          char = { enabled = false },
        },
      },
    },
  },
  keys = {
    { lhs = "s", mode = { "n", "x", "o" }, rhs = flash("jump"), desc = "Flash jump" },
    { lhs = "S", mode = { "n", "x", "o" }, rhs = flash("treesitter"), desc = "Flash Treesitter" },
    { lhs = "r", mode = "o", rhs = flash("remote"), desc = "Flash remote" },
    { lhs = "R", mode = { "o", "x" }, rhs = flash("treesitter_search"), desc = "Flash Treesitter search" },
    { lhs = "<c-s>", mode = "c", rhs = flash("toggle"), desc = "Toggle Flash search" },
  },
}
