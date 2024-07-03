return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		jump = {
			autojump = true,
		},
		modes = {
			char = {
				jump_labels = true,
				multi_line = false,
			},
		},
	},
	keys = {
		{
			"<c-f>",
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
