local function dap(action)
  return function()
    local module = require("blak.util").load_plugin("nvim-dap", "dap")
    if module and module[action] then
      return module[action]()
    end
  end
end

local function dapui_toggle()
  local module = require("blak.util").load_plugin("nvim-dap-ui", "dapui")
  if module then
    module.toggle()
  end
end

local function dap_repl_toggle()
  local module = require("blak.util").load_plugin("nvim-dap", "dap")
  if module and module.repl then
    module.repl.toggle()
  end
end

return {
  id = "debug.dap",
  label = "DAP",
  description = "nvim-dap plus dap-ui for opt-in debugging workflows",
  plugins = {
    {
      "mfussenegger/nvim-dap",
      lazy = true,
    },
    {
      "rcarriga/nvim-dap-ui",
      lazy = true,
      main = "dapui",
      dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio",
      },
      opts = {},
    },
  },
  keys = {
    { lhs = "<leader>db", rhs = dap("toggle_breakpoint"), desc = "Debug breakpoint" },
    { lhs = "<leader>dc", rhs = dap("continue"), desc = "Debug continue" },
    { lhs = "<leader>di", rhs = dap("step_into"), desc = "Debug step into" },
    { lhs = "<leader>do", rhs = dap("step_over"), desc = "Debug step over" },
    { lhs = "<leader>dO", rhs = dap("step_out"), desc = "Debug step out" },
    { lhs = "<leader>dr", rhs = dap_repl_toggle, desc = "Debug REPL" },
    { lhs = "<leader>dt", rhs = dap("terminate"), desc = "Debug terminate" },
    { lhs = "<leader>du", rhs = dapui_toggle, desc = "Debug UI" },
  },
}
