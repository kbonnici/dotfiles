local status, typescript = pcall(require, 'typescript')

if not status then
    print('[Error]: typescript.nvim not installed!')
    return
end

typescript.setup({
    disable_commands = true, -- prevent the plugin from creating Vim commands
    go_to_source_definition = {
        fallback = true, -- fall back to standard LSP definition on failure
    },
})
