return {
  id = "lang.lua",
  label = "Lua",
  description = "lua_ls, stylua, and Lua Treesitter",
  treesitter = { "lua", "luadoc" },
  mason = { "stylua" },
  lsp = {
    servers = {
      lua_ls = {},
    },
  },
  format = {
    formatters_by_ft = {
      lua = { "stylua" },
    },
  },
}
