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
    "SnacksPicker",
    "SnacksPickerBorder",
    "SnacksPickerBox",
    "SnacksPickerBoxBorder",
    "SnacksPickerList",
    "SnacksPickerListBorder",
    "SnacksPickerPreview",
    "SnacksPickerPreviewBorder",
    "SnacksPickerInput",
    "SnacksPickerInputBorder",

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
    local def = vim.api.nvim_get_hl(0, { name = hl, link = false })
    local updated = vim.tbl_extend("force", def, { bg = "none", ctermbg = "none" })
    vim.api.nvim_set_hl(0, hl, updated)
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
