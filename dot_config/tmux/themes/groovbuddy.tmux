# Groovbuddy Theme Palette (Matched to Ghostty/WezTerm)
tmux_conf_theme_colour_1="#14110e"    # Background
tmux_conf_theme_colour_2="#3c2f2a"    # Inactive borders / dark brown
tmux_conf_theme_colour_3="#ebdbb2"    # Soft foreground text
tmux_conf_theme_colour_4="#83a598"    # Primary Accent (Active Window - Blue)
tmux_conf_theme_colour_5="#fabd2f"    # Yellow Accent
tmux_conf_theme_colour_6="#14110e"    
tmux_conf_theme_colour_7="#ebdbb2"    # Foreground Text
tmux_conf_theme_colour_8="#14110e"    
tmux_conf_theme_colour_9="#fe8019"    # Orange Accent
tmux_conf_theme_colour_10="#d3869b"   # Magenta Accent
tmux_conf_theme_colour_11="#b8bb26"   # Green Accent
tmux_conf_theme_colour_12="#28201a"   # Status bar bg (shade of colour_1 #14110e)

set -g status-style "bg=#28201a,fg=#ebdbb2"
setw -g window-status-style "bg=#28201a,fg=#a89984"
set -g pane-active-border-style "fg=#fe8019"
setw -g mode-style "bg=#3c2f2a,fg=default"
set -g clock-mode-colour "#ffffff"

set -g status-left "#[fg=#14110e,bg=#d3869b,bold] ❐ #S #[fg=#ebdbb2,bg=#28201a,nobold]"
setw -g window-status-current-style "bg=#fe8019,fg=#14110e,bold"
set -g status-right "#[fg=#14110e,bg=#fabd2f,bold] %H:%M #[fg=#14110e,bg=#b8bb26,bold] %d %b "

set -g message-style "fg=#ebdbb2,bg=#28201a,bold"
set -g message-command-style "fg=#ebdbb2,bg=#28201a,bold"
