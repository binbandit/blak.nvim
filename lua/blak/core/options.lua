local M = {}

local function set_if_exists(name, value)
  pcall(function()
    vim.opt[name] = value
  end)
end

function M.setup(config)
  vim.opt.termguicolors = true
  vim.opt.number = true
  vim.opt.relativenumber = config.editor.relative_number
  vim.opt.cursorline = true
  vim.opt.signcolumn = "yes"
  vim.opt.splitbelow = true
  vim.opt.splitright = true
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  vim.opt.undofile = true
  vim.opt.updatetime = 250
  vim.opt.timeoutlen = 400
  vim.opt.scrolloff = config.editor.scrolloff
  vim.opt.sidescrolloff = config.editor.sidescrolloff
  vim.opt.tabstop = config.editor.tabstop
  vim.opt.shiftwidth = config.editor.shiftwidth
  vim.opt.softtabstop = config.editor.shiftwidth
  vim.opt.expandtab = config.editor.expandtab
  vim.opt.completeopt = { "menu", "menuone", "noselect" }
  vim.opt.pumheight = 12
  vim.opt.wrap = false
  vim.opt.linebreak = true
  vim.opt.breakindent = true
  vim.opt.inccommand = "split"
  vim.opt.grepprg = "rg --vimgrep --smart-case --hidden"
  vim.opt.grepformat = "%f:%l:%c:%m"

  if config.editor.clipboard then
    vim.opt.clipboard = "unnamedplus"
  end

  set_if_exists("winborder", config.ui.winborder)
  set_if_exists("smoothscroll", true)
  set_if_exists("jumpoptions", "view")

  if config.ui.colorscheme then
    pcall(vim.cmd.colorscheme, config.ui.colorscheme)
  end
end

return M
