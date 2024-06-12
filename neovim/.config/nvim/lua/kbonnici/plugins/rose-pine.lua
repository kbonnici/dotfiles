return {
	"rose-pine/neovim",
	name = "rose-pine",
	event = "VeryLazy",
	config = function()
		require("rose-pine").setup({
			disable_background = true, -- transparency
			disable_float_background = true,
		})
	end,
}
