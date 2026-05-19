local commands = {
  "SupermavenClearLog",
  "SupermavenLogout",
  "SupermavenRestart",
  "SupermavenShowLog",
  "SupermavenStart",
  "SupermavenStatus",
  "SupermavenStop",
  "SupermavenToggle",
  "SupermavenUseFree",
  "SupermavenUsePro",
}

local function preview()
  return require("blak.util").load_plugin("supermaven-nvim", "supermaven-nvim.completion_preview")
end

local function with_suggestion(action)
  return function()
    local module = preview()
    if module and module.has_suggestion and module.has_suggestion() and module[action] then
      module[action]()
    end
  end
end

local function clear_suggestion()
  local module = preview()
  if module and module.on_dispose_inlay then
    module.on_dispose_inlay()
  end
end

return {
  id = "ai.supermaven",
  label = "Supermaven",
  description = "Optional Supermaven inline AI completion. Never enabled by default.",
  plugins = function(config)
    return {
      {
        "supermaven-inc/supermaven-nvim",
        main = "supermaven-nvim",
        cmd = commands,
        event = "InsertEnter",
        opts = function(_, opts)
          local merged = vim.tbl_deep_extend("force", {
            ignore_filetypes = {
              ["blak-extras"] = true,
              snacks_input = true,
              TelescopePrompt = true,
            },
            log_level = "info",
          }, opts or {}, vim.tbl_get(config, "ai", "supermaven") or {})
          merged.disable_keymaps = true
          return merged
        end,
      },
    }
  end,
  keys = {
    { lhs = "<leader>aS", rhs = "<cmd>SupermavenToggle<cr>", desc = "Supermaven toggle" },
    { lhs = "<M-l>", mode = "i", rhs = with_suggestion("on_accept_suggestion"), desc = "Supermaven accept suggestion" },
    { lhs = "<M-w>", mode = "i", rhs = with_suggestion("on_accept_suggestion_word"), desc = "Supermaven accept word" },
    { lhs = "<M-]>", mode = "i", rhs = clear_suggestion, desc = "Supermaven clear suggestion" },
  },
}
