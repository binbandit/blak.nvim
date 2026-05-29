return {
  version = "0.2.2",
  leader = " ",
  localleader = "\\",

  package = {
    backend = "lazy",
    channel = "stable", -- stable | edge | nightly
    check_updates = false,
  },

  ui = {
    colorscheme = "tokyonight-night",
    transparent = false,
    icons = true,
    notify = true,
    winborder = "rounded",
    splash = {
      enabled = true,
      animate = true,
      loop = true,
    },
  },

  editor = {
    clipboard = true,
    confirm = true,
    relative_number = true,
    scrolloff = 8,
    sidescrolloff = 8,
    tabstop = 2,
    shiftwidth = 2,
    expandtab = true,
  },

  completion = {
    super_tab = false,
  },

  performance = {
    bigfile_size = 1.5 * 1024 * 1024,
    max_treesitter_lines = 10000,
  },

  picker = {
    provider = "fff", -- fff | snacks | telescope | fzf_lua
  },

  explorer = {
    provider = "oil", -- oil | snacks
  },

  terminal = {
    provider = "native", -- native | snacks
    toggle_key = "<leader>tt",
  },

  keymaps = {},

  plugins = {
    specs = {},
  },

  hooks = {
    before = {},
    after = {},
  },

  ai = {
    claudecode = {},
    sidekick = {
      nes = { enabled = false },
    },
    supermaven = {},
  },

  mini = {
    modules = {},
    opts = {},
  },

  snacks = {},

  treesitter = {
    ensure_installed = {
      "bash",
      "c",
      "diff",
      "html",
      "json",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "query",
      "regex",
      "toml",
      "vim",
      "vimdoc",
      "yaml",
    },
  },

  lsp = {
    automatic_enable = true,
    servers = {
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      },
    },
    diagnostics = {
      virtual_text = { spacing = 2, source = "if_many" },
      virtual_lines = false,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { border = "rounded", source = "if_many" },
    },
  },

  mason = {
    automatic_install = true,
    ensure_installed = {
      "stylua",
      "shfmt",
      "tree-sitter-cli",
    },
  },

  format = {
    enabled = true,
    timeout_ms = 1000,
    lsp_format = "fallback",
    formatters_by_ft = {
      lua = { "stylua" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },
    },
  },

  lint = {
    events = { "BufWritePost", "BufReadPost", "InsertLeave" },
    linters_by_ft = {},
  },

  extras = {
    enabled = {},
  },
}
