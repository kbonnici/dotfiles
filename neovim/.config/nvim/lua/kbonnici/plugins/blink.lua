return {
  "saghen/blink.cmp",
  -- optional: provides snippets for the snippet source
  dependencies = { "rafamadriz/friendly-snippets", { "L3MON4D3/LuaSnip", version = "v2.*" } },
  -- use a release tag to download pre-built binaries
  version = "v0.*",
  ---@module 'blink.cmp'
  ---@diagnostic disable-next-line: undefined-doc-name
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = "default",

      ["<C-p>"] = { "select_prev", "show", "fallback" },
      ["<C-n>"] = { "select_next", "show", "fallback" },
    },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },
    snippets = {
      expand = function(snippet)
        require("luasnip").lsp_expand(snippet)
      end,
      active = function(filter)
        if filter and filter.direction then
          return require("luasnip").jumpable(filter.direction)
        end
        return require("luasnip").in_snippet()
      end,
      jump = function(direction)
        require("luasnip").jump(direction)
      end,
    },
    sources = {
      default = { "lsp", "path", "luasnip", "buffer" },
    },
    -- experimental signature help support
    -- signature = { enabled = true },

    completion = {
      accept = {
        -- Create an undo point when accepting a completion item
        create_undo_point = true,
        -- Experimental auto-brackets support
        auto_brackets = {
          -- Whether to auto-insert brackets for functions
          enabled = true,
          -- Default brackets to use for unknown languages
          default_brackets = { "(", ")" },
          -- Overrides the default blocked filetypes
          override_brackets_for_filetypes = {},
          -- Synchronously use the kind of the item to determine if brackets should be added
          kind_resolution = {
            enabled = true,
            -- blocked_filetypes = { "typescriptreact", "javascriptreact", "vue" },
            blocked_filetypes = {},
          },
          -- Asynchronously use semantic token to determine if brackets should be added
          semantic_token_resolution = {
            enabled = true,
            blocked_filetypes = {},
            -- How long to wait for semantic tokens to return before assuming no brackets should be added
            timeout_ms = 400,
          },
        },
      },
      menu = {
        border = "rounded",
        scrollbar = false,
      },
      documentation = {
        auto_show = true,
        window = {
          border = "rounded",
        },
      },
    },
  },
}
