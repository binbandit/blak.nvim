local M = {}

local uv = vim.uv or vim.loop

function M.notify(message, level, opts)
  level = level or vim.log.levels.INFO
  opts = vim.tbl_extend("force", { title = "Blak" }, opts or {})
  vim.schedule(function()
    vim.notify(message, level, opts)
  end)
end

function M.warn(message)
  M.notify(message, vim.log.levels.WARN)
end

function M.error(message)
  M.notify(message, vim.log.levels.ERROR)
end

function M.try_require(module)
  local ok, value = pcall(require, module)
  if ok then
    return value
  end
  return nil, value
end

function M.is_module_not_found(err, module)
  return type(err) == "string" and err:find("module '" .. module .. "' not found", 1, true) ~= nil
end

function M.load_plugin(plugin, module)
  local ok, value = pcall(require, module)
  if ok then
    return value
  end

  pcall(vim.cmd, "Lazy load " .. plugin)
  ok, value = pcall(require, module)
  if ok then
    return value
  end

  M.warn(plugin .. " is not installed or could not be loaded. Run :Lazy sync, then restart.")
  return nil
end

function M.executable(binary)
  return vim.fn.executable(binary) == 1
end

function M.sep()
  return package.config:sub(1, 1)
end

function M.join(...)
  if vim.fs and vim.fs.joinpath then
    return vim.fs.joinpath(...)
  end
  local sep = M.sep()
  local out = {}
  for _, part in ipairs({ ... }) do
    if part and part ~= "" then
      table.insert(out, (tostring(part):gsub("[/\\]+$", "")))
    end
  end
  return table.concat(out, sep)
end

function M.mkdir(path)
  vim.fn.mkdir(path, "p")
end

function M.read_file(path)
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end
  local data = fd:read("*a")
  fd:close()
  return data
end

function M.write_file(path, data)
  M.mkdir(vim.fn.fnamemodify(path, ":h"))
  local fd = assert(io.open(path, "w"))
  fd:write(data)
  fd:close()
end

function M.copy_file(from, to)
  local data = M.read_file(from)
  if not data then
    return false
  end
  M.write_file(to, data)
  return true
end

function M.file_exists(path)
  return uv.fs_stat(path) ~= nil
end

function M.unique(list)
  local seen = {}
  local out = {}
  for _, value in ipairs(list or {}) do
    if value ~= nil and value ~= "" and not seen[value] then
      seen[value] = true
      table.insert(out, value)
    end
  end
  table.sort(out)
  return out
end

function M.extend_list(dst, src)
  dst = dst or {}
  for _, value in ipairs(src or {}) do
    table.insert(dst, value)
  end
  return M.unique(dst)
end

function M.tbl_keys(tbl)
  local keys = {}
  for key, _ in pairs(tbl or {}) do
    table.insert(keys, key)
  end
  table.sort(keys)
  return keys
end

function M.git_root()
  local ok, result = pcall(vim.fs.root, 0, { ".git" })
  if ok and result then
    return result
  end
  local cwd = uv.cwd()
  local handle = io.popen("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")
  if handle then
    local root = handle:read("*l")
    handle:close()
    if root and root ~= "" then
      return root
    end
  end
  return cwd
end

function M.open_scratch(title, lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "blak"
  pcall(vim.api.nvim_buf_set_name, buf, string.format("%s://%d", title:gsub("%s+", "-"), buf))
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines or {})
  vim.cmd("botright split")
  vim.api.nvim_win_set_buf(0, buf)
  vim.bo[buf].modifiable = false
  return buf
end

return M
