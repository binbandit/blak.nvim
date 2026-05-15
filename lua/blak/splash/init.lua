local M = {}

local ns = vim.api.nvim_create_namespace("blak.splash")
local highlights = {}

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
  if not highlights[key] then
    local name = "BlakSplash_" .. key:gsub("[^%w]", "_")
    vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg })
    highlights[key] = name
  end
  return highlights[key]
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
            priority = 200,
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

function M.header()
  local splash = data()
  local width = splash.cols or 0
  local header = normalize_frame(splash.frames[1], width)
  vim.list_extend(header, {
    pad_line("", width),
    center_line("BLAK", width),
    center_line("where bloat goes to die", width),
  })
  return header
end

function M.play(buf, opts)
  opts = opts or {}
  local splash = data()
  if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].blak_splash_playing then
    return
  end

  local width = splash.cols or 0
  local start, indent = find_region(buf, normalize_frame(splash.frames[1], width))
  if not start then
    return
  end

  vim.b[buf].blak_splash_playing = true
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  local uv = vim.uv or vim.loop
  local timer = uv.new_timer()
  local index = 1

  local function stop()
    if timer and not timer:is_closing() then
      timer:stop()
      timer:close()
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.b[buf].blak_splash_playing = false
    end
  end

  vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
    buffer = buf,
    once = true,
    callback = stop,
  })

  timer:start(0, splash.delays[1] or 40, vim.schedule_wrap(function()
    if not vim.api.nvim_buf_is_valid(buf) then
      stop()
      return
    end
    set_lines(buf, start, splash.frames[index], width, indent, splash.colors and splash.colors[index])
    index = index + 1
    if index > #splash.frames then
      if opts.loop == false then
        stop()
        return
      end
      index = 1
    end
  end))
end

function M.attach_to_snacks(config)
  if not (config.ui.splash.enabled and config.ui.splash.animate) then
    return
  end

  local group = vim.api.nvim_create_augroup("BlakSplash", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "snacks_dashboard", "dashboard" },
    callback = function(event)
      vim.defer_fn(function()
        M.play(event.buf, { loop = config.ui.splash.loop })
      end, 80)
    end,
  })

  vim.defer_fn(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "snacks_dashboard" then
        M.play(buf, { loop = config.ui.splash.loop })
      end
    end
  end, 250)
end

function M.setup(_)
  -- Autocmds are attached after snacks.nvim setup, because the dashboard buffer belongs to Snacks.
end

function M.preview()
  local splash = data()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "blak-splash"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, splash.frames[1])
  vim.cmd("botright split")
  vim.api.nvim_win_set_buf(0, buf)
  M.play(buf, { loop = true })
end

return M
