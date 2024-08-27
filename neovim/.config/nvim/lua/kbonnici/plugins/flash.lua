return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		jump = {
			pos = "end",
		},
		label = {
			rainbow = {
				enabled = true,
				shade = 3,
			},
		},
		modes = {
			char = {
				jump_labels = true,
				multi_line = false,
				autohide = true,
				highlight = {
					backdrop = false,
				},
				jump = {
					autojump = true,
				},
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
