# dotfiles

A macOS terminal environment tuned for working alongside AI coding agents like Claude Code:
**Ghostty + tmux + zsh + Neovim (LazyVim)**, with `rg` + `fzf` everywhere.

## Install

```bash
# 1. Put this folder at ~/dotfiles (unzip it there, or clone your own repo)
cd ~/dotfiles

# 2. Run the bootstrap (asks for your password once, for Homebrew)
./install.sh            # add --macos to also set fast key repeat, show dotfiles in Finder, etc.
```

It's safe to re-run. Anything it would overwrite is moved to `~/.dotfiles-backup/<timestamp>/`.

What it does, in order:

1. Installs Xcode Command Line Tools and Homebrew if missing
2. Installs everything in `Brewfile`
3. Symlinks each config package into `~` with GNU stow
4. Asks for your git name/email → `~/.gitconfig.local` (kept out of the repo)
5. Installs Node LTS via mise, tmux plugins, and Claude Code (native installer)
6. Syncs Neovim plugins

Afterwards: open **Ghostty**, run `gh auth login`, then `claude` to sign in.

To publish your own copy: `gh repo create dotfiles --private --source . --push`.

## Layout

Each top-level folder is a stow "package" that mirrors `~`:

| Package    | Links to                                   |
|------------|--------------------------------------------|
| `zsh`      | `~/.zshrc`, `~/.zprofile`                  |
| `ghostty`  | `~/.config/ghostty/config`                 |
| `tmux`     | `~/.config/tmux/tmux.conf`                 |
| `starship` | `~/.config/starship.toml`                  |
| `git`      | `~/.gitconfig`, `~/.config/git/ignore`     |
| `mise`     | `~/.config/mise/config.toml`               |
| `nvim`     | `~/.config/nvim/` (LazyVim)                |
| `claude`   | `~/.claude/settings.json`, `CLAUDE.md`, hooks, status line |
| `bin`      | `~/.local/bin/` helper scripts (`rgf`, `tms`, `wt`) |

Because these are symlinks, editing `~/.zshrc` edits the repo. Commit changes with `git` in `~/dotfiles`.
After adding a new file to a package, run `./install.sh --links`.

Machine-specific shell tweaks go in `~/.zshrc.local` (not tracked).

## Daily workflow

```
tms                     fuzzy-pick a project → its own tmux session
Ctrl-a C                open Claude in a split beside your current pane
Ctrl-h/j/k/l            move between tmux panes and nvim splits seamlessly
Ctrl-a g                lazygit popup: review, stage, commit what the agent did
wt feature-x            new git worktree + tmux window running Claude (parallel agents)
rgf <pattern>           live ripgrep + fzf; Enter opens the hit in nvim
```

When Claude needs input or finishes, you get a macOS notification and a 🔔 on that tmux window.

## Parallel agents with `wt`

`wt` gives each agent its own [git worktree](https://git-scm.com/docs/git-worktree): a separate
checkout of the same repo, on its own branch, so several Claudes can edit at once without
touching each other's files (or yours).

```
wt fix-login            worktree ~/code/app.worktrees/fix-login + tmux window running Claude
Ctrl-a W                same, prompting for the branch name
wt -l                   list this repo's worktrees
wt -r fix-login         remove the worktree folder (the branch is kept)
```

Run it from anywhere inside the repo (including another worktree). An existing branch is
checked out as is; a new one starts from your current commit. Outside tmux it just creates
the worktree and prints the path.

A typical loop:

1. `wt refactor-api` and `wt fix-login`: hand each Claude its task, keep working in the main checkout.
2. When one finishes, review its branch: `Ctrl-a g` (lazygit) in its window, or
   `<leader>gV` in nvim for the branch vs main.
3. Merge it from the main checkout, then clean up:
   `wt -r fix-login && git branch -d fix-login`.

Gotchas:

- **Fresh checkout:** untracked files aren't copied. Bring over `.env` and reinstall
  dependencies (`node_modules`, `.venv`, ...) in each worktree.
- **One branch, one worktree:** git won't check out the same branch twice, so
  `wt main` fails while `main` is your main checkout.
- **`wt -r` refuses if there are uncommitted changes** in the worktree. Commit or discard them first.

## Cheat sheet

**Shell**

| Key / command | What it does |
|---|---|
| `Ctrl-R` | atuin history search |
| `Ctrl-T` | fzf file picker (inserts path) |
| `Alt-C` | fzf cd into a directory |
| `z <name>` | jump to a frequent directory (zoxide) |
| `c` / `cc` | `claude` / `claude --continue` |
| `v`, `lg`, `ll` | nvim, lazygit, detailed listing |

**tmux** (prefix is `Ctrl-a`)

| Key | What it does |
|---|---|
| `\|` / `-` | split right / down |
| `c` | new window |
| `C` | Claude in a 40% side split |
| `g` | lazygit popup |
| `f` | project picker (`tms`) popup |
| `W` | prompt for a branch → `wt` |
| `H J K L` | resize pane |
| `[` then `v`/`y` | copy mode, select, copy to clipboard |
| `r` | reload config |
| `I` / `U` | install / update plugins |

Sessions are auto-saved and restored across reboots (tmux-resurrect + continuum).

**Neovim** (leader is `Space`; press it and wait for the menu)

| Key | What it does |
|---|---|
| `<leader><space>` | find files |
| `<leader>/` | live grep (rg) |
| `<leader>sw` | grep word under cursor |
| `<leader>gg` | lazygit |
| `<leader>gv` / `<leader>gV` | diffview: working tree / branch vs main |
| `<leader>gh` | file history |
| `<leader>ac` | toggle Claude inside nvim |
| `<leader>as` (visual) | send selection to Claude |
| `<leader>aa` / `<leader>ad` | accept / reject Claude's proposed diff |

Running Claude in a tmux pane instead of inside nvim? Type `/ide` in Claude to connect
it to Neovim so it can see your open file and selection.

Buffers auto-reload when an agent edits a file on disk.

## Claude Code config

- `~/.claude/CLAUDE.md`: global instructions (use uv, don't commit unless asked, ...). Edit to taste.
- `~/.claude/settings.json`: read-only commands (`git status/diff/log`, `rg`, `fd`, `gh pr view`, ...)
  are pre-approved; `.env` files are blocked from being read. Notification + Stop hooks and the status line are wired up here.
- Per-project rules go in that repo's own `CLAUDE.md` / `.claude/settings.json`.

## Customizing

- **Theme:** Catppuccin across Ghostty, tmux and Neovim. List Ghostty themes with `ghostty +list-themes`.
- **Neovim extras:** `:LazyExtras` to toggle language packs; add plugins in `nvim/.config/nvim/lua/plugins/`.
- **Projects dir:** `tms` looks in `~/code` by default; set `PROJECTS_DIR` in `~/.zshrc.local`.
- **Auto-start tmux:** uncomment the `command =` line at the bottom of the Ghostty config.
