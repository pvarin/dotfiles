#!/usr/bin/env bash
# install.sh — bootstrap this Mac's terminal environment from ~/dotfiles.
# Safe to re-run: every step checks before acting, and any existing config
# it would replace is moved to ~/.dotfiles-backup/<timestamp>/ first.
#
#   ./install.sh            full setup
#   ./install.sh --links    only (re)link the config files
#   ./install.sh --macos    also apply a few macOS defaults (fast key repeat, window tiling keys, etc.)
#   ./install.sh --help
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh ghostty tmux starship git mise nvim claude bin)
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

LINKS_ONLY=0
APPLY_MACOS=0
for arg in "$@"; do
  case "$arg" in
    --links) LINKS_ONLY=1 ;;
    --macos) APPLY_MACOS=1 ;;
    -h|--help) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

# ------------------------------------------------------------------ helpers
bold=$'\033[1m'; blue=$'\033[34m'; green=$'\033[32m'; yellow=$'\033[33m'; red=$'\033[31m'; reset=$'\033[0m'
step() { printf '\n%s==>%s %s%s%s\n' "$blue" "$reset" "$bold" "$*" "$reset"; }
ok()   { printf '  %s✓%s %s\n' "$green" "$reset" "$*"; }
warn() { printf '  %s!%s %s\n' "$yellow" "$reset" "$*"; }
die()  { printf '%sError:%s %s\n' "$red" "$reset" "$*" >&2; exit 1; }
has()  { command -v "$1" >/dev/null 2>&1; }

# ------------------------------------------------------------------ steps
check_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || die "This script is for macOS."
}

install_xcode_clt() {
  step "Xcode Command Line Tools"
  if xcode-select -p >/dev/null 2>&1; then
    ok "already installed"
    return
  fi
  xcode-select --install || true
  echo "  A dialog should have opened. Finish the install there; waiting..."
  until xcode-select -p >/dev/null 2>&1; do sleep 10; done
  ok "installed"
}

install_homebrew() {
  step "Homebrew"
  if ! has brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  has brew || die "Homebrew didn't install correctly."
  ok "$(brew --version | head -n1)"
}

install_packages() {
  step "Packages from Brewfile (this is the slow part)"
  brew bundle --file "$DOTFILES/Brewfile"
  ok "Brewfile applied"
}

# Move anything that would block a symlink into the backup dir.
backup_conflicts() {
  local pkg="$1" rel target
  while IFS= read -r rel; do
    rel="${rel#./}"
    target="$HOME/$rel"
    if [[ -L "$target" ]]; then
      # Already a link into this repo? Leave it. Any other symlink: back it up.
      [[ "$(readlink "$target")" == *"$(basename "$DOTFILES")/$pkg/"* ]] && continue
    elif [[ ! -e "$target" ]]; then
      continue
    fi
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$target" "$BACKUP_DIR/$rel"
    warn "backed up existing ~/$rel"
  done < <(cd "$DOTFILES/$pkg" && find . \( -type f -o -type l \) ! -name '.DS_Store')
}

link_dotfiles() {
  step "Linking config files into ~ (GNU stow)"
  has stow || die "stow not found (run without --links first, or: brew install stow)"
  chmod +x "$DOTFILES"/bin/.local/bin/* "$DOTFILES"/claude/.claude/*.sh "$DOTFILES"/claude/.claude/hooks/*.sh
  local pkg
  for pkg in "${PACKAGES[@]}"; do
    backup_conflicts "$pkg"
    # --no-folding links individual files, so tools can still write their own
    # state (plugins, caches, lockfiles) next to them without it landing in the repo.
    stow --dir "$DOTFILES" --target "$HOME" --no-folding --restow "$pkg"
    ok "$pkg"
  done
  [[ -d "$BACKUP_DIR" ]] && warn "previous files saved in $BACKUP_DIR"
  return 0
}

setup_git_identity() {
  step "Git identity (~/.gitconfig.local)"
  if [[ -f "$HOME/.gitconfig.local" ]]; then
    ok "already exists"
    return
  fi
  if [[ ! -t 0 ]]; then
    warn "not interactive; create ~/.gitconfig.local with [user] name/email later"
    return
  fi
  local name email
  read -r -p "  Your name for git commits: " name
  read -r -p "  Your email for git commits: " email
  printf '[user]\n\tname = %s\n\temail = %s\n' "$name" "$email" > "$HOME/.gitconfig.local"
  ok "wrote ~/.gitconfig.local"
}

setup_runtimes() {
  step "Runtimes (mise: node LTS)"
  if has mise; then
    mise install --yes >/dev/null && ok "mise tools installed" || warn "mise install failed; run 'mise install' later"
  else
    warn "mise not found"
  fi
}

setup_tmux_plugins() {
  step "tmux plugins"
  local tpm="$HOME/.config/tmux/plugins/tpm"
  if [[ ! -d "$tpm" ]]; then
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm"
  fi
  if "$tpm/bin/install_plugins" >/dev/null 2>&1; then
    ok "plugins installed"
  else
    warn "run 'prefix + I' inside tmux to install plugins"
  fi
}

setup_neovim() {
  step "Neovim plugins (LazyVim first-run sync)"
  if has nvim; then
    nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 && ok "plugins synced" \
      || warn "sync reported issues; open nvim and run :Lazy to check"
  else
    warn "nvim not found"
  fi
}

install_claude_code() {
  step "Claude Code"
  if has claude || [[ -x "$HOME/.local/bin/claude" ]]; then
    ok "already installed"
    return
  fi
  # Native installer: self-updating, installs to ~/.local/bin/claude
  curl -fsSL https://claude.ai/install.sh | bash
  ok "installed (run 'claude' to sign in)"
}

apply_macos_defaults() {
  step "macOS defaults"
  defaults write NSGlobalDomain KeyRepeat -int 2                 # fast key repeat
  defaults write NSGlobalDomain InitialKeyRepeat -int 15         # short delay before repeat
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false  # hold j/k repeats in vim
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.finder AppleShowAllFiles -bool true   # show dotfiles in Finder
  defaults write com.apple.finder ShowPathbar -bool true
  killall Finder >/dev/null 2>&1 || true
  apply_window_tiling_shortcuts
  ok "applied (key repeat changes need a log out/in)"
}

# Window tiling (Window > Move & Resize) on Ctrl+Option instead of Fn+Ctrl.
# Modifiers: ^ Ctrl, ~ Option, @ Cmd, $ Shift, # Fn/Globe. Apps pick these up on relaunch.
apply_window_tiling_shortcuts() {
  defaults write -g NSUserKeyEquivalents -dict-add "Left"   '^~\UF702'
  defaults write -g NSUserKeyEquivalents -dict-add "Right"  '^~\UF703'
  defaults write -g NSUserKeyEquivalents -dict-add "Top"    '^~\UF700'
  defaults write -g NSUserKeyEquivalents -dict-add "Bottom" '^~\UF701'
  defaults write -g NSUserKeyEquivalents -dict-add "Fill"   '^~f'   # not Return: Ghostty swallows Ctrl+Return
  ok "window tiling shortcuts: Ctrl+Option+arrows, Ctrl+Option+F to fill"
}

finish() {
  mkdir -p "$HOME/code"
  step "Done 🎉"
  cat <<EOF

  Next steps:
    1. Quit Terminal and open ${bold}Ghostty${reset} (Applications).
    2. Run ${bold}gh auth login${reset} to connect GitHub.
    3. Run ${bold}claude${reset} once to sign in.
    4. Start working: ${bold}tms${reset} to pick a project, ${bold}Ctrl-a C${reset} to open Claude beside you.

  Cheat sheet: see $DOTFILES/README.md
EOF
}

# ------------------------------------------------------------------ main
check_macos
if [[ $LINKS_ONLY -eq 1 ]]; then
  link_dotfiles
  exit 0
fi

install_xcode_clt
install_homebrew
install_packages
link_dotfiles
setup_git_identity
setup_runtimes
setup_tmux_plugins
install_claude_code
setup_neovim
[[ $APPLY_MACOS -eq 1 ]] && apply_macos_defaults
finish
