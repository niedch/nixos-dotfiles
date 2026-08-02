local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.g.has_lsp = vim.loop.fs_stat(vim.fn.expand("$HOME/.config/nvim-lsp-enabled")) ~= nil

local plugins = { { import = "nic.plugins" } }
if vim.g.has_lsp then
	table.insert(plugins, { import = "nic.plugins.lsp" })
end

local theme_file = vim.fn.expand("~/.local/share/themes/current/neovim.lua")
if vim.loop.fs_stat(theme_file) then
	vim.list_extend(plugins, dofile(theme_file))
end

require("lazy").setup(plugins, {
	lockfile = (vim.env.NVIM_CONFIG or vim.fn.stdpath("config")) .. "/lazy-lock.json",
	change_detection = {
		notify = false,
	},
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
