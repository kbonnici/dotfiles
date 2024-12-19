return {
  {
    "williamboman/mason.nvim",
    event = "VeryLazy",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = "VeryLazy",
    config = function()
      require("mason-lspconfig").setup({})
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPost",
    dependencies = {
      {
        "nvimdev/lspsaga.nvim",
        config = function()
          require("lspsaga").setup({
            symbol_in_winbar = { -- breadcrumbs
              enable = false,
            },
            lightbulb = {
              enable = false,
            },
            finder = {
              keys = {
                toggle_or_open = "<cr>",
              },
            },
          })

          vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<cr>")
          vim.keymap.set("n", "<leader>lr", "<cmd>Lspsaga rename<cr>")
          vim.keymap.set("n", "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<cr>")
          vim.keymap.set("n", "<leader>lpr", "<cmd>Lspsaga lsp_rename ++project<cr>")
          vim.keymap.set({ "n", "v" }, "<leader>la", "<cmd>Lspsaga code_action<cr>")
        end,
        dependencies = {
          "nvim-treesitter/nvim-treesitter",
          "nvim-tree/nvim-web-devicons",
        },
      },
      { "saghen/blink.cmp" },
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      require("mason-lspconfig").setup_handlers({
        -- default handler
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
          })
        end,
        ["denols"] = function()
          lspconfig["denols"].setup({
            root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
            capabilities = capabilities,
          })
        end,
        ["ts_ls"] = function()
          lspconfig["ts_ls"].setup({
            root_dir = lspconfig.util.root_pattern("package.json"),
            single_file_support = false,
            capabilities = capabilities,
          })
        end,
      })

      vim.keymap.set("n", "<leader>gf", function()
        vim.lsp.buf.format({ async = false })
      end)
      vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function()
          -- only format if an lsp is attached
          if next(vim.lsp.get_clients()) ~= nil then
            vim.lsp.buf.format({ async = false })
          end
        end,
      })
    end,
  },
}
