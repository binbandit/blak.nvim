local M = {}

local registered = {}
local registered_lookup = {}

-- Built-in commands do not appear in maparg(), so optional keys need a small
-- reserved list when Blak would otherwise shadow native editing behavior.
local nvim_builtin_keys = {
  n = {
    ["-"] = true,
  },
}

local function mode_list(mode)
  return type(mode) == "table" and mode or { mode }
end

local function has_keymap(mode, lhs)
  local keymap = vim.fn.maparg(lhs, mode, false, true)
  return type(keymap) == "table" and next(keymap) ~= nil
end

local function is_nvim_builtin_key(mode, lhs)
  return nvim_builtin_keys[mode] and nvim_builtin_keys[mode][lhs]
end

local function map(mode, lhs, rhs, desc, opts)
  opts = vim.tbl_extend("force", { silent = true, desc = desc }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)

  local mode_label = type(mode) == "table" and table.concat(mode, ",") or mode
  local key = mode_label .. "|" .. lhs .. "|" .. (desc or "")
  if not registered_lookup[key] then
    registered_lookup[key] = true
    table.insert(registered, { mode = mode, lhs = lhs, desc = desc or "" })
  end
end

local function map_if_available(mode, lhs, rhs, desc, opts)
  for _, item in ipairs(mode_list(mode)) do
    if not has_keymap(item, lhs) and not is_nvim_builtin_key(item, lhs) then
      map(item, lhs, rhs, desc, opts)
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
  registered = {}
  registered_lookup = {}

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
  map("n", "<leader>lu", "<cmd>BlakUpdate<cr>", "Update Blak")
  map("n", "<leader>lr", "<cmd>BlakRollback<cr>", "Rollback update")
  map("n", "<leader>ld", "<cmd>BlakDoctor<cr>", "Doctor")
  map("n", "<leader>le", "<cmd>BlakExtras<cr>", "Extras")

  map("n", "<leader>tt", "<cmd>BlakTerminal<cr>", "Terminal")
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
end

function M.apply_extra(keys)
  for _, item in ipairs(keys or {}) do
    map(item.mode or "n", item.lhs, item.rhs, item.desc, item.opts)
  end
end

function M.show()
  local lines = { "# Blak keymaps", "", "These are the mappings registered by Blak core and enabled extras.", "" }
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
