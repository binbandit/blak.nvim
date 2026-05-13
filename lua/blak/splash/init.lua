local M = {}

local ns = vim.api.nvim_create_namespace("blak.splash")

local function data()
  return require("blak.splash.frames.blackhole")
end

local function first_nonblank(lines)
  for index, line in ipairs(lines) do
    if line:find("%S") then
      return index, vim.trim(line)
    end
  end
  return 1, lines[1] or ""
end

local function set_lines(buf, start, frame)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  local old_modifiable = vim.bo[buf].modifiable
  pcall(function()
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, start, start + #frame, false, frame)
    vim.bo[buf].modifiable = old_modifiable
  end)
  return true
end

local function find_region(buf, frame)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local anchor_index, anchor = first_nonblank(frame)
  if anchor == "" then
    return nil
  end
  for index, line in ipairs(lines) do
    if vim.trim(line) == anchor then
      return index - anchor_index
    end
  end
  return nil
end

function M.header()
  local splash = data()
  local header = vim.deepcopy(splash.frames[1])
  vim.list_extend(header, {
    "",
    "                         BLAK",
    "              where bloat goes to die",
  })
  return header
end

function M.play(buf, opts)
  opts = opts or {}
  local splash = data()
  if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].blak_splash_playing then
    return
  end

  local start = find_region(buf, splash.frames[1])
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
    set_lines(buf, start, splash.frames[index])
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
