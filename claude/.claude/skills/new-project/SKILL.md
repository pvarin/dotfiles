---
name: new-project
description: Start a new project in ~/code — folder, git repo, README.md, a CLAUDE.md written from the user's description, first commit, optional GitHub repo, and a tmux session to work in. Use whenever the user wants to start, create, spin up or scaffold a new project, repo or app ("new project called X", "let's start a repo for Y", "set up a folder for my Z idea"), even if they don't say "project". Not for cloning an existing repo or adding to a project that already exists.
argument-hint: <name> [what it's for]
---

# New project

Set up `~/code/<name>` so the user can start working (or hand it to an agent) right away.
Invoking this skill is the user asking for the first commit, so commit without asking again.
Anything that leaves the machine (GitHub) still needs their explicit yes.

## 1. Gather inputs

- **Name**: from the arguments or the request. Use it as the folder, repo and tmux session
  name, so keep it to lowercase letters, digits and `-`. Turning "Habit Tracker" into
  `habit-tracker` is just formatting; go ahead. Only confirm if you had to change the words
  (shortening, dropping parts). If no name was given, ask.
- **Description**: what the project is for, in the user's words. It feeds README.md and
  CLAUDE.md. If they gave none, ask in the same message as the GitHub question below.
- **GitHub**: always ask "GitHub repo too? private / public / no", unless the request already
  answered it. Default suggestion: private.

Ask everything missing in one message, not one question at a time.

## 2. Check before creating anything

- `~/code/<name>` must not exist. If it does, stop and tell the user. Never write into an
  existing folder: it may be a real project.
- If GitHub was requested: `gh repo view <name>` should fail (no repo by that name yet).
  If one exists, ask whether to pick another name or skip GitHub.

## 3. Create

```bash
mkdir -p ~/code/<name> && cd ~/code/<name> && git init -q   # first branch is "main" via ~/.gitconfig
```

Write two files:

**README.md**: `# <name>`, one or two sentences on what it is (from the description), and a
`## Getting started` section with `TODO` for now.

**CLAUDE.md**: instructions for agents working in this repo. Global preferences (uv, mise,
commit rules) already live in `~/.claude/CLAUDE.md`, so don't repeat them here. Keep it short:

```markdown
# <name>

<What this project is and who it's for, 1–3 sentences from the user's description.>

## Stack
<Languages/frameworks the user mentioned, or "TODO: not chosen yet".>

## Commands
- Run: TODO
- Test: TODO
- Lint: TODO

## Notes
<Anything specific the user said: constraints, goals, things to avoid. Omit if nothing.>
```

Only state facts the user gave you. Leave `TODO` rather than inventing a stack or commands;
a wrong CLAUDE.md misleads every future agent in this repo. Keep the user's certainty: "probably
Python" becomes "Python (tentative)", not "Python".

Then commit everything with the message `Initial commit`, following your usual commit
conventions (attribution trailers and so on).

## 4. GitHub (only if the user said yes)

```bash
gh repo create <name> --private --source . --remote origin   # or --public
# git over HTTPS doesn't use the gh login on this Mac by default; wire it up for this repo
git config --local credential.https://github.com.helper ''
git config --local --add credential.https://github.com.helper '!gh auth git-credential'
git push -q -u origin main
```

## 5. tmux session

Create a detached session the way `tms` names it (dots and colons become `_`):

```bash
tmux has-session -t=<name> 2>/dev/null || tmux new-session -d -s <name> -c ~/code/<name>
```

Don't switch the user's terminal to it: they're usually reading this conversation in a tmux
pane, and jumping away would hide your report. Tell them how to get there instead.

## 6. Report

A few lines: the path, the GitHub URL (leave that part out if there's no repo), and how to start:

```
~/code/<name>  ·  github.com/<user>/<name> (private)
Open it:  Ctrl-a f → <name>   (or: tms ~/code/<name>)
Then:     Ctrl-a C for Claude beside you
```
