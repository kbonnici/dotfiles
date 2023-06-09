local status, _ = pcall(require, "nvim-treesitter")
if not status then
	print("[Error]: Treesitter not installed!")
	return
end

local treesitter_config_status, treesitter = pcall(require, "nvim-treesitter.configs")
if not treesitter_config_status then
	print("[Error]: Could not find Treesitter.configs")
	return
end

--require'nvim-treesitter.configs'.setup {
treesitter.setup({
	ensure_installed = {
		"c",
		"lua",
		"vim",
		"help",
		"query",
		"json",
		"css",
		"html",
		"javascript",
		"typescript",
		"tsx",
		"rust",
		"markdown",
		"markdown_inline",
		"gitignore",
		"dockerfile",
	},

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = true,

	highlight = {
		enable = true,

		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},

	indent = {
		enable = true,
	},

	autotag = {
		enable = true,
	},
})
