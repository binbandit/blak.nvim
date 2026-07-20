-- tailwindcss installs through mason-lspconfig as
-- tailwindcss-language-server. The server only attaches when it finds a
-- Tailwind config in the project, so it is free on non-Tailwind codebases.
-- classFunctions needs tailwindcss-language-server 0.14 or newer, which is
-- what Mason installs.
return {
  id = "lang.tailwind",
  label = "Tailwind CSS",
  description = "Tailwind class completion, hovers, and lint via tailwindcss-language-server",
  lsp = {
    servers = {
      tailwindcss = {
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
