-- Shell formatting (shfmt) already ships in Blak core, so this extra only adds
-- the bash language server. bashls runs shellcheck itself whenever it is on
-- $PATH and offers its fixes as code actions, so shellcheck is installed for
-- the server rather than registered again as an nvim-lint linter.
return {
  id = "lang.bash",
  label = "Bash",
  description = "bashls language server with shellcheck diagnostics for shell scripts",
  treesitter = { "bash" },
  mason = { "shellcheck" },
  lsp = {
    servers = {
      bashls = {},
    },
  },
}
