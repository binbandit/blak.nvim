-- `terraform_fmt` shells out to the `terraform` CLI, which must be on $PATH.
-- terraform-ls does not serve generic .hcl files, so HCL gets Treesitter only.
-- tflint runs as a language server (`tflint --langserver`) rather than through
-- nvim-lint, whose tflint parser places every diagnostic one line too low.
return {
  id = "lang.terraform",
  label = "Terraform",
  description = "terraform-ls, tflint, terraform fmt, Terraform/HCL Treesitter",
  treesitter = { "terraform", "hcl" },
  lsp = {
    servers = {
      terraformls = {},
      tflint = {},
    },
  },
  format = {
    formatters_by_ft = {
      terraform = { "terraform_fmt" },
      ["terraform-vars"] = { "terraform_fmt" },
    },
  },
}
