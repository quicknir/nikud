export ZDOTDIR=${${(%):-%x}:P:h}

# Dir bookmarks are potentially used in previewing recent dirs
hash -d nikud="${ZDOTDIR:h:h}"

# Prevents duplicate entries in PATH
typeset -U path PATH

# Uses the repo's built in mamba setup - devtools env gives us access to things like eza and bat
# needed in env not rc because fzf previews launch in a non-interactive subshell
path[1,0]=~nikud/micromamba/envs/devtools/bin
# If using the built in downloaded micromamba, have it on the path
path[1,0]=~nikud/micromamba/bin

# Useful to define editor "early" as it may be used by other code to set defaults, e.g. tmux
export EDITOR=vim
export VISUAL=vim

export TERM="xterm-256color"

export XDG_CONFIG_HOME=~nikud/xdg_config_home

# "Encouraging" some other tools to use XDG_CONFIG_HOME
export IPYTHONDIR="${XDG_CONFIG_HOME}/ipython"
export JUPYTER_CONFIG_DIR="${XDG_CONFIG_HOME}/jupyter"

# fzf previews run in a fresh, non-interactive shell, so anything needed by preview code
# should be defined here
# Typically we use ls (or eza) to preview dirs, and cat (or bat) to preview
# files. So any settings related to these should be here.
# Further, any reload commands are also executed similarly, so any functions called in a
# reload binding also need to be defined in zshenv.
# TODO: it might be nice to fallback to find if fd isn't available. For now though, I just
# always install fd.

function __dir_entries() {
  local cmd1="cdr -l | tr -s ' ' | cut -d ' ' -f 2-"
  local cmd="fd --type d $@"
  eval "{ $cmd1 & $cmd }"
}

function __file_entries() {
  fd --color always "$@"
}

# This is done like this just to avoid needing the dependency on vivid everywhere
# to change the ls colors theme, use vivid generate solarized-light.yml > ls_colors.txt
# ~~~THEME
export LS_COLORS=$(cat ~nikud/zsh/ls_colors.txt)

# ~~~THEME
export BAT_THEME='Solarized (light)'

function __fzf_ls_bat_preview() {
  # This expansion is to force expanding any directory bookmarks, which often show up in the arguments
  # to preview
  local d=${~1}
  if [[ -d $d ]]; then
    eza --icons --group-directories-first --color=always $d
  else
    bat --color=always --style numbers,grid $d
  fi
}

# A useful function and we already need it so may as well define it here
function maybe_source () {
    test -f $1 && . $1
}

# If not using the built in micromamba setup ignore_env.zsh needs to provide
# the environment for finding eza and bat.
# It may also contain machine specific directory bookmarks; they need to be defined there
# for previews to work correctly (otherwise, fzf's non-interactive preview subshell will
# not recognize the bookmark and the preview will fail)
maybe_source "$ZDOTDIR/ignore_env.zsh"

# A per host file that optionally gets sourced
maybe_source $ZDOTDIR/host_$(hostname)_env.zsh