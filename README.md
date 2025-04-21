# nikud
A dotfiles repo

### Highlights
 - Installs all needed executables contained inside the cloned repo directory
   - Includes zsh and tmux
   - fzf, fd-find, bat and eza which are used heavily in the integrated and improved fzf
    setup
   - and other useful tools like ripgrep, neovim, git-delta, etc. Easy to add tools.
   - also installs auto-completion for many of these executables
 - A zsh config that includes a lot of the most useful functionality without being
   overwhelming. Code is well organized and documented.
 - Includes several of the top of zsh plugins:
   - powerline10k
   - fzf-tab
   - fast-syntax-highlighting
   - autosuggestions
 - Includes a nice tmux setup via oh-my-tmux
 - Some vscode/terminal integration niceties (particularly between vscode and tmux)
 - Includes a basic neovim setup - easy to extend further
 - config of other applications handled via XDG_CONFIG_HOME - no bare repo, no symlinks
 - and some other small things I can't remember


### Installation
Clone the repo recursively (anywhere), and from the cloned directory
run `./setup.sh`.

### Uninstallation
To stop using the dotfiles repo, just delete the symlink at `~/.zshenv`. If desired, the
old zshenv can be restored - it's backed up to `~/.zshenv.bak_<number>`. The dotfiles repo
folder can then be deleted - this removes all traces of installation, including executables.

### Is nikud a framework?
No. I'm not trying to make this some kind of general purpose solution that people can change
a handful of environment variables or config file, to suit their needs (a la OMZ, prezto,
etc). It's my personal dotfiles that I've taken a bit of extra time to document and organize,
that I think will be useful for other folks. You should fork it and change what you want!

