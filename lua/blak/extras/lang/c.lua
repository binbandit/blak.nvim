return {
  id = "lang.c",
  label = "C/C++",
  description = "clangd, clang-format, C/C++ Treesitter",
  treesitter = { "c", "cpp" },
  mason = { "clang-format" },
  lsp = {
    servers = {
      clangd = {},
    },
  },
  format = {
    formatters_by_ft = {
      c = { "clang_format" },
      cpp = { "clang_format" },
      objc = { "clang_format" },
      objcpp = { "clang_format" },
      cuda = { "clang_format" },
    },
  },
}
