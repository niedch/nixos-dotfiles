-- Load the Omarchy theme's lazy.nvim plugin specs from an external file.
-- The file returns a LazySpec (a list of plugin tables) plus a "LazyVim/LazyVim"
-- entry whose `opts.colorscheme` is the colorscheme to apply. We drop that entry
-- (the LazyVim distro is not used in this setup) and apply the colorscheme ourselves.
local theme_path = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")

local function load_theme_specs()
  local ok, chunk = pcall(loadfile, theme_path)
  if not ok or type(chunk) ~= "function" then
    return {}
  end
  local ok2, specs = pcall(chunk)
  if not ok2 or type(specs) ~= "table" then
    return {}
  end

  local colorscheme = nil
  local plugins = {}
  for _, spec in ipairs(specs) do
    local id = type(spec) == "table" and (spec[1] or spec.name) or nil
    if type(id) == "string" and id:lower():match("^lazyvim") then
      local opts = type(spec.opts) == "function" and spec.opts() or spec.opts
      colorscheme = type(opts) == "table" and opts.colorscheme or colorscheme
    else
      spec.lazy = false
      spec.priority = spec.priority or 1000
      plugins[#plugins + 1] = spec
    end
  end

  if colorscheme then
    vim.api.nvim_create_autocmd("User", {
      group = vim.api.nvim_create_augroup("omarchy_theme", { clear = true }),
      pattern = "VeryLazy",
      once = true,
      callback = function()
        pcall(vim.cmd.colorscheme, colorscheme)
      end,
    })
  end

  return plugins
end

return {
  { name = "omarchy-theme", import = load_theme_specs },
}