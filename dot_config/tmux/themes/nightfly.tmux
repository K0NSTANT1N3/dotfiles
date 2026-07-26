# Nightfly Theme Palette (Matched to Ghostty/WezTerm)
tmux_conf_theme_colour_1="#011627"    # Background
tmux_conf_theme_colour_2="#65737e"    # Inactive borders / muted gray
tmux_conf_theme_colour_3="#c0caf5"    # Soft foreground text
tmux_conf_theme_colour_4="#82aaff"    # Primary Accent (Active Window - Blue)
tmux_conf_theme_colour_5="#ffca3a"    # Yellow Accent
tmux_conf_theme_colour_6="#011627"    
tmux_conf_theme_colour_7="#c0caf5"    # Foreground Text
tmux_conf_theme_colour_8="#011627"    
tmux_conf_theme_colour_9="#ffca3a"    # Yellow Accent
tmux_conf_theme_colour_10="#c792ea"   # Purple Accent
tmux_conf_theme_colour_11="#7fdbca"   # Cyan/Teal Accent
tmux_conf_theme_colour_12="#0e2233"   # Status bar bg (shade of colour_1 #011627)

# Status Bar & Windows
set -g status-style "bg=#0e2233,fg=#c0caf5"
setw -g window-status-current-style "bg=#82aaff,fg=#011627,bold"
setw -g window-status-style "bg=#011627,fg=#65737e"

# Active & Inactive Pane Borders
set -g pane-border-style "fg=#1d3b53"
set -g pane-active-border-style "fg=#82aaff"

# Text Selection / Copy Mode Highlight (Fixes the sharp yellow!)
setw -g mode-style "bg=#1d3b53,fg=default"

set -g clock-mode-colour "#ffffff"

set -g status-left "#[fg=#011627,bg=#c792ea,bold] ❐ #S #[fg=#c0caf5,bg=#0e2233,nobold]"
setw -g window-status-current-style "bg=#82aaff,fg=#011627,bold"
set -g status-right "#[fg=#011627,bg=#ffca3a,bold] %H:%M #[fg=#011627,bg=#7fdbca,bold] %d %b "

set -g message-style "fg=#c0caf5,bg=#0e2233,bold"
set -g message-command-style "fg=#c0caf5,bg=#0e2233,bold"
