return {
	"williamboman/mason.nvim",

	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			automatic_installation = true,
			automatic_enable = {
				exclude = {
					"jdtls",
				},
			},
			ensure_installed = {
				"html",
				"cssls",
				"sqlls",
				"cucumber_language_server",
				"lua_ls",
				"gopls",
				"jdtls",
				"vtsls",
				"zls",
				"buf_ls",
				"rust_analyzer",
				"yamlls",
				"nil_ls",
        "basedpyright"
			},
		})

		mason_tool_installer.setup({
			automatic_installation = true,
			ensure_installed = {
				"stylua",
				"eslint_d",
				"xmlformatter",
				"java-debug-adapter",
				"java-test",
				"js-debug-adapter",
			},
		})
	end,
}
