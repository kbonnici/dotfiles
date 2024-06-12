return {
	"lewis6991/gitsigns.nvim",
	lazy = true,
	event = "VeryLazy",
	config = function()
		require("gitsigns").setup({
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				local ok, ts_repeat_move = pcall(require, "nvim-treesitter.textobjects.repeatable_move")
				local next_hunk_repeat, prev_hunk_repeat = nil, nil
				if ok then
					next_hunk_repeat, prev_hunk_repeat =
						ts_repeat_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
				end

				-- Navigation
				map({ "n", "x", "o" }, "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						if not next_hunk_repeat then
							gs.next_hunk()
						else
							next_hunk_repeat()
						end
					end)
					return "<Ignore>"
				end, { expr = true })

				map({ "n", "x", "o" }, "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						if not prev_hunk_repeat then
							gs.prev_hunk()
						else
							prev_hunk_repeat()
						end
					end)
					return "<Ignore>"
				end, { expr = true })

				-- Actions
				map("n", "<leader>hl", function()
					gs.toggle_linehl()
					gs.toggle_numhl()
				end)
				map("n", "<leader>hq", gs.setqflist)
				map("n", "<leader>hs", gs.stage_hunk)
				map("n", "<leader>hr", gs.reset_hunk)
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end)
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end)
				map("n", "<leader>hS", gs.stage_buffer)
				map("n", "<leader>hu", gs.undo_stage_hunk)
				map("n", "<leader>hR", gs.reset_buffer)
				map("n", "<leader>hp", gs.preview_hunk)
				map("n", "<leader>hB", function()
					gs.blame_line({ full = true })
				end)
				map("n", "<leader>hb", gs.toggle_current_line_blame)
				map("n", "<leader>hd", gs.diffthis)
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end)
				map("n", "<leader>td", gs.toggle_deleted)

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
			end,
		})
	end,
}
