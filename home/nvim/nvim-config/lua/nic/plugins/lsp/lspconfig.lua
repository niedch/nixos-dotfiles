return {
	{
		"j-hui/fidget.nvim",
		opts = {
			-- options
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "antosha417/nvim-lsp-file-operations", config = true },
			{ "folke/neodev.nvim", opts = {} },
		},
		config = function()
			vim.lsp.config("cucumber_language_server", {
				root_markers = { "package.json" },
				settings = {
					cucumber = {
						features = { "**/*.feature" },
						glue = { "**/steps/**/*.js", "**/steps/**/*.ts", "*/e2e/steps/**/*.ts", "**/e2e/*.go" },
					},
				},
			})

			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "✘",
						[vim.diagnostic.severity.WARN] = "▲",
						[vim.diagnostic.severity.HINT] = "⚑",
						[vim.diagnostic.severity.INFO] = "»",
					},
				},
				virtual_text = true,
			})

			-- vim.api.nvim_create_autocmd("LspAttach", {
			-- 	desc = "Enable inlay hints",
			-- 	callback = function(event)
			-- 		local id = vim.tbl_get(event, "data", "client_id")
			-- 		local client = id and vim.lsp.get_client_by_id(id)
			-- 		if client == nil or not client.supports_method("textDocument/inlayHint") then
			-- 			return
			-- 		end
			--
			-- 		vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
			-- 	end,
			-- })

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(event)
					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client then
						client.server_capabilities.semanticTokensProvider = nil
					end
				end,
			})
		end,
	},
}
