# Opus 5.5 prompt rubric

Source: Anthropic, "Getting the most out of Opus 5.5" (https://claude.dev/blog/getting-the-most-out-of-opus-5-5/), last fetched 2026-09-23. Every rule below comes from that post. Do not add rules from elsewhere; if a prompt has a problem no rule covers, report it as outside the rubric.

Each rule has an **Applies when** line. Skip rules that don't apply to the prompt at hand; a chat question does not need a TASKS.md.

## Asking

### R1. Whole task in one message
**Applies when:** always.
**Check:** the prompt hands over the entire task, with the context needed to do it, instead of drip-feeding steps or leaving parts for later messages.
**Fix:** merge the pieces into one message. If context is missing, name what is missing; do not invent it.

### R2. Finish line
**Applies when:** the prompt asks for work, not a single answer.
**Check:** it says what "done" looks like in a way the model can verify ("the tests pass", "every endpoint is migrated").
**Fix:** add one concrete, checkable finish line.

### R3. Stopping conditions
**Applies when:** the work runs over several steps, especially unattended.
**Check:** it says when to keep going and when to stop and ask. It rules out destructive actions: deleting data, force-pushing, changing anything outside the repository.
**Fix:** add a stop rule, e.g. "When a step doesn't need my input, keep going. Stop only if a test fails and you can't explain why. Stop before anything destructive: deleting data, force-pushing, or changing anything outside this repository." For rules that should hold across sessions, put them in CLAUDE.md instead.

### R4. No thinking directives
**Applies when:** always.
**Check:** no "think carefully", "think step by step", "think hard" or similar. Opus 5.5 already thinks before every response.
**Fix:** delete them. If the goal is a fast answer, say "Answer directly." In Claude Code, thinking depth is controlled with the effort level, not with prompt text.

### R5. Design: list what to avoid
**Applies when:** the prompt asks for visual design (UI, pages, slides, graphics).
**Check:** it lists specific patterns to exclude, not only generic taste words ("modern", "clean").
**Fix:** add an exclusion list. The post's examples: cream backgrounds, italic headings, "01 / 02 / 03" labels, monospace formatting, pill buttons. Tell the author to extend the list after seeing results.

### R6. Attach visuals, don't transcribe them
**Applies when:** the prompt contains data that came from a chart, diagram, screenshot or slide.
**Check:** the source is attached rather than retyped into the prompt.
**Fix:** replace the transcription with the attached image or file.

## Long runs

### R7. Fan out large work to subagents
**Applies when:** audits, migrations, or reviews of a large codebase.
**Check:** it asks for the work to be split across parallel subagents, each result verified before it is merged, and the findings combined into a summary table.
**Fix:** add that instruction.

### R8. Task list in a file
**Applies when:** runs long enough that context may be summarized.
**Check:** progress is kept in a tracked file (e.g. TASKS.md), not only in the conversation.
**Fix:** tell the model to keep and update a checklist file.

## Results

### R9. Blockers first in the summary
**Applies when:** the run ends with a summary for a human.
**Check:** the summary format puts what the model needs from the human first.
**Fix:** specify the format, e.g. "End with: Blocked on me, Changed, Found."

### R10. Review passes report only blocking issues
**Applies when:** the prompt asks for a review of a diff or pull request.
**Check:** it asks for blocking issues only, each with file and line, why it fails, and how to reproduce it.
**Fix:** add those output requirements.

### R11. Mark unconfirmed information
**Applies when:** research or analysis.
**Check:** it asks the model to flag anything it could not verify and say where it tried to verify it.
**Fix:** add that instruction.

### R12. Document audits cite locations
**Applies when:** the prompt asks for a check of a long plan, report or deck.
**Check:** it asks for contradictions in numbers, dates, names and cross-references, each with its exact location.
**Fix:** add those categories and the location requirement.

### R13. Specify the deliverable
**Applies when:** the output is a spreadsheet, document or other file.
**Check:** it names the format and the structure: columns, sections, formatting.
**Fix:** add the structure.

## Conversation

### R14. Lock earlier answers, but not in analysis
**Applies when:** long projects with many separate questions.
**Check:** long Q&A-style projects include "Once you have answered something, treat that answer as done. Focus on what I'm asking now, and don't go back over an earlier answer unless I ask about it." Analytical projects, where later findings may overturn earlier conclusions, must not include it.
**Fix:** add or remove the instruction accordingly.

### R15. Don't ask for internal reasoning
**Applies when:** always.
**Check:** the prompt does not ask the model to reproduce its internal reasoning or thinking in the reply. Such requests are declined and can get the message flagged.
**Fix:** ask for a plain-language explanation of the approach or the decisions instead.
