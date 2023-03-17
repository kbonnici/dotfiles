-- leader key
vim.g.mapleader = " "

local map = function(mode, mapping, target, options)
	local opts = options or {}
	vim.keymap.set(mode, mapping, target, opts)
end

local opts = { silent = true, noremap = true }

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
map("x", "<leader>p", '"_dP')

-- yank to system clipboard
map("n", "<leader>y", '"+y')
map("v", "<leader>y", '"+y')
map("n", "<leader>Y", '"+Y')

-- delete into void register
map("n", "<leader>d", '"_d')
map("v", "<leader>d", '"_d')

-- cut character into void register
map("n", "x", '"_x')

-- remove Q mapping (can remap to something later?)
map("n", "Q", "<nop>")

-- shortcut to save and quit
map("n", "<leader>q", ":q<CR>")
map("n", "<leader>w", ":w<CR>")

-- splits
map("n", "<leader>sh", "<C-w>s") -- horizontal split
map("n", "<leader>sv", "<C-w>v") -- vertical split
map("n", "<leader>se", "<C-w>=") -- set splits to equal width
map("n", "<leader>sx", ":close<CR>") -- close current split
-- move between splits easily
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- tabs
map("n", "<leader>to", ":tabnew<CR>") -- open new tab
map("n", "<leader>tx", ":tabclose<CR>") -- close current tab
map("n", "<leader>tn", ":tabn<CR>") -- next tab
map("n", "<leader>tp", ":tabp<CR>") -- prev tab

-- nvim-tree
map("n", "<leader>e", ":NvimTreeToggle<CR>")

-- telescope mappings
map("n", "<leader>ff", ":Telescope find_files<CR>")

-- trouble mappings
map("n", "<leader>xx", "<cmd>TroubleToggle<cr>", opts)
map("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", opts)
map("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", opts)
map("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", opts)
map("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", opts)
map("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", opts)
