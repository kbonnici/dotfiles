local status, catppuccin = pcall(require, "catppuccin")

if not status then
    print("[Error]: catppuccin not installed!")
    return
end

catppuccin.setup({
    transparent_background = true
})
