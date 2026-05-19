-- This file is yours. Keep only the values you want to change.
-- Run :BlakExtras to enable optional language, UI, Git, AI, and editor modules.

---@type blak.UserConfig
return {
  picker = {
    provider = "fff", -- fff | snacks | telescope | fzf_lua
  },

  completion = {
    super_tab = false,
  },

  editor = {
    confirm = true, -- false skips prompts before commands abandon unsaved changes
  },

  terminal = {
    toggle_key = "<leader>tt", -- false disables the terminal mapping
  },

  extras = {
    enabled = {
      -- "lang.typescript",
      -- "git.lazygit",
    },
  },

  keymaps = {
    -- Every active mapping needs a description so it appears in :BlakKeys.
    -- { key = "<leader>sg", action = "<cmd>BlakPick grep<cr>", description = "Grep" },
    -- { mode = { "n", "x" }, key = "<leader>y", action = '"+y', description = "Yank to clipboard" },
    -- { key = "<leader>rn", action = function() vim.lsp.buf.rename() end, description = "Rename symbol" },
    -- { key = "<leader>/", disable = true },
  },

  plugins = {
    specs = {
      -- Add lazy.nvim specs here when a personal plugin is not a Blak extra.
      -- { "tpope/vim-sleuth", event = "BufReadPost" },
    },
  },

  hooks = {
    after = {
      -- Runs after Blak finishes setup and after each successful user.lua reload.
      -- function(config)
      --   vim.opt.cursorline = false
      -- end,
    },
  },
}

-- Advanced: own the config table directly instead of returning a table.
-- Remove the table above and use this form when you want full Lua control:
--
-- ---@param config blak.Config
-- ---@param blak blak.UserContext
-- return function(config, blak)
--   config.picker.provider = "snacks"
--   table.insert(config.extras.enabled, "lang.typescript")
--   table.insert(config.plugins.specs, { "tpope/vim-sleuth", event = "BufReadPost" })
-- end
