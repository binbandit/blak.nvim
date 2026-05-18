local M = {}

local BLINK_DESC_PREFIX = "blink.cmp: "

local function blink_loaded()
  return package.loaded["blink.cmp"]
    and package.loaded["blink.cmp.config"]
    and package.loaded["blink.cmp.keymap"]
    and package.loaded["blink.cmp.keymap.apply"]
end

local function desired_mappings(config)
  local spec = require("blak.plugins.completion")(config)[1]
  local keymap_config = vim.deepcopy(vim.tbl_get(spec, "opts", "keymap") or {})
  return require("blink.cmp.keymap").get_mappings(keymap_config, "default")
end

local function delete_blink_keymaps(bufnr)
  for _, mode in ipairs({ "i", "s" }) do
    for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(bufnr, mode)) do
      if mapping.desc and vim.startswith(mapping.desc, BLINK_DESC_PREFIX) then
        pcall(vim.api.nvim_buf_del_keymap, bufnr, mode, mapping.lhs)
      end
    end
  end
end

local function blink_enabled()
  local ok, config = pcall(require, "blink.cmp.config")
  if not ok or type(config.enabled) ~= "function" then
    return false
  end
  return config.enabled()
end

local function apply_to_buffer(bufnr, mappings)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end

  vim.api.nvim_buf_call(bufnr, function()
    if not blink_enabled() then
      return
    end
    delete_blink_keymaps(bufnr)
    require("blink.cmp.keymap.apply").keymap_to_current_buffer(mappings)
  end)
end

local function watch_insert_enter(mappings)
  local group = vim.api.nvim_create_augroup("BlakBlinkCompletionKeymaps", { clear = true })
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
      apply_to_buffer(vim.api.nvim_get_current_buf(), mappings)
    end,
  })
end

function M.refresh(config)
  if not blink_loaded() then
    return
  end

  local ok, mappings = pcall(desired_mappings, config)
  if not ok then
    require("blak.util").warn("Could not refresh blink.cmp keymaps: " .. tostring(mappings))
    return
  end

  watch_insert_enter(mappings)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    apply_to_buffer(bufnr, mappings)
  end
end

return M
