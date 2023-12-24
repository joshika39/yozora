local status, bl = pcall(require, 'bufferline')
if (not status) then return end

local sep_fg = '#340021'
local sep_bg = '#18001C'
local sel_sep_fg = sep_fg

local fg = '#FFE5A6'
local bg = sep_bg

local highlight_fg = '#FFB863'


bl.setup {
  options = {
    mode = 'tabs',
    separator_style = 'slope',
    always_show_bufferline = false,
    show_buffer_icons = true,
    show_buffer_close_icons = false,
    show_duplicate_prefix = false,
    show_close_icon = false,
    color_icons = true
  },
  highlights = {
    separator = {
      fg = sep_fg,
      bg = sep_bg
    },
    separator_selected = {
      fg = sel_sep_fg,
    },
    background = {
      fg = fg,
      bg = bg,
    },
    buffer_selected = {
      fg = highlight_fg,
      bold = true,
      italic = false
    },
    fill = {
      fg = sep_fg
    }
  }
}
