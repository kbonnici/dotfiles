local color = "catppuccin"

local ok, _ = pcall(vim.cmd.colorscheme, color)
if not ok then
  vim.cmd.colorscheme("default")
end

-- transparent background
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
--vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
--vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { bg = "none" })
--vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
--vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
--vim.api.nvim_set_hl(0, "TroubleNormal", { bg = "none" })
--vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
--vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
--vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
