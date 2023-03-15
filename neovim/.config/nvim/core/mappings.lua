-- leader key
vim.g.mapleader = " "

local map = vim.keymap.set

-- move selected text up and down
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- keep cursor at current location when appending line below
map("n", "J", "mzJ`z")

-- keep cursor in the center of the screen
-- when jumping half-pages
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- keep search terms in the middle of the screen
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- keep yanked text when pasting
map("x", "<leader>p", "\"_dP")

-- yank to system clipboard
map("n", "<leader>y", "\"+y")
map("v", "<leader>y", "\"+y")
map("n", "<leader>Y", "\"+Y")

-- delete into void register
map("n", "<leader>d", "\"_d")
map("v", "<leader>d", "\"_d")

-- remove Q mapping (can remap to something later?)
map("n", "Q", "<nop>")
