// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
  site: "https://binbandit.github.io",
  base: "/blak.nvim",
  trailingSlash: "ignore",
  integrations: [
    starlight({
      title: "blak.nvim",
      description:
        "A native-first Neovim distribution. Everything useful. Nothing escapes.",
      favicon: "/favicon.svg",
      social: {
        github: "https://github.com/binbandit/blak.nvim",
      },
      customCss: ["./src/styles/custom.css"],
      components: {
        Hero: "./src/components/Hero.astro",
        ThemeSelect: "./src/components/ThemeSelect.astro",
        SiteTitle: "./src/components/SiteTitle.astro",
      },
      head: [
        {
          tag: "meta",
          attrs: {
            name: "theme-color",
            content: "#000000",
          },
        },
        {
          tag: "meta",
          attrs: {
            property: "og:type",
            content: "website",
          },
        },
        {
          tag: "meta",
          attrs: {
            property: "og:title",
            content: "blak.nvim — Everything useful. Nothing escapes.",
          },
        },
        // The brand is a black hole. Force the dark theme before any
        // Starlight script runs so the page never flashes light.
        {
          tag: "script",
          content: `(() => {
  try {
    localStorage.setItem('starlight-theme', 'dark');
  } catch (_) {}
  document.documentElement.dataset.theme = 'dark';
})();`,
        },
      ],
      editLink: {
        baseUrl:
          "https://github.com/binbandit/blak.nvim/edit/main/docs/src/content/docs/",
      },
      lastUpdated: true,
      pagination: true,
      tableOfContents: {
        minHeadingLevel: 2,
        maxHeadingLevel: 4,
      },
      expressiveCode: {
        themes: ["github-dark-default"],
        styleOverrides: {
          borderRadius: "0.5rem",
          frames: {
            shadowColor: "transparent",
          },
        },
      },
      sidebar: [
        {
          label: "Start here",
          items: [
            { label: "Why Blak", slug: "start/why" },
            { label: "Install", slug: "start/install" },
            { label: "Requirements", slug: "start/requirements" },
            { label: "Customize", slug: "start/customize" },
          ],
        },
        {
          label: "Guide",
          items: [
            { label: "Philosophy", slug: "guide/philosophy" },
            { label: "Plugins", slug: "guide/plugins" },
            { label: "Pickers", slug: "guide/pickers" },
            { label: "LSP", slug: "guide/lsp" },
            { label: "Mason", slug: "guide/mason" },
            { label: "Treesitter", slug: "guide/treesitter" },
            { label: "Formatting", slug: "guide/formatting" },
            { label: "Linting", slug: "guide/linting" },
            { label: "Commands", slug: "guide/commands" },
            { label: "Keymaps", slug: "guide/keymaps" },
            { label: "Extras", slug: "guide/extras" },
            { label: "Splash & dashboard", slug: "guide/splash" },
            { label: "Colorscheme", slug: "guide/colorscheme" },
            { label: "Health checks", slug: "guide/health" },
            { label: "Updates & rollback", slug: "guide/updates" },
          ],
        },
        {
          label: "Reference",
          items: [
            { label: "Defaults", slug: "reference/defaults" },
            { label: "Config schema", slug: "reference/schema" },
            { label: "Editor options", slug: "reference/options" },
            { label: "Autocmds", slug: "reference/autocmds" },
            { label: "User events", slug: "reference/events" },
            { label: "Public API", slug: "reference/api" },
            { label: "Directory layout", slug: "reference/structure" },
          ],
        },
        {
          label: "Project",
          items: [
            { label: "Contributing", slug: "contributing" },
            { label: "Writing an extra", slug: "project/writing-extras" },
            { label: "Dev install", slug: "project/dev-install" },
            { label: "Validation & CI", slug: "project/validation" },
            { label: "News", slug: "news" },
          ],
        },
      ],
    }),
  ],
});
