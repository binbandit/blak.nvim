local function suggestion()
  return require("blak.util").load_plugin("copilot.lua", "copilot.suggestion")
end

local function with_suggestion(action)
  return function()
    local module = suggestion()
    if module and module[action] then
      module[action]()
    end
  end
end

-- <C-]> expands abbreviations in insert mode, so only take the key when there
-- is a suggestion on screen to dismiss.
local function dismiss()
  local module = suggestion()
  if module and module.is_visible and module.is_visible() then
    module.dismiss()
    return ""
  end
  return "<C-]>"
end

-- copilot.lua hides suggestions during completion by checking pumvisible(),
-- which blink.cmp never sets, so both would draw inline text at the cursor.
-- Read the loaded module only; blink must not pull Copilot in on its own.
local function copilot_suggestion_visible()
  local module = package.loaded["copilot.suggestion"]
  return module ~= nil and module.is_visible() ~= nil
end

return {
  id = "ai.copilot",
  label = "Copilot",
  description = "Optional GitHub Copilot inline completion. Never enabled by default.",
  plugins = function(config)
    return {
      {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        opts = function(_, opts)
          local merged = vim.tbl_deep_extend("force", {
            panel = { enabled = false },
            suggestion = {
              enabled = true,
              auto_trigger = true,
              hide_during_completion = true,
            },
          }, opts or {}, vim.tbl_get(config, "ai", "copilot") or {})
          -- Blak owns the insert-mode mappings so they stay visible in :BlakKeys.
          -- A non-table suggestion is left alone for copilot.lua to reject.
          if type(merged.suggestion) == "table" then
            merged.suggestion.keymap = {
              accept = false,
              accept_word = false,
              accept_line = false,
              next = false,
              prev = false,
              dismiss = false,
              toggle_auto_trigger = false,
            }
          end
          return merged
        end,
      },
      {
        "saghen/blink.cmp",
        opts = {
          completion = {
            ghost_text = {
              -- Yield the inline preview to Copilot instead of drawing over it.
              -- Blink is otherwise untouched, and this leaves with the extra.
              enabled = function()
                return not copilot_suggestion_visible()
              end,
            },
          },
        },
      },
    }
  end,
  keys = {
    { lhs = "<leader>ag", rhs = with_suggestion("toggle_auto_trigger"), desc = "Copilot toggle auto trigger" },
    { lhs = "<M-l>", mode = "i", rhs = with_suggestion("accept"), desc = "Copilot accept suggestion" },
    { lhs = "<M-w>", mode = "i", rhs = with_suggestion("accept_word"), desc = "Copilot accept word" },
    { lhs = "<M-]>", mode = "i", rhs = with_suggestion("next"), desc = "Copilot next suggestion" },
    { lhs = "<M-[>", mode = "i", rhs = with_suggestion("prev"), desc = "Copilot previous suggestion" },
    { lhs = "<C-]>", mode = "i", rhs = dismiss, desc = "Copilot dismiss suggestion", opts = { expr = true } },
  },
}
