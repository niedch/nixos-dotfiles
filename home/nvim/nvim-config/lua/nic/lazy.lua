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

local plugins = { { import = "nic.plugins" }, { import = "nic.plugins.lsp" } }

local theme_file = vim.fn.expand("~/.local/share/themes/current/neovim.lua")
if vim.loop.fs_stat(theme_file) then
	vim.list_extend(plugins, dofile(theme_file))
end

require("lazy").setup(plugins, {
	lockfile = vim.fn.expand("~/Projects/nixos-dotfiles/home/nvim/nvim-config/lazy-lock.json"),
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
