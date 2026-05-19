local M = {}

local registered = {}
local registered_lookup = {}
local disabled_keymaps = {}
local owned_keymaps = {}
local terminal_lhs

-- Built-in commands do not appear in maparg(), so optional keys need a small
-- reserved list when Blak would otherwise shadow native editing behavior.
local nvim_builtin_keys = {
  n = {
    ["-"] = true,
  },
}

local function mode_list(mode)
  return type(mode) == "table" and mode or { mode or "n" }
end

local function is_nvim_builtin_key(mode, lhs)
  return nvim_builtin_keys[mode] and nvim_builtin_keys[mode][lhs]
end

local function registry_key(mode, lhs)
  return tostring(mode) .. "|" .. tostring(lhs)
end

local function rebuild_registered_lookup()
  registered_lookup = {}
  for index, item in ipairs(registered) do
    registered_lookup[registry_key(item.mode, item.lhs)] = index
  end
end

local function register(mode, lhs, desc)
  for _, item in ipairs(mode_list(mode)) do
    local key = registry_key(item, lhs)
    local index = registered_lookup[key]
    if index then
      registered[index].desc = desc or ""
    else
      table.insert(registered, { mode = item, lhs = lhs, desc = desc or "" })
      registered_lookup[key] = #registered
    end
  end
end

local function unregister(mode, lhs)
  local modes = {}
  for _, item in ipairs(mode_list(mode)) do
    modes[item] = true
  end

  local changed = false
  for index = #registered, 1, -1 do
    local item = registered[index]
    if modes[item.mode] and item.lhs == lhs then
      table.remove(registered, index)
      changed = true
    end
  end
  if changed then
    rebuild_registered_lookup()
  end
end

local function is_disabled(mode, lhs)
  return disabled_keymaps[registry_key(mode, lhs)] == true
end

local function enabled_modes(mode, lhs, force)
  local modes = {}
  for _, item in ipairs(mode_list(mode)) do
    if force or not is_disabled(item, lhs) then
      table.insert(modes, item)
    end
  end
  return modes
end

local function keymap_del_opts(opts)
  if type(opts) == "table" and opts.buffer ~= nil then
    return { buffer = opts.buffer }
  end
end

local function ownable_keymap_opts(opts)
  -- Buffer-local maps are owned by their buffer event, such as LspAttach.
  return not (type(opts) == "table" and opts.buffer ~= nil)
end

local function keymap_matches_owner(owner)
  local keymap = vim.fn.maparg(owner.lhs, owner.mode, false, true)
  if type(keymap) ~= "table" or next(keymap) == nil then
    return false
  end
  if (keymap.desc or "") ~= owner.desc then
    return false
  end
  if owner.callback ~= nil then
    return keymap.callback == owner.callback
  end
  if owner.rhs ~= nil and owner.rhs ~= "" then
    return keymap.rhs == owner.rhs
  end
  return true
end

local function remember_keymap(mode, lhs, opts)
  if not ownable_keymap_opts(opts) then
    return
  end

  for _, item in ipairs(mode_list(mode)) do
    local keymap = vim.fn.maparg(lhs, item, false, true)
    if type(keymap) == "table" and next(keymap) ~= nil then
      owned_keymaps[registry_key(item, lhs)] = {
        mode = item,
        lhs = lhs,
        desc = keymap.desc or "",
        rhs = keymap.rhs,
        callback = keymap.callback,
      }
    end
  end
end

local function forget_keymap(mode, lhs, opts)
  if not ownable_keymap_opts(opts) then
    return
  end

  for _, item in ipairs(mode_list(mode)) do
    owned_keymaps[registry_key(item, lhs)] = nil
  end
end

local function clear_owned_keymaps()
  for key, owner in pairs(owned_keymaps) do
    if keymap_matches_owner(owner) then
      pcall(vim.keymap.del, owner.mode, owner.lhs)
    end
    owned_keymaps[key] = nil
  end
end

local function delete_keymap(mode, lhs, opts)
  for _, item in ipairs(mode_list(mode)) do
    pcall(vim.keymap.del, item, lhs, keymap_del_opts(opts))
    unregister(item, lhs)
    forget_keymap(item, lhs, opts)
  end
end

local function map(mode, lhs, rhs, desc, opts, force)
  local modes = enabled_modes(mode, lhs, force)
  if #modes == 0 then
    return
  end

  opts = vim.tbl_extend("force", { silent = true }, opts or {}, { desc = desc })
  vim.keymap.set(#modes == 1 and modes[1] or modes, lhs, rhs, opts)
  register(modes, lhs, desc)
  remember_keymap(modes, lhs, opts)
end

local function map_if_available(mode, lhs, rhs, desc, opts)
  for _, item in ipairs(mode_list(mode)) do
    if is_disabled(item, lhs) then
      unregister(item, lhs)
    else
      local keymap = vim.fn.maparg(lhs, item, false, true)
      if type(keymap) == "table" and next(keymap) ~= nil then
        if keymap.desc == desc then
          register(item, lhs, desc)
        end
      elseif not is_nvim_builtin_key(item, lhs) then
        map(item, lhs, rhs, desc, opts)
      end
    end
  end
end

local function keymap_lhs(item)
  return item.key or item.lhs
end

local function keymap_mode(item)
  return item.mode or item.modes or "n"
end

local function keymap_rhs(item)
  if item.disable == true then
    return false
  end
  if item.action ~= nil then
    return item.action
  end
  return item.rhs
end

local function keymap_desc(item)
  return item.description or item.desc
end

local function configure_disabled_keymaps(config)
  disabled_keymaps = {}
  for _, item in ipairs(config.keymaps or {}) do
    local lhs = type(item) == "table" and keymap_lhs(item) or nil
    if type(lhs) == "string" and keymap_rhs(item) == false then
      for _, mode in ipairs(mode_list(keymap_mode(item))) do
        disabled_keymaps[registry_key(mode, lhs)] = true
      end
    end
  end
end

local function apply_keymaps(keys, force)
  for _, item in ipairs(keys or {}) do
    local lhs = keymap_lhs(item)
    local rhs = keymap_rhs(item)
    if rhs == false then
      delete_keymap(keymap_mode(item), lhs, item.opts)
    else
      map(keymap_mode(item), lhs, rhs, keymap_desc(item), item.opts, force)
    end
  end
end

local function picker(kind)
  return function()
    require("blak.providers.picker").pick(kind)
  end
end

local function save_buffer()
  vim.cmd("silent update")
end

local function delete_buffer()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.bufdelete then
    snacks.bufdelete()
  else
    vim.cmd("bdelete")
  end
end

local function open_explorer(config)
  return function()
    require("blak.core.explorer").open(config)
  end
end

local function clear_terminal_keymap(lhs)
  local keymap = vim.fn.maparg(lhs, "n", false, true)
  if type(keymap) == "table" and keymap.desc == "Terminal" then
    pcall(vim.keymap.del, "n", lhs)
    unregister("n", lhs)
  end
end

local function map_terminal(config)
  local lhs = vim.tbl_get(config, "terminal", "toggle_key")
  if lhs == false or lhs == "" then
    if terminal_lhs then
      clear_terminal_keymap(terminal_lhs)
    end
    terminal_lhs = nil
    return
  end

  lhs = lhs or "<leader>tt"
  if terminal_lhs and terminal_lhs ~= lhs then
    clear_terminal_keymap(terminal_lhs)
  end
  terminal_lhs = lhs
  map("n", lhs, "<cmd>BlakTerminal<cr>", "Terminal")
end

local function gitsigns()
  return require("blak.util").load_plugin("gitsigns.nvim", "gitsigns")
end

local function git_action(action, arg)
  return function()
    local gs = gitsigns()
    if gs and gs[action] then
      return gs[action](arg)
    end
  end
end

local function git_range_action(action)
  return function()
    local gs = gitsigns()
    if gs and gs[action] then
      local first = vim.fn.line("v")
      local last = vim.fn.line(".")
      if first > last then
        first, last = last, first
      end
      return gs[action]({ first, last })
    end
  end
end

local function git_nav(direction)
  return function()
    if vim.wo.diff then
      vim.cmd.normal({ direction == "next" and "]c" or "[c", bang = true })
      return
    end
    local gs = gitsigns()
    if gs and gs.nav_hunk then
      return gs.nav_hunk(direction)
    end
  end
end

function M.setup(config)
  clear_owned_keymaps()
  registered = {}
  registered_lookup = {}
  configure_disabled_keymaps(config)

  map("n", "<Esc>", "<cmd>nohlsearch<cr>", "Clear search")

  map("n", "<leader><space>", picker("smart"), "Smart find")
  map("n", "<leader>/", picker("grep"), "Grep")
  map("n", "<leader>ff", picker("files"), "Find files")
  map("n", "<leader>fg", picker("grep"), "Grep")
  map("n", "<leader>fb", picker("buffers"), "Buffers")
  map("n", "<leader>fr", picker("recent"), "Recent files")
  map("n", "<leader>fc", picker("commands"), "Commands")
  map("n", "<leader>fk", picker("keymaps"), "Keymaps")
  map("n", "<leader>fh", picker("help"), "Help")

  map("n", "<leader>bd", delete_buffer, "Delete buffer")
  map("n", "<leader>bn", "<cmd>bnext<cr>", "Next buffer")
  map("n", "<leader>bp", "<cmd>bprevious<cr>", "Previous buffer")
  map_if_available("n", "<leader>`", "<C-^>", "Toggle last file")

  map_if_available("n", "<leader>ws", "<cmd>rightbelow split<cr>", "Split window below")
  map_if_available("n", "<leader>wv", "<cmd>rightbelow vsplit<cr>", "Split window right")

  map("n", "<leader>e", open_explorer(config), require("blak.core.explorer").label(config))

  map_if_available({ "n", "i", "x", "s" }, "<C-s>", save_buffer, "Save")
  map_if_available({ "n", "i", "x", "s" }, "<D-s>", save_buffer, "Save")

  map("n", "]h", git_nav("next"), "Next git hunk")
  map("n", "[h", git_nav("prev"), "Previous git hunk")
  map("n", "<leader>gs", git_action("stage_hunk"), "Stage hunk")
  map("v", "<leader>gs", git_range_action("stage_hunk"), "Stage hunk")
  map("n", "<leader>gr", git_action("reset_hunk"), "Reset hunk")
  map("v", "<leader>gr", git_range_action("reset_hunk"), "Reset hunk")
  map("n", "<leader>gS", git_action("stage_buffer"), "Stage buffer")
  map("n", "<leader>gR", git_action("reset_buffer"), "Reset buffer")
  map("n", "<leader>gp", git_action("preview_hunk"), "Preview hunk")
  map("n", "<leader>gb", git_action("blame_line", { full = true }), "Blame line")
  map("n", "<leader>gd", git_action("diffthis"), "Diff this")

  map("n", "<leader>xx", picker("diagnostics"), "Diagnostics")
  map("n", "<leader>xd", function() vim.diagnostic.open_float() end, "Line diagnostic")
  map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
  map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")

  map("n", "<leader>ll", "<cmd>Lazy<cr>", "Lazy")
  map("n", "<leader>lo", "<cmd>Blak<cr>", "Blak overview")
  map("n", "<leader>lc", "<cmd>BlakConfig<cr>", "Blak config")
  map("n", "<leader>lu", "<cmd>BlakUpdate<cr>", "Update Blak")
  map("n", "<leader>lU", "<cmd>BlakUpgrade<cr>", "Upgrade Blak")
  map("n", "<leader>lr", "<cmd>BlakRollback<cr>", "Rollback update")
  map("n", "<leader>ld", "<cmd>BlakDoctor<cr>", "Doctor")
  map("n", "<leader>le", "<cmd>BlakExtras<cr>", "Extras")
  map("n", "<leader>lk", "<cmd>BlakKeys<cr>", "Blak keymaps")
  map("n", "<leader>ln", "<cmd>BlakNews<cr>", "Blak news")
  map("n", "<leader>ls", "<cmd>BlakSplash<cr>", "Blak splash")
  map("n", "<leader>lt", "<cmd>BlakToolsInstall<cr>", "Install Blak tools")
  map("n", "<leader>lT", "<cmd>BlakTreesitterInstall<cr>", "Install Treesitter parsers")

  map_terminal(config)
  map("n", "<leader>uf", "<cmd>BlakFormatToggle<cr>", "Toggle format on save")
  map("n", "<leader>?", "<cmd>BlakKeys<cr>", "Blak keymaps")

  map("n", "<leader>qq", "<cmd>qa<cr>", "Quit all")

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("BlakLspKeys", { clear = true }),
    callback = function(event)
      local opts = { buffer = event.buf }
      map("n", "gd", vim.lsp.buf.definition, "Go to definition", opts)
      map("n", "gD", vim.lsp.buf.declaration, "Go to declaration", opts)
      map("n", "gI", vim.lsp.buf.implementation, "Go to implementation", opts)
      map("n", "gr", vim.lsp.buf.references, "References", opts)
      map("n", "K", vim.lsp.buf.hover, "Hover", opts)
      map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action", opts)
      map("n", "<leader>cr", vim.lsp.buf.rename, "Rename", opts)
      map("n", "<leader>cs", picker("lsp_symbols"), "Document symbols", opts)
      map("n", "<leader>cS", picker("workspace_symbols"), "Workspace symbols", opts)
      map("n", "<leader>cf", function()
        local conform = require("blak.util").load_plugin("conform.nvim", "conform")
        if conform then
          conform.format({ bufnr = event.buf, lsp_format = config.format.lsp_format })
        end
      end, "Format", opts)
    end,
  })

  M.apply_extra(config._extra_keymaps or {})
  apply_keymaps(config.keymaps, true)
end

function M.apply_extra(keys)
  apply_keymaps(keys, false)
end

function M.show()
  local lines = {
    "# Blak keymaps",
    "",
    "These are the mappings registered by Blak core, enabled extras, and user.lua.",
    "",
  }
  table.sort(registered, function(a, b)
    return a.lhs < b.lhs
  end)
  for _, item in ipairs(registered) do
    local mode = type(item.mode) == "table" and table.concat(item.mode, ",") or item.mode
    table.insert(lines, string.format("%-5s %-18s %s", mode, item.lhs, item.desc))
  end
  require("blak.util").open_scratch("Blak keymaps", lines)
end

return M
