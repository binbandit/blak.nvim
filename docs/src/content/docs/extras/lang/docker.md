---
title: Docker Extra
description: Configure lang.docker for dockerls, the docker-compose language server, hadolint, and Dockerfile Treesitter.
---

`lang.docker` adds Dockerfile and Docker Compose support, with `hadolint`
linting for Dockerfiles.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.docker",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable lang.docker
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `dockerfile` |
| Mason | `hadolint` |
| LSP | `dockerls`, `docker_compose_language_service` |
| Linting | `hadolint` for `dockerfile` |
| Filetype | registers `yaml.docker-compose` for Compose files |

Language servers install automatically through Mason: `dockerls` maps to
`dockerfile-language-server` and `docker_compose_language_service` to
`docker-compose-language-service`.

## Compose file detection

Stock Neovim does not assign Compose files their own filetype, so this extra
registers `yaml.docker-compose` for `docker-compose.yml`, `docker-compose.yaml`,
`compose.yml`, `compose.yaml`, and dotted variants such as
`compose.override.yaml`. That filetype is what
`docker_compose_language_service` attaches to.

## Install and verify

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a `Dockerfile` and check `:LspInfo` for `dockerls`; save it to see
`hadolint` diagnostics. Open a `docker-compose.yml` and check that
`docker_compose_language_service` attaches.
