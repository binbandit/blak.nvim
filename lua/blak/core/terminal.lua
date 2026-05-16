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

function M.toggle(opts)
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

return M
