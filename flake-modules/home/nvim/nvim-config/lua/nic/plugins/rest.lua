return {
	"rest-nvim/rest.nvim",
	ft = "http",
	cmd = { "Rest" },
	build = false,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"j-hui/fidget.nvim",
		"nvim-neotest/nvim-nio",
		{
			"manoelcampos/xml2lua",
			build = false,
			config = function(plugin)
				package.path = package.path .. ";" .. plugin.dir .. "/?.lua;" .. plugin.dir .. "/?/init.lua"
			end,
		},
		{
			"lunarmodules/lua-mimetypes",
			build = false,
			config = function(plugin)
				package.path = package.path .. ";" .. plugin.dir .. "/?.lua;" .. plugin.dir .. "/?/init.lua"
			end,
		},
	},
	keys = {
		{ "<leader>mh", "<cmd>Rest run<cr>", ft = "http", desc = "Run REST request under cursor" },
		{ "<leader>mi", "<cmd>Rest open<cr>", ft = "http", desc = "Open REST result pane" },
		{ "<leader>ml", "<cmd>Rest last<cr>", ft = "http", desc = "Run last REST request" },
		{ "<leader>rr", "<cmd>Rest run<cr>", ft = "http", desc = "Run REST request under cursor" },
		{ "<leader>ro", "<cmd>Rest open<cr>", ft = "http", desc = "Open REST result pane" },
		{ "<leader>rl", "<cmd>Rest last<cr>", ft = "http", desc = "Run last REST request" },
	},
	config = function()
		---@type rest.Opts
		vim.g.rest_nvim = {
			-- Custom options can be configured here if desired.
			-- Default options are used automatically.
		}
	end,
}
