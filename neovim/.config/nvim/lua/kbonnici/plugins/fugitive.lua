return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gg", "<cmd>Git<cr>")
	end,
}
