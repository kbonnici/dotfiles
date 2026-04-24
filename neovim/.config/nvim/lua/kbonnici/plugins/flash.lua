return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    jump = {
      pos = "start",
    },
    label = {
      rainbow = {
        enabled = false,
        shade = 3,
      },
    },
    modes = {
      char = {
        jump_labels = true,
        multi_line = false,
        autohide = true,
        highlight = {
          backdrop = true,
        },
        jump = {
          autojump = true,
        },
      },
    },
  },
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash",
    },
    {
      "<c-s>",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter_search()
      end,
      desc = "Treesitter Search",
    },
    {
      "s",
      mode = { "o", "x" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
  },
}
