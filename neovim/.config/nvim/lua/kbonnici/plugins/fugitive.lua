return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gg", "<cmd>G<cr>")
		vim.keymap.set("n", "<leader>gp", "<cmd>G pull<cr>")
		vim.keymap.set("n", "<leader>gP", "<cmd>G push<cr>")
		vim.keymap.set("n", "<leader>gc", "<cmd>G commit<cr>")
	end,
}
