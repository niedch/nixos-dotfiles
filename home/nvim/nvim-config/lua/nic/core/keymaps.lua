vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "J", "mzJ`z")

-- Navigate vim panes better
vim.keymap.set("n", "<c-k>", "<cmd>silent wincmd k<CR>")
vim.keymap.set("n", "<c-j>", "<cmd>silent wincmd j<CR>")
vim.keymap.set("n", "<c-h>", "<cmd>silent wincmd h<CR>")
vim.keymap.set("n", "<c-l>", "<cmd>silent wincmd l<CR>")

-- Move selection in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Stay in visual mode when indenting
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Jump to previous/next item in quickfix/location list
vim.keymap.set('n', '<leader>k', '<cmd>lprev<cr>zz', { desc = 'Previous item in location list' })
vim.keymap.set('n', '<leader>j', '<cmd>lnext<cr>zz', { desc = 'Next item in location list' })

vim.keymap.set('n', '<leader>k', '<cmd>cprev<cr>zz', { desc = 'Previous item in qfixlist' })
vim.keymap.set('n', '<leader>j', '<cmd>cnext<cr>zz', { desc = 'Next item in qfixlist' })

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Save to clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("v", "<leader>64", "y:let @0=system('base64', @0)<cr>gvP")
vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "q:", "<nop>")
vim.keymap.set("n", "<leader>Q", "<cmd>silent qa!<CR>")

vim.keymap.set("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader>db", "<cmd>:tabnew<CR><cmd>:DBUI<CR>")

vim.keymap.set("n", "<C-w>z", "<cmd>silent :tabnew %<CR>")

-- Must use LazyVimKeymaps autocmd to override LazyVim's default <leader>bb (switch buffer)
-- because LazyVim.safe_keymap_set defers mappings to run after user config, always overwriting
-- any earlier vim.keymap.set for the same key. Hooking into LazyVimKeymaps ensures this runs after.
vim.api.nvim_create_autocmd("User", { pattern = "LazyVimKeymaps", once = true, callback = function()
  vim.keymap.set("n", "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>")
end })
vim.keymap.set("n", "<leader>bc", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>")
vim.keymap.set("n", "<leader>bl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>")
vim.keymap.set("n", '<leader>br', "<cmd>lua require'dap'.clear_breakpoints()<cr>")
vim.keymap.set("n", '<leader>ba', '<cmd>Telescope dap list_breakpoints<cr>')
vim.keymap.set("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>")
vim.keymap.set("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>")
vim.keymap.set("n", "<leader>dk", "<cmd>lua require'dap'.step_into()<cr>")
vim.keymap.set("n", "<leader>do", "<cmd>lua require'dap'.step_out()<cr>")
vim.keymap.set("n", '<leader>dd', function() require('dap').disconnect(); require('dapui').close(); end)
vim.keymap.set("n", '<leader>dt', function() require('dap').terminate(); require('dapui').close(); end)
vim.keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>")
vim.keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>")
vim.keymap.set("n", '<leader>di', function() require "dap.ui.widgets".hover() end)
vim.keymap.set("n", '<leader>d?', function() local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes) end)
