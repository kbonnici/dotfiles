local status, cmp = pcall(require, 'cmp')


if not status then
    print('[Error]: nvim-cmp not installed!')
    return
end

local kind_status, lspkind = pcall(require, "lspkind")

if not kind_status then
    print('[Error]: lspkind not installed!')
    return
end

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<C-j>'] = cmp.mapping.select_next_item(),
        ['<C-k>'] = cmp.mapping.select_prev_item(),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer" },
    },
    window = {
        completion = cmp.config.window.bordered({
            border = "rounded",
            col_offset = 0,
        })
    },
    formatting = {
        format = lspkind.cmp_format({
            maxwidth = math.floor(vim.api.nvim_win_get_width(0)/4),
            ellipsis_char = "...",
        })
    }
})
