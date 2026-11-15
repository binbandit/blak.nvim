local M = {}

local function fzf()
  local module = require("blak.util").load_plugin("fzf-lua", "fzf-lua")
  if not module then
    error("fzf-lua is not available", 0)
  end
  return module
end

function M.files(opts)
  return fzf().files(opts)
end
function M.grep(opts)
  return fzf().live_grep(opts)
end
function M.buffers(opts)
  return fzf().buffers(opts)
end
-- Match the Snacks and Telescope pickers, which list files opened this session too.
function M.recent(opts)
  return fzf().oldfiles(vim.tbl_extend("keep", opts or {}, { include_current_session = true }))
end
function M.commands(opts)
  return fzf().commands(opts)
end
function M.keymaps(opts)
  return fzf().keymaps(opts)
end
function M.help(opts)
  return fzf().helptags(opts)
end
function M.diagnostics(opts)
  return fzf().diagnostics_workspace(opts)
end
function M.lsp_symbols(opts)
  return fzf().lsp_document_symbols(opts)
end
-- Query the server as you type, like the Snacks and Telescope workspace symbol pickers.
function M.workspace_symbols(opts)
  return fzf().lsp_live_workspace_symbols(opts)
end

return M
