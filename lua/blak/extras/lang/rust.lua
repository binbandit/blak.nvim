return {
  id = "lang.rust",
  label = "Rust",
  description = "rust_analyzer, crates.nvim, rustfmt fallback, Taplo, Rust/TOML Treesitter",
  treesitter = { "rust", "toml" },
  mason = { "codelldb" },
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
      opts = {},
    },
  },
}
