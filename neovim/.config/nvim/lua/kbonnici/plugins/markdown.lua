return {
  "OXY2DEV/markview.nvim",
  lazy = true,    -- false Recommended
  ft = "markdown", -- If you decide to lazy-load anyway

  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function(_, opts)
    require("markview").setup(opts)
    require("markview.extras.checkboxes").setup({
      --- When true, list item markers will
      --- be removed.
      remove_markers = true,

      --- If false, running the command on
      --- visual mode doesn't change the
      --- mode.
      exit = true,

      default_marker = "-",
      default_state = "X",

      --- A list of states
      states = {
        { " ", "X" },
        { "-", "o", "~" },
      },
    })

    local markviewGroup = vim.api.nvim_create_augroup("Markview Group", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "*.md" },
      callback = function()
        vim.keymap.set("n", "<CR>", "<cmd>CheckboxToggle<cmd>")
      end,
      group = markviewGroup,
    })
  end,
  opts = {
    hybrid_modes = { "n" },
    checkboxes = {
      enable = true,
    },
    headings = {
      heading_1 = {
        style = "label",
        align = "left",
        corner_right = "",
        padding_right = " ",
        corner_left = "",
        corner_right_hl = "MarkviewHeading1Sign",
        corner_left_hl = "MarkviewHeading1Sign",
        padding_left = " ",
        icon = "",
      },
      heading_2 = {
        style = "label",
        align = "left",
        corner_right = "",
        corner_right_hl = "MarkviewHeading2Sign",
        corner_left_hl = "MarkviewHeading2Sign",
        padding_right = " ",
        corner_left = "",
        padding_left = " ",
        icon = "",
      },
      heading_3 = {
        style = "label",
        align = "left",
        corner_right = "",
        padding_right = " ",
        corner_left = "",
        corner_right_hl = "MarkviewHeading3Sign",
        corner_left_hl = "MarkviewHeading3Sign",
        padding_left = " ",
        icon = "",
      },
      heading_4 = {
        style = "label",
        align = "left",
        corner_right = "",
        padding_right = " ",
        corner_left = "",
        corner_right_hl = "MarkviewHeading4Sign",
        corner_left_hl = "MarkviewHeading4Sign",
        padding_left = " ",
        icon = "",
      },
      heading_5 = {
        style = "label",
        align = "left",
        corner_right = "",
        padding_right = " ",
        corner_left = "",
        corner_right_hl = "MarkviewHeading5Sign",
        corner_left_hl = "MarkviewHeading5Sign",
        padding_left = " ",
        icon = "",
      },
      heading_6 = {
        style = "label",
        align = "left",
        corner_right = "",
        padding_right = " ",
        corner_left = "",
        corner_right_hl = "MarkviewHeading6Sign",
        corner_left_hl = "MarkviewHeading6Sign",
        padding_left = " ",
        icon = "",
      },
    },
  },
}
