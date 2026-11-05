-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Set tab and indentation width
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.g.autoformat = false

-- Change this one line to enable physical-QWERTY commands for Colemak/Georgian.
vim.g.physical_qwerty_keys = false

if vim.g.physical_qwerty_keys then
  require("config.keyboard_layout").setup()
else
  vim.opt.langmap = ""
end

-- Horizontal scrolling (wrap is off): scroll one column at a time instead of
-- jumping half a screen when the cursor (plus inlay hints) passes the right edge.
vim.opt.sidescroll = 1
