local M = {}

local function builtin()
  local module = require("blak.util").load_plugin("telescope.nvim", "telescope.builtin")
  if not module then
    error("telescope.nvim is not available", 0)
  end
  return module
end

function M.files(opts)
  return builtin().find_files(opts)
end
function M.grep(opts)
  return builtin().live_grep(opts)
end
function M.buffers(opts)
  return builtin().buffers(opts)
end
function M.recent(opts)
  return builtin().oldfiles(opts)
end
function M.commands(opts)
  return builtin().commands(opts)
end
function M.keymaps(opts)
  return builtin().keymaps(opts)
end
function M.help(opts)
  return builtin().help_tags(opts)
end
function M.diagnostics(opts)
  return builtin().diagnostics(opts)
end
function M.lsp_symbols(opts)
  return builtin().lsp_document_symbols(opts)
end
function M.workspace_symbols(opts)
  return builtin().lsp_dynamic_workspace_symbols(opts)
end

return M
