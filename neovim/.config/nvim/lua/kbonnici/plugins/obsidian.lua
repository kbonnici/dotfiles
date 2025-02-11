return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	-- event = {
	--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
	--   -- refer to `:h file-pattern` for more examples
	--   "BufReadPre path/to/my-vault/*.md",
	--   "BufNewFile path/to/my-vault/*.md",
	-- },
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",
	},
	opts = {
		workspaces = {
			{
				name = "personal",
				path = "~/Obsidian Vault/",
			},
			{
				name = "no-vault",
				path = function()
					-- alternatively use the CWD:
					-- return assert(vim.fn.getcwd())
					return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
				end,
				overrides = {
					notes_subdir = vim.NIL, -- have to use 'vim.NIL' instead of 'nil'
					new_notes_location = "current_dir",
					templates = {
						folder = vim.NIL,
					},
					disable_frontmatter = true,
				},
			},
		},
		daily_notes = {
			-- Optional, if you keep daily notes in a separate directory.
			folder = "1-dailies",
			-- Optional, if you want to change the date format for the ID of daily notes.
			date_format = "%d-%m-%Y",
			-- Optional, if you want to change the date format of the default alias of daily notes.
			alias_format = "%B %-d, %Y",
			-- Optional, default tags to add to each new daily note created.
			default_tags = { "daily" },
			-- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
			template = "Daily Note",
		},
		--
		-- Optional, for templates (see below).
		templates = {
			folder = "Templates",
			date_format = "%d-%m-%Y",
			time_format = "%H:%M",
			-- A map for custom variables, the key should be the variable and the value a function
			substitutions = {},
		},

		new_notes_location = "current_dir",

		mappings = {
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
			["<leader>ch"] = {
				action = function()
					return require("obsidian").util.toggle_checkbox()
				end,
				opts = { buffer = true },
			},
			-- either follow link or toggle checkbox.
			["<cr>"] = {
				action = function()
					return require("obsidian").util.smart_action()
				end,
				opts = { buffer = true, expr = true },
			},
			["<leader>ot"] = {
				action = function()
					return "<cmd>ObsidianToday<cr>"
				end,
				opts = { buffer = true, expr = true },
			},
			["<leader>of"] = {
				action = function()
					return "<cmd>ObsidianTomorrow<cr>"
				end,
				opts = { buffer = true, expr = true },
			},
			["<leader>ob"] = {
				action = function()
					return "<cmd>ObsidianBacklinks<cr>"
				end,
				opts = { buffer = true, expr = true },
			},
			["<leader>og"] = {
				action = function()
					return "<cmd>ObsidianTags<cr>"
				end,
				opts = { buffer = true, expr = true },
			},
			["<leader>oy"] = {
				action = function()
					return "<cmd>ObsidianYesterday<cr>"
				end,
				opts = { buffer = true, expr = true },
			},
			["<leader>on"] = {
				action = function()
					return "<cmd>ObsidianNew<cr>"
				end,
				opts = { buffer = true, expr = true },
			},
			["<leader>od"] = {
				action = function()
					return "<cmd>ObsidianDailies<cr>"
				end,
				opts = { buffer = true, expr = true },
			},
			["<leader>oo"] = {
				action = function()
					return "<cmd>ObsidianOpen<cr>"
				end,
				opts = { buffer = true, expr = true },
			},
			["<leader>fg"] = {
				action = function()
					return "<cmd>ObsidianSearch<cr>"
				end,
				opts = { buffer = true, expr = true },
			},
			["<leader>oi"] = {
				action = function()
					return "<cmd>ObsidianPasteImg<cr>"
				end,
				opts = { buffer = true, expr = true },
			},
			["<leader>oc"] = {
				action = function()
					return "<cmd>ObsidianTOC<cr>"
				end,
				opts = { buffer = true, expr = true },
			},
			["<leader>oT"] = {
				action = function()
					return "<cmd>ObsidianNewFromTemplate<cr>"
				end,
				opts = { buffer = true, expr = true },
			},
			["<C-p>"] = {
				action = function()
					return "<cmd>ObsidianQuickSwitch<cr>"
				end,
				opts = { buffer = true, expr = true },
			},
		},
		ui = {
			enable = true, -- set to false to disable all additional syntax features
			update_debounce = 200, -- update delay after a text change (in milliseconds)
			max_file_length = 5000, -- disable UI features for files with more than this many lines
			-- Define how various check-boxes are displayed
			checkboxes = {
				-- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
				-- [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
				-- [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
				-- [">"] = { char = "", hl_group = "ObsidianRightArrow" },
				-- ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
				-- ["x"] = { char = "", hl_group = "ObsidianDone" },
				-- ["!"] = { char = "", hl_group = "ObsidianImportant" },
				-- Replace the above with this if you don't have a patched font:
				-- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
				-- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

				-- You can also add more custom ones...
			},
			-- Use bullet marks for non-checkbox lists.
			-- bullets = { char = "•", hl_group = "ObsidianBullet" },
			bullets = { char = "", hl_group = "" },
			external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
			-- Replace the above with this if you don't have a patched font:
			-- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
			reference_text = { hl_group = "ObsidianRefText" },
			highlight_text = { hl_group = "ObsidianHighlightText" },
			tags = { hl_group = "ObsidianTag" },
			block_ids = { hl_group = "ObsidianBlockID" },
			hl_groups = {
				-- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
				ObsidianTodo = { bold = true, fg = "#f78c6c" },
				ObsidianDone = { bold = true, fg = "#89ddff" },
				ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
				ObsidianTilde = { bold = true, fg = "#ff5370" },
				ObsidianImportant = { bold = true, fg = "#d73128" },
				ObsidianBullet = { bold = true, fg = "#89ddff" },
				ObsidianRefText = { underline = true, fg = "#c792ea" },
				ObsidianExtLinkIcon = { fg = "#c792ea" },
				ObsidianTag = { italic = true, fg = "#89ddff" },
				ObsidianBlockID = { italic = true, fg = "#89ddff" },
				ObsidianHighlightText = { bg = "#75662e" },
			},
		},

		-- Optional, customize how note IDs are generated given an optional title.
		---@param title string|?
		---@return string
		note_id_func = function(title)
			-- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
			-- In this case a note with the title 'My new note' will be given an ID that looks
			-- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
			local suffix = ""
			if title ~= nil then
				-- If title is given, transform it into valid file name.
				suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
			else
				-- If title is nil, just add 4 random uppercase letters to the suffix.
				for _ = 1, 4 do
					suffix = suffix .. string.char(math.random(65, 90))
				end
			end
			return tostring(os.time()) .. "-" .. suffix
		end,
	},
}
