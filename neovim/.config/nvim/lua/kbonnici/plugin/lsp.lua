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

local function command(cmd)
    return ":" .. cmd .. "<cr>"
end

lsp.on_attach(function(_, bufnr) -- (client, bufnr)
	local opts = {buffer = bufnr, remap = false}
	local map = vim.keymap.set

    map("n", "gd", 		    command("Lspsaga peek_definition"), opts)
    map("n", "gi", 		    command("lua vim.lsp.buf.implementation()"), opts)
    map("n", "gf",          command("Lspsaga lsp_finder"), opts)
    map("n", "K", 		    command("Lspsaga hover_doc"), opts)
    map("n", "<leader>la", 	command("Lspsaga code_action"), opts)
    map("n", "<leader>lr", 	command("Lspsaga rename"), opts)

    map("n", "gl", 		    command("Lspsaga show_line_diagnostics"), opts)
    map("n", "gn", 	command("Lspsaga diagnostic_jump_next"), opts)
    map("n", "gp", 	command("Lspsaga diagnostic_jump_prev"), opts)

end)
-- enable vim global variable in lua
lsp.nvim_workspace()

lsp.setup()
