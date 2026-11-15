-- Delve's own DAP server, started on a free port for each session. Go finds
-- go.mod from the working directory, so dlv runs in the debugged package's
-- module even when Neovim's cwd is a parent folder or another module.
local function delve(callback, config)
  callback({
    type = "server",
    port = "${port}",
    executable = {
      command = "dlv",
      args = { "dap", "-l", "127.0.0.1:${port}" },
      cwd = config.program and vim.fs.root(config.program, "go.mod"),
    },
    -- The first launch of a large program can take a while to compile.
    options = { initialize_timeout_sec = 20 },
  })
end

local function arguments()
  return require("dap.utils").splitstr(vim.fn.input("Arguments: "))
end

-- `outputMode = "remote"` sends the program's output to the DAP console
-- instead of dlv's own stdout, which nothing shows.
local function launch(name, extra)
  return vim.tbl_extend("force", {
    type = "go",
    name = name,
    request = "launch",
    program = "${fileDirname}",
    outputMode = "remote",
  }, extra or {})
end

return {
  id = "lang.go",
  label = "Go",
  description = "gopls, goimports/gofumpt, golangci-lint, Go Treesitter",
  treesitter = { "go", "gomod", "gosum", "gowork" },
  mason = { "goimports", "gofumpt", "golangci-lint" },
  lsp = {
    servers = {
      gopls = {},
    },
  },
  format = {
    formatters_by_ft = {
      go = { "goimports", "gofumpt" },
    },
  },
  lint = {
    linters_by_ft = {
      go = { "golangcilint" },
    },
  },
  integrations = {
    ["debug.dap"] = {
      mason = { "delve" },
      plugins = {
        {
          "mfussenegger/nvim-dap",
          lazy = true,
          opts = {
            adapters = { go = delve },
            configurations = {
              go = {
                launch("Debug package"),
                launch("Debug package with arguments", { args = arguments }),
                launch("Debug package tests", { mode = "test" }),
              },
            },
          },
        },
      },
    },
    ["test.neotest"] = {
      plugins = {
        {
          "nvim-neotest/neotest",
          lazy = true,
          dependencies = { "fredrikaverpil/neotest-golang" },
          opts = {
            adapters = {
              ["neotest-golang"] = {
                -- Debug tests with the Delve adapter above. The default mode
                -- needs nvim-dap-go and re-runs its setup on every debug
                -- session, which duplicates each Go launch configuration.
                dap_mode = "manual",
                -- A function so neotest-golang gets a fresh table each time;
                -- it appends the test filter to the table it is given.
                dap_manual_config = function()
                  return launch("Debug test", { mode = "test" })
                end,
              },
            },
          },
        },
      },
    },
  },
}
