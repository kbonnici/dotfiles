local status, lsp = pcall(require, 'lsp-zero')
if not status then
    print('[Error]: LSP-Zero not installed!')
    return
end

lsp.preset('recommended')

lsp.ensure_installed({
	'tsserver',
	'lua_ls',
	'eslint',
	'rust_analyzer',
})

lsp.on_attach(function(_, bufnr) -- (client, bufnr)
	local opts = {buffer = bufnr, remap = false}
	local map = vim.keymap.set

    map("n", "gd", 		    function() vim.lsp.buf.definition() end, opts)
    map("n", "K", 		    function() vim.lsp.buf.hover() end, opts)
    map("n", "<leader>la", 	function() vim.lsp.buf.code_action() end, opts)
    map("n", "<leader>lr", 	function() vim.lsp.buf.references() end, opts)
    map("n", "<leader>sr", 	function() vim.lsp.buf.rename() end, opts)
    map("i", "<C-h>", 		function() vim.lsp.buf.signature_help() end, opts)

    map("n", "gl", 		    function() vim.diagnostic.open_float() end, opts)
    map("n", "<leader>gn", 	function() vim.diagnostic.goto_next() end, opts)
    map("n", "<leader>gp", 	function() vim.diagnostic.goto_prev() end, opts)
    map("n", "gl", 		    function() vim.diagnostic.open_float() end, opts)
    map("n", "gl", 		    function() vim.diagnostic.open_float() end, opts)

end)

-- enable vim global variable in lua
lsp.nvim_workspace()

lsp.setup()
