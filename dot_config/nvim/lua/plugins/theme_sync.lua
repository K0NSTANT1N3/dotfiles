-- lua/plugins/theme_sync.lua
-- Make Neovim use the same theme name as wezterm (~/.config/wezterm/current_theme)
return {
    {
        "LazyVim/LazyVim",
        opts = function(_, opts)
            local wezterm_theme_file = vim.fn.expand("~/.config/wezterm/current_theme")
            local theme_name

            local f = io.open(wezterm_theme_file, "r")
            if f then
                theme_name = f:read("*l")
                f:close()
            end

            local map = {
                nightfly = "nightfly",
                groovbox = "gruvbox", -- your shell script uses "groovbox"
                nightshift = "tokyonight",
                groovbuddy = "gruvbox-material",
            }

            opts.colorscheme = map[theme_name] or "tokyonight"
        end,
    },
}
