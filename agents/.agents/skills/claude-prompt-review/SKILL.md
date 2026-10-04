---
name: claude-prompt-review
description: Review a prompt for Claude Opus 5.5 against Anthropic's guidance and return findings plus an optimized version.
disable-model-invocation: true
---

# Claude prompt review

Review a prompt meant for Claude Opus 5.5 and optimize it. The prompt may come from another agent, from the user, or from you.

The standard is the shared rubric at `~/.agents/skills/writing-claude-prompts/RUBRIC.md`. Read it first. Use no rules beyond it.

## Input

The argument is a file path or pasted prompt text. If neither was given, ask for the prompt and stop.

## Process

1. Read the rubric and the prompt.
2. Decide which rules apply, using each rule's **Applies when** line. Note what the prompt is for (coding task, long unattended run, research, design, review, document audit, chat) since that decides which rules apply.
3. Check the prompt against each applicable rule. A finding needs the exact passage (or "missing") and the rule it breaks.
4. Write the optimized prompt. Change only what a finding requires. Keep the author's wording, structure and language everywhere else.
5. Where a fix needs facts only the author has (the real finish line, which actions count as destructive, which design patterns to avoid), put a visible placeholder like `[FINISH LINE: ?]` and list it under open questions. Never invent the fact.

## Output

Answer in chat, in this order:

1. **Open questions**: placeholders the author must fill. Omit the section if there are none.
2. **Findings**: one line per finding: rule ID, the quoted passage or "missing", what to change. Most important first: missing finish lines and stop rules come before wording issues.
3. **Optimized prompt**: the full rewritten prompt in a code block.
4. **Outside the rubric** (optional): problems you noticed that no rule covers, labelled as your own observation, not guidance from the post.

If the prompt passes every applicable rule, say so and don't rewrite it.

Write the optimized prompt back to the file only if the user asks.
