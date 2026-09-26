# ~/.zshrc — interactive shell config
# Managed by ~/dotfiles (stow package: zsh). Machine-specific tweaks go in ~/.zshrc.local

# ---------------------------------------------------------------- history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS SHARE_HISTORY

# ---------------------------------------------------------------- options
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS INTERACTIVE_COMMENTS NO_BEEP
bindkey -e   # emacs-style line editing (Ctrl-A/E etc.). Use `bindkey -v` for vi mode.

# ---------------------------------------------------------------- completion
if command -v brew >/dev/null 2>&1; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
fi
autoload -Uz compinit && compinit -C
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' menu select

# ---------------------------------------------------------------- tools
# mise: per-project runtimes (node, go, ...). Python is handled by uv.
command -v mise     >/dev/null && eval "$(mise activate zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"

# fzf: Ctrl-T (files), Alt-C (cd into dir). Ctrl-R is taken over by atuin below.
if command -v fzf >/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  export FZF_DEFAULT_OPTS='--height 50% --layout=reverse --border --info=inline'
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"
  source <(fzf --zsh)
fi

# atuin: searchable, per-directory shell history on Ctrl-R (up-arrow left alone)
command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"

# ---------------------------------------------------------------- aliases
# Friendly replacements are only defined for *you*, not for AI agents.
# Claude Code sets CLAUDECODE=1 in its shells; keeping plain `ls`/`cat` output
# there avoids confusing the agent with icons, colors and pagers.
if [[ -z "$CLAUDECODE" ]]; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -la --group-directories-first --icons=auto --git'
  alias lt='eza --tree --level=2 --icons=auto'
fi
alias v='nvim'
alias vim='nvim'
alias lg='lazygit'
alias g='git'
alias gs='git status -sb'
alias gd='git diff'
alias c='claude'
alias cc='claude --continue'
alias dots='cd ~/dotfiles'
alias reload='exec zsh'

# ---------------------------------------------------------------- local overrides
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
