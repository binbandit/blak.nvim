return function(config)
  local stable = config.package.channel == "stable"
  local spec = {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    version = stable and "1.*" or false,
    opts_extend = { "sources.default" },
    opts = {
      keymap = { preset = "default" },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
          window = { border = "rounded" },
        },
        ghost_text = { enabled = true },
        menu = { border = "rounded" },
      },
      signature = {
        enabled = true,
        window = { border = "rounded" },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = {
        implementation = "prefer_rust_with_warning",
      },
    },
  }

  if not stable then
    spec.build = "cargo build --release"
  end

  return { spec }
end
