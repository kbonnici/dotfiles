return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function()
        local oil = require("oil")
        oil.setup({
            keymaps = {
                ["q"] = "actions.close",
                ["<C-h>"] = false,
                ["<C-l>"] = false,
                ["K"] = "actions.preview",
            },
        })
        vim.keymap.set("n", "-", oil.open)
    end,
}
