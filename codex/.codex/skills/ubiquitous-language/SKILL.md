---
name: ubiquitous-language
description: Extract a DDD-style ubiquitous language glossary from the current conversation, flagging ambiguities and proposing canonical terms. Saves to UBIQUITOUS_LANGUAGE.md. Use when the user wants to define domain terms, build a glossary, harden terminology, create a ubiquitous language, or mentions "domain model" or "DDD".
---

# Ubiquitous Language

Extract and formalize domain terminology from the current conversation into a consistent glossary, saved to a local file.

## Process

1. Scan the conversation for domain-relevant nouns, verbs, and concepts.
2. Explore the repository when domain language can be inferred from code, docs, specs, schemas, tests, or existing glossary files.
3. Identify terminology problems:
   - Same word used for different concepts.
   - Different words used for the same concept.
   - Vague or overloaded terms.
4. Propose a canonical glossary with opinionated term choices.
5. Write to `UBIQUITOUS_LANGUAGE.md` in the working directory.
6. Output a concise summary inline in the conversation.

## Output Format

Write `UBIQUITOUS_LANGUAGE.md` with this structure:

```md
# Ubiquitous Language

## Order lifecycle

| Term | Definition | Aliases to avoid |
|------|------------|------------------|
| **Order** | A customer's request to purchase one or more items. | Purchase, transaction |
| **Invoice** | A request for payment sent to a customer after delivery. | Bill, payment request |

## People

| Term | Definition | Aliases to avoid |
|------|------------|------------------|
| **Customer** | A person or organization that places orders. | Client, buyer, account |
| **User** | An authentication identity in the system. | Login, account |

## Relationships

- An **Invoice** belongs to exactly one **Customer**.
- An **Order** produces one or more **Invoices**.

## Example dialogue

> **Dev:** "When a **Customer** places an **Order**, do we create the **Invoice** immediately?"
> **Domain expert:** "No. An **Invoice** is only generated once a **Fulfillment** is confirmed."
> **Dev:** "So if a **Shipment** is cancelled before dispatch, no **Invoice** exists for it?"
> **Domain expert:** "Exactly. The **Invoice** lifecycle is tied to the **Fulfillment**, not the **Order**."

## Flagged ambiguities

- "account" was used to mean both **Customer** and **User**. These are distinct concepts: a **Customer** places orders, while a **User** is an authentication identity that may or may not represent a **Customer**.
```

## Rules

- Be opinionated. When multiple words exist for the same concept, pick the best one and list the others as aliases to avoid.
- Flag conflicts explicitly. If a term is ambiguous, call it out in "Flagged ambiguities" with a clear recommendation.
- Keep definitions tight. One sentence max. Define what the term is, not what it does.
- Show relationships. Use bold term names and express cardinality where obvious.
- Only include domain terms. Skip generic programming concepts unless they have domain-specific meaning.
- Group terms into natural clusters by subdomain, lifecycle, actor, or workflow. Do not force groupings when one table is clearer.
- Write a short example dialogue of 3-5 exchanges that demonstrates the terms in context.

## Re-running

When invoked again in the same conversation:

1. Read the existing `UBIQUITOUS_LANGUAGE.md`.
2. Incorporate new terms from subsequent discussion.
3. Update definitions if understanding has evolved.
4. Mark changed entries with "(updated)" and new entries with "(new)".
5. Re-flag any new ambiguities.
6. Rewrite the example dialogue to incorporate new terms.

## Post-output Instruction

After writing the file, state:

> I've written/updated `UBIQUITOUS_LANGUAGE.md`. From this point forward I will use these terms consistently. If I drift from this language or you notice a term that should be added, let me know.
