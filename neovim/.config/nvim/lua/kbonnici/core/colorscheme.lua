local colorscheme = "catppuccin-macchiato"
local status, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)

if not status then
    print("[Error]: " .. colorscheme .. " not installed!")
end
