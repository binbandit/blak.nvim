local M = {}

local ns = vim.api.nvim_create_namespace("blak.splash")
-- Splash color groups by "fg_bg" key. Kept with their colors because
-- `:colorscheme` runs `hi clear`, which wipes the groups while the extmarks
-- still point at their names; define_highlights() brings them back.
---@type table<string, { name: string, fg?: string, bg?: string }>
local highlights = {}
local states = {}

local function data()
  return require("blak.splash.frames.blackhole")
end

local function frame_anchor(lines)
  local best_index, best_anchor, best_column = 1, "", 1
  for index, line in ipairs(lines) do
    local anchor = vim.trim(line)
    if #anchor > #best_anchor then
      best_index, best_anchor, best_column = index, anchor, line:find("%S") or 1
    end
  end
  return best_index, best_anchor, best_column
end

local function pad_line(line, width)
  local padding = width - vim.api.nvim_strwidth(line)
  return padding > 0 and (line .. string.rep(" ", padding)) or line
end

local function center_line(line, width)
  local padding = width - vim.api.nvim_strwidth(line)
  if padding <= 0 then
    return line
  end
  local before = math.floor(padding / 2)
  return string.rep(" ", before) .. line .. string.rep(" ", padding - before)
end

local function normalize_frame(frame, width, indent)
  local prefix = string.rep(" ", indent or 0)
  return vim.tbl_map(function(line)
    return prefix .. pad_line(line, width)
  end, frame)
end

local function get_hl(fg, bg)
  fg = fg ~= "NONE" and fg or nil
  bg = bg ~= "NONE" and bg or nil
  if not fg and not bg then
    return nil
  end

  local key = (fg or "none") .. "_" .. (bg or "none")
  local hl = highlights[key]
  if not hl then
    hl = { name = "BlakSplash_" .. key:gsub("[^%w]", "_"), fg = fg, bg = bg }
    highlights[key] = hl
    vim.api.nvim_set_hl(0, hl.name, { fg = fg, bg = bg })
  end
  return hl.name
end

local function define_highlights()
  for _, hl in pairs(highlights) do
    vim.api.nvim_set_hl(0, hl.name, { fg = hl.fg, bg = hl.bg })
  end
end

local function paint_colors(buf, start, line_count, colors, indent)
  vim.api.nvim_buf_clear_namespace(buf, ns, start, start + line_count)
  if not colors then
    return
  end

  local col_offset = indent or 0
  for row_index, row_runs in ipairs(colors) do
    if row_index <= line_count then
      local row = start + row_index - 1
      for _, run in ipairs(row_runs) do
        local hl = get_hl(run[3], run[4])
        if hl then
          pcall(vim.api.nvim_buf_set_extmark, buf, ns, row, col_offset + run[1], {
            end_col = col_offset + run[2],
            hl_group = hl,
            -- Outrank Snacks's own dashboard header highlight, which sits in the
            -- low hundreds, so the milli palette wins on every cell.
            priority = 1000,
          })
        end
      end
    end
  end
end

local function set_lines(buf, start, frame, width, indent, colors)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  local lines = normalize_frame(frame, width, indent)
  local old_modifiable = vim.bo[buf].modifiable
  local ok = pcall(function()
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, start, start + #lines, false, lines)
    paint_colors(buf, start, #lines, colors, indent)
  end)
  pcall(function()
    vim.bo[buf].modifiable = old_modifiable
  end)
  return ok
end

local function find_region(buf, frame)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local anchor_index, anchor, anchor_column = frame_anchor(frame)
  if anchor == "" then
    return nil
  end
  for index, line in ipairs(lines) do
    local match_column = line:find(anchor, 1, true)
    if match_column and vim.trim(line) == anchor then
      return index - anchor_index, math.max(0, match_column - anchor_column)
    end
  end
  return nil
end

local function stop_state(buf)
  local state = states[buf]
  if state and state.timer and not state.timer:is_closing() then
    state.timer:stop()
    state.timer:close()
  end
  if state and state.autocmd then
    pcall(vim.api.nvim_del_autocmd, state.autocmd)
  end
  states[buf] = nil
  if vim.api.nvim_buf_is_valid(buf) then
    vim.b[buf].blak_splash_playing = false
  end
end

function M.header()
  local splash = data()
  local width = splash.cols or 0
  local header = normalize_frame(splash.frames[1], width)
  vim.list_extend(header, {
    center_line("BLAK", width),
    center_line("where bloat goes to die", width),
    pad_line("", width),
  })
  return header
end

function M.play(buf, opts)
  opts = opts or {}
  local splash = data()
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local width = splash.cols or 0
  local start, indent = find_region(buf, normalize_frame(splash.frames[1], width))
  if not start then
    return
  end

  local existing = states[buf]
  if existing then
    existing.start = start
    existing.indent = indent
    existing.loop = opts.loop
    existing.paused = false

    if opts.animate == false then
      stop_state(buf)
      set_lines(buf, start, splash.frames[1], width, indent, splash.colors and splash.colors[1])
      return
    end

    local frame_index = existing.frame_index or 1
    if
      not set_lines(
        buf,
        start,
        splash.frames[frame_index],
        width,
        indent,
        splash.colors and splash.colors[frame_index]
      )
    then
      stop_state(buf)
    end
    return
  end

  vim.b[buf].blak_splash_playing = true
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  -- Paint frame 1 with its color spans synchronously so the splash is never
  -- visible as uncolored braille, even before the first timer tick fires or
  -- when animation is disabled entirely.
  set_lines(buf, start, splash.frames[1], width, indent, splash.colors and splash.colors[1])

  if opts.animate == false then
    vim.b[buf].blak_splash_playing = false
    return
  end

  local uv = vim.uv
  local timer = uv.new_timer()
  local state = {
    frame_index = 1,
    indent = indent,
    index = 2,
    loop = opts.loop,
    paused = false,
    start = start,
    timer = timer,
  }
  states[buf] = state

  local function stop()
    stop_state(buf)
  end

  state.autocmd = vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
    buffer = buf,
    once = true,
    callback = stop,
  })

  timer:start(
    splash.delays[1] or 40,
    splash.delays[1] or 40,
    vim.schedule_wrap(function()
      state = states[buf]
      if not state or not vim.api.nvim_buf_is_valid(buf) then
        stop()
        return
      end
      if state.paused then
        return
      end
      local ok = set_lines(
        buf,
        state.start,
        splash.frames[state.index],
        width,
        state.indent,
        splash.colors and splash.colors[state.index]
      )
      if not ok then
        stop()
        return
      end
      state.frame_index = state.index
      state.index = state.index + 1
      if state.index > #splash.frames then
        if state.loop == false then
          stop()
          return
        end
        state.index = 1
      end
    end)
  )
end

-- The `~` filler rows under the splash are noise. The local value lives with
-- the dashboard buffer, so the window gets its own fillchars back as soon as
-- it shows another buffer.
local function hide_end_of_buffer(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_win_call(win, function()
      vim.opt_local.fillchars:append({ eob = " " })
    end)
  end
end

-- Snacks drops the statusline (laststatus=0) for the startup dashboard, which
-- moves the native ruler into the command line. 'ruler' is global, so hide it
-- while the dashboard is focused, keep it hidden for floats opened over it
-- (pickers, :BlakSplash), and restore it when a regular window takes focus.
local saved_ruler
local function sync_ruler()
  if vim.bo.filetype == "snacks_dashboard" then
    if saved_ruler == nil then
      saved_ruler, vim.o.ruler = vim.o.ruler, false
    end
  elseif saved_ruler ~= nil and vim.api.nvim_win_get_config(0).relative == "" then
    vim.o.ruler, saved_ruler = saved_ruler, nil
  end
end

function M.attach_to_snacks(config)
  if not config.ui.splash.enabled then
    return
  end

  local animate = config.ui.splash.animate ~= false
  local loop = animate and config.ui.splash.loop ~= false

  local group = vim.api.nvim_create_augroup("BlakSplash", { clear = true })

  local function start(buf)
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    if vim.bo[buf].filetype ~= "snacks_dashboard" then
      return
    end
    hide_end_of_buffer(buf)
    M.play(buf, { loop = loop, animate = animate })
  end

  -- Snacks fires these once the dashboard buffer is fully rendered, so the
  -- anchor search reliably finds frame 1 and the post-update event lets us
  -- re-paint after resizes/refreshes that would otherwise clear our marks.
  local function start_all()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      start(buf)
    end
    sync_ruler()
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = group,
    callback = sync_ruler,
  })

  local function pause_all()
    for buf, state in pairs(states) do
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "snacks_dashboard" then
        state.paused = true
      end
    end
  end

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "SnacksDashboardUpdatePre",
    callback = pause_all,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = { "SnacksDashboardOpened", "SnacksDashboardUpdatePost" },
    callback = start_all,
  })

  -- Fallback for the cold-start case where the dashboard buffer already
  -- exists by the time this autocmd group is created.
  vim.schedule(start_all)
end

function M.setup(_)
  -- Dashboard autocmds are attached after snacks.nvim setup (attach_to_snacks),
  -- because the dashboard buffer belongs to Snacks.
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("BlakSplashColors", { clear = true }),
    desc = "Restore Blak splash colors after :colorscheme",
    callback = define_highlights,
  })
end

-- A centered float sized to the art, so the preview never disturbs the layout.
function M.preview()
  local splash = data()
  local frame = splash.frames[1]
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "blak-splash"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, frame)
  vim.bo[buf].modifiable = false

  -- The float takes its border from 'winborder'; count it when centering.
  local border = (vim.o.winborder ~= "" and vim.o.winborder ~= "none") and 2 or 0
  local columns, lines = vim.o.columns, vim.o.lines - vim.o.cmdheight
  local width = math.max(1, math.min(splash.cols, columns - border))
  local height = math.max(1, math.min(#frame, lines - border))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    width = width,
    height = height,
    row = math.max(0, math.floor((lines - height - border) / 2)),
    col = math.max(0, math.floor((columns - width - border) / 2)),
  })
  vim.wo[win].wrap = false

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  for _, lhs in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set(
      "n",
      lhs,
      close,
      { buffer = buf, nowait = true, silent = true, desc = "Close splash preview" }
    )
  end
  -- Close once focus moves away so a looping preview never lingers unfocused.
  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = buf,
    once = true,
    callback = function()
      vim.schedule(close)
    end,
  })

  M.play(buf, { loop = true })
end

return M
