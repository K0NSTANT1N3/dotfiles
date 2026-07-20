-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
-- Always-on transparency for Neovim, regardless of colorscheme
local transparent_group = vim.api.nvim_create_augroup("MyTransparentBG", { clear = true })

local function apply_transparency()
    local groups = {
        "Normal",
        "NormalNC",
        "NormalFloat",
        "SignColumn",
        "LineNr",
        "FoldColumn",
        "EndOfBuffer",
        "StatusLine",
        "StatusLineNC",
        "TabLine",
        "TabLineFill",
        "TabLineSel",
    }
    for _, hl in ipairs(groups) do
        vim.api.nvim_set_hl(0, hl, { bg = "none" })
    end
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group = transparent_group,
    callback = apply_transparency,
})

apply_transparency()
