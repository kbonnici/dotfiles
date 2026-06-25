-- Add mason bin to PATH so LSP servers can be found
vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"

if vim.g.vscode then
  local vscode = require("vscode-neovim")
  if vscode then
    require("kbonnici.core.vscode-mappings")
  end
else
  -- ordinary neovim
  vim.loader.enable()
  require("kbonnici.core")
  require("kbonnici")
  require("kbonnici.core.colorscheme")
end
