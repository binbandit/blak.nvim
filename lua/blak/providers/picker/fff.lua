local M = {}

local function fff()
  local picker = require("blak.util").load_plugin("fff", "fff")
  if not picker then
    error("fff.nvim is not available")
  end
  return picker
end

function M.files(opts)
  opts = opts or {}
  local picker = fff()
  if opts.cwd and picker.find_files_in_dir then
    return picker.find_files_in_dir(opts.cwd)
  end
  return picker.find_files()
end

function M.grep(opts)
  local picker = fff()
  return picker.live_grep(opts or {})
end

return M
