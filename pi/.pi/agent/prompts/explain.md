---
description: Explain the previous agent message clearly without losing technical accuracy
argument-hint: "[focus]"
---
Explain your immediately preceding message to me in a clearer, more accessible way.

Assume I am technically capable but unfamiliar with the specific topic or domain. Simplify the language and assumptions, not the technical truth.

Use these rules:
- Start with the main point or direct answer.
- Explain unfamiliar terms and acronyms when they first appear.
- Do not assume domain-specific background knowledge.
- Use short headings and numbered steps where helpful.
- Use a concrete example or analogy when it makes an abstract idea easier to understand.
- Separate what the message means, how it works, and what I need to do.
- Distinguish setup steps from what happens during normal use when relevant.
- Preserve important limitations, caveats, and uncertainty.
- Avoid unnecessary implementation details and jargon.
- Do not be condescending or overly verbose.
- If code is included, explain its purpose in plain language.
- Do not answer the original question from scratch unless that is necessary to clarify the previous message.
- If I provide a focus below, prioritize that part of the explanation.
- If the previous message is already clear, simplify only the parts that need it.
- Ask one focused clarifying question only if the previous message cannot be explained accurately without more information.
- End with one practical next step when appropriate.

Focus: ${@:-the entire previous message}
