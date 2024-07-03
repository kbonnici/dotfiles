return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	config = function()
		require("dashboard").setup({
			theme = "hyper",
			config = {
				week_header = {
					enable = true,
				},
				mru = {
					limit = 3,
				},
				shortcut = {
					{ desc = " Update", group = "@property", action = "Lazy update", key = "u" },
					{
						desc = " Files",
						group = "Label",
						action = "Telescope find_files",
						key = "f",
					},
					{
						desc = " dotfiles",
						group = "Number",
						action = "Telescope find_files search_dirs=~/dotfiles",
						key = "d",
					},
					{
						desc = "󰐥 Quit",
						group = "DiagnosticHint",
						action = "q",
						key = "q",
					},
				},
			},
		})
	end,
	dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
