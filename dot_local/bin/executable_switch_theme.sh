#!/bin/bash

set -eu

THEME=${1:-}
THEMES=("nightfly" "groovbox" "nightshift" "groovbuddy")

if [[ -z "$THEME" ]]; then
    printf 'Usage: %s <%s>\n' "$0" "$(IFS='|'; echo "${THEMES[*]}")"
    exit 1
fi

valid=false
for candidate in "${THEMES[@]}"; do
    if [[ "$candidate" == "$THEME" ]]; then
        valid=true
        break
    fi
done

if [[ "$valid" != true ]]; then
    printf 'Invalid theme. Available: %s\n' "${THEMES[*]}" >&2
    exit 1
fi

# 1. WezTerm
printf '%s\n' "$THEME" >"$HOME/.config/wezterm/current_theme"

# 2. Ghostty
cp "$HOME/.config/ghostty/themes/$THEME.ghostty" \
   "$HOME/.config/ghostty/current-theme.ghostty"
pkill -USR2 -x ghostty 2>/dev/null || true

# 3. Tmux Integration
TMUX_THEME_FILE="$HOME/.config/tmux/themes/$THEME.tmux"
if [[ -f "$TMUX_THEME_FILE" ]]; then
    mkdir -p "$HOME/.config/tmux"
    cp "$TMUX_THEME_FILE" "$HOME/.config/tmux/current-theme.tmux"
    
    # Reload tmux and re-run Oh My Tmux's internal layout builder
    if tmux info &>/dev/null; then
        tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true
        tmux source-file "$HOME/.config/tmux/current-theme.tmux" 2>/dev/null || true
        tmux run-shell 'python3 ~/.tmux/scripts/theme.py 2>/dev/null || true'
        tmux refresh-client -S 2>/dev/null || true
    fi
fi

printf 'Theme switched to %s across WezTerm, Ghostty, Neovim, and Tmux!\n' "$THEME"


