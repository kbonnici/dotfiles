local status, nvim_tree = pcall(require, 'nvim-tree')

if not status then
    print("[Error]: Nvim-Tree not installed!")
    return
end

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

nvim_tree.setup({
    renderer = {
        icons = {
            glyphs = {
                folder = {
                    arrow_closed = " ▶",
                    arrow_open = " ▼",
                }
            }
        }
    },
    actions = {
        open_file = {
            window_picker = {
                enable = false
            }
        }
    }
})
