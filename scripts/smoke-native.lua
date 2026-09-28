local config = vim.deepcopy(require("blak.config.defaults"))
local keys = require("blak.core.keymaps")
vim.g.mapleader = " "
keys.setup(config)
require("blak.core.commands").setup(config)

-- External formatters work even when there is no language server attached.
assert(#vim.lsp.get_clients({ bufnr = 0 }) == 0)
local formatted
package.loaded.conform = {
  format = function(opts)
    formatted = opts
  end,
}
vim.cmd.normal({ " cf", bang = false })
assert(formatted, "format key requires LSP")

config.keymaps = {
  { key = "<leader>cf", action = "<Nop>", description = "Custom formatter" },
}
keys.setup(config)
assert(vim.fn.maparg("<leader>cf", "n", false, true).desc == "Custom formatter")
config.keymaps = { { key = "<leader>cf", disable = true } }
keys.setup(config)
assert(vim.fn.maparg("<leader>cf", "n") == "", "disabled format key was restored")
config.keymaps = {}
keys.setup(config)

-- Diagnostic navigation still opens an unfocused cursor float in both directions.
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "first", "second", "third" })
local namespace = vim.api.nvim_create_namespace("BlakNativeSmoke")
vim.diagnostic.set(namespace, 0, {
  { lnum = 0, col = 0, message = "first diagnostic", severity = vim.diagnostic.severity.ERROR },
  { lnum = 2, col = 0, message = "last diagnostic", severity = vim.diagnostic.severity.WARN },
})
local open_float = vim.diagnostic.open_float
local deprecate = vim.deprecate
local shown
vim.diagnostic.open_float = function(opts)
  shown = opts
end
vim.deprecate = function(name, ...)
  assert(name ~= "opts.float", "diagnostic jump still uses the deprecated float option")
  return deprecate(name, ...)
end
for _, case in ipairs({ { "]d", 3 }, { "[d", 1 } }) do
  shown = nil
  vim.fn.maparg(case[1], "n", false, true).callback()
  assert(
    vim.wait(1000, function()
      return shown ~= nil
    end),
    "diagnostic jump did not open a float"
  )
  assert(vim.api.nvim_win_get_cursor(0)[1] == case[2], "diagnostic jump moved to the wrong line")
  assert(shown.bufnr == vim.api.nvim_get_current_buf())
  assert(shown.scope == "cursor" and shown.focus == false, "diagnostic float behavior changed")
end
vim.diagnostic.open_float = open_float
vim.deprecate = deprecate
vim.diagnostic.reset(namespace)

-- Discovery includes native global maps and reports only the effective scope.
local native_rename = vim.fn.maparg("grn", "n", false, true)
assert(native_rename.desc, "Neovim's native rename mapping is unavailable")
vim.keymap.set("n", "<F8>", "<Nop>", { desc = "Shadowed global map" })
vim.keymap.set("n", "<F8>", "<Nop>", { buffer = 0, desc = "Effective buffer map" })
vim.keymap.set("n", "<F9>", "<Nop>", { desc = "Global hidden by undescribed buffer map" })
vim.keymap.set("n", "<F9>", "<Nop>", { buffer = 0 })
vim.keymap.set("n", "<leader>ff", "<Nop>", { buffer = 0, desc = "User buffer file picker" })
local other = vim.api.nvim_create_buf(true, false)
vim.keymap.set("n", "<F10>", "<Nop>", { buffer = other, desc = "Other buffer only" })
keys.show()
local rendered = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
assert(rendered:find(native_rename.desc, 1, true), "native global mapping is missing from BlakKeys")
assert(rendered:find("Effective buffer map", 1, true), "buffer-local mapping is missing")
assert(rendered:find("User buffer file picker", 1, true), "user override is missing")
assert(not rendered:find("Shadowed global map", 1, true), "shadowed global mapping is listed")
assert(not rendered:find("Global hidden by undescribed buffer map", 1, true))
assert(not rendered:find("Other buffer only", 1, true), "mapping from another buffer is listed")
assert(not rendered:find("<leader>ff%s+Find files"), "overridden Blak mapping is still listed")
assert(rendered:find("<leader>cf%s+Format"), "Blak mapping lost its familiar leader notation")
vim.cmd.close()

-- Yank highlighting uses the supported namespace, retaining the same behavior.
local on_yank = vim.hl.on_yank
local highlighted = false
vim.hl.on_yank = function(opts)
  highlighted = opts.timeout == 180
end
require("blak.core.autocmds").setup(config)
vim.api.nvim_exec_autocmds("TextYankPost", { modeline = false })
vim.hl.on_yank = on_yank
assert(highlighted, "native yank highlighting was not invoked")

print("Native editing and keymap discovery checks passed")
