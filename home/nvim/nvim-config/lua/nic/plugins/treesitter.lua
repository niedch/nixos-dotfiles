return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"windwp/nvim-ts-autotag",
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				branch = "main",
				init = function()
					vim.g.no_plugin_maps = true
				end,
			},
		},
		config = function()
			require("nvim-treesitter").setup({
				auto_install = true,
				-- autotag is typically provided by nvim-ts-autotag plugin which still hooks in here,
				-- but since it's an external plugin we can leave it.
			})

			-- Native Neovim 0.10+ treesitter syntax highlighting & folding
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local success = pcall(vim.treesitter.start)
					if success then
						-- Native Neovim treesitter indentation
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

						-- Preserve legacy regex syntax for Markdown as originally configured
						if vim.bo[args.buf].filetype == "markdown" then
							vim.bo[args.buf].syntax = "ON"
						end
					end
				end,
			})

			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
				},
			})

			local ts_select = require("nvim-treesitter-textobjects.select")
			local keymaps = {
				["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
				["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
				["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
				["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },

				["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
				["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },

				["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
				["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

				["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
				["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

				["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
				["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },

				["am"] = { query = "@function.outer", desc = "Select outer part of a method/function definition" },
				["im"] = { query = "@function.inner", desc = "Select inner part of a method/function definition" },

				["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
				["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
			}

			for key, mapping in pairs(keymaps) do
				vim.keymap.set({ "x", "o" }, key, function()
					ts_select.select_textobject(mapping.query, "textobjects")
				end, { desc = mapping.desc })
			end
		end,
	},
}

