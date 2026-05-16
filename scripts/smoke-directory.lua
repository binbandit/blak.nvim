-- Run after init.lua and a directory argument have been processed.
-- This catches regressions where `blak .` opens an empty buffer instead of Oil.
local filetype = vim.bo.filetype
local name = vim.api.nvim_buf_get_name(0)

assert(filetype == "oil", string.format("directory arg opened filetype %q, expected oil", filetype))
assert(name:match("^oil://"), string.format("directory arg opened %q, expected oil:// buffer", name))
