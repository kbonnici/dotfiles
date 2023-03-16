local status, cmp = pcall(require, 'cmp')


if not status then
    print('[Error]: nvim-cmp not installed!')
    return
end


cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<C-j>'] = cmp.mapping.select_next_item(),
        ['<C-k>'] = cmp.mapping.select_prev_item(),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
    }),

    window = {
        completion = cmp.config.window.bordered({
            border = "rounded",
            col_offset = 0,
        })
    },
    formatting = {
        format = function(_, vim_item)
            local function trim(text)
                local max = math.floor(vim.api.nvim_win_get_width(0) / 4)

                if text and text:len() > max then
                    text = text:sub(1, max) .. "..."
                end

                return text
            end

            vim_item.abbr = trim(vim_item.abbr)
            return vim_item
        end
    }
})
