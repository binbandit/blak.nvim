local M = {}

local ns = vim.api.nvim_create_namespace("blak.splash")

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

local function set_lines(buf, start, frame, width, indent)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  local lines = normalize_frame(frame, width, indent)
  local old_modifiable = vim.bo[buf].modifiable
  pcall(function()
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, start, start + #lines, false, lines)
    vim.bo[buf].modifiable = old_modifiable
  end)
  return true
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
    set_lines(buf, start, splash.frames[index], width, indent)
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
