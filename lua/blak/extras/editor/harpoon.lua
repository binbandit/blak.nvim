local function harpoon()
  return require("blak.util").load_plugin("harpoon", "harpoon")
end

local function add_file()
  local module = harpoon()
  if module then
    module:list():add()
  end
end

local function toggle_menu()
  local module = harpoon()
  if module then
    module.ui:toggle_quick_menu(module:list())
  end
end

local function select_file(index)
  return function()
    local module = harpoon()
    if module then
      module:list():select(index)
    end
  end
end

local function navigate(direction)
  return function()
    local module = harpoon()
    if module then
      local list = module:list()
      list[direction](list)
    end
  end
end

return {
  id = "editor.harpoon",
  label = "Harpoon",
  description = "Harpoon v2 project file marks and quick menu",
  plugins = {
    {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      lazy = true,
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {},
      config = function(_, opts)
        require("harpoon"):setup(opts)
      end,
    },
  },
  keys = {
    { lhs = "<leader>ha", rhs = add_file, desc = "Harpoon add file" },
    { lhs = "<leader>hh", rhs = toggle_menu, desc = "Harpoon menu" },
    { lhs = "<leader>hp", rhs = navigate("prev"), desc = "Previous Harpoon file" },
    { lhs = "<leader>hn", rhs = navigate("next"), desc = "Next Harpoon file" },
    { lhs = "<leader>h1", rhs = select_file(1), desc = "Harpoon file 1" },
    { lhs = "<leader>h2", rhs = select_file(2), desc = "Harpoon file 2" },
    { lhs = "<leader>h3", rhs = select_file(3), desc = "Harpoon file 3" },
    { lhs = "<leader>h4", rhs = select_file(4), desc = "Harpoon file 4" },
  },
}
