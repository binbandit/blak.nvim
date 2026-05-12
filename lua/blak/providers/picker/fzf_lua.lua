local M = {}

local function fzf()
  return require("fzf-lua")
end

function M.smart(opts) return fzf().files(opts) end
function M.files(opts) return fzf().files(opts) end
function M.grep(opts) return fzf().live_grep(opts) end
function M.buffers(opts) return fzf().buffers(opts) end
function M.recent(opts) return fzf().oldfiles(opts) end
function M.commands(opts) return fzf().commands(opts) end
function M.keymaps(opts) return fzf().keymaps(opts) end
function M.help(opts) return fzf().help_tags(opts) end
function M.diagnostics(opts) return fzf().diagnostics_document(opts) end
function M.lsp_symbols(opts) return fzf().lsp_document_symbols(opts) end
function M.workspace_symbols(opts) return fzf().lsp_workspace_symbols(opts) end

return M
