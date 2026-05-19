return {
  id = "editor.render-markdown",
  label = "Render Markdown",
  description = "In-buffer Markdown rendering for headings, lists, code, and links",
  treesitter = { "markdown", "markdown_inline" },
  plugins = {
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown" },
      cmd = {
        "RenderMarkdown",
        "RenderMarkdownEnable",
        "RenderMarkdownDisable",
        "RenderMarkdownToggle",
      },
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-mini/mini.icons",
      },
      opts = {},
    },
  },
  keys = {
    { lhs = "<leader>um", rhs = "<cmd>RenderMarkdownToggle<cr>", desc = "Render Markdown" },
  },
}
