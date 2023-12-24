local status, gs = pcall(require, 'gitsigns')
if (not status) then return end

gs.setup {}
