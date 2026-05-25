local M = {}

local function builtin()
  return require("telescope.builtin")
end

function M.files(opts) return builtin().find_files(opts) end
function M.grep(opts) return builtin().live_grep(opts) end
function M.buffers(opts) return builtin().buffers(opts) end
function M.recent(opts) return builtin().oldfiles(opts) end
function M.commands(opts) return builtin().commands(opts) end
function M.keymaps(opts) return builtin().keymaps(opts) end
function M.help(opts) return builtin().help_tags(opts) end
function M.diagnostics(opts) return builtin().diagnostics(opts) end
function M.lsp_symbols(opts) return builtin().lsp_document_symbols(opts) end
function M.workspace_symbols(opts) return builtin().lsp_dynamic_workspace_symbols(opts) end

return M
