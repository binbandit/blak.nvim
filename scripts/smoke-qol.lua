-- Run through scripts/run-test.lua with isolated XDG paths.
local config = vim.deepcopy(require("blak.config.defaults"))
require("blak.core.commands").setup(config)

local calls = {}
local original_conform = package.loaded.conform
package.loaded.conform = {
  format = function(opts)
    table.insert(calls, opts)
  end,
}
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "first", "middle", "last é", "" })
vim.cmd("BlakFormat")
assert(calls[1].range == nil, "formatting without a range should format the whole buffer")
assert(calls[1].lsp_format == nil, "manual formatting overrides per-filetype LSP policy")

vim.cmd("2,3BlakFormat")
assert(
  vim.deep_equal(calls[2].range, { start = { 2, 0 }, ["end"] = { 3, #"last é" } }),
  "line ranges must include the entire final line using byte columns"
)
vim.api.nvim_buf_set_mark(0, "<", 2, 1, {})
vim.api.nvim_buf_set_mark(0, ">", 3, 2, {})
vim.cmd("'<,'>BlakFormat")
assert(vim.deep_equal(calls[3].range, calls[2].range), "visual line ranges did not reach Conform")
vim.cmd("4BlakFormat")
assert(
  vim.deep_equal(calls[4].range, { start = { 4, 0 }, ["end"] = { 4, 0 } }),
  "empty selected lines should use column zero"
)
package.loaded.conform = original_conform
vim.bo.modified = false

local terminal = require("blak.core.terminal")
terminal.toggle_native({ cmd = "cat" })
vim.cmd.stopinsert()
local live = vim.api.nvim_get_current_buf()
local job = vim.b[live].terminal_job_id
terminal.toggle_native()
terminal.toggle_native()
vim.cmd.stopinsert()
assert(vim.api.nvim_get_current_buf() == live, "a running terminal should be reused")
assert(vim.fn.jobwait({ job }, 0)[1] == -1, "hiding a running terminal stopped its process")
vim.api.nvim_buf_delete(live, { force = true })

terminal.toggle_native({ cmd = "printf blak-terminal-finished" })
vim.cmd.stopinsert()
local exited = vim.api.nvim_get_current_buf()
job = vim.b[exited].terminal_job_id
assert(vim.fn.jobwait({ job }, 2000)[1] == 0, "the terminal fixture did not exit")
local output = table.concat(vim.api.nvim_buf_get_lines(exited, 0, -1, false), "\n")
assert(output:find("blak-terminal-finished", 1, true), "terminal fixture output is missing")
terminal.toggle_native()
terminal.toggle_native()
vim.cmd.stopinsert()
local fresh = vim.api.nvim_get_current_buf()
assert(fresh ~= exited, "reopening an exited terminal must start a fresh shell")
assert(
  vim.fn.jobwait({ vim.b[fresh].terminal_job_id }, 0)[1] == -1,
  "new terminal shell is not running"
)
assert(vim.api.nvim_buf_is_valid(exited), "reopening the terminal discarded its previous output")
assert(
  table
    .concat(vim.api.nvim_buf_get_lines(exited, 0, -1, false), "\n")
    :find("blak-terminal-finished", 1, true),
  "reopening the terminal modified its previous output"
)
vim.api.nvim_buf_delete(fresh, { force = true })
vim.api.nvim_buf_delete(exited, { force = true })

print("Quality-of-life checks passed")
