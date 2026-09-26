# Global instructions for Claude Code (applies to every project)

## Environment
- macOS, zsh, Ghostty + tmux. Editor is Neovim.
- Available CLI tools: rg, fd, jq, yq, gh, git, delta, bat, eza, uv, mise.
- Prefer `rg` over grep and `fd` over find.

## Languages & dependencies
- Python: use `uv` (`uv run`, `uv add`, `uv venv`). Never `pip install` globally.
- Node and other runtimes: managed per project with `mise` (`mise.toml`). Don't install global npm packages without asking.
- Never use `sudo`.

## Git
- Don't commit, push, or open PRs unless I ask.
- When asked to commit: small, focused commits with clear messages.
- Never force-push or rewrite history on shared branches.

## Working style
- Run the project's tests/linters after making changes when they exist.
- Ask before large refactors or adding new dependencies.
- Keep explanations short; show diffs rather than describing them.
