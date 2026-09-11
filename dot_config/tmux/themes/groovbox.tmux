# Groovbox Theme Palette (Matched to Ghostty/WezTerm)
tmux_conf_theme_colour_1="#282828"    # Background
tmux_conf_theme_colour_2="#928374"    # Inactive borders / gray
tmux_conf_theme_colour_3="#dcd7ba"    # Soft foreground text
tmux_conf_theme_colour_4="#83a598"    # Primary Accent (Active Window - Blue)
tmux_conf_theme_colour_5="#fabd2f"    # Yellow Accent
tmux_conf_theme_colour_6="#282828"    
tmux_conf_theme_colour_7="#dcd7ba"    # Foreground Text
tmux_conf_theme_colour_8="#282828"    
tmux_conf_theme_colour_9="#d79921"    # Warm Yellow Accent
tmux_conf_theme_colour_10="#d3869b"   # Magenta Accent
tmux_conf_theme_colour_11="#b8bb26"   # Green Accent
tmux_conf_theme_colour_12="#32302f"   # Status bar bg (shade of colour_1 #282828)

set -g status-style "bg=#32302f,fg=#dcd7ba"
setw -g window-status-style "bg=#32302f,fg=#928374"
set -g pane-active-border-style "fg=#83a598"
setw -g mode-style "bg=#504945,fg=default"
set -g clock-mode-colour "#83a598"

set -g status-left "#[fg=#282828,bg=#d3869b,bold] ❐ #S #[fg=#dcd7ba,bg=#32302f,nobold]"
setw -g window-status-current-style "bg=#83a598,fg=#282828,bold"
tmux_conf_theme_status_right=' %H:%M | %d %b '
tmux_conf_theme_status_right_fg="#282828,#282828"
tmux_conf_theme_status_right_bg="#d79921,#fabd2f"
tmux_conf_theme_status_right_attr="bold,bold"

set -g message-style "fg=#dcd7ba,bg=#32302f,bold"
set -g message-command-style "fg=#dcd7ba,bg=#32302f,bold"
