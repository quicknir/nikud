# This files handles both the core fzf functionality of 3 widgets (directory changer,
# file picker, reverse history search), as well as fzf-tab

. "${ZDOTDIR:h}/fzf-tab/fzf-tab.plugin.zsh"

# Use anonymous, immediately-executed function to keep some things local
function {
  # Use the = style for arguments rather than a space. fzf-tab gets confused otherwise
  local fzf_colors="--color=16,fg:11,bg:-1,hl:1:regular,hl+:1,bg+:7,fg+:-1:regular:underline"
  fzf_colors+=" --color=prompt:4,pointer:13,marker:13,spinner:3,info:3"

  # These arguments used both in fzf, and fzf-tab
  # -e is for exact matching within a group
  # ctrl-z ignore: https://github.com/junegunn/fzf/issues/2289
  local fzf_base_args="-e ${fzf_colors} --bind=ctrl-l:accept --bind=ctrl-z:ignore" 

  # The 40% height is only used outside of tmux, so it's not very important
  export FZF_DEFAULT_OPTS="${fzf_base_args} --ansi --layout default --height 40% --tmux 62%,38% --exit-0"

  # ~~~THEME
  zstyle ':fzf-tab:*' group-colors \
    $'\033[34m' $'\033[31m' $'\033[32m' $'\033[35m' $'\033[36m' $'\033[33m' $'\033[95m' $'\033[91m' $'\033[93m'
  zstyle ':fzf-tab:*' default-color $'\033[93m'
  zstyle ':fzf-tab:*' single-color $'\033[93m'

  zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
  zstyle ':fzf-tab:*' prefix ''
  # As of the latest fzf-tab, FZF_DEFAULT_OPTIONS are ignored completely (by default).
  # So, we need to separately set anything we want for fzf-tab
  zstyle ':fzf-tab:*' fzf-flags ${(z)fzf_base_args}

  tc_opts="--preview-window hidden --bind 'ctrl-h:toggle-preview' --preview '__fzf_ls_bat_preview {}'"
  export FZF_CTRL_T_OPTS="${tc_opts} --bind 'ctrl-i:unbind(ctrl-i)+reload(__file_entries -u)' --bind 'ctrl-space:toggle'"
  export FZF_ALT_C_OPTS="${tc_opts} --bind 'ctrl-i:unbind(ctrl-i)+reload(__dir_entries -u)'"
}

# Replace the fzf cd widget. Our widget doesn't print the line.
# Also, this cd widget includes all of the directories from our history.
fzf-cd-widget() {
  setopt localoptions pipefail no_aliases 2> /dev/null
  # +m to disable multiselect
  local dir="$(__dir_entries | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-}" fzf +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  dir=${~dir}
  builtin cd -q "${(q)dir}" && my-redraw-prompt;
  local ret=$?
  return $ret
}
zle -N fzf-cd-widget

__fsel() {
  local search_dir="."
  local cut_width="3"

  if [[ ${LBUFFER[-1]} != ' ' ]]; then
      tokens=(${(z)LBUFFER})
      if [[ -d ${~tokens[-1]} ]]; then
          search_dir=${~tokens[-1]}
          cut_width="2"
      fi
  fi
  builtin cd -q $search_dir
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  __file_entries | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-} ${FZF_CTRL_T_OPTS-}" fzf -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

fzf-file-widget() {
  LBUFFER="${LBUFFER}$(__fsel)"
  local ret=$?
  zle reset-prompt
  return $ret
}

zle -N fzf-file-widget

__hist_sel() {
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  local cmd="tac ${HISTFILE}.color"
  eval "$cmd" | awk '!visited[$0]++' | FZF_DEFAULT_OPTS="--scheme history  ${FZF_DEFAULT_OPTS-}" fzf "$@" | while read item; do
    echo -n "${item} "
  done
  local ret=$?
  echo
  return $ret
}

fzf-history-widget() {
  LBUFFER="${LBUFFER}$(__hist_sel)"
  local ret=$?
  zle reset-prompt
  return $ret
}

zle -N fzf-history-widget

# Not currently used; come back to this one day
# fzf-rg-widget() {
#   RG_PREFIX="rg --line-number --no-heading --color=always --smart-case "
#   fzf --ansi \
#       --disabled --query "$INITIAL_QUERY" \
#       --bind "change:reload:sleep 0.1; eval $RG_PREFIX {q} || true" \
#       --delimiter : \
#       --preview 'bat --color=always {1} --highlight-line {2}' \
#       --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
# }
# zle -N fzf-rg-widget
# bindkey '^S' fzf-rg-widget
