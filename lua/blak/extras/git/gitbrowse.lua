return {
  id = "git.gitbrowse",
  label = "Git Browse",
  description = "Open the current file, line, or repo on the Git remote in a browser",
  keys = {
    {
      lhs = "<leader>gB",
      mode = { "n", "x" },
      desc = "Git browse (open on remote)",
      rhs = function()
        require("snacks").gitbrowse()
      end,
    },
  },
}
