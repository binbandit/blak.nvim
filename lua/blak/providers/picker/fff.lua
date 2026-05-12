local M = {}

local function fff()
  return require("fff")
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
  return fff().live_grep(opts or {})
end

function M.smart(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or require("blak.util").git_root()
  return M.files(opts)
end

return M
