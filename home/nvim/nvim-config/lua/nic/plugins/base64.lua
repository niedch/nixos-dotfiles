return {
  "deponian/nvim-base64",
	event = { "BufReadPre", "BufNewFile" },
  version = "*",
  keys = {
    { "<leader>bd", "<Plug>(FromBase64)", mode = "x" },
    { "<leader>be", "<Plug>(ToBase64)", mode = "x" },
  },
  config = function()
    require("nvim-base64").setup()
  end,
}
