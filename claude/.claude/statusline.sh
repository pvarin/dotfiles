#!/usr/bin/env bash
# Claude Code status line: model · directory · git branch (+ dirty marker)
input="$(cat)"
model="$(jq -r '.model.display_name // "Claude"' <<<"$input")"
dir="$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")"
dir="${dir:-$PWD}"

branch=""
if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch="$(git -C "$dir" branch --show-current 2>/dev/null)"
  [[ -z "$branch" ]] && branch="$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)"
  if [[ -n "$(git -C "$dir" status --porcelain 2>/dev/null | head -n1)" ]]; then
    branch="$branch*"
  fi
fi

printf '\033[35m%s\033[0m \033[2m·\033[0m \033[34m%s\033[0m' "$model" "${dir/#$HOME/~}"
[[ -n "$branch" ]] && printf ' \033[2m·\033[0m \033[33m %s\033[0m' "$branch"
printf '\n'
