return {
  id = "editor.render-markdown",
  label = "Render Markdown",
  description = "In-buffer Markdown rendering for headings, lists, code, and links",
  treesitter = { "markdown", "markdown_inline" },
  plugins = {
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown" },
      cmd = "RenderMarkdown",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-mini/mini.icons",
      },
      opts = {
        -- LaTeX needs a latex parser plus utftex or latex2text; without them
        -- it renders nothing and only adds :checkhealth warnings.
        latex = { enabled = false },
      },
    },
  },
  keys = {
    { lhs = "<leader>um", rhs = "<cmd>RenderMarkdown toggle<cr>", desc = "Render Markdown" },
  },
}
