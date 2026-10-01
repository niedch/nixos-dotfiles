local function set_transparency()
  local highlights = {
    -- Core editor windows and popups
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "Pmenu",
    "Terminal",
    "EndOfBuffer",
    "FoldColumn",
    "Folded",
    "SignColumn",

    -- Status bar, tabline, and winbar
    "StatusLine",
    "StatusLineNC",
    "WinBar",
    "WinBarNC",
    "TabLine",
    "TabLineFill",
    "TabLineSel",

    -- Floating plugins & pickers
    "WhichKeyFloat",
    "TelescopeNormal",
    "TelescopeBorder",
    "TelescopePromptBorder",
    "TelescopePromptTitle",

    -- Neo-tree
    "NeoTreeNormal",
    "NeoTreeNormalNC",
    "NeoTreeVertSplit",
    "NeoTreeWinSeparator",
    "NeoTreeEndOfBuffer",

    -- Nvim-tree
    "NvimTreeNormal",
    "NvimTreeVertSplit",
    "NvimTreeEndOfBuffer",
  }

  for _, hl in ipairs(highlights) do
    vim.api.nvim_set_hl(0, hl, { bg = "none" })
  end
end

local group = vim.api.nvim_create_augroup("TransparentBackground", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  pattern = "*",
  callback = set_transparency,
})

-- Execute once immediately so initial buffers have transparency
set_transparency()
