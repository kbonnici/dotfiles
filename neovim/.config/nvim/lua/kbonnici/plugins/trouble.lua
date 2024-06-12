return {
  "folke/trouble.nvim",
  lazy = true,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  config = function()
    local trouble = require("trouble")
    vim.keymap.set("n", "<leader>xx", trouble.toggle)
    vim.keymap.set("n", "<leader>xn", function()
      local hasNext = trouble.next({ skip_groups = true, jump = true })
      if not hasNext then
        print("[Trouble]: Nothing left to jump to.")
      end
    end)
    vim.keymap.set("n", "<leader>xp", function()
      local hasPrev = trouble.previous({ skip_groups = true, jump = true })
      if not hasPrev then
        print("[Trouble]: Nothing left to jump to.")
      end
    end)
    vim.keymap.set("n", "<leader>xw", function()
      print("Workspace Diagnostics")
      trouble.toggle("workspace_diagnostics")
    end)
    vim.keymap.set("n", "<leader>xd", function()
      print("Doc Diagnostics")
      trouble.toggle("document_diagnostics")
    end)
    vim.keymap.set("n", "<leader>xq", function()
      print("Quickfix List")
      trouble.toggle("quickfix")
    end)
    vim.keymap.set("n", "<leader>xl", function()
      print("Location List")
      trouble.toggle("loclist")
    end)
  end,
}
