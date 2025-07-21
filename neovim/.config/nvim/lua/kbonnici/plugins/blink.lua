return {
	"saghen/blink.cmp",
	enabled = function()
		return not vim.tbl_contains({ "typr", "markdown" }, vim.bo.filetype)
	end,
	-- optional: provides snippets for the snippet source
	dependencies = {
		"rafamadriz/friendly-snippets",
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			build = "make install_jsregexp",
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},
		"Kaiser-Yang/blink-cmp-avante",
	},
	-- use a release tag to download pre-built binaries
	version = "*",
	---@module 'blink.cmp'
	---@diagnostic disable-next-line: undefined-doc-name
	---@type blink.cmp.Config
	opts = {
		keymap = {
			preset = "default",

			["<C-p>"] = { "select_prev", "show", "fallback" },
			["<C-n>"] = { "select_next", "show", "fallback" },
		},

		snippets = { preset = "luasnip" },
		sources = {
			default = { "avante", "lsp", "path", "snippets", "buffer" },
			providers = {
				avante = {
					module = "blink-cmp-avante",
					name = "Avante",
					opts = {
						-- options for blink-cmp-avante
					},
				},
			},
		},

		completion = {
			menu = {
				border = "rounded",
				scrollbar = false,
			},
			documentation = {
				auto_show = true,
				window = {
					border = "rounded",
				},
			},
		},
	},
}
