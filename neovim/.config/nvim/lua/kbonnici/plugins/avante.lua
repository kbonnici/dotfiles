return {
	"yetone/avante.nvim",
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	-- ⚠️ must add this setting! ! !
	build = function()
		-- conditionally use the correct build system for the current OS
		if vim.fn.has("win32") == 1 then
			return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
		else
			return "make"
		end
	end,
	event = "VeryLazy",
	version = false, -- Never set this value to "*"! Never!
	---@module 'avante'
	---@type avante.Config
	opts = {
		-- add any opts here
		-- for example
		provider = "qwen_small",
		providers = {
			["qwen_small"] = {
				__inherited_from = "ollama",
				endpoint = "https://chat.kbonnici.com/ollama",
				model = "qwen3:14b",
				api_key_name = "AVANTE_OPEN_WEB_UI_API_KEY",
			},
			["qwen_large"] = {
				__inherited_from = "ollama",
				endpoint = "https://chat.kbonnici.com/ollama",
				model = "gemma3:27b",
				api_key_name = "AVANTE_OPEN_WEB_UI_API_KEY",
			},
		},

		selector = {
			provider = "snacks",
			provider_opts = {},
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
		"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
		"folke/snacks.nvim", -- for input provider snacks
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		{
			-- support for image pasting
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				-- recommended settings
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					-- required for Windows users
					use_absolute_path = true,
				},
			},
		},
		{
			-- Make sure to set this up properly if you have lazy=true
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
	input = {
		provider = "snacks",
		provider_opts = {
			-- Additional snacks.input options
			title = "Avante Input",
			icon = " ",
		},
	},
}
