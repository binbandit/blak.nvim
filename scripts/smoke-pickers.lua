-- Exercise the actual native fff backend and UI, plus the Snacks fallback.
local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
vim.fn.writefile({ "local answer = 42" }, root .. "/fixture.lua")
local ok, err = xpcall(function()
  local fff = require("blak.providers.picker.fff")
  fff.files({ cwd = root })
  local picker = require("fff.picker_ui.picker_ui")
  assert(
    vim.wait(10000, function()
      return picker.state.active and #picker.state.items > 0
    end, 50),
    "fff files picker did not find the fixture"
  )
  assert(picker.state.items[1].name == "fixture.lua", "fff searched the wrong directory")
  picker.close()
  fff.grep({ cwd = root, query = "answer" })
  assert(
    vim.wait(10000, function()
      return picker.state.active and #picker.state.items > 0
    end, 50),
    "fff grep picker did not find fixture content"
  )
  picker.close()
  local buffers = require("blak.providers.picker.snacks").buffers({})
  assert(buffers, "Snacks buffer picker did not open")
  buffers:close()
end, debug.traceback)
vim.fn.delete(root, "rf")
assert(ok, err)
print("Picker integration passed")
