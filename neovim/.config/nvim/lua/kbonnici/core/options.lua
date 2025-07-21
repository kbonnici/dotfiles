local opt = vim.opt

-- line numbers
opt.number = true
opt.relativenumber = true

-- disable changing cursor for different modes
-- opt.guicursor = ""

opt.cursorline = true

-- disable mode information in default statusline
opt.showmode = false

opt.laststatus = 3

local tabwidth = 2
-- tabs
opt.tabstop = tabwidth
opt.softtabstop = tabwidth
opt.shiftwidth = tabwidth
opt.expandtab = true

opt.smartindent = true

opt.wrap = false

opt.swapfile = false
opt.backup = false

opt.hlsearch = false
opt.incsearch = true

--opt.termguicolors = true

opt.scrolloff = 8
opt.signcolumn = "yes"
opt.isfname:append("@-@")

-- column to help detect long lines
-- opt.colorcolumn = "80"

opt.updatetime = 50
opt.conceallevel = 2
vim.diagnostic.config({ severity_sort = true })
