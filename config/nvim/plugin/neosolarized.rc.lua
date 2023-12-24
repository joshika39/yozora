local status, n = pcall(require, 'neosolarized')
if (not status) then return end

n.setup({ comment_italics = true })

local cb = require('colorbuddy.init')
local Color = require('colorbuddy.init').Color
local colors = require('colorbuddy.init').colors
local Group = require('colorbuddy.init').Group
local groups = require('colorbuddy.init').groups
local styles = require('colorbuddy.init').styles

Color.new('black', '#000000')
Group.new('CursorLine', colors.none, colors.base03, styles.NONE, colors.base1)
Group.new('CursorLineNr', colors.yellow, colors.black, styles.NONE, colors.base1)
Group.new('Visual', colors.none, colors.base03, styles.reverse)
