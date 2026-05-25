-- Run after Lazy sync with Blak runtime loaded.
local function lines()
  return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local function finish(err)
  if err then
    vim.api.nvim_err_writeln(err)
    vim.cmd("cquit")
    return
  end
  vim.cmd("qa!")
end

vim.cmd("enew")
vim.bo.filetype = "javascript"
vim.api.nvim_input("iif (true) ")

vim.defer_fn(function()
  if package.loaded["nvim-autopairs"] == nil or vim.api.nvim_get_mode().mode ~= "i" then
    finish("nvim-autopairs did not load on InsertEnter")
    return
  end
  vim.api.nvim_input("{<CR>x<Esc>")
end, 250)

vim.defer_fn(function()
  local current = lines()
  if vim.api.nvim_get_mode().mode ~= "n" or current[1] ~= "if (true) {" or current[2] ~= "  x" or current[3] ~= "}" then
    finish("bracket Enter should place cursor inside and closing brace below, got " .. vim.inspect(current))
    return
  end
  finish()
end, 900)
