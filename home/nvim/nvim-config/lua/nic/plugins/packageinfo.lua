return {
	"vuki656/package-info.nvim",
	config = function()
		require("package-info").setup()

		-- Toggle dependency versions
		vim.keymap.set({ "n" }, "<leader>nt", require("package-info").toggle)

		-- Update dependency on the line
		vim.keymap.set({ "n" }, "<leader>nu", require("package-info").update, { silent = true, noremap = true })

		-- Install a new dependency
		vim.keymap.set({ "n" }, "<leader>ni", require("package-info").install, { silent = true, noremap = true })

		-- Install a different dependency version
		vim.keymap.set({ "n" }, "<leader>np", require("package-info").change_version, { silent = true, noremap = true })
	end,
}
