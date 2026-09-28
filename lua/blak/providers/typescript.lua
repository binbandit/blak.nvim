local M = {}

local function tsserver(lib)
  local path = vim.fs.joinpath(lib, "tsserver.js")
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end
  local data = require("blak.util").read_file(vim.fs.joinpath(lib, "..", "package.json"))
  local ok, pkg = pcall(vim.json.decode, data or "")
  if ok and type(pkg) == "table" and type(pkg.version) == "string" and pkg.version ~= "" then
    return path
  end
end

-- Read the configured Mason root at use time, including after a tool install.
function M.mason_path()
  local ok, settings = pcall(require, "mason.settings")
  local root = ok and settings.current.install_root_dir
    or vim.fs.joinpath(vim.fn.stdpath("data"), "mason")
  return tsserver(
    vim.fs.joinpath(
      root,
      "packages",
      "typescript-language-server",
      "node_modules",
      "typescript",
      "lib"
    )
  )
end

local function workspace_path(root)
  local folders = {
    "node_modules/typescript/lib",
    ".vscode/pnpify/typescript/lib",
    ".yarn/sdks/typescript/lib",
    ".pnpm/sdks/typescript/lib",
  }
  while root do
    for _, folder in ipairs(folders) do
      local path = tsserver(vim.fs.joinpath(root, folder))
      if path then
        return path
      end
    end
    local parent = vim.fs.dirname(root)
    root = parent ~= root and parent or nil
  end
end

-- A project-local language server may not see Mason's TypeScript dependency.
-- Resolve per client, preserving explicit paths and compatible workspace SDKs.
function M.before_init(params, config)
  local opts = config.init_options or {}
  if
    vim.tbl_get(opts, "tsserver", "path") ~= nil
    or vim.tbl_get(opts, "tsserver", "fallbackPath") ~= nil
  then
    return
  end
  local path = workspace_path(config.root_dir) or M.mason_path()
  if path then
    opts.tsserver = opts.tsserver or {}
    opts.tsserver.path = path
    config.init_options = opts
    params.initializationOptions = opts
  end
end

return M
