-- Copy this file to lua/blak/user.lua and edit it.
-- Returning a table keeps your local changes small and easy to review.

---@type blak.UserConfig
return {
  package = {
    channel = "stable", -- stable | edge | nightly
  },

  picker = {
    provider = "fff",
  },

  completion = {
    super_tab = false,
  },

  terminal = {
    toggle_key = "<leader>tt",
  },

  ai = {
    sidekick = {
      nes = { enabled = false },
      -- cli = { mux = { enabled = true, backend = "tmux" } },
    },
  },

  mini = {
    modules = {
      -- "ai",
      -- "surround",
      -- "pairs",
      -- "splitjoin",
    },
    opts = {
      -- surround = { n_lines = 80 },
    },
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
      -- "ui.comfy-line-numbers",
      -- "ui.dim",
      -- "ui.image-preview",
      -- "ui.lualine",
      -- "ui.zen",

      -- Git
      -- "git.lazygit",
      -- "git.diffview",

      -- AI
      -- "ai.copilot",
      -- "ai.sidekick",

      -- Editor
      -- "editor.mini",
      -- "editor.neotree",
      -- "editor.snacks-explorer",
      -- "editor.snacks-terminal",
      -- "editor.telescope",
      -- "editor.fzf-lua",
    },
  },
}
