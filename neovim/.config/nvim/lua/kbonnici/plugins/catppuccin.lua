return {
	"catppuccin/nvim",
	name = "catppuccin",
	config = function()
		require("catppuccin").setup({
			transparent_background = true,
			disable_float_background = true,
			flavour = "macchiato",
		})
	end,
}
