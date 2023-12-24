local status, ts = pcall(require, 'nvim-treesitter.configs')
if (not status) then return end

ts.setup {
  highlight = {
    enable = true,
    disable = {}
  },
  indent = {
    enable = true,
    disable = {}
  },
  ensure_installed = {
    'tsx',
    'json',
    'css',
    'lua',
    'javascript',
    'c',
    'markdown',
    'markdown_inline'
  },
  autotag = {
    enable = true
  },
  auto_install = true,
  sync_install = false,
}
