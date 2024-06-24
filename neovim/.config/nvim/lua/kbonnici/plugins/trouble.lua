return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
	config = function()
		local trouble = require("trouble")

		local trouble_map = function(mapping, mode)
			vim.keymap.set("n", mapping, function()
				trouble.toggle({ mode = mode, focus = true })
			end)
		end

		trouble_map("<leader>xx", "diagnostics")
		trouble_map("<leader>xs", "lsp_document_symbols")
		trouble_map("<leader>xl", "lsp")
	end,
}
