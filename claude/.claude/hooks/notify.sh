#!/usr/bin/env bash
# Claude Code hook: macOS notification + terminal bell when Claude needs you or finishes.
# Used by the Notification and Stop hooks in ~/.claude/settings.json.
# The hook's JSON payload arrives on stdin; $1 is an optional fallback message.

input="$(cat)"
msg="$(jq -r '.message // empty' <<<"$input" 2>/dev/null)"
cwd="$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)"
msg="${msg:-${1:-Claude needs your attention}}"
project="$(basename "${cwd:-$PWD}")"

# Ring the bell so tmux flags the window (🔔 in the status bar).
{ printf '\a' > /dev/tty; } 2>/dev/null || true

# Only pop a notification on macOS.
if command -v osascript >/dev/null 2>&1; then
  osascript - "$msg" "$project" >/dev/null 2>&1 <<'EOF'
on run argv
  display notification (item 1 of argv) with title "Claude Code" subtitle (item 2 of argv) sound name "Glass"
end run
EOF
fi

exit 0
