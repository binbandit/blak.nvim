-- Copy this file to lua/blak/user.lua and edit it.
-- Returning a table keeps your local changes small and easy to review.

return {
  package = {
    channel = "stable", -- stable | edge | nightly
  },

  picker = {
    provider = "fff",
  },

  extras = {
    enabled = {
      -- Languages
      -- "lang.lua",
      -- "lang.typescript",
      -- "lang.typescript-tsgo",
      -- "lang.python",
      -- "lang.rust",
      -- "lang.go",
      -- "lang.markdown",

      -- UI
      -- "ui.animations",
      -- "ui.base46",
      -- "ui.image-preview",
      -- "ui.lualine",
      -- "ui.zen",

      -- Git
      -- "git.lazygit",
      -- "git.diffview",

      -- AI
      -- "ai.copilot",

      -- Editor
      -- "editor.neotree",
      -- "editor.snacks-explorer",
      -- "editor.telescope",
      -- "editor.fzf-lua",
    },
  },
}
