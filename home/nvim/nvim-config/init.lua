require("nic.core.options")
require("nic.core.keymaps")
require("nic.lazy")

vim.g.lazyvim_check_order = false

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })

-- Transparent Status Bar
vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'none' })
vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = 'none' }) -- for inactive windows
vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })

-- Transparent Symbol Bar / Top Bars
vim.api.nvim_set_hl(0, 'WinBar', { bg = 'none' })
vim.api.nvim_set_hl(0, 'WinBarNC', { bg = 'none' })
vim.api.nvim_set_hl(0, 'TabLine', { bg = 'none' })
vim.api.nvim_set_hl(0, 'TabLineFill', { bg = 'none' })
vim.api.nvim_set_hl(0, 'TabLineSel', { bg = 'none' })
