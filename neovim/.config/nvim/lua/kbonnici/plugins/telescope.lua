function LoadTroubleMappings()
	local ok, trouble = pcall(require, "trouble.sources.telescope")
	if not ok then
		return nil
	end

	local mapping = { ["<c-t>"] = trouble.open }

	return {
		i = mapping,
		n = mapping,
	}
end

return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", function()
				builtin.find_files({ path_display = { "truncate" } })
			end)
			vim.keymap.set("n", "<leader>fb", function()
				builtin.buffers({ path_display = { "truncate" } })
			end)
			vim.keymap.set("n", "<leader>fh", builtin.help_tags)
			vim.keymap.set("n", "<leader>fg", builtin.live_grep)
			vim.keymap.set("n", "<C-p>", function()
				builtin.git_files({ path_display = { "truncate" } })
			end)
			-- vim.keymap.set("n", "<leader>gb", builtin.git_branches)
		end,
	},

	{
		"nvim-telescope/telescope-ui-select.nvim",
		lazy = true,
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					mappings = LoadTroubleMappings() or require("telescope.config").values.default_mappings,
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
				pickers = {
					find_files = {
						find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
					},
				},
			})

			telescope.load_extension("ui-select")
		end,
	},
}
