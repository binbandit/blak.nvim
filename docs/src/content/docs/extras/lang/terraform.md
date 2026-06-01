---
title: Terraform Extra
description: Configure lang.terraform for terraform-ls, tflint, terraform fmt, and Terraform/HCL Treesitter.
---

`lang.terraform` adds Terraform and HCL support through terraform-ls, with
`terraform fmt` formatting and `tflint` linting.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.terraform",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable lang.terraform
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `terraform`, `hcl` |
| Mason | `tflint` |
| LSP | `terraformls` |
| Formatting | `terraform_fmt` for `terraform`, `terraform-vars` |
| Linting | `tflint` for `terraform` |

`terraformls` installs automatically through Mason (package `terraform-ls`).

`terraform_fmt` shells out to the `terraform` CLI, which must be on your
`$PATH`. terraform-ls does not serve generic `.hcl` files (Packer, Nomad), so
HCL receives Treesitter highlighting only.

## Configure terraform-ls

```lua
return {
  extras = { enabled = { "lang.terraform" } },
  lsp = {
    servers = {
      terraformls = {
        settings = {
          terraform = {
            validation = { enableEnhancedValidation = true },
          },
        },
      },
    },
  },
}
```

## Install and verify

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a `.tf` file and check `:LspInfo` for `terraform-ls`. Ensure the
`terraform` CLI is installed for format-on-save to work.
