#!/usr/bin/env zsh
# Inspired by https://github.com/wfxr/tmux-power/blob/master/tmux-power.tmux

# Using built in terminal colors with solarized palette; see colors.zsh for reference

# $1: option
# $2: value
tmux_set() {
    tmux set-option -gq "$1" "$2"
}

# other choies: /
rarrow=''
larrow=''

sep=white # used between left status and window status, and between windows

# Status options
tmux_set status-style bg=$sep  # sep needs to match background or the right window looks funny
tmux_set status-left-length 150
tmux_set status-right-length 150

# Left status - just session info
prefix=red
copy_mode=yellow
regular=green
session_color="#{?client_prefix,#[fg=$prefix#,bg=$prefix],}#{?pane_in_mode,#[fg=$copy_mode#,bg=$copy_mode],}"
session="#[bg=$regular]$session_color#[fg=brightblack]  #S #[fg=$regular]$session_color#[bg=$sep]$rarrow"
tmux_set status-left "$session"

# Right status - note that brightred in solarized is orange
ram="#[fg=brightred]$larrow#[fg=brightblack,bg=brightred] #{ram_icon} #{ram_percentage} "
cpu="#[fg=cyan]$larrow#[fg=brightblack,bg=cyan] 󰻠 #{cpu_percentage} "
time="#[fg=red]$larrow#[fg=brightblack,bg=red]  %T " 
date="#[fg=blue]$larrow#[fg=brightblack,bg=blue]  %F "
tmux_set status-right "$ram$cpu$time$date"

# Window status
tmux_set window-status-separator ""
# handles color changing of window depending whether it's the recently active one
inactive=blue
last=cyan
window_color="#{?window_last_flag,#[fg=$last#,bg=$last],#[fg=$inactive#,bg=$inactive]}"
# Note that brightwhite is the background color in solarized light
tmux_set window-status-format "$window_color#[fg=$sep]$rarrow#[fg=brightwhite] #I:#W $window_color#[bg=$sep]$rarrow"
tmux_set window-status-current-format "#[fg=white,bg=brightwhite]$rarrow#[fg=blue,bold] #I:#W #[fg=brightwhite,bg=white,nobold]$rarrow"

tmux_set pane-border-style "fg=blue,bg=default"
tmux_set pane-active-border-style "fg=blue,bg=default"

tmux_set message-style "fg=blue,bg=white"
tmux_set message-command-style "fg=red,bg=white"  # only used when you go into vim command line - practically never

tmux_set mode-style "bg=white"  # Copy mode highlight