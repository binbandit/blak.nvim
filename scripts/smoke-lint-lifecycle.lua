-- Run against the pinned nvim-lint installed by scripts/smoke.sh.
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/nvim-lint")
local lint = require("lint")
local linting = require("blak.core.linting")
local config = vim.deepcopy(require("blak.config.defaults"))
config.lint.events = { "InsertLeave" }
local runs = {}
local warnings = {}
local original_notify = vim.notify
vim.notify = function(message, level)
  if level == vim.log.levels.WARN then
    table.insert(warnings, message)
  end
end

local function healthy(name)
  lint.linters[name] = {
    cmd = assert(vim.fn.exepath("sh")),
    args = { "-c", "printf fixture" },
    stdin = false,
    append_fname = false,
    parser = function()
      runs[name] = (runs[name] or 0) + 1
      return {
        { lnum = 0, col = 0, message = name, severity = vim.diagnostic.severity.WARN },
      }
    end,
  }
end
healthy("blak_healthy")
healthy("blak_second")
lint.linters.blak_broken = function()
  error("Blak fixture factory failed")
end

local function run(mapping, filetype, expected)
  runs = {}
  config.lint.linters_by_ft = mapping
  vim.bo.filetype = filetype
  linting.setup(config)
  vim.api.nvim_exec_autocmds("InsertLeave", { modeline = false })
  assert(
    vim.wait(2000, function()
      return #lint.get_running() == 0 and vim.deep_equal(runs, expected)
    end, 10),
    "fixture linters did not finish: " .. vim.inspect(runs)
  )
  assert(vim.deep_equal(runs, expected), "unexpected linter runs: " .. vim.inspect(runs))
end

for _, names in ipairs({
  { "blak_missing", "blak_healthy" },
  { "blak_broken", "blak_healthy" },
  { "blak_healthy", "blak_missing", "blak_second" },
  { "blak_healthy", "blak_broken", "blak_second" },
}) do
  local expected = { blak_healthy = 1 }
  if vim.tbl_contains(names, "blak_second") then
    expected.blak_second = 1
  end
  run({ blakaudit = names }, "blakaudit", expected)
end
assert(
  #warnings == 2,
  "missing/failing linter errors should each warn once: " .. vim.inspect(warnings)
)
assert(warnings[1]:find("blak_missing", 1, true), "the missing linter warning lacked its name")
assert(warnings[2]:find("blak_broken", 1, true), "the factory warning lacked its name")

run({
  ["blakaudit.child"] = { "blak_healthy" },
  blakaudit = { "blak_second" },
  child = { "blak_broken" },
}, "blakaudit.child", { blak_healthy = 1 })
run({
  blakaudit = { "blak_missing", "blak_healthy" },
  child = { "blak_healthy", "blak_second" },
}, "blakaudit.child", { blak_healthy = 1, blak_second = 1 })
run({
  ["blakaudit.child"] = {},
  blakaudit = { "blak_healthy" },
}, "blakaudit.child", {})
run({ ["*"] = { "blak_healthy" }, ["_"] = { "blak_second" } }, "unconfigured", {})

-- Both a real background file load and a targeted synthetic event must lint
-- that buffer, preserving the visible buffer and its diagnostics.
local visible = vim.api.nvim_get_current_buf()
vim.bo.filetype = "blakvisible"
local path = vim.fn.tempname()
vim.fn.writefile({ "background fixture" }, path)
local background = vim.fn.bufadd(path)
vim.bo[background].filetype = "blakbackground"
config.lint.events = { "BufReadPost" }
config.lint.linters_by_ft = {
  blakvisible = { "blak_second" },
  blakbackground = { "blak_healthy" },
}
linting.setup(config)
local namespace = lint.get_namespace("blak_healthy")
for _, trigger in ipairs({
  function()
    vim.fn.bufload(background)
  end,
  function()
    vim.api.nvim_exec_autocmds("BufReadPost", { buffer = background })
  end,
}) do
  runs = {}
  vim.diagnostic.reset(namespace)
  trigger()
  assert(
    vim.wait(2000, function()
      return #lint.get_running() == 0
        and #vim.diagnostic.get(background, { namespace = namespace }) == 1
    end, 10),
    "the background buffer did not receive its linter diagnostic"
  )
  assert(vim.deep_equal(runs, { blak_healthy = 1 }), "background event linted the visible buffer")
  assert(
    #vim.diagnostic.get(visible, { namespace = namespace }) == 0,
    "diagnostics went to the wrong buffer"
  )
  assert(vim.api.nvim_get_current_buf() == visible, "linting changed the visible buffer")
end
vim.api.nvim_buf_delete(background, { force = true })
vim.fn.delete(path)

vim.notify = original_notify
print("Linter failure isolation and filetype checks passed")
