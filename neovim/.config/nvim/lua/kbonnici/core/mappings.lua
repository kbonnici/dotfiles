-- leader key
vim.g.mapleader = " "

local map = function(mode, mapping, target, options)
  local opts = options or { silent = true, noremap = true }
  vim.keymap.set(mode, mapping, target, opts)
end

-- move selected text up and down
map("v", "K", ":m '<-2<CR>gv=gv")
map("v", "J", ":m '>+1<CR>gv=gv")

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
map("n", "<leader>sh", "<C-w>s")     -- horizontal split
map("n", "<leader>sv", "<C-w>v")     -- vertical split
map("n", "<leader>se", "<C-w>=")     -- set splits to equal width
map("n", "<leader>sx", ":close<CR>") -- close current split
--
-- move between splits easily
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, opts)
    -- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<space>la", vim.lsp.buf.code_action, opts)
    -- since some LSP's don't implement declaration, use definition as a fallback
    vim.keymap.set("n", "gD", function()
      local result = vim.lsp.buf.declaration()
      if not result then
        vim.lsp.buf.definition()
      end
    end, opts)

    -- local ok, trouble = pcall(require, "trouble")
    -- if not ok then
    --   vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    -- else
    --   vim.keymap.set("n", "gr", function()
    --     trouble.toggle("lsp_references")
    --   end, opts)
    -- end
  end,
})
