-- Exercise the real extras UI and persistence with isolated XDG paths.
local extras = require("blak.extras")
local saved = require("blak.extras.state")
local view = require("blak.extras_view")
local config = vim.deepcopy(require("blak.config.defaults"))
local original = saved.read()
local original_columns, original_lines = vim.o.columns, vim.o.lines
local win

local function open(ids, value)
  saved.write(ids)
  view.open(value or config)
  win = vim.api.nvim_get_current_win()
  return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local function main_line(lines, id)
  for line, text in ipairs(lines) do
    if text:find(id .. " ", 1, true) then
      return line
    end
  end
  error("extra is missing from the view: " .. id)
end

local function toggle(line, key)
  vim.api.nvim_win_set_cursor(win, { line, 0 })
  vim.fn.maparg(key or "x", "n", false, true).callback()
end

local function assert_fits()
  local opts = vim.api.nvim_win_get_config(win)
  local border = opts.border and opts.border ~= "none" and #opts.border > 0 and 2 or 0
  assert(opts.width > 0 and opts.height > 0, "extras window has invalid dimensions")
  assert(opts.col >= 0 and opts.row >= 0, "extras window starts outside the screen")
  assert(opts.col + opts.width + border <= vim.o.columns, "extras window is wider than the screen")
  assert(
    opts.row + opts.height + border <= vim.o.lines - vim.o.cmdheight,
    "extras window is taller than the usable screen"
  )
end

local ok, err = xpcall(function()
  local initial = { "lang.lua", "lang.python", "lang.rust" }
  local lines = open(initial)
  for line, text in ipairs(lines) do
    if text == "" or text:match("^[A-Z][A-Za-z ]+ %(%d+%)$") then
      toggle(line)
      assert(
        vim.deep_equal(saved.read(), initial),
        "a heading or separator toggled an unrelated extra"
      )
    end
  end

  -- Names, descriptions and feature details target their own extra.
  for offset = 0, 2 do
    lines = open(initial)
    local first = main_line(lines, "lang.python")
    toggle(first + offset, offset == 1 and "<CR>" or "x")
    assert(
      vim.deep_equal(saved.read(), { "lang.lua", "lang.rust" }),
      "an extra's display row toggled the wrong entry"
    )
    local updated = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    assert(
      vim.api.nvim_win_get_cursor(win)[1] == main_line(updated, "lang.python"),
      "redraw did not return the cursor to the toggled extra's name"
    )
  end

  local managed = vim.deepcopy(config)
  managed.extras.enabled = { "lang.python" }
  lines = open({}, managed)
  toggle(main_line(lines, "lang.python"))
  assert(
    vim.tbl_contains(extras.enabled(managed), "lang.python"),
    "UI disabled a config-managed extra"
  )
  assert(vim.deep_equal(saved.read(), {}), "UI wrote state for a config-managed extra")

  vim.api.nvim_win_close(win, true)
  vim.o.columns, vim.o.lines = 40, 12
  open({})
  assert_fits()
  for _, size in ipairs({ { 120, 45 }, { 24, 7 }, { 20, 3 }, { 40, 12 } }) do
    vim.o.columns, vim.o.lines = size[1], size[2]
    vim.api.nvim_exec_autocmds("VimResized", { modeline = false })
    assert_fits()
  end
  vim.api.nvim_win_close(win, true)
  vim.api.nvim_exec_autocmds("VimResized", { modeline = false })
end, debug.traceback)

if win and vim.api.nvim_win_is_valid(win) then
  vim.api.nvim_win_close(win, true)
end
vim.o.columns, vim.o.lines = original_columns, original_lines
saved.write(original)
assert(ok, err)
print("Extras UI checks passed")
