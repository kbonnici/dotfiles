local status, lsp_saga = pcall(require, 'lspsaga')
if not status then
    print('[Error]: Lspsaga not installed!')
    return
end
lsp_saga.setup({
    move_in_saga = { prev = "<C-k>", next = "<C-j>" },

    finder_action_keys = {
        open = "<cr>",
    },

    definition_action_keys = {
        edit = "<cr>",
    },

    ui = {
        title = true, -- neovim v0.9+ only
        border = "rounded", -- ["single", "double", "rounded", "solid", "shadow"]
    },

    symbol_in_winbar = {
        enable = true,
        show_file = true,
        hide_keyword = false,
        separator = " > ",
    }
})

