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
map("x", "<leader>p", '\"_dP')

-- yank to system clipboard
map("n", "<leader>y", '\"+y')
map("v", "<leader>y", '\"+y')
map("n", "<leader>Y", '\"+Y')

-- delete into void register
map("n", "<leader>d", '"_d')
map("v", "<leader>d", '"_d')

-- cut character into void register
map("n", "x", '"_x')

-- remove Q mapping (can remap to something later?)
map("n", "Q", "<nop>")

-- splits
map("n", "<leader>sh", "<C-w>s") -- horizontal split
map("n", "<leader>sv", "<C-w>v") -- vertical split
map("n", "<leader>se", "<C-w>=") -- set splits to equal width
map("n", "<leader>sx", ":close<CR>") -- close current split

-- tabs
map("n", "<leader>to", ":tabnew<CR>") -- open new tab
map("n", "<leader>tx", ":tabclose<CR>") -- close current tab
map("n", "<leader>tn", ":tabn<CR>") -- next tab
map("n", "<leader>tp", ":tabp<CR>") -- prev tab
