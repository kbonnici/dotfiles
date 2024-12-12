return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    local oil = require("oil")
    oil.setup({
      keymaps = {
        ["q"] = "actions.close",
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["K"] = "actions.preview",
      },
      view_options = {
        show_hidden = true,
      },
    })
    vim.keymap.set("n", "-", oil.open_float)
  end,
}
