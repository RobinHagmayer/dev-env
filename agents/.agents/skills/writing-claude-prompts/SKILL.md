---
name: writing-claude-prompts
description: Writing prompts that Claude Opus 5.5 will run — subagent and workflow agent prompts, scheduled routine prompts, system prompts, task prompts the user asks you to draft, and stopping rules for CLAUDE.md. Use before drafting any prompt meant for another Claude.
---

# Writing Claude prompts

Write prompts for Claude Opus 5.5 following Anthropic's guidance for that model. The rules live in [RUBRIC.md](RUBRIC.md); read it before drafting.

## Process

1. Read [RUBRIC.md](RUBRIC.md).
2. Before drafting, work out the parts that rules R1–R3 need: the whole task and its context, a checkable finish line, and when to keep going or stop. If you can't work out the finish line or the stop rule from the conversation, ask the user once. Don't guess at them.
3. Draft the prompt. Apply only the rules whose **Applies when** matches this prompt.
4. Check the draft against every applicable rule and fix what fails.
5. Hand over or send the prompt. When the user asked for the prompt itself, give it in a code block, followed by one line listing the rules you applied.

## Boundaries

- Don't write rules into a prompt that the post doesn't support. The rubric is the whole standard.
- Keep the language the prompt will be used in. A German task gets a German prompt.
- To review or improve a prompt someone else wrote, use `/claude-prompt-review` instead.
