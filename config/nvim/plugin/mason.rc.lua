local status, mason = pcall(require, 'mason')
if (not status) then return end

local lspstatus, lspconfig = pcall(require, 'mason-lspconfig')
if (not lspstatus) then return end

mason.setup {}

lspconfig.setup {
  ensure_installed = { 'tailwindcss', 'tsserver', 'eslint', 'html', 'cssls' }
}

require 'lspconfig'.tailwindcss.setup {}
require 'lspconfig'.tsserver.setup {}
