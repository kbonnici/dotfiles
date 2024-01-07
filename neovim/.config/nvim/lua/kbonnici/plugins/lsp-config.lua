return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "tsserver", "html", "cssls" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")

			require("mason-lspconfig").setup_handlers({
				-- default handler
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
					})
				end,
				-- Handlers for specific servers
				["lua_ls"] = function()
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								workspace = {
									library = {
										vim.env.VIMRUNTIME .. "/lua",
									},
								},
							},
						},
					})
				end,
			})

			vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format)
			vim.api.nvim_create_autocmd("BufWritePost", {
				callback = function()
					-- only format if an lsp is attached
					if next(vim.lsp.get_clients()) ~= nil then
						vim.lsp.buf.format()
					end
				end,
			})
		end,
	},
}
