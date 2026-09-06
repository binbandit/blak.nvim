-- :lua errors alone do not make a subsequent :qa fail. Make assertions fatal.
return function(path)
  local ok, err = xpcall(function()
    dofile(path)
  end, debug.traceback)
  if not ok then
    vim.api.nvim_err_writeln(err)
    vim.cmd("cquit 1")
  end
end
