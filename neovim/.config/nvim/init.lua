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
