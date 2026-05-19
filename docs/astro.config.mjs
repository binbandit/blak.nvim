// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

const site = "https://getblak.dev";
const socialImage = new URL("/social-card.png", site).href;
const socialImageAlt =
  "blak.nvim social card with the landing-page ASCII black-hole splash.";

// https://astro.build/config
export default defineConfig({
  site,
  trailingSlash: "ignore",
  integrations: [
    starlight({
      title: "blak.nvim",
      description:
        "A native-first Neovim distribution. Everything useful. Nothing escapes.",
      favicon: "/favicon.svg",
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
            property: "og:image",
            content: socialImage,
          },
        },
        {
          tag: "meta",
          attrs: {
            property: "og:image:type",
            content: "image/png",
          },
        },
        {
          tag: "meta",
          attrs: {
            property: "og:image:width",
            content: "1200",
          },
        },
        {
          tag: "meta",
          attrs: {
            property: "og:image:height",
            content: "630",
          },
        },
        {
          tag: "meta",
          attrs: {
            property: "og:image:alt",
            content: socialImageAlt,
          },
        },
        {
          tag: "meta",
          attrs: {
            name: "twitter:image",
            content: socialImage,
          },
        },
        {
          tag: "meta",
          attrs: {
            name: "twitter:image:alt",
            content: socialImageAlt,
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
        // Enhance the Pagefind search dialog: better placeholder, an
        // empty-state hint with clickable quick links to popular pages.
        // Pagefind builds its UI lazily on first dialog open; we run on
        // DOMContentLoaded then observe the document for form insertion.
        {
          tag: "script",
          content: `(() => {
  const POPULAR = [
    { label: 'Install',     href: '/start/install/' },
    { label: 'Why Blak',    href: '/start/why/' },
    { label: 'Commands',    href: '/guide/commands/' },
    { label: 'Keymaps',     href: '/guide/keymaps/' },
    { label: 'Extras',      href: '/guide/extras/' },
    { label: 'LSP',         href: '/guide/lsp/' },
  ];
  const PLACEHOLDER = 'Search docs — install, extras, lsp, keymaps, schema…';

  function buildEmptyState() {
    const el = document.createElement('div');
    el.className = 'blak-search-empty';
    el.innerHTML = [
      '<div class="blak-search-empty-eyebrow">Tip</div>',
      '<p class="blak-search-empty-hint">Search runs across every guide and reference page. Start typing, or jump in:</p>',
      '<div class="blak-search-empty-grid">',
      ...POPULAR.map(function (p) {
        return '<a class="blak-search-empty-chip" href="' + p.href + '"><span class="blak-search-empty-chip-mark" aria-hidden="true">&#9656;</span>' + p.label + '</a>';
      }),
      '</div>',
    ].join('');
    return el;
  }

  function enhance(form) {
    if (!form || form.dataset.blakEnhanced) return;
    form.dataset.blakEnhanced = '1';
    var input = form.querySelector('.pagefind-ui__search-input');
    if (input) input.placeholder = PLACEHOLDER;
    form.appendChild(buildEmptyState());
  }

  function scan() {
    document.querySelectorAll('.pagefind-ui__form').forEach(enhance);
  }

  function setup() {
    scan();
    new MutationObserver(scan).observe(document.documentElement, {
      childList: true,
      subtree: true,
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setup);
  } else {
    setup();
  }
})();`,
        },
      ],
      editLink: {
        baseUrl: "https://github.com/binbandit/blak.nvim/edit/main/docs/",
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
          label: "Extras",
          items: [
            { label: "Overview", slug: "guide/extras" },
            { label: "Lua", slug: "extras/lang/lua" },
            { label: "TypeScript", slug: "extras/lang/typescript" },
            { label: "TypeScript tsgo", slug: "extras/lang/typescript-tsgo" },
            { label: "Python", slug: "extras/lang/python" },
            { label: "Rust", slug: "extras/lang/rust" },
            { label: "Go", slug: "extras/lang/go" },
            { label: "Markdown", slug: "extras/lang/markdown" },
            { label: "DAP", slug: "extras/debug/dap" },
            { label: "Neotest", slug: "extras/test/neotest" },
            { label: "Animations", slug: "extras/ui/animations" },
            { label: "Base46", slug: "extras/ui/base46" },
            { label: "Comfy line numbers", slug: "extras/ui/comfy-line-numbers" },
            { label: "Dim", slug: "extras/ui/dim" },
            { label: "Image preview", slug: "extras/ui/image-preview" },
            { label: "Lualine", slug: "extras/ui/lualine" },
            { label: "Zen", slug: "extras/ui/zen" },
            { label: "LazyGit", slug: "extras/git/lazygit" },
            { label: "Diffview", slug: "extras/git/diffview" },
            { label: "Copilot", slug: "extras/ai/copilot" },
            { label: "Sidekick", slug: "extras/ai/sidekick" },
            { label: "Aerial", slug: "extras/editor/aerial" },
            { label: "Harpoon", slug: "extras/editor/harpoon" },
            { label: "Mini.nvim modules", slug: "extras/editor/mini" },
            { label: "Overseer", slug: "extras/editor/overseer" },
            { label: "Refactoring", slug: "extras/editor/refactoring" },
            { label: "Render Markdown", slug: "extras/editor/render-markdown" },
            { label: "TODO comments", slug: "extras/editor/todo-comments" },
            { label: "Trouble", slug: "extras/editor/trouble" },
            { label: "Window navigation", slug: "extras/editor/window-navigation" },
            { label: "Neo-tree", slug: "extras/editor/neotree" },
            { label: "Snacks explorer", slug: "extras/editor/snacks-explorer" },
            { label: "Snacks terminal", slug: "extras/editor/snacks-terminal" },
            { label: "Telescope", slug: "extras/editor/telescope" },
            { label: "fzf-lua", slug: "extras/editor/fzf-lua" },
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
