local M = {}
local skip_next_lazy_update_backup = false

local function lockfile()
  return require("blak.util").join(vim.fn.stdpath("config"), "lazy-lock.json")
end

local function backup_dir()
  return require("blak.util").join(vim.fn.stdpath("state"), "blak", "lockbacks")
end

local function timestamp()
  return os.date("%Y%m%d-%H%M%S")
end

local function next_backup_path()
  local util = require("blak.util")
  local dir = backup_dir()
  local stamp = timestamp()
  local path = util.join(dir, "lazy-lock-" .. stamp .. ".json")
  if not util.file_exists(path) then
    return path
  end

  for index = 1, 999 do
    path = util.join(dir, string.format("lazy-lock-%s-%03d.json", stamp, index))
    if not util.file_exists(path) then
      return path
    end
  end

  local uv = vim.uv or vim.loop
  return util.join(dir, string.format("lazy-lock-%s-%s.json", stamp, uv.hrtime()))
end

local function backup_order(path)
  local name = vim.fn.fnamemodify(path, ":t")
  local stamp, suffix = name:match("^lazy%-lock%-(%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d)%-?(%d*)%.json$")
  if stamp then
    return stamp, tonumber(suffix) or 0
  end
  return name, 0
end

local function latest_backup(files)
  table.sort(files, function(a, b)
    local a_stamp, a_suffix = backup_order(a)
    local b_stamp, b_suffix = backup_order(b)
    if a_stamp == b_stamp then
      return a_suffix < b_suffix
    end
    return a_stamp < b_stamp
  end)
  return files[#files]
end

local function lazy_update()
  local dest = M.backup()
  skip_next_lazy_update_backup = dest ~= nil
  local ok, err = pcall(vim.cmd, "Lazy update")
  if skip_next_lazy_update_backup then
    skip_next_lazy_update_backup = false
  end
  if not ok then
    error(err)
  end
end

function M.backup()
  local util = require("blak.util")
  local lock = lockfile()
  if not util.file_exists(lock) then
    return nil
  end
  util.mkdir(backup_dir())
  local dest = next_backup_path()
  if util.copy_file(lock, dest) then
    return dest
  end
  return nil
end

function M.setup(_)
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyUpdatePre",
    group = vim.api.nvim_create_augroup("BlakUpdate", { clear = true }),
    callback = function()
      if skip_next_lazy_update_backup then
        skip_next_lazy_update_backup = false
        return
      end
      local dest = M.backup()
      if dest then
        require("blak.util").notify("Rollback point created: " .. vim.fn.fnamemodify(dest, ":t"))
      end
    end,
  })
end

function M.update()
  lazy_update()
end

function M.upgrade()
  require("blak.util").notify("Upgrade mode: review Lazy changes before accepting workflow-affecting plugin swaps.")
  lazy_update()
end

function M.rollback()
  local util = require("blak.util")
  local files = vim.fn.glob(util.join(backup_dir(), "lazy-lock-*.json"), false, true)
  local latest = latest_backup(files)
  if not latest then
    util.warn("No rollback lockfile found.")
    return
  end
  util.copy_file(latest, lockfile())
  util.notify("Restored " .. vim.fn.fnamemodify(latest, ":t") .. ". Running :Lazy restore.")
  vim.cmd("Lazy restore")
end

function M.news()
  local root = vim.fn.stdpath("config")
  local news = require("blak.util").join(root, "NEWS.md")
  if vim.fn.filereadable(news) == 1 then
    vim.cmd.edit(news)
  else
    require("blak.util").open_scratch("Blak news", {
      "Blak v0.1.0",
      "",
      "Initial release: native-first LSP, fff.nvim file picker, Snacks dashboard, blink.cmp, Mason, Conform, nvim-lint, Oil, Gitsigns, and reversible extras.",
    })
  end
end

return M
