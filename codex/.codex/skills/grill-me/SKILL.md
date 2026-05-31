---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when the user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

# Grill Me

Interview the user relentlessly about every aspect of a plan or design until you reach shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one by one.

For each question:

1. Explain why the question matters.
2. Provide your recommended answer.
3. Ask for the user's answer in free-form prose.

If a question can be answered by exploring the codebase, explore the codebase instead. Prefer repository evidence over asking the user for discoverable facts.

Keep pressure constructive: challenge contradictions, missing edge cases, fragile assumptions, security risks, and over-engineering, but accept an explicit user decision after it has been stress-tested.
