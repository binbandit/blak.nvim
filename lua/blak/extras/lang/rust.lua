-- Build with Cargo and debug the binary it produced, so breakpoints always
-- match the source. A package or workspace with several binaries asks which.
local function cargo_binary()
  local dap = require("dap")
  local util = require("blak.util")
  return coroutine.create(function(dap_run_co)
    -- Scheduled so a reason notified just before shows ahead of "Run aborted".
    local function finish(program)
      vim.schedule(function()
        coroutine.resume(dap_run_co, program or dap.ABORT)
      end)
    end
    local function built(result)
      if result.code ~= 0 then
        -- Each error with its `--> file:line:col` location.
        local errors = vim.tbl_filter(function(line)
          return line:match("^error") or line:match("^%s*%-%->")
        end, vim.split(result.stderr, "\n"))
        util.error("cargo build failed:\n" .. table.concat(errors, "\n"))
        return finish()
      end
      local binaries = {}
      for line in vim.gsplit(result.stdout, "\n", { trimempty = true }) do
        local ok, message = pcall(vim.json.decode, line, { luanil = { object = true } })
        if
          ok
          and message.reason == "compiler-artifact"
          and message.executable
          and vim.tbl_contains(message.target.kind, "bin")
        then
          table.insert(binaries, message.executable)
        end
      end
      if #binaries == 0 then
        util.warn("cargo build produced no binary to debug.")
      end
      if #binaries < 2 then
        return finish(binaries[1])
      end
      -- Cargo reports artifacts in build order, which changes between builds.
      table.sort(binaries)
      vim.ui.select(binaries, {
        prompt = "Debug binary",
        format_item = function(path)
          return vim.fs.basename(path)
        end,
      }, finish)
    end

    util.notify("Building with cargo for debugging...")
    local ok, err = pcall(vim.system, {
      "cargo",
      "build",
      "--message-format=json-render-diagnostics",
    }, { cwd = vim.fs.root(0, "Cargo.toml"), text = true }, vim.schedule_wrap(built))
    if not ok then
      util.error("Could not run cargo: " .. tostring(err))
      finish()
    end
  end)
end

return {
  id = "lang.rust",
  label = "Rust",
  description = "rust_analyzer, crates.nvim, rustfmt fallback, Taplo, Rust/TOML Treesitter",
  treesitter = { "rust", "toml" },
  lsp = {
    servers = {
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            check = { command = "clippy" },
          },
        },
      },
      taplo = {},
    },
  },
  format = {
    formatters_by_ft = {
      rust = { "rustfmt", lsp_format = "fallback" },
      toml = { "taplo", lsp_format = "fallback" },
    },
  },
  plugins = {
    {
      "saecki/crates.nvim",
      event = { "BufRead Cargo.toml", "BufNewFile Cargo.toml" },
      main = "crates",
      -- The in-process language server routes crates.nvim through the LSP
      -- keys (K hover, <leader>ca actions) and blink.cmp's LSP source.
      opts = {
        lsp = {
          enabled = true,
          actions = true,
          completion = true,
          hover = true,
        },
      },
    },
  },
  integrations = {
    ["debug.dap"] = {
      mason = { "codelldb" },
      plugins = {
        {
          "mfussenegger/nvim-dap",
          lazy = true,
          opts = {
            adapters = {
              -- codelldb speaks DAP over stdio when started without --port.
              -- Loading LLDB can outlast nvim-dap's 4 second default.
              codelldb = {
                type = "executable",
                command = "codelldb",
                options = { initialize_timeout_sec = 20 },
              },
            },
            configurations = {
              rust = {
                {
                  type = "codelldb",
                  name = "Debug binary (cargo build)",
                  request = "launch",
                  program = cargo_binary,
                  cwd = "${workspaceFolder}",
                  -- Loads rustc's LLDB formatters, so String, Vec and
                  -- friends show their contents instead of raw fields.
                  sourceLanguages = { "rust" },
                },
              },
            },
          },
        },
      },
    },
  },
}
