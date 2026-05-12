local M = {}

local function lockfile()
  return require("blak.util").join(vim.fn.stdpath("config"), "lazy-lock.json")
end

local function backup_dir()
  return require("blak.util").join(vim.fn.stdpath("state"), "blak", "lockbacks")
end

local function timestamp()
  return os.date("%Y%m%d-%H%M%S")
end

function M.backup()
  local util = require("blak.util")
  local lock = lockfile()
  if not util.file_exists(lock) then
    return nil
  end
  util.mkdir(backup_dir())
  local dest = util.join(backup_dir(), "lazy-lock-" .. timestamp() .. ".json")
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
      local dest = M.backup()
      if dest then
        require("blak.util").notify("Rollback point created: " .. vim.fn.fnamemodify(dest, ":t"))
      end
    end,
  })
end

function M.update()
  M.backup()
  vim.cmd("Lazy update")
end

function M.upgrade()
  M.backup()
  require("blak.util").notify("Upgrade mode: review Lazy changes before accepting workflow-affecting plugin swaps.")
  vim.cmd("Lazy update")
end

function M.rollback()
  local util = require("blak.util")
  local files = vim.fn.glob(util.join(backup_dir(), "lazy-lock-*.json"), false, true)
  table.sort(files)
  local latest = files[#files]
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
