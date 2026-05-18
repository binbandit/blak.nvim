local M = {}

local state = {
  buf = nil,
  win = nil,
}

local function valid_buf(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

local function valid_win(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function open_window()
  vim.cmd("botright 12split")
  state.win = vim.api.nvim_get_current_win()
end

local function normalize(config_or_opts, maybe_opts)
  if maybe_opts ~= nil or (type(config_or_opts) == "table" and config_or_opts.terminal ~= nil) then
    return config_or_opts or require("blak.config").get(), maybe_opts or {}
  end
  return require("blak.config").get(), config_or_opts or {}
end

local function terminal_config(config)
  return config.terminal or { provider = "native" }
end

function M.provider(config)
  return terminal_config(config or require("blak.config").get()).provider or "native"
end

function M.label(config)
  return M.provider(config) == "snacks" and "Snacks terminal" or "Native terminal split"
end

function M.toggle_native(opts)
  opts = opts or {}

  if valid_win(state.win) and not opts.cmd then
    vim.api.nvim_win_close(state.win, true)
    state.win = nil
    return
  end

  if valid_win(state.win) then
    vim.api.nvim_set_current_win(state.win)
  else
    open_window()
  end

  if valid_buf(state.buf) and opts.cmd == nil then
    vim.api.nvim_win_set_buf(state.win, state.buf)
  else
    vim.cmd.terminal(opts.cmd or vim.o.shell)
    state.buf = vim.api.nvim_get_current_buf()
    vim.bo[state.buf].buflisted = false
  end

  vim.cmd.startinsert()
end

local function toggle_snacks(config, opts)
  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.terminal then
    require("blak.util").warn("Snacks terminal is not available; using native terminal.")
    return M.toggle_native(opts)
  end

  local snack_opts = vim.tbl_deep_extend(
    "force",
    {},
    vim.tbl_get(config, "snacks", "terminal") or {},
    terminal_config(config).snacks or {}
  )
  return snacks.terminal.toggle(opts.cmd, snack_opts)
end

function M.toggle(config_or_opts, maybe_opts)
  local config, opts = normalize(config_or_opts, maybe_opts)
  opts = opts or {}

  if M.provider(config) == "snacks" then
    return toggle_snacks(config, opts)
  end
  return M.toggle_native(opts)
end

return M
