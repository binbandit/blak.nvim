local M = {}

function M.setup(_)
  local group = vim.api.nvim_create_augroup("BlakCore", { clear = true })

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function()
      vim.highlight.on_yank({ timeout = 180 })
    end,
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      vim.cmd("tabdo wincmd =")
    end,
  })

  vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function(event)
      local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
      local line_count = vim.api.nvim_buf_line_count(event.buf)
      if mark[1] > 0 and mark[1] <= line_count then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "help", "qf", "man", "checkhealth", "lspinfo", "notify" },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, desc = "Close" })
    end,
  })
end

return M
