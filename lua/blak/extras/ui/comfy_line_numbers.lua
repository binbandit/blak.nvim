local DEFAULT_LABELS = {
  "1",
  "2",
  "3",
  "4",
  "5",
  "11",
  "12",
  "13",
  "14",
  "15",
  "21",
  "22",
  "23",
  "24",
  "25",
  "31",
  "32",
  "33",
  "34",
  "35",
  "41",
  "42",
  "43",
  "44",
  "45",
  "51",
  "52",
  "53",
  "54",
  "55",
  "111",
  "112",
  "113",
  "114",
  "115",
  "121",
  "122",
  "123",
  "124",
  "125",
  "131",
  "132",
  "133",
  "134",
  "135",
  "141",
  "142",
  "143",
  "144",
  "145",
  "151",
  "152",
  "153",
  "154",
  "155",
  "211",
  "212",
  "213",
  "214",
  "215",
  "221",
  "222",
  "223",
  "224",
  "225",
  "231",
  "232",
  "233",
  "234",
  "235",
  "241",
  "242",
  "243",
  "244",
  "245",
  "251",
  "252",
  "253",
  "254",
  "255",
}

local function direction_desc(direction, count)
  local suffix = count == 1 and "line" or "lines"
  return string.format("Comfy %s %d %s", direction, count, suffix)
end

local function keymaps(labels)
  local maps = {}
  for index, label in ipairs(labels or DEFAULT_LABELS) do
    table.insert(maps, {
      mode = { "n", "x", "o" },
      lhs = label .. "j",
      rhs = index .. "j",
      desc = direction_desc("down", index),
    })
    table.insert(maps, {
      mode = { "n", "x", "o" },
      lhs = label .. "<Down>",
      rhs = index .. "j",
      desc = direction_desc("down", index),
    })
    table.insert(maps, {
      mode = { "n", "x", "o" },
      lhs = label .. "k",
      rhs = index .. "k",
      desc = direction_desc("up", index),
    })
    table.insert(maps, {
      mode = { "n", "x", "o" },
      lhs = label .. "<Up>",
      rhs = index .. "k",
      desc = direction_desc("up", index),
    })
  end
  return maps
end

local keys = keymaps(DEFAULT_LABELS)

return {
  id = "ui.comfy-line-numbers",
  label = "Comfy line numbers",
  description = "Left-hand relative line labels for easier vertical motions",
  keys = keys,
  plugins = {
    {
      "mluders/comfy-line-numbers.nvim",
      event = "VeryLazy",
      opts = {
        labels = DEFAULT_LABELS,
        up_key = "k",
        down_key = "j",
        hidden_file_types = { "undotree" },
        hidden_buffer_types = { "terminal", "nofile" },
      },
      config = function(_, opts)
        require("comfy-line-numbers").setup(opts)
        -- setup() maps `<label>j/k` again without descriptions, in "v" mode.
        -- Drop its Select-mode copies so digits typed into snippet
        -- placeholders stay literal, then restore Blak's described mappings.
        for _, label in ipairs(opts.labels) do
          pcall(vim.keymap.del, "s", label .. opts.up_key)
          pcall(vim.keymap.del, "s", label .. opts.down_key)
        end
        require("blak.core.keymaps").apply_extra(keys)
      end,
    },
  },
}
