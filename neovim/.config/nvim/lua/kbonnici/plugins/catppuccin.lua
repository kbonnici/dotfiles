return {
	"catppuccin/nvim",
	name = "catppuccin",
	config = function()
		require("catppuccin").setup({
			transparent_background = true,
			disable_float_background = true,
			flavour = "macchiato",
			custom_highlights = function(colors)
				return {
					["@markup.italic.markdown_inline"] = { fg = colors.sapphire, italic = true },
					["@markup.strong.markdown_inline"] = { fg = colors.yellow, bold = true },
				}
			end,
		})
	end,
}
