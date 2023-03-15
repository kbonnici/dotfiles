local opt = vim.opt

-- line numbers
opt.number = true
opt.relativenumber = true

-- disable changing cursor for different modes
opt.guicursor = ""

-- tabs
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

opt.smartindent = true

opt.wrap = false

opt.swapfile = false
opt.backup = false

opt.hlsearch = false
opt.incsearch = true

opt.termguicolors = true

opt.scrolloff = 8
opt.signcolumn = "yes"
opt.isfname:append("@-@")

-- column to help detect long lines
-- opt.colorcolumn = "80"

opt.updatetime = 50
