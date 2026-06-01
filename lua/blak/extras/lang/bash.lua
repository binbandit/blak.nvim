-- Shell formatting (shfmt) already ships in Blak core, so this extra only adds
-- the bash language server and shellcheck linting on top of it.
return {
  id = "lang.bash",
  label = "Bash",
  description = "bashls language server and shellcheck linting for shell scripts",
  treesitter = { "bash" },
  mason = { "shellcheck" },
  lsp = {
    servers = {
      bashls = {},
    },
  },
  lint = {
    linters_by_ft = {
      sh = { "shellcheck" },
      bash = { "shellcheck" },
    },
  },
}
