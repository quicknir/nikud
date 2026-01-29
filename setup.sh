#!/bin/bash

function symlink_and_bak() {
  local src="$1"
  local dest="$2"
  if [[ -e $dest ]] || [[ -L $dest ]]; then
    for ((i=0; ; i++)); do 
      local backup="${dest}.bak_${i}" 
      if [[ ! -e $backup ]] && [[ ! -L $backup ]]; then
        break;
      fi;
    done
    mv "$dest" "$backup"
  fi
  ln -s "$src" "$dest"
}

repo_dir=$(dirname $(realpath "$0"))
symlink_and_bak "${repo_dir}/zsh/zdotdir/my_env.zsh" "${HOME}/.zshenv"
mamba_dir="${repo_dir}/micromamba"
if [[ $(uname) == "Darwin" ]] ; then
  mamba_url="osx-64"
else
  mamba_url="linux-64"
fi
curl -Ls "https://micro.mamba.pm/api/micromamba/${mamba_url}/latest" | tar -xvj -C "$mamba_dir" bin/micromamba
"${mamba_dir}/bin/micromamba" -r "$mamba_dir" create -f "${mamba_dir}/devtools.yaml" -y -c conda-forge
echo Install fonts - Jetbrains Mono Nerd Font from https://www.nerdfonts.com/font-downloads