local icons = require("utils.icons")

yozora = {
  plugins = {
		ai = {
			chatgpt = {
				enabled = true,
			},
			codeium = {
				enabled = false,
			},
			copilot = {
				enabled = true,
			},
			tabnine = {
				enabled = false,
			},
		},
  },
  icons = icons,
  lsp = {
		virtual_text = true, -- show virtual text (errors, warnings, info) inline messages
	},
}
