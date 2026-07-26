# Nightshift Theme Palette (Matched to Ghostty/WezTerm)
tmux_conf_theme_colour_1="#0b0f1a"    # Background
tmux_conf_theme_colour_2="#5b6268"    # Inactive borders / dark gray
tmux_conf_theme_colour_3="#d0d0d0"    # Soft foreground text
tmux_conf_theme_colour_4="#51afef"    # Primary Accent (Active Window - Blue)
tmux_conf_theme_colour_5="#ecbe7b"    # Yellow Accent
tmux_conf_theme_colour_6="#0b0f1a"    
tmux_conf_theme_colour_7="#d0d0d0"    # Foreground Text
tmux_conf_theme_colour_8="#0b0f1a"    
tmux_conf_theme_colour_9="#ecbe7b"    # Yellow Accent
tmux_conf_theme_colour_10="#c678dd"   # Purple Accent
tmux_conf_theme_colour_11="#46d9ff"   # Cyan Accent
tmux_conf_theme_colour_12="#151b2b"   # Status bar bg (shade of colour_1 #0b0f1a)

# Status Bar & Windows
set -g status-style "bg=#151b2b,fg=#d0d0d0"
setw -g window-status-current-style "bg=#51afef,fg=#0b0f1a,bold"
setw -g window-status-style "bg=#151b2b,fg=#5b6268"

# Active & Inactive Pane Borders
set -g pane-border-style "fg=#29394d"
set -g pane-active-border-style "fg=#51afef"

# Text Selection / Copy Mode Highlight
setw -g mode-style "bg=#29394d,fg=default"

set -g clock-mode-colour "#51afef"

set -g status-left "#[fg=#0b0f1a,bg=#c678dd,bold] ❐ #S #[fg=#d0d0d0,bg=#151b2b,nobold]"
setw -g window-status-current-style "bg=#51afef,fg=#0b0f1a,bold"
set -g status-right "#[fg=#0b0f1a,bg=#ecbe7b,bold] %H:%M #[fg=#0b0f1a,bg=#46d9ff,bold] %d %b "

set -g message-style "fg=#d0d0d0,bg=#151b2b,bold"
set -g message-command-style "fg=#d0d0d0,bg=#151b2b,bold"
