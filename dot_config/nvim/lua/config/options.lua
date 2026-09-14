-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Set tab and indentation width
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.g.autoformat = false

-- Keep Vim commands on their physical QWERTY positions while typing with
-- Colemak or Georgian. This also follows XKB layout changes on X11.
require("config.keyboard_layout").setup()
