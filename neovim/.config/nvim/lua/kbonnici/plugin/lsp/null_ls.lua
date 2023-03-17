local status, null_ls = pcall(require, "null-ls")

if not status then
	print("[Error]: null-ls not installed!")
	return
end

local mason_null_ls_status, mason_null_ls = pcall(require, "mason-null-ls")

if not mason_null_ls_status then
	print("[Error]: mason-null-ls not installed!")
	return
end

local automatic_setup = true
mason_null_ls.setup({
	ensure_installed = {
		"eslint_d",
		"prettierd",
		"stylua",
	},
	automatic_installation = false,
	automatic_setup = automatic_setup, -- Recommended, but optional
})

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local lsp_formatting = function(bufnr)
	vim.lsp.buf.format({
		filter = function(client)
			-- apply whatever logic you want (in this example, we'll only use null-ls)
			return client.name == "null-ls"
		end,
		bufnr = bufnr,
	})
end

local ts_nvim_status, ts_nvim = pcall(require, "typescript")

if not ts_nvim_status then
	print("[Error]: typescript_nvim not installed!")
	return
end

null_ls.setup({
	sources = {
		diagnostics.eslint_d,
		formatting.prettierd,
		formatting.stylua,
		ts_nvim.extentions["null-ls"]["code-actions"],
	},
	-- format on save
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					lsp_formatting(bufnr)
				end,
			})
		end
	end,
})

if automatic_setup then
	mason_null_ls.setup_handlers()
end
