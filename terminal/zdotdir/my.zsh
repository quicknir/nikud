# Enable Powerlevel10k instant prompt. Should stay close to the top of /spare/ssd_local/nir/zsh/home/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set terminal
export TERM="xterm-256color"

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Better ls coloring when using solarized terminal theme
eval $(eval "dircolors ${termdir}/dircolors-solarized/dircolors.ansi-light")
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Handy reference, courtesy of https://github.com/seebi/dircolors-solarized
# SOLARIZED HEX     16/8 TERMCOL  XTERM/HEX   L*A*B      sRGB        HSB
# --------- ------- ---- -------  ----------- ---------- ----------- -----------
# base03    #002b36  8/4 brblack  234 #1c1c1c 15 -12 -12   0  43  54 193 100  21
# base02    #073642  0/4 black    235 #262626 20 -12 -12   7  54  66 192  90  26
# base01    #586e75 10/7 brgreen  240 #4e4e4e 45 -07 -07  88 110 117 194  25  46
# base00    #657b83 11/7 bryellow 241 #585858 50 -07 -07 101 123 131 195  23  51
# base0     #839496 12/6 brblue   244 #808080 60 -06 -03 131 148 150 186  13  59
# base1     #93a1a1 14/4 brcyan   245 #8a8a8a 65 -05 -02 147 161 161 180   9  63
# base2     #eee8d5  7/7 white    254 #d7d7af 92 -00  10 238 232 213  44  11  93
# base3     #fdf6e3 15/7 brwhite  230 #ffffd7 97  00  10 253 246 227  44  10  99
# yellow    #b58900  3/3 yellow   136 #af8700 60  10  65 181 137   0  45 100  71
# orange    #cb4b16  9/3 brred    166 #d75f00 50  50  55 203  75  22  18  89  80
# red       #dc322f  1/1 red      160 #d70000 50  65  45 220  50  47   1  79  86
# magenta   #d33682  5/5 magenta  125 #af005f 50  65 -05 211  54 130 331  74  83
# violet    #6c71c4 13/5 brmagenta 61 #5f5faf 50  15 -45 108 113 196 237  45  77
# blue      #268bd2  4/4 blue      33 #0087ff 55 -10 -45  38 139 210 205  82  82
# cyan      #2aa198  6/6 cyan      37 #00afaf 60 -35 -05  42 161 152 175  74  63
# green     #859900  2/2 green     64 #5f8700 60 -20  65 133 153   0  68 100  60

# Usage: palette
palette() {
    local -a colors
    for i in {000..16}; do
        colors+=("%F{$i}hello: $i%f")
    done
    print -cP $colors
}

# Usage: printc COLOR_CODE
printc() {
    local color="%F{$1}"
    echo -E ${(qqqq)${(%)color}}
}

# Colors for fzf-tab
zstyle ':fzf-tab:*' default-color $'\033[93m'

# Our zshenv has handled setting zdotdir to the path within our repo, so now
# we can use zdotdir to locate the rest of our config
termdir="${ZDOTDIR:h}"

alias vi=vim
# For better vi usability, reduce key delay/timeout                                                                       KEYTIMEOUT=1

# Vim-like movement bindings!
zmodload zsh/complist  # Necessary so that menuselect keymap gets loaded; otherwise gets lazy loaded on first use
bindkey -M menuselect '^J' down-line-or-history
bindkey -M menuselect '^K' up-line-or-history
bindkey -M menuselect '^H' backward-char
bindkey -M menuselect '^L' forward-char

# fzf setup
fzfdir="$termdir/fzf"
export PATH="$PATH:$fzfdir/bin"

source "$fzfdir/shell/key-bindings.zsh"

# To generate paths, use default find-based command for dirs,
# and ag to find files more quickly
_fzf_compgen_path() {
  { _fzf_compgen_dir $1 & ag --hidden -g "" "$1" } 2> /dev/null
}

# Exact matching similar to helm
export FZF_DEFAULT_OPTS="-e \
   --color 16,fg:11,bg:-1,hl:1,hl+:1,bg+:7,fg+:11 \
   --color prompt:4,pointer:13,marker:13,spinner:3,info:3"

# CTRL-E - word based history search
__hist_word_sel() {

  local cmd='for line in $(fc -l 0 | cut -d '' '' -f 3-); do for word in $line; do echo $word; done; done | sort --unique'
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} ${FZF_CTRL_T_OPTS-}" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  return $ret
}

__fzfcmd() {
  [ -n "${TMUX_PANE-}" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "${FZF_TMUX_OPTS-}" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-history-word-widget() {
  LBUFFER="${LBUFFER}$(__hist_word_sel)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle -N fzf-history-word-widget
bindkey '^E' fzf-history-word-widget

# Useful aliases

# This one
alias hist-dur='history -iD 0 | fzf'

# Suffixes!
alias -s txt=vim

# Named directories
hash -d config="${ZDOTDIR:h:h}"

# Support for GUI clipboard
source $ZDOTDIR/clipboard.zsh

# A separate file that gets sourced; convenient for putting things you may not want to upstream
() { local FILE="$ZDOTDIR/ignore.zsh" && test -f $FILE && . $FILE }

# recent directories
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 1000

# Replace the fzf cd widget. Our widget doesn't print the line
fzf-cd-widget() {
  local cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs'     -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-}" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  builtin cd -q "${(q)dir}" && my-redraw-prompt;
  local ret=$?
  return $ret
}
zle -N fzf-cd-widget


fzf-recent-dir-widget() {
  local cmd="cdr -l | tr -s ' ' | cut -d ' ' -f 2-"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-}" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  eval "dir=$dir"  # Force ~ expansion
  builtin cd -q "${dir}" && my-redraw-prompt;
  local ret=$?
  return $ret
}
zle -N fzf-recent-dir-widget
bindkey '^F' fzf-recent-dir-widget

# Intuitive back-forward navigation, similar to a browser.
# Also provides up (cd ..), and down (fzf recursive dir search).
# Bound to Ctrl-hjkl
# https://www.reddit.com/r/zsh/comments/ka4sae/navigate_folder_history_like_in_fish/
function my-redraw-prompt() {
  {
    builtin echoti civis
    builtin local f
    for f in chpwd "${chpwd_functions[@]}" precmd "${precmd_functions[@]}"; do
      (( ! ${+functions[$f]} )) || "$f" &>/dev/null || builtin true
    done
    builtin zle reset-prompt
  } always {
    builtin echoti cnorm
  }
}

function my-cd-rotate() {
  () {
    builtin emulate -L zsh
    while (( $#dirstack )) && ! builtin pushd -q $1 &>/dev/null; do
      builtin popd -q $1
    done
    (( $#dirstack ))
  } "$@" && my-redraw-prompt
}

function my-cd-up()      { builtin cd -q .. && my-redraw-prompt; }
function my-cd-back()    { my-cd-rotate +1; }
function my-cd-forward() { my-cd-rotate -0; }

builtin zle -N my-cd-up
builtin zle -N my-cd-back
builtin zle -N my-cd-forward

bindkey -v '^K' my-cd-up
bindkey -v '^H' my-cd-back
bindkey -v '^L' my-cd-forward
bindkey -v '^J' fzf-cd-widget

# To customize prompt, run `p10k configure` or edit $ZDOTDIR/.p10k.zsh.
[[ ! -f "${ZDOTDIR}/.p10k.zsh" ]] || source "${ZDOTDIR}/.p10k.zsh"