---@meta

---@alias blak.PackageChannel "stable"|"edge"|"nightly"
---@alias blak.PickerProvider "fff"|"snacks"|"telescope"|"fzf_lua"
---@alias blak.ExplorerProvider "oil"|"snacks"
---@alias blak.TerminalProvider "native"|"snacks"
---@alias blak.WinBorder "none"|"single"|"double"|"rounded"|"solid"|"shadow"|string
---@alias blak.LspFormatMode "never"|"fallback"|"prefer"|"first"|string
---@alias blak.PluginSpec string|table
---@alias blak.ExtraId
---| "ai.copilot"
---| "ai.sidekick"
---| "editor.fzf-lua"
---| "editor.mini"
---| "editor.neotree"
---| "editor.snacks-explorer"
---| "editor.snacks-terminal"
---| "editor.telescope"
---| "editor.window-navigation"
---| "git.diffview"
---| "git.lazygit"
---| "lang.go"
---| "lang.lua"
---| "lang.markdown"
---| "lang.python"
---| "lang.rust"
---| "lang.typescript"
---| "lang.typescript-tsgo"
---| "ui.animations"
---| "ui.base46"
---| "ui.comfy-line-numbers"
---| "ui.dim"
---| "ui.image-preview"
---| "ui.lualine"
---| "ui.zen"
---@alias blak.UserHook fun(config: blak.Config, blak: blak.UserContext)
---@alias blak.UserConfigLoader blak.UserConfig|fun(config: blak.Config, blak: blak.UserContext): blak.UserConfig?

---@class blak.UserConfig
---@field version? string
---@field leader? string
---@field localleader? string
---@field package? blak.PackageConfig
---@field ui? blak.UiConfig
---@field editor? blak.EditorConfig
---@field completion? blak.CompletionConfig
---@field performance? blak.PerformanceConfig
---@field picker? blak.PickerConfig
---@field explorer? blak.ExplorerConfig
---@field terminal? blak.TerminalConfig
---@field keymaps? blak.KeymapSpec[]
---@field plugins? blak.PluginConfig
---@field hooks? blak.HooksConfig
---@field ai? blak.AiConfig
---@field mini? blak.MiniConfig
---@field snacks? table
---@field treesitter? blak.TreesitterConfig
---@field lsp? blak.LspConfig
---@field mason? blak.MasonConfig
---@field format? blak.FormatConfig
---@field lint? blak.LintConfig
---@field extras? blak.ExtrasConfig

---@alias blak.Config blak.UserConfig

---@class blak.UserContext
---@field defaults blak.Config
---@field util table

---@class blak.PackageConfig
---@field backend? "lazy"|string
---@field channel? blak.PackageChannel
---@field check_updates? boolean

---@class blak.UiConfig
---@field colorscheme? string
---@field transparent? boolean
---@field theme? table
---@field icons? boolean
---@field notify? boolean
---@field winborder? blak.WinBorder
---@field splash? blak.SplashConfig

---@class blak.SplashConfig
---@field enabled? boolean
---@field animate? boolean
---@field loop? boolean

---@class blak.EditorConfig
---@field clipboard? boolean
---@field relative_number? boolean
---@field scrolloff? integer
---@field sidescrolloff? integer
---@field tabstop? integer
---@field shiftwidth? integer
---@field expandtab? boolean

---@class blak.CompletionConfig
---@field super_tab? boolean

---@class blak.PerformanceConfig
---@field bigfile_size? number
---@field max_treesitter_lines? integer

---@class blak.PickerConfig
---@field provider? blak.PickerProvider

---@class blak.ExplorerConfig
---@field provider? blak.ExplorerProvider

---@class blak.TerminalConfig
---@field provider? blak.TerminalProvider
---@field toggle_key? string|false

---@class blak.KeymapSpec
---@field mode? string|string[]
---@field key? string
---@field action? string|function|false
---@field description? string
---@field disable? boolean
---@field lhs? string
---@field rhs? string|function|false
---@field desc? string
---@field opts? table

---@class blak.PluginConfig
---@field specs? blak.PluginSpec[]

---@class blak.HooksConfig
---@field before? blak.UserHook|blak.UserHook[]
---@field after? blak.UserHook|blak.UserHook[]

---@class blak.AiConfig
---@field sidekick? blak.SidekickConfig

---@class blak.SidekickConfig
---@field nes? blak.FeatureToggle
---@field cli? blak.SidekickCliConfig

---@class blak.FeatureToggle
---@field enabled? boolean

---@class blak.SidekickCliConfig
---@field picker? "snacks"|string
---@field mux? blak.SidekickMuxConfig

---@class blak.SidekickMuxConfig
---@field enabled? boolean
---@field backend? "tmux"|"zellij"|string

---@class blak.MiniConfig
---@field modules? string[]
---@field opts? table<string, table>

---@class blak.TreesitterConfig
---@field ensure_installed? string[]

---@class blak.LspConfig
---@field automatic_enable? boolean
---@field servers? table<string, table>
---@field diagnostics? table

---@class blak.MasonConfig
---@field automatic_install? boolean
---@field ensure_installed? string[]

---@class blak.FormatterList
---@field [integer] string
---@field stop_after_first? boolean

---@alias blak.FormatterSpec string|blak.FormatterList|fun(bufnr: integer): any

---@class blak.FormatConfig
---@field enabled? boolean
---@field timeout_ms? integer
---@field lsp_format? blak.LspFormatMode
---@field formatters_by_ft? table<string, blak.FormatterSpec>

---@class blak.LintConfig
---@field events? string[]
---@field linters_by_ft? table<string, string[]>

---@class blak.ExtrasConfig
---@field enabled? blak.ExtraId[]

return {}
