vim.g.mapleader = " "
vim.g.background = "light"

vim.opt.swapfile = false

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

-- Fake tell vim the netrw is already loaded
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1
vim.g.loaded_netrw_gitignore = 1

vim.opt.updatetime = 50
vim.opt.conceallevel = 1

vim.opt.colorcolumn = "120"
vim.wo.number = true
-- vim.opt.spelllang = "en_us"
-- vim.opt.spell = true

vim.filetype.add({
	extension = {
		["http"] = "http",
		["rest"] = "http",
		["zul"] = "xml",
		["jenkinsfile"] = "groovy",
	},
	pattern = {
		["Jenkinsfile.*"] = "groovy",
		["*.prompt"] = "markdown",
	},
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
