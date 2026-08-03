local function with_suggestion(action)
  return function()
    local module = require("blak.util").load_plugin("copilot.lua", "copilot.suggestion")
    if module and module[action] then
      module[action]()
    end
  end
end

-- Nothing can be on screen unless copilot.lua is already loaded, so read the
-- loaded module rather than demand-loading it: these callers run per keystroke
-- and must not pay for a :Lazy load, or warn on every press when the plugin is
-- missing. is_visible() returns the extmark row, which is 0 on the first line.
local function visible()
  local module = package.loaded["copilot.suggestion"]
  return module ~= nil and module.is_visible() ~= nil
end

-- <C-]> expands abbreviations in insert mode, so only take the key when there
-- is a suggestion on screen to dismiss.
local function dismiss()
  if not visible() then
    return "<C-]>"
  end
  package.loaded["copilot.suggestion"].dismiss()
  return ""
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
              -- copilot.lua hides suggestions during completion by checking
              -- pumvisible(), which blink never sets, so both would draw inline
              -- text at the cursor. Yield to Copilot instead of drawing over it.
              -- Blink is otherwise untouched, and this leaves with the extra.
              -- Note this key holds one predicate: another extra that yields to
              -- blink the same way needs a shared one, not a second fragment.
              enabled = function()
                return not visible()
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
