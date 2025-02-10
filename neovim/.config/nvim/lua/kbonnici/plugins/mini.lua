return {
  "echasnovski/mini.nvim",
  version = "*",
  enabled = true,
  config = function()
    require("mini.icons").setup()
    require("mini.git").setup()
    require("mini.diff").setup()
    -- require("mini.statusline").setup({
    --
    --   content = {
    --     active = function()
    --       local MiniStatusline = require("mini.statusline")
    --
    --       local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
    --       local git = MiniStatusline.section_git({ trunc_width = 40 })
    --       local diff = MiniStatusline.section_diff({ trunc_width = 75 })
    --       local diagnostics = MiniStatusline.section_diagnostics({
    --         trunc_width = 75,
    --         icon = "",
    --         signs = {
    --           ERROR = "%#ErrorMsg# ",
    --           WARN = "%#WarningMsg# ",
    --           INFO = "%#Title# ",
    --           HINT = "%#@lsp.type.operator# ",
    --         },
    --       })
    --       -- local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
    --       local filename = "%f %m"
    --       local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
    --       local location = "%P %l:%c"
    --       -- local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
    --
    --       local function highlight_text(params)
    --         if type(params) ~= "table" then
    --           error("Expected a table")
    --         end
    --
    --         return "%#" .. params.highlight .. "#" .. params.text .. "%#Normal#"
    --       end
    --
    --       local format_summary = function(data)
    --         local summary = vim.b[data.buf].minidiff_summary
    --         if not summary then
    --           vim.b[data.buf].minidiff_summary_string = ""
    --           return
    --         end
    --
    --         local t = {}
    --         if summary.add > 0 then
    --           table.insert(
    --             t,
    --             highlight_text({
    --               highlight = "MiniDiffSignAdd",
    --               text = "+" .. summary.add,
    --             })
    --           )
    --         end
    --         if summary.change > 0 then
    --           table.insert(
    --             t,
    --             highlight_text({
    --               highlight = "MiniDiffSignChange",
    --               text = "~" .. summary.change,
    --             })
    --           )
    --         end
    --         if summary.delete > 0 then
    --           table.insert(
    --             t,
    --             highlight_text({
    --               highlight = "MiniDiffSignDelete",
    --               text = "-" .. summary.delete,
    --             })
    --           )
    --         end
    --         vim.b[data.buf].minidiff_summary_string = table.concat(t, " ")
    --       end
    --       local au_opts = { pattern = "MiniDiffUpdated", callback = format_summary }
    --       vim.api.nvim_create_autocmd("User", au_opts)
    --
    --       local recording_reg = vim.fn.reg_recording()
    --       local recording = recording_reg == "" and "" or "recording @" .. recording_reg
    --
    --       return MiniStatusline.combine_groups({
    --         { hl = mode_hl,                  strings = { mode } },
    --         { hl = "MiniStatuslineDevinfo",  strings = { git } },
    --         { hl = "MiniStatuslineFilename", strings = { diff, diagnostics } },
    --         "%<", -- Mark general truncate point
    --         { hl = "MiniStatuslineFilename", strings = { filename } },
    --         "%=", -- End left alignment
    --         { hl = "WarningMsg",             strings = { recording } },
    --         { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
    --         { hl = mode_hl,                  strings = { location } },
    --       })
    --     end,
    --   },
    -- })
    require("mini.ai").setup()
  end,
}
