-- tailwindcss installs through mason-lspconfig as
-- tailwindcss-language-server. classFunctions needs tailwindcss-language-server
-- 0.14 or newer, which is what Mason installs.

-- Manifests that name Tailwind as a dependency, and the text to look for.
local manifests = {
  ["package.json"] = "tailwindcss",
  ["mix.lock"] = "tailwind",
  ["Gemfile.lock"] = "tailwind",
}

-- nvim-lspconfig falls back to `.git` so Tailwind v4 projects without a
-- config file still attach, which starts a server in every repository. Attach
-- only to the nearest directory with a Tailwind config or a manifest that
-- depends on Tailwind (v4 projects list `tailwindcss` or `@tailwindcss/*`).
local function root_dir(bufnr, on_dir)
  local root = vim.fs.root(bufnr, function(name, path)
    if name:match("^tailwind%.config%.[cm]?[jt]s$") then
      return true
    end
    local needle = manifests[name]
    local data = needle and require("blak.util").read_file(vim.fs.joinpath(path, name))
    return data ~= nil and data:find(needle, 1, true) ~= nil
  end)
  if root then
    on_dir(root)
  end
end

return {
  id = "lang.tailwind",
  label = "Tailwind CSS",
  description = "Tailwind class completion, hovers, and lint via tailwindcss-language-server",
  lsp = {
    servers = {
      tailwindcss = {
        root_dir = root_dir,
        settings = {
          tailwindCSS = {
            classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
            classFunctions = { "clsx", "cn", "cva", "cx", "tw", "twMerge" },
          },
        },
      },
    },
  },
}
