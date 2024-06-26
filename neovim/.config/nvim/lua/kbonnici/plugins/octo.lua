return {
	"pwntester/octo.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("octo").setup({
			use_local_fs = true,
			suppress_missing_scope = {
				projects_v2 = true,
			},
			enable_builtin = true,
			default_merge_method = "squash",
			picker_config = {
				use_emojis = true,
			},
		})

		vim.keymap.set("n", "<leader>o", ":Octo<cr>")
	end,
}
