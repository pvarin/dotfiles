# ~/.zprofile — login shell setup (runs once per login, before .zshrc)

# Homebrew (Apple Silicon lives in /opt/homebrew, Intel in /usr/local)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# XDG base dirs so tools keep config in ~/.config instead of ~/Library
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# ~/.local/bin: our helper scripts + the Claude Code native installer
typeset -U path
path=("$HOME/.local/bin" $path)

export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R -F -X"
