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

function M.setup(config)
  vim.api.nvim_create_user_command("Blak", function()
    require("blak.util").open_scratch("Blak", {
      "BLAK",
      "",
      "Everything useful. Nothing escapes.",
      "",
      "Commands:",
      "  :BlakDoctor        health checks",
      "  :BlakExtras        list/enable/disable extras",
      "  :BlakKeys          show keymaps",
      "  :BlakPick files    picker entrypoint",
      "  :BlakUpdate        update plugins with lockfile backup",
      "  :BlakRollback      restore last lockfile backup",
      "  :BlakTreesitterInstall install configured parsers",
      "  :BlakTerminal      toggle a native terminal split",
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

  vim.api.nvim_create_user_command("BlakExtras", function(opts)
    require("blak.extras").command(opts)
  end, { nargs = "*", complete = function(_, line)
    return require("blak.extras").complete(line)
  end, desc = "Manage Blak extras" })

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
