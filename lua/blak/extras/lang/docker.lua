-- docker-compose-language-service attaches to the `yaml.docker-compose`
-- filetype, which stock Neovim does not detect, so register it here.
return {
  id = "lang.docker",
  label = "Docker",
  description = "dockerls and docker-compose language servers, hadolint, Dockerfile Treesitter",
  treesitter = { "dockerfile" },
  mason = { "hadolint" },
  lsp = {
    servers = {
      dockerls = {},
      docker_compose_language_service = {},
    },
  },
  lint = {
    linters_by_ft = {
      dockerfile = { "hadolint" },
    },
  },
  apply = function(_)
    vim.filetype.add({
      filename = {
        ["docker-compose.yml"] = "yaml.docker-compose",
        ["docker-compose.yaml"] = "yaml.docker-compose",
        ["compose.yml"] = "yaml.docker-compose",
        ["compose.yaml"] = "yaml.docker-compose",
      },
      pattern = {
        ["[Dd]ocker%-[Cc]ompose%..*%.ya?ml"] = "yaml.docker-compose",
        ["[Cc]ompose%..*%.ya?ml"] = "yaml.docker-compose",
      },
    })
  end,
}
