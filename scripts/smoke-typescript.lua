local util = require("blak.util")
local typescript = require("blak.providers.typescript")
local temp = vim.fn.tempname()
local project = util.join(temp, "workspace")
local mason = util.join(temp, "custom-mason")
local bundled =
  util.join(mason, "packages", "typescript-language-server", "node_modules", "typescript")
local workspace = util.join(project, "node_modules", "typescript")
package.loaded["mason.settings"] = { current = { install_root_dir = mason } }

local function sdk(path)
  util.write_file(util.join(path, "package.json"), '{"version":"6.0.3"}')
  util.write_file(util.join(path, "lib", "tsserver.js"), "// test fixture")
  return util.join(path, "lib", "tsserver.js")
end

local function initialize(root, opts)
  local c = { root_dir = root, init_options = opts or { hostInfo = "neovim" } }
  local params = { initializationOptions = c.init_options }
  require("blak.extras.lang.typescript_legacy").lsp.servers.ts_ls.before_init(params, c)
  assert(params.initializationOptions == c.init_options, "SDK did not reach the initialize request")
  return c.init_options
end

assert(typescript.mason_path() == nil, "missing TypeScript was reported as usable")
local fallback = sdk(bundled)
local bare_params, bare_config = {}, { root_dir = project }
typescript.before_init(bare_params, bare_config)
assert(
  bare_params.initializationOptions.tsserver.path == fallback,
  "SDK was not sent when init_options was initially absent"
)
local custom_config = vim.deepcopy(require("blak.config.defaults"))
local custom_hook = function() end
custom_config.lsp.servers.ts_ls = { before_init = custom_hook }
require("blak.extras").apply_one(custom_config, "lang.typescript-legacy")
assert(
  custom_config.lsp.servers.ts_ls.before_init == custom_hook,
  "TypeScript extra overwrote a user initialization hook"
)
local opts = initialize(project)
assert(opts.tsserver.path == fallback, "Mason TypeScript was not supplied to ts_ls")
assert(opts.hostInfo == "neovim", "TypeScript setup discarded other initialization options")
local local_path = sdk(workspace)
assert(
  initialize(util.join(project, "packages", "app")).tsserver.path == local_path,
  "workspace TypeScript must win over Mason, including ancestor workspaces"
)
assert(
  initialize(project, { tsserver = { path = "/custom/tsserver.js", logVerbosity = "verbose" } }).tsserver.path
    == "/custom/tsserver.js",
  "TypeScript setup overwrote the user's explicit SDK"
)
assert(
  initialize(project, { tsserver = { fallbackPath = "/custom/tsserver.js" } }).tsserver.path == nil,
  "TypeScript setup overrode an explicit fallback SDK"
)
vim.fn.delete(util.join(workspace, "lib", "tsserver.js"))
assert(
  initialize(project).tsserver.path == fallback,
  "TypeScript without tsserver.js did not fall back"
)
vim.fn.delete(workspace, "rf")
local yarn = sdk(util.join(project, ".yarn", "sdks", "typescript"))
assert(initialize(project).tsserver.path == yarn, "Yarn SDK was ignored")
vim.fn.delete(project, "rf")
vim.fn.delete(bundled, "rf")
assert(initialize(project).tsserver == nil, "a missing SDK produced an invalid tsserver path")

-- Existing Mason receipts do not prove that the TypeScript runtime is intact.
local installs, refreshes = 0, 0
local installing = false
local pkg = {
  is_installed = function()
    return true
  end,
  is_installing = function()
    return installing
  end,
  install = function(_, install_opts)
    assert(install_opts.force, "repair must replace an already-installed package")
    installs = installs + 1
  end,
}
package.loaded["mason-registry"] = {
  get_package = function(name)
    assert(name == "typescript-language-server")
    return pkg
  end,
  refresh = function(callback)
    refreshes = refreshes + 1
    callback()
  end,
}
local c = vim.deepcopy(require("blak.config.defaults"))
c.mason.ensure_installed = {}
c.lsp.servers = { ts_ls = {} }
require("blak.core.tools").ensure(c)
assert(installs == 1 and refreshes == 1, "broken TypeScript installation was not repaired")
sdk(bundled)
require("blak.core.tools").ensure(c)
assert(installs == 1, "healthy TypeScript was reinstalled")
vim.fn.delete(bundled, "rf")
installing = true
require("blak.core.tools").ensure(c)
assert(installs == 1, "repair duplicated an in-progress installation")
c.lsp.servers = {}
require("blak.core.tools").ensure(c)
assert(refreshes == 3, "disabled TypeScript extra still requested repairs")

vim.fn.delete(temp, "rf")
print("TypeScript checks passed")
