return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	event = "VeryLazy",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup()
		vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>")
	end,
}
