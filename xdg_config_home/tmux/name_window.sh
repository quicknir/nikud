#!/usr/bin/env zsh

# This script is invoked by tmux to determine the name of the window.
# It's invoked in tmux-power.tmux as:
#   #($XDG_CONFIG_HOME/tmux/name_window.sh #{pane_pid} #{pane_tty} #{pane_p} #W)
# If the current window name ($4) is non-empty, it is used as the window name and the script exits.
# Since the default window name is empty, this means that if the user has set a custom name for the
# window, it will be preserved.
# Otherwise, pane_pid and pane_tty are used to determine the command running in the pane. From
# there, the window name is determined as follows:
# - If the command is ssh or mosh-client, the window name is set to username@hostname
# - If the command is zsh, the window name is set to the current directory path
# - If the command is lazygit, the window name is set to " <current directory path>"
# - Otherwise, the window name is set to the command name (without arguments)

# In the future I may special case more commands similar to lazygit as it's fairly simple

# This approach leaves window names generally empty except when manually set. This is fine
# for the status bar display but other use cases like choose-tree will not work properly. 
# The solution then would be to actually invoke tmux renamew from this script, but to do
# that we will also need to keep some state (via tmux set -g "@is_manual_name$pane_id")
# to remember whether the window is manually renamed or not, and will need to bind the
# rename function to first set this variable properly... Too much work for now.

# _pane_info and _ssh_or_mosh_args are taken close to verbatim from oh-my-tmux
# https://github.com/gpakosz/.tmux
# The match and break logic is to stop "descending" down child subprocesses
# The original code only handled ssh, I added lazygit because lazygit often
# launches child subprocesses, and we'd rather still show lazygit as the command.
_pane_info() {
  pane_pid="$1"
  pane_tty="${2##/dev/}"

  ps -t "$pane_tty" --sort=lstart -o user=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -o pid= -o ppid= -o command= | awk -v pane_pid="$pane_pid" -v ssh="$(command -v ssh)" '
    ((/ssh/ && !/-W/ && !/tsh proxy ssh/ && !/sss_ssh_knownhostsproxy/) || !/ssh/) && !/tee/ {
      user[$2] = $1; if (!child[$3]) child[$3] = $2; pid=$2; $1 = $2 = $3 = ""; command[pid] = substr($0,4)
    }
    END {
      pid = pane_pid
      while (child[pid]) {
        if (match(command[pid], "^" ssh " |^ssh |^lazygit")) {
          break
        }
        pid = child[pid]
      }

      print pid":"user[pid]":"command[pid]
    }
  '
}

_ssh_or_mosh_args() {
  case "$1" in
    *ssh*)
      args=$(printf '%s' "$1" | perl -n -e 'print if s/.*?\bssh[\w_-]*\s*(.*)/\1/')
      ;;
    *mosh-client*)
      args=$(printf '%s' "$1" | sed -E -e 's/.*mosh-client -# (.*)\|.*$/\1/' -e 's/-[^ ]*//g' -e 's/\d:\d//g')
      ;;
  esac

 printf '%s' "$args"
}

# A function that takes one argument, which is a path. If it is over 20 characters,
# Turn the first path segment into its first letter. Repeat until the path is under 20 characters.
function _shorten_path() {
    local p="$1"

    # Split the path into segments.
    local -a segments
    segments=("${(@s:/:)p}")

    # Iterate through the segments and shorten them one by one.
    local i=1
    # If the first segment starts with ~, skip it
    if [[ "${segments[1]}" = \~* ]]; then
        (( i++ ))
    fi
    for (( ; i < ${#segments[@]}; i++ )); do
        if (( ${#p} <= 30 )); then
            break
        fi

        # Shorten the segment to its first letter if it's not already a single character or empty
        if (( ${#segments[i]} > 1 )); then
            segments[i]="${segments[i][1]}"
        fi

        # Rebuild the path from the segments.
        p="${(j:/:)segments}"

    done

    echo "$p"
}

function _window() {

  pane_pid=$1
  pane_tty=$2
  pane_path=$3
  pane_id=$4
  window_name=$5

  # I'm a bad person
  zero_width_space="​"

  # If the window name does not end with a zero width space *and* is non-empty
  # it is a manual name then just return it
  if [[ "${window_name: -1}" != "$zero_width_space" ]] && [[ -n "$window_name" ]]; then
    echo "$window_name"
    return
  fi

  pane_info=$(_pane_info "$pane_pid" "$pane_tty")
  command=${pane_info#*:}
  command_username=${command%%:*}
  command=${command#*:}

  ssh_or_mosh_args=$(_ssh_or_mosh_args "$command")

  if [ -n "$ssh_or_mosh_args" ]; then
    # shellcheck disable=SC2086
    ssh_or_mosh_args="${ssh_or_mosh_args} -l ${command_username}"
    # echo $ssh_or_mosh_args
    hostname=$(ssh -G ${=ssh_or_mosh_args} 2>/dev/null | awk '/^hostname / { print $2; exit }')
    # shellcheck disable=SC2086
    [ -z "$hostname" ] && hostname=$(ssh -T -o ControlPath=none -o ProxyCommand="sh -c 'echo %%hostname%% %h >&2'" $ssh_or_mosh_args 2>&1 | awk '/^%hostname% / { print $2; exit }')

    # shellcheck disable=SC2086
    username=$(ssh -G ${=ssh_or_mosh_args} 2>/dev/null | awk '/^user / { print $2; exit }')
    # shellcheck disable=SC2086
    [ -z "$username" ] && username=$(ssh $ssh_or_mosh_args -T -o ControlPath=none -o ProxyCommand="sh -c 'echo %%username%% %r >&2'" 2>&1 | awk '/^%username% / { print $2; exit }')
    # shellcheck disable=SC2086
    [ -z "$username" ] && username=$(ssh $ssh_or_mosh_args -v -T -o ControlPath=none -o ProxyCommand=false -o IdentityFile='%%username%%/%r' 2>&1 | awk '/%username%/ { print substr($4,12); exit }')
    new_name="${username}@${hostname}"
  elif [[ "${command%% *}" = *"zsh" ]]; then
    new_name=$(_shorten_path ${(D)pane_path})
  elif [[ "${command%% *}" = *"lazygit" ]]; then
    new_name=" $(_shorten_path ${(D)pane_path})"
  else
    new_name="${${command%% *}:t}"
  fi
  tmux renamew -t $pane_id "$new_name$zero_width_space"
  echo $new_name$zero_width_space
}

_window "$@"
