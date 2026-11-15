---
title: Terraform Extra
description: Configure lang.terraform for terraform-ls, tflint, terraform fmt, and Terraform/HCL Treesitter.
---

`lang.terraform` adds Terraform and HCL support through terraform-ls, with
`terraform fmt` formatting and tflint diagnostics.

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
| LSP | `terraformls`, `tflint` |
| Formatting | `terraform_fmt` for `terraform`, `terraform-vars` |

Both servers install automatically through Mason (packages `terraform-ls` and
`tflint`). tflint runs as a language server (`tflint --langserver`), so its
diagnostics update as you type. Put tflint rules and plugins in `.tflint.hcl`.

`terraform_fmt` shells out to the `terraform` CLI, which must be on your
`$PATH`. Without it, saving falls back to terraform-ls, which reports
`Terraform (CLI) is required. Please install Terraform or make it available in
$PATH` and leaves the file unformatted. terraform-ls does not serve generic
`.hcl` files (Packer, Nomad), so HCL receives Treesitter highlighting only.

## Configure terraform-ls

terraform-ls reads its options at startup from `init_options`; it ignores
`settings`:

```lua
return {
  extras = { enabled = { "lang.terraform" } },
  lsp = {
    servers = {
      terraformls = {
        init_options = {
          experimentalFeatures = { prefillRequiredFields = true },
          validation = { enableEnhancedValidation = true },
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

Open a `.tf` file and check `:checkhealth vim.lsp` for `terraformls` and
`tflint`. Ensure the `terraform` CLI is installed for format-on-save to work.
