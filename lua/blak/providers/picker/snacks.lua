local M = {}

local function picker()
  local ok, snacks = pcall(require, "snacks")
  if ok then
    return snacks.picker
  end
  return _G.Snacks and _G.Snacks.picker
end

local function call(name, opts)
  local p = picker()
  if not p or not p[name] then
    error("Snacks picker does not support " .. name)
  end
  return p[name](opts or {})
end

function M.smart(opts) return call("files", opts) end
function M.files(opts) return call("files", opts) end
function M.grep(opts) return call("grep", opts) end
function M.buffers(opts) return call("buffers", opts) end
function M.recent(opts) return call("recent", opts) end
function M.commands(opts) return call("commands", opts) end
function M.keymaps(opts) return call("keymaps", opts) end
function M.help(opts) return call("help", opts) end
function M.diagnostics(opts) return call("diagnostics", opts) end
function M.lsp_symbols(opts) return call("lsp_symbols", opts) end
function M.workspace_symbols(opts) return call("lsp_workspace_symbols", opts) end

return M
