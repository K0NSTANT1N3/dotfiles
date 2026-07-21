local wezterm = require("wezterm")

local config = {}

-- Font
config.font = wezterm.font_with_fallback({
	{ family = "FiraCode Nerd Font", weight = "Light" },
	"Noto Color Emoji",
})
config.font_size = 11
config.harfbuzz_features = { "calt=1", "liga=1" }

-- ===========================
-- Theme table
-- ===========================
local themes = {
	nightfly = {
		foreground = "#c0caf5",
		background = "#011627",
		cursor_bg = "#7fdbca",
		ansi = { "#011627", "#ef5350", "#22da6e", "#ffca3a", "#82aaff", "#c792ea", "#7fdbca", "#a7adba" },
		brights = { "#65737e", "#ef5350", "#22da6e", "#ffca3a", "#82aaff", "#c792ea", "#7fdbca", "#c0caf5" },
	},
	groovbox = {
		foreground = "#dcd7ba",
		background = "#282828",
		cursor_bg = "#ebdbb2",
		ansi = { "#282828", "#cc241d", "#98971a", "#d79921", "#458588", "#b16286", "#689d6a", "#a89984" },
		brights = { "#928374", "#fb4934", "#b8bb26", "#fabd2f", "#83a598", "#d3869b", "#8ec07c", "#ebdbb2" },
	},


	groovbuddy = {
	foreground = "#ebdbb2",
	background = "#14110e",  -- darker, warmer, almost-black brown
	cursor_bg  = "#ebdbb2",

	ansi = {
		"#14110e", -- black
		"#fb4934", -- red
		"#b8bb26", -- green
		"#fabd2f", -- yellow
		"#83a598", -- blue
		"#d3869b", -- magenta
		"#8ec07c", -- cyan
		"#ebdbb2", -- white
	},
	brights = {
		"#3c2f2a", -- bright black (key for zsh autosuggest visibility)
		"#fe8019", -- bright red/orange
		"#b8bb26",
		"#fabd2f",
		"#83a598",
		"#d3869b",
		"#8ec07c",
		"#fbf1c7",
	},
	},

	nightshift = {
		foreground = "#d0d0d0",
		background = "#0b0f1a",
		cursor_bg = "#5fb3b3",
		ansi = { "#0b0f1a", "#ff6c6b", "#98be65", "#ecbe7b", "#51afef", "#c678dd", "#46d9ff", "#dfdfdf" },
		brights = { "#5b6268", "#ff6c6b", "#98be65", "#ecbe7b", "#51afef", "#c678dd", "#46d9ff", "#ffffff" },
	},
}

-- read theme from file
local theme_file = os.getenv("HOME") .. "/.config/wezterm/current_theme"
local theme_name = nil
local f = io.open(theme_file, "r")
if f then
	theme_name = f:read("*l")
	f:close()
end

if theme_name and themes[theme_name] then
	local t = themes[theme_name]
	config.colors = {
		foreground = t.foreground,
		background = t.background,
		cursor_bg = t.cursor_bg,
		ansi = t.ansi,
		brights = t.brights,
	}
end

-- Window
config.window_background_opacity = 0.96
config.text_background_opacity = 1
config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.initial_cols = 70
config.initial_rows = 22
config.window_decorations = "INTEGRATED_BUTTONS"

-- Cursor
config.default_cursor_style = "BlinkingBar"
config.cursor_thickness = 2
config.cursor_blink_rate = 1000

-- Scrollback & bell
config.scrollback_lines = 10000
config.audible_bell = "Disabled"
config.enable_scroll_bar = true

wezterm.on("window-focus-changed", function(window, pane)
	if window:is_focused() then
		window:set_config_overrides({
--			window_background_opacity = 0.95, -- less transparent when focused
		})
	else
		window:set_config_overrides({
--			window_background_opacity = 0.7, -- more transparent when not focused
		})
	end
end)

-- Keybindings
config.keys = {
	{ key = "t", mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
	{ key = "h", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "E", mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "O", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
}

config.front_end = "WebGpu"

return config
