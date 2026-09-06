-- Real plugin options must survive reload, including function-valued user opts.
local util = require("blak.util")
local user = util.join(vim.fn.stdpath("config"), "lua", "blak", "user.lua")
local original = util.read_file(user)
local compressed = vim.fn.tempname()
local ok, err = xpcall(function()
  vim.cmd("Lazy load conform.nvim blink.cmp")
  assert(
    vim.wait(10000, function()
      return package.loaded["blink.cmp.keymap.apply"] ~= nil
    end, 50),
    "Blink keymaps did not finish initializing"
  )
  local function reload(extra)
    util.write_file(user, [[
return {
  plugins = { specs = {
    { "stevearc/conform.nvim", opts = function(_, opts)
      opts.format_on_save = false
      opts.formatters_by_ft.custom = { "fixture" }
    end },
    { "saghen/blink.cmp", opts = { keymap = { ["<C-space>"] = false, ["<F6>"] = { "show" } } } },
  } },
]] .. extra .. "\n}")
    assert(require("blak.core.reload").reload({ notify = false }))
  end
  reload('format = { formatters_by_ft = { temporary = { "fixture" } } },')
  assert(require("conform").formatters_by_ft.temporary, "initial formatter not applied")
  reload("")
  assert(require("conform").formatters_by_ft.temporary == nil, "removed formatter survived reload")
  assert(require("conform").formatters_by_ft.custom[1] == "fixture", "custom plugin opts lost")
  assert(
    #vim.api.nvim_get_autocmds({ group = "Conform", event = "BufWritePre" }) == 0,
    "reload re-enabled explicitly disabled Conform format-on-save"
  )
  local mappings = vim.api.nvim_buf_get_keymap(0, "i")
  local found = false
  for _, mapping in ipairs(mappings) do
    assert(mapping.lhs ~= "<C-Space>", "reload re-enabled disabled Blink shortcut")
    found = found or mapping.lhs == "<F6>"
  end
  assert(found, "reload dropped custom Blink shortcut")

  -- Native helpers must remain available when Blak has no replacement.
  assert(vim.g.loaded_gzip == 1, "native compressed-file support disabled")
  assert(vim.g.loaded_tarPlugin ~= nil, "native tar support disabled")
  assert(vim.g.loaded_zipPlugin ~= nil, "native zip support disabled")
  assert(vim.fn.exists(":Tutor") == 2, "native Tutor disabled")
  if vim.fn.executable("gzip") == 1 then
    vim.fn.writefile({ "native compressed file" }, compressed)
    vim.fn.system({ "gzip", compressed })
    assert(vim.v.shell_error == 0, "could not create compressed fixture")
    vim.cmd.edit(vim.fn.fnameescape(compressed .. ".gz"))
    assert(vim.api.nvim_get_current_line() == "native compressed file", "gzip file was not decoded")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "round trip" })
    vim.cmd("write")
    local content = vim.fn.system({ "gzip", "-dc", compressed .. ".gz" })
    assert(
      vim.v.shell_error == 0 and content == "round trip\n",
      "gzip write did not preserve compression"
    )
  end

  -- Buffer-specific Blak UI shortcuts must be discoverable too.
  local extras_buf = require("blak.extras_view").open()
  require("blak.core.keymaps").show()
  local lines = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  assert(lines:find("Toggle Blak extra", 1, true), "BlakKeys omitted extras UI shortcuts")
  vim.cmd("close")
  vim.api.nvim_buf_delete(extras_buf, { force = true })
end, debug.traceback)
vim.fn.delete(compressed)
vim.fn.delete(compressed .. ".gz")
if original then
  util.write_file(user, original)
else
  vim.fn.delete(user)
end
assert(ok, err)
print("Plugin reload integration passed")
