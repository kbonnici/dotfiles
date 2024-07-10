return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	-- event = {
	-- 	-- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	-- 	-- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
	-- 	'BufReadPre "~/Obsidian Vault/**.md"',
	-- 	'BufNewFile "~/Obsidian Vault/**.md"',
	-- },
	dependencies = {
		"nvim-lua/plenary.nvim",

		-- see below for full list of optional dependencies 👇
	},
	opts = {
		workspaces = {
			{
				name = "Obsidian Vault",
				path = "~/Obsidian Vault",
			},
		},

		-- see below for full list of options 👇
	},
}
