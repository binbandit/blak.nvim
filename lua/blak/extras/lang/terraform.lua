-- `terraform_fmt` shells out to the `terraform` CLI, which must be on $PATH.
-- terraform-ls does not serve generic .hcl files, so HCL gets Treesitter only.
return {
  id = "lang.terraform",
  label = "Terraform",
  description = "terraform-ls, tflint, terraform fmt, Terraform/HCL Treesitter",
  treesitter = { "terraform", "hcl" },
  mason = { "tflint" },
  lsp = {
    servers = {
      terraformls = {},
    },
  },
  format = {
    formatters_by_ft = {
      terraform = { "terraform_fmt" },
      ["terraform-vars"] = { "terraform_fmt" },
    },
  },
  lint = {
    linters_by_ft = {
      terraform = { "tflint" },
    },
  },
}
