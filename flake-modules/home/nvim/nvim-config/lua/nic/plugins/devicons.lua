return {
	{
		"nvim-tree/nvim-web-devicons",
		opts = {
			color_icons = false,
		},
		config = function(_, opts)
			local devicons = require("nvim-web-devicons")
			devicons.setup(opts)
			-- Keep the default glyph but tint it a neutral grey to match Koyanagi
			local d = devicons.get_default_icon()
			devicons.set_default_icon(d.icon, "#8A8A8A", d.cterm_color)
		end,
	},
}
