local M = {}

local pickers = {
  "smart",
  "files",
  "grep",
  "buffers",
  "recent",
  "commands",
  "keymaps",
  "help",
  "diagnostics",
  "lsp_symbols",
  "workspace_symbols",
}

local function complete_picker()
  return pickers
end

local function extras_command(opts)
  require("blak.extras").command(opts)
end

local function complete_extras(arglead, line)
  return require("blak.extras").complete(arglead, line)
end

local function user_config_path()
  local util = require("blak.util")
  return util.join(vim.fn.stdpath("config"), "lua", "blak", "user.lua")
end

local function create_user_config(path)
  local util = require("blak.util")
  for _, example in ipairs(vim.api.nvim_get_runtime_file("lua/blak/user.example.lua", false)) do
    if util.copy_file(example, path) then
      return true
    end
  end

  util.write_file(path, "return {}\n")
  return true
end

local function refresh_file_indexes()
  local fff = package.loaded.fff
  if fff and type(fff.scan_files) == "function" then
    pcall(fff.scan_files)
  end
end

local function open_user_config()
  local path = user_config_path()
  local created = false
  if vim.fn.filereadable(path) == 0 then
    created = create_user_config(path)
  end

  vim.cmd.edit(vim.fn.fnameescape(path))
  refresh_file_indexes()
  if created then
    require("blak.util").notify("Created lua/blak/user.lua")
  end
end

function M.setup(config)
  vim.api.nvim_create_user_command("Blak", function()
    require("blak.util").open_scratch("Blak", {
      "BLAK",
      "",
      "Everything useful. Nothing escapes.",
      "",
      "Commands:",
      "  :Blak                      overview",
      "  :BlakDoctor                health checks",
      "  :BlakKeys                  show keymaps",
      "  :BlakNews                  release notes",
      "  :BlakConfig                edit lua/blak/user.lua",
      "  :BlakPick {kind}           picker entrypoint",
      "  :BlakExtras                extras UI",
      "  :BlackExtras               alias for :BlakExtras",
      "  :BlakUpdate                update plugins with lockfile backup",
      "  :BlakUpgrade               intentional bigger moves",
      "  :BlakRollback              restore last lockfile backup",
      "  :BlakToolsInstall          install Mason tools",
      "  :BlakTreesitterInstall     install configured parsers",
      "  :BlakTerminal [cmd]        toggle a native terminal split",
      "  :BlakFormat                format current buffer",
      "  :BlakFormatToggle[!]       toggle format-on-save",
      "  :BlakSplash                preview the splash animation",
    })
  end, { desc = "Open Blak overview" })

  vim.api.nvim_create_user_command("BlakDoctor", function()
    vim.cmd("checkhealth blak")
  end, { desc = "Run Blak health checks" })

  vim.api.nvim_create_user_command("BlakKeys", function()
    require("blak.core.keymaps").show()
  end, { desc = "Show Blak keymaps" })

  vim.api.nvim_create_user_command("BlakPick", function(opts)
    require("blak.providers.picker").pick(opts.args ~= "" and opts.args or "smart")
  end, { nargs = "?", complete = complete_picker, desc = "Run a Blak picker" })

  vim.api.nvim_create_user_command("BlakExtras", extras_command, {
    nargs = "*",
    complete = complete_extras,
    desc = "Manage Blak extras",
  })

  vim.api.nvim_create_user_command("BlackExtras", extras_command, {
    nargs = "*",
    complete = complete_extras,
    desc = "Alias for :BlakExtras",
  })

  vim.api.nvim_create_user_command("BlakUpdate", function()
    require("blak.core.update").update()
  end, { desc = "Update plugins after creating a rollback point" })

  vim.api.nvim_create_user_command("BlakUpgrade", function()
    require("blak.core.update").upgrade()
  end, { desc = "Run an explicit upgrade" })

  vim.api.nvim_create_user_command("BlakRollback", function()
    require("blak.core.update").rollback()
  end, { desc = "Restore latest lockfile backup and run Lazy restore" })

  vim.api.nvim_create_user_command("BlakNews", function()
    require("blak.core.update").news()
  end, { desc = "Open Blak release notes" })

  vim.api.nvim_create_user_command("BlakConfig", open_user_config, { desc = "Edit lua/blak/user.lua" })

  vim.api.nvim_create_user_command("BlakToolsInstall", function()
    require("blak.core.tools").ensure(config, { force = true })
  end, { desc = "Install Mason tools required by enabled extras" })

  vim.api.nvim_create_user_command("BlakTreesitterInstall", function()
    require("blak.core.treesitter").install(config, { notify = true })
  end, { desc = "Install configured Treesitter parsers" })

  vim.api.nvim_create_user_command("BlakTerminal", function(opts)
    require("blak.core.terminal").toggle({ cmd = opts.args ~= "" and opts.args or nil })
  end, { nargs = "*", desc = "Toggle a native terminal split" })

  vim.api.nvim_create_user_command("BlakFormat", function()
    local conform = require("blak.util").load_plugin("conform.nvim", "conform")
    if conform then
      conform.format({ lsp_format = config.format.lsp_format })
    end
  end, { desc = "Format current buffer" })

  vim.api.nvim_create_user_command("BlakFormatToggle", function(opts)
    local bang = opts.bang
    if bang then
      vim.g.blak_disable_autoformat = not vim.g.blak_disable_autoformat
      require("blak.util").notify("Global autoformat " .. (vim.g.blak_disable_autoformat and "disabled" or "enabled"))
    else
      vim.b.blak_disable_autoformat = not vim.b.blak_disable_autoformat
      require("blak.util").notify("Buffer autoformat " .. (vim.b.blak_disable_autoformat and "disabled" or "enabled"))
    end
  end, { bang = true, desc = "Toggle format-on-save. Use ! for global." })

  vim.api.nvim_create_user_command("BlakSplash", function()
    require("blak.splash").preview()
  end, { desc = "Preview the Blak splash animation" })
end

return M
