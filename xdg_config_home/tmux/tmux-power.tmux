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
tmux_set status-left "#[bg=$regular]$session_color#[fg=brightblack]  #S #[fg=$regular]$session_color#[bg=$sep]$rarrow"

# Right status
function add_rseg() {
    RS+="#[fg=$1]$larrow#[fg=brightblack,bg=$1] $2 "
}
add_rseg brightred "#{ram_icon} #{ram_percentage}"  # note that brightred in solarized is orange
add_rseg cyan "󰻠 #{cpu_percentage}"
add_rseg red " %T"
add_rseg blue " %F"
tmux_set status-right "$RS"

# Window status
tmux_set window-status-separator ""
# handles color changing of window depending whether it's the recently active one
inactive=blue
last=cyan
window_color="#{?window_last_flag,#[fg=$last#,bg=$last],#[fg=$inactive#,bg=$inactive]}"
# Note that brightwhite is the background color in solarized light
# #W needs extra quotes as it coulld contain spaces
window_naming="#I:#($XDG_CONFIG_HOME/tmux/name_window.sh #{pane_pid} #{pane_tty} #{pane_current_path} #{pane_id} '#W')"
tmux_set window-status-format "$window_color#[fg=$sep]$rarrow#[fg=brightwhite] $window_naming $window_color#[bg=$sep]$rarrow"
tmux_set window-status-current-format "#[fg=white,bg=brightwhite]$rarrow#[fg=blue,bold] $window_naming #[fg=brightwhite,bg=white,nobold]$rarrow"

tmux_set pane-border-style "fg=blue,bg=default"
tmux_set pane-active-border-style "fg=blue,bg=default"

tmux_set message-style "fg=blue,bg=white"
tmux_set message-command-style "fg=red,bg=white"  # only used when you go into vim command line - practically never

tmux_set mode-style "bg=white"  # Copy mode highlight