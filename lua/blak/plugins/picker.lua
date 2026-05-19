return function(config)
  local enabled = config.picker.provider == "fff"
  return {
    {
      "dmtrKovalenko/fff",
      enabled = enabled,
      lazy = true,
      dependencies = { "nvim-mini/mini.icons" },
      build = function()
        local ok, download = pcall(require, "fff.download")
        if ok and download.download_or_build_binary then
          download.download_or_build_binary()
        end
      end,
      opts = {
        prompt = "BLAK › ",
        layout = {
          width = 0.88,
          height = 0.82,
        },
        frecency = {
          enabled = true,
        },
        history = {
          enabled = true,
        },
      },
      config = function(_, opts)
        require("fff").setup(opts)
      end,
    },
  }
end
