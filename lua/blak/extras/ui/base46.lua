return {
  id = "ui.base46",
  label = "Base46",
  description = "Install the Base46 colorscheme collection",
  plugins = {
    {
      "duxlabs-dev/base46",
      -- Load after startup so `:colorscheme base46-<Tab>` and colorscheme
      -- pickers list the collection. setup() only stores options; no theme is
      -- applied. A base46 `ui.colorscheme` still loads it earlier on demand.
      event = "VeryLazy",
      opts = {},
    },
  },
}
