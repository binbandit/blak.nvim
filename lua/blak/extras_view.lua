local M = {}

local ns = vim.api.nvim_create_namespace("blak.extras_view")
local state = {
  buf = nil,
  win = nil,
  rows = {},
  config = nil,
}

local sections = {
  { key = "enabled_plugins", title = "Enabled Plugins" },
  { key = "enabled_languages", title = "Enabled Languages" },
  { key = "plugins", title = "Plugins" },
  { key = "languages", title = "Languages" },
  { key = "stale", title = "Stale State" },
}

local function unique(values)
  local seen = {}
  local out = {}
  for _, value in ipairs(values or {}) do
    if value and value ~= "" and not seen[value] then
      seen[value] = true
      table.insert(out, value)
    end
  end
  table.sort(out)
  return out
end

local function keys(tbl)
  local out = {}
  for key in pairs(tbl or {}) do
    table.insert(out, key)
  end
  table.sort(out)
  return out
end

local function is_language(id)
  return id:match("^lang%.") ~= nil
end

local function plugin_label(spec)
  if type(spec) ~= "string" then
    return nil
  end
  return spec:gsub("%.git$", ""):match("([^/]+)$") or spec
end

local function collect_plugin_names(specs, out)
  for _, spec in ipairs(specs or {}) do
    if type(spec) == "string" then
      table.insert(out, plugin_label(spec))
    elseif type(spec) == "table" then
      if type(spec[1]) == "string" then
        table.insert(out, plugin_label(spec[1]))
      end
    end
  end
end

local function plugin_names(extra, config)
  if not extra or not extra.plugins then
    return {}
  end

  local ok, specs = pcall(function()
    return type(extra.plugins) == "function" and extra.plugins(config) or extra.plugins
  end)
  if not ok then
    return {}
  end

  local out = {}
  collect_plugin_names(specs, out)
  return unique(out)
end

local function formatters(extra)
  local out = {}
  for _, list in pairs(vim.tbl_get(extra, "format", "formatters_by_ft") or {}) do
    for _, formatter in ipairs(list or {}) do
      if type(formatter) == "string" then
        table.insert(out, formatter)
      end
    end
  end
  return unique(out)
end

local function linters(extra)
  local out = {}
  for _, list in pairs(vim.tbl_get(extra, "lint", "linters_by_ft") or {}) do
    for _, linter in ipairs(list or {}) do
      if type(linter) == "string" then
        table.insert(out, linter)
      end
    end
  end
  return unique(out)
end

local function feature_parts(extra, config)
  local parts = {}
  local plugins = plugin_names(extra, config)
  local lsp = keys(vim.tbl_get(extra, "lsp", "servers"))
  local snacks = keys(extra.snacks)
  local fmts = formatters(extra)
  local lint = linters(extra)

  if #plugins > 0 then
    table.insert(parts, "Plugins: " .. table.concat(plugins, ", "))
  end
  if #lsp > 0 then
    table.insert(parts, "LSP: " .. table.concat(lsp, ", "))
  end
  if #fmts > 0 then
    table.insert(parts, "Format: " .. table.concat(fmts, ", "))
  end
  if #lint > 0 then
    table.insert(parts, "Lint: " .. table.concat(lint, ", "))
  end
  if #(extra.mason or {}) > 0 then
    table.insert(parts, "Mason: " .. table.concat(extra.mason, ", "))
  end
  if #(extra.treesitter or {}) > 0 then
    table.insert(parts, "Treesitter: " .. table.concat(extra.treesitter, ", "))
  end
  if #snacks > 0 then
    table.insert(parts, "Snacks: " .. table.concat(snacks, ", "))
  end
  if extra.keys and #extra.keys > 0 then
    table.insert(parts, "Keys: " .. tostring(#extra.keys))
  end

  return parts
end

local function enabled_lookup(config)
  local out = {}
  for _, id in ipairs(require("blak.extras").enabled(config)) do
    out[id] = true
  end
  return out
end

local function state_lookup()
  local out = {}
  for _, id in ipairs(require("blak.extras.state").read()) do
    out[id] = true
  end
  return out
end

local function config_lookup(config)
  local out = {}
  for _, id in ipairs(vim.tbl_get(config, "extras", "enabled") or {}) do
    out[id] = true
  end
  return out
end

local function source_label(entry)
  if not entry.enabled then
    return nil
  end
  if entry.configured and entry.persisted then
    return "config + state"
  end
  if entry.configured then
    return "config"
  end
  if entry.persisted then
    return "state"
  end
  return nil
end

local function build_entries(config)
  local extras = require("blak.extras")
  local enabled = enabled_lookup(config)
  local persisted = state_lookup()
  local configured = config_lookup(config)
  local grouped = {}

  for _, section in ipairs(sections) do
    grouped[section.key] = {}
  end

  for _, extra in ipairs(extras.all()) do
    local entry = {
      id = extra.id,
      extra = extra,
      enabled = enabled[extra.id] == true,
      persisted = persisted[extra.id] == true,
      configured = configured[extra.id] == true,
      known = true,
    }
    local lang = is_language(extra.id)
    if entry.enabled and lang then
      table.insert(grouped.enabled_languages, entry)
    elseif entry.enabled then
      table.insert(grouped.enabled_plugins, entry)
    elseif lang then
      table.insert(grouped.languages, entry)
    else
      table.insert(grouped.plugins, entry)
    end
  end

  for id in pairs(enabled) do
    if not extras.is_known(id) then
      table.insert(grouped.stale, {
        id = id,
        enabled = true,
        persisted = persisted[id] == true,
        configured = configured[id] == true,
        known = false,
      })
    end
  end

  for _, entries in pairs(grouped) do
    table.sort(entries, function(a, b)
      return a.id < b.id
    end)
  end

  return grouped
end

local function add_highlight(highlights, line, group, start_col, end_col)
  table.insert(highlights, { line = line - 1, group = group, start_col = start_col, end_col = end_col })
end

local function render(config)
  local grouped = build_entries(config)
  local lines = {
    "Blak Extras",
    "Enable or disable extras with x. Sync plugin changes with s. Refresh with r. Close with q.",
    "Extras enabled in lua/blak/user.lua are read-only here; remove them there to disable.",
    "",
  }
  local rows = {}
  local highlights = {}

  add_highlight(highlights, 1, "Title", 0, -1)
  add_highlight(highlights, 2, "Comment", 0, -1)
  add_highlight(highlights, 3, "Comment", 0, -1)

  for _, section in ipairs(sections) do
    local entries = grouped[section.key]
    if #entries > 0 then
      local header = string.format("%s (%d)", section.title, #entries)
      table.insert(lines, header)
      add_highlight(highlights, #lines, "Statement", 0, -1)

      for _, entry in ipairs(entries) do
        local status = entry.enabled and "●" or "○"
        local lock = entry.configured and "  [config]" or ""
        local label = entry.known and (entry.extra.label or entry.id) or "Unknown extra"
        local main = string.format("  %s %-26s %s%s", status, entry.id, label, lock)
        table.insert(lines, main)
        rows[#lines] = entry
        add_highlight(highlights, #lines, entry.enabled and "DiagnosticOk" or "Comment", 2, 5)
        add_highlight(highlights, #lines, "Identifier", 6, 6 + #entry.id)
        if entry.configured then
          add_highlight(highlights, #lines, "Comment", #main - #lock, -1)
        end

        local description = entry.known and entry.extra.description or "Unknown extra; press x to remove it from saved state if it came from extras.json."
        table.insert(lines, "    " .. description)
        add_highlight(highlights, #lines, "Comment", 0, -1)

        if entry.known then
          local parts = feature_parts(entry.extra, config)
          if #parts > 0 then
            table.insert(lines, "    " .. table.concat(parts, "  "))
            add_highlight(highlights, #lines, "Special", 0, -1)
          end
        else
          local source = source_label(entry)
          if source then
            table.insert(lines, "    Source: " .. source)
            add_highlight(highlights, #lines, "Special", 0, -1)
          end
        end

        table.insert(lines, "")
      end
    end
  end

  if #lines > 0 and lines[#lines] == "" then
    table.remove(lines)
  end

  return lines, rows, highlights
end

local function dimensions()
  local columns = math.max(vim.o.columns, 80)
  local screen_lines = math.max(vim.o.lines - vim.o.cmdheight, 20)
  local width = math.min(110, math.max(64, math.floor(columns * 0.86)))
  local height = math.min(30, math.max(12, screen_lines - 4))
  width = math.min(width, columns - 4)
  height = math.min(height, screen_lines - 4)

  return {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(1, math.floor((screen_lines - height) / 2)),
    col = math.max(2, math.floor((columns - width) / 2)),
    border = "rounded",
    title = " Blak Extras ",
    title_pos = "center",
    style = "minimal",
  }
end

local function apply_window_options(win)
  vim.wo[win].cursorline = true
  vim.wo[win].foldcolumn = "0"
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].spell = false
  vim.wo[win].wrap = false
end

local function place_cursor(id)
  if not id or not state.win or not vim.api.nvim_win_is_valid(state.win) then
    return
  end

  for line, entry in pairs(state.rows) do
    if entry.id == id then
      pcall(vim.api.nvim_win_set_cursor, state.win, { line, 0 })
      return
    end
  end
end

local function redraw(opts)
  opts = opts or {}
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    return
  end

  local lines, rows, highlights = render(state.config or require("blak.config").get())
  state.rows = rows
  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(state.buf, ns, hl.group, hl.line, hl.start_col, hl.end_col)
  end
  vim.bo[state.buf].modifiable = false
  place_cursor(opts.cursor_id)
end

local function entry_at_cursor()
  if not state.win or not vim.api.nvim_win_is_valid(state.win) then
    return nil
  end

  local line = vim.api.nvim_win_get_cursor(state.win)[1]
  while line > 0 do
    if state.rows[line] then
      return state.rows[line]
    end
    line = line - 1
  end
  return nil
end

local function toggle_current()
  local entry = entry_at_cursor()
  if not entry then
    return
  end

  local ok = require("blak.extras").toggle(entry.id, state.config)
  redraw({ cursor_id = entry.id })
  if ok and entry.known and entry.extra and entry.extra.plugins then
    require("blak.util").notify("Run :BlakExtras sync when you want lazy.nvim to reconcile plugin installs.")
  end
end

local function sync()
  vim.cmd("Lazy sync")
end

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
end

local function set_keymaps(buf)
  local opts = { buffer = buf, silent = true, nowait = true }
  vim.keymap.set("n", "x", toggle_current, vim.tbl_extend("force", opts, { desc = "Toggle Blak extra" }))
  vim.keymap.set("n", "<CR>", toggle_current, vim.tbl_extend("force", opts, { desc = "Toggle Blak extra" }))
  vim.keymap.set("n", "s", sync, vim.tbl_extend("force", opts, { desc = "Sync Blak extras with lazy.nvim" }))
  vim.keymap.set("n", "r", function()
    redraw()
  end, vim.tbl_extend("force", opts, { desc = "Refresh Blak extras" }))
  vim.keymap.set("n", "q", close, vim.tbl_extend("force", opts, { desc = "Close Blak extras" }))
  vim.keymap.set("n", "<Esc>", close, vim.tbl_extend("force", opts, { desc = "Close Blak extras" }))
end

function M.open(config)
  state.config = config or require("blak.config").get()

  if state.win and vim.api.nvim_win_is_valid(state.win) and state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_set_current_win(state.win)
    pcall(vim.api.nvim_win_set_config, state.win, dimensions())
    redraw()
    return state.buf
  end
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].buftype = "nofile"
  vim.bo[state.buf].filetype = "blak-extras"
  vim.bo[state.buf].swapfile = false
  vim.bo[state.buf].modifiable = false
  pcall(vim.api.nvim_buf_set_name, state.buf, string.format("BlakExtras://%d", state.buf))

  state.win = vim.api.nvim_open_win(state.buf, true, dimensions())
  apply_window_options(state.win)
  set_keymaps(state.buf)
  redraw()
  return state.buf
end

return M
