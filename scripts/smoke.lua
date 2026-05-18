-- Run with: NVIM_APPNAME=blak-test nvim --headless -u NONE --cmd 'set loadplugins' --cmd 'lua vim.opt.rtp:prepend(vim.fn.getcwd())' -c 'lua dofile("scripts/smoke.lua")' -c qa
-- This catches actual runtime/plugin-manager regressions in CI.
local sep = package.config:sub(1, 1)

local function join(...)
  local out = {}
  for _, part in ipairs({ ... }) do
    if part and part ~= "" then
      table.insert(out, (tostring(part):gsub("[/\\]+$", "")))
    end
  end
  return table.concat(out, sep)
end

local function write_file(path, data)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local fd = assert(io.open(path, "w"))
  fd:write(data)
  fd:close()
end

local runtime_dir = join(vim.fn.stdpath("state"), "blak-smoke-runtime")
local user_file = join(runtime_dir, "lua", "blak", "user.lua")
vim.fn.delete(runtime_dir, "rf")
write_file(user_file, "return { editor = { relative_number = false }, picker = { provider = 'fff' } }\n")
vim.opt.rtp:prepend(runtime_dir)

vim.g.blak_config = {
  ui = { splash = { enabled = false } },
  mason = { automatic_install = false },
}
require("blak").setup()
vim.opt.rtp:prepend(vim.fn.getcwd())
assert(require("blak.config").get())
assert(require("blak.config").get().editor.relative_number == false, "user.lua was not loaded")
assert(require("blak.config").get().explorer.provider == "oil", "Oil should be the default explorer provider")
assert(vim.fn.exists(":Lazy") == 2, "lazy.nvim command was not registered")
assert(vim.fn.exists(":BlakTerminal") == 2, "BlakTerminal command was not registered")
assert(vim.fn.maparg("<leader>/", "n", false, true).desc == "Grep", "<leader>/ grep mapping missing")
assert(vim.fn.maparg("<leader>tt", "n", false, true).desc == "Terminal", "<leader>tt terminal mapping missing")
local blak_keymaps = {
  ["<leader>lc"] = "Blak config",
  ["<leader>le"] = "Extras",
  ["<leader>lk"] = "Blak keymaps",
  ["<leader>ln"] = "Blak news",
  ["<leader>lo"] = "Blak overview",
  ["<leader>ls"] = "Blak splash",
  ["<leader>lt"] = "Install Blak tools",
  ["<leader>lT"] = "Install Treesitter parsers",
  ["<leader>lU"] = "Upgrade Blak",
}
for lhs, desc in pairs(blak_keymaps) do
  assert(vim.fn.maparg(lhs, "n", false, true).desc == desc, lhs .. " mapping missing")
end
assert(vim.fn.maparg("-", "n") == "", "Blak should leave native - unmapped")
local previous_oil = package.loaded.oil
local called_oil = false
local opened_dir = "unset"
package.loaded.oil = {
  open = function(dir)
    called_oil = true
    opened_dir = dir
  end,
}
vim.fn.maparg("<leader>e", "n", false, true).callback()
package.loaded.oil = previous_oil
assert(called_oil, "<leader>e did not call Oil")
assert(opened_dir == nil, "<leader>e should let Oil choose the current buffer directory")
local previous_snacks = package.loaded.snacks
local called_snacks = false
package.loaded.snacks = {
  explorer = function()
    called_snacks = true
  end,
}
require("blak.core.explorer").open({ explorer = { provider = "snacks" } })
package.loaded.snacks = previous_snacks
assert(called_snacks, "snacks explorer provider did not call Snacks.explorer")
local splash = require("blak.splash")
local splash_data = require("blak.splash.frames.blackhole")
local splash_buf = vim.api.nvim_create_buf(false, true)
vim.bo[splash_buf].filetype = "snacks_dashboard"
local function splash_lines(indent)
  return vim.tbl_map(function(line)
    return string.rep(" ", indent) .. line
  end, splash.header())
end
local function splash_frame_anchor(frame)
  local best_index, best_anchor, best_column = 1, "", 1
  for index, line in ipairs(frame) do
    local anchor = vim.trim(line)
    if #anchor > #best_anchor then
      best_index, best_anchor, best_column = index, anchor, line:find("%S") or 1
    end
  end
  return best_index, best_anchor, best_column
end
local function splash_frame_indent(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for _, frame in ipairs(splash_data.frames) do
    local normalized = vim.tbl_map(function(line)
      local padding = splash_data.cols - vim.api.nvim_strwidth(line)
      return padding > 0 and (line .. string.rep(" ", padding)) or line
    end, frame)
    local anchor_index, anchor, anchor_column = splash_frame_anchor(normalized)
    for index, line in ipairs(lines) do
      local match_column = line:find(anchor, 1, true)
      if match_column and vim.trim(line) == anchor then
        return index - anchor_index, match_column - anchor_column
      end
    end
  end
end
vim.api.nvim_buf_set_lines(splash_buf, 0, -1, false, splash_lines(2))
splash.play(splash_buf, { loop = true })
assert(vim.b[splash_buf].blak_splash_playing, "splash animation did not start")
vim.api.nvim_buf_set_lines(splash_buf, 0, -1, false, splash_lines(8))
splash.play(splash_buf, { loop = true })
vim.wait(120, function()
  return false
end, 20)
local _, refreshed_indent = splash_frame_indent(splash_buf)
assert(refreshed_indent == 8, "running splash did not keep the refreshed dashboard indent")
splash.attach_to_snacks({ ui = { splash = { enabled = true, animate = true, loop = true } } })
vim.wait(20, function()
  return false
end, 10)
vim.api.nvim_exec_autocmds("User", { pattern = "SnacksDashboardUpdatePre", modeline = false })
vim.api.nvim_buf_set_lines(splash_buf, 0, -1, false, splash_lines(12))
vim.api.nvim_exec_autocmds("User", { pattern = "SnacksDashboardUpdatePost", modeline = false })
local _, event_indent = splash_frame_indent(splash_buf)
assert(event_indent == 12, "splash did not repaint at the refreshed dashboard indent")
vim.api.nvim_buf_delete(splash_buf, { force = true })
local lazy_plugins = require("lazy.core.config").plugins
assert(lazy_plugins["tokyonight.nvim"], "tokyonight.nvim spec missing")
assert(lazy_plugins["tokyonight.nvim"].lazy == false, "tokyonight.nvim must load eagerly")
assert(
  lazy_plugins["tokyonight.nvim"].priority > lazy_plugins["snacks.nvim"].priority,
  "tokyonight.nvim must load before UI plugins"
)
if lazy_plugins["tokyonight.nvim"]._.loaded then
  assert(vim.g.colors_name == "tokyonight-night", "TokyoNight Night should be the default colorscheme")
end
assert(lazy_plugins["oil.nvim"], "oil.nvim spec missing")
assert(lazy_plugins["oil.nvim"].lazy == false, "oil.nvim must load eagerly for directory args")
assert(lazy_plugins["oil.nvim"].opts.default_file_explorer == true, "oil.nvim must take directory buffers")
local reload_seen = false
vim.api.nvim_create_autocmd("User", {
  pattern = "BlakConfigReloaded",
  callback = function()
    reload_seen = true
  end,
})
vim.cmd.edit(vim.fn.fnameescape(user_file))
vim.api.nvim_buf_set_lines(0, 0, -1, false, {
  "return { editor = { relative_number = true }, picker = { provider = 'snacks' } }",
})
vim.cmd.write()
vim.wait(1000, function()
  return reload_seen and require("blak.config").get().picker.provider == "snacks"
end)
assert(reload_seen, "saving user.lua did not emit BlakConfigReloaded")
assert(require("blak.config").get().editor.relative_number == true, "saving user.lua did not reload config")
assert(require("blak.config").get().picker.provider == "snacks", "saving user.lua did not refresh picker config")
vim.cmd("checkhealth blak")
vim.fn.delete(runtime_dir, "rf")
