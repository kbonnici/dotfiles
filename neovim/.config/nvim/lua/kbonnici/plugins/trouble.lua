return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
	},
	config = function()
		local trouble = require("trouble")
		vim.keymap.set("n", "<leader>tt", function()
			trouble.toggle()
		end)
		vim.keymap.set("n", "<leader>tn", function()
			local hasNext = trouble.next({ skip_groups = true, jump = true })
			if not hasNext then
				print("[Trouble]: Nothing left to jump to.")
			end
		end)
		vim.keymap.set("n", "<leader>tp", function()
			local hasPrev = trouble.previous({ skip_groups = true, jump = true })
			if not hasPrev then
				print("[Trouble]: Nothing left to jump to.")
			end
		end)
		--		vim.keymap.set("n", "<leader>xw", function()
		--            print("Showing Workspace Diagnostics")
		--			trouble.toggle("workspace_diagnostics")
		--		end)
		--		vim.keymap.set("n", "<leader>xd", function()
		--            print("Showing Doc Diagnostics")
		--			trouble.toggle("document_diagnostics")
		--		end)
		--		vim.keymap.set("n", "<leader>xq", function()
		--            print("Showing Quickfix List")
		--			trouble.toggle("quickfix")
		--		end)
		--		vim.keymap.set("n", "<leader>xl", function()
		--            print("Showing Location List")
		--			trouble.toggle("loclist")
		--		end)
		vim.keymap.set("n", "gR", function()
			print("Show References")
			trouble.toggle("lsp_references")
		end)
	end,
}
