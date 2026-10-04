---
name: scoped-commits
description: Use when writing a commit message, committing staged changes, amending, squashing, or rewording history.
---

Scoped Commits is a loose standard for commit messages: the **scope** — the subsystem, area, or module the commit touches — leads the subject line, because that is what everyone reading a log is scanning for.

```
<scope>: <description>

[optional body]

[optional trailer(s)]
```

Only the scope and description are required. Reverts, merges, and other special commits are exempt (see _Special commits_).

Real subject lines from projects that work this way:

| Project | Subject |
|---|---|
| Linux | `i2c: virtio: mark device ready before registering the adapter` |
| FreeBSD | `linuxulator: Return EINVAL for invalid inotify flags` |
| Git | `gitlab-ci: update macOS image` |
| Go | `net/http/cookiejar: add godoc links` |
| nixpkgs | `xwayland: 24.1.11 -> 24.1.12` |

## Process

### 1. Read the change

`git diff --staged` (or the range being reworded). The subject line is a claim about what the diff does — make it from the diff, not from the conversation that led to it, which usually describes intent rather than what landed.

Done when you can name every file the commit touches and say why it changed.

### 2. Learn the project's scope vocabulary

Scopes are per-project, and the value of the format comes from a log where the same area always carries the same word. Look in this order:

1. Documented rules — `CONTRIBUTING.md`, `docs/`, `.gitmessage`, a commit template, a commitlint config. Projects using Scoped Commits often pin the valid scopes and the description style there. A documented rule wins over everything below.
2. The live vocabulary — `git log --no-merges --format='%s' -n 100`. The text before the first colon is the scope set the project actually uses.

Done when you can quote either a documented rule or prior subject lines using the scope you are about to write — or say plainly that the project has no convention yet and you are setting one.

### 3. Name the scope

The scope answers _where_, so reach for the name the project's contributors use for that area:

- a module or directory path — `net/http/cookiejar`, `parser`
- a component or feature area — `auth`, `billing`
- an infrastructure or build area — `gitlab-ci`, `docs`, `deps`

Reuse an existing scope verbatim when one fits. `auth` and `authentication` as two spellings of one area split the log into two piles that no grep finds at once.

Nested scopes narrow the area (`i2c: virtio:`) when the project already writes them that way.

When the change spans several areas, take the first of these that works:

1. A more general scope that covers all of them.
2. The scopes separated by commas.
3. `treewide`, `all`, or `global` if it touches the whole tree.
4. Failing those, treat it as a special commit: drop the scope and write a very good description.

### 4. Write the description

A short summary of what the change does, in the mood and capitalization the project's log already uses (imperative and lowercase is the common default — `add`, `fix`, `mark`). Aim for a subject line, scope included, under ~72 characters.

Make it specific enough to be recognized on its own: `auth: fix login bug` earns its place in a log scan; `auth: fix bug` does not.

### 5. Add a body when the diff leaves a question open

Blank line, then prose wrapped at ~72 characters. The body carries what the diff cannot show: why the change was needed, the approach and what was rejected, consequences for callers, the reproduction a fix closes. Skip it when the subject line already says everything — a version bump needs no body.

### 6. Add trailers when the project uses them

Blank line, then `Key: value` lines — `Jira-Ticket: PROJ-123`, `Signed-off-by:`, `Co-Authored-By:`, `Fixes: #123`. Follow whatever step 2 turned up.

A ticket number goes either in parentheses after the scope or in a trailer; match the project:

```
auth (PROJ-123): fix login bug
```

```
auth: fix login bug

Jira-Ticket: PROJ-123
```

## Scope names an area, not a category

`feat`, `fix`, `chore`, `refactor` classify the _kind_ of change and tell a reader nothing about where to look — that is Conventional Commits, a different standard. Under Scoped Commits the leading word is always the part of the system that changed, and the kind of change is left to the description's verb.

The two formats look similar enough to blend by accident. `fix(auth): login bug` is Conventional Commits; the Scoped Commits line for the same change is `auth: fix login bug`.

## Special commits

Reverts, merges, and the like take any format. Git's own default revert message is fine; so is a custom one that carries the original commit's scope. Some projects pin a format for these too — step 2 finds it.

## Why the scope leads

Three readers scan a log, and all three scan it by area:

- **Contributors** catching up on a part of the codebase, reading the project's inertia, or hunting for commits that will collide with work in progress.
- **Debuggers** looking for recent changes near the component where a bug showed up.
- **Incident responders** reading the log around the time production broke — an `auth` commit at the start of an API error spike is an immediate suspect.

None of them is scanning for whether something was a feature or a chore. Putting the area first makes the log answer the question it is usually asked.

One thing this format deliberately does not buy: generated changelogs. A commit log is written for contributors tracking how the code got here; a changelog is written for users tracking what changed between releases. Write the changelog separately.
