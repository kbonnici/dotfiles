local status, autopairs = pcall(require, "nvim-autopairs")

if not status then
	print("[Error]: nvim-autopairs not installed!")
	return
end

autopairs.setup({
	check_ts = true,
	ts_config = {
		-- lua = {'string'},-- it will not add a pair on that treesitter node
		-- javascript = {'template_string'},
		-- java = false,-- don't check treesitter on java
	},
})

local cmp_status, cmp = pcall(require, "cmp")

if not cmp_status then
	print("[Error]: nvim-cmp not installed!")
	return
end

local cmp_autopairs_status, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")

if not cmp_autopairs_status then
	print("[Error]: cmp_autopairs not installed!")
	return
end

-- insert `(` after selected function or method
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
