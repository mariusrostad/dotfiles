# AGENTS.md

## Workflow Orchestration

### 1. Plan Before Acting

- Plan any non-trivial task before writing code, especially tasks with 3+ steps or architectural decisions.
- If something goes sideways, stop and re-plan before continuing.
- Include verification steps in the plan, not just implementation steps.
- Write detailed specs up front when ambiguity would otherwise leak into implementation.

### 2. Parallel And Subagent Strategy

- Use available parallel tools and subagents to keep the main context focused.
- Offload research, exploration, and independent analysis when the tooling supports it.
- For complex problems, spend more compute on isolated investigation before editing.
- Keep each delegated task focused on one line of inquiry or one implementation concern.

### 3. Self-Improvement Loop

- After any correction from the user, update `scratchpads/<feature>/tasks/lessons.md` with the pattern.
- Write rules that prevent the same mistake from recurring.
- Iterate on these lessons until the mistake rate drops.
- Review relevant lessons at session start when working in an existing project.

### 4. Verification Before Done

- Never declare a task complete without proving it works.
- Diff behavior before and after changes when relevant.
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, and demonstrate correctness.

### 5. Demand Elegance (Balanced)

- For non-trivial changes, pause and ask: "Is there a more elegant way?"
- If a fix feels hacky, say: "Knowing everything I know now, implement the elegant solution."
- Skip this for simple, obvious fixes; do not over-engineer.
- Challenge your own work before presenting it.

### 6. Autonomous Bug Fixing

- When given a bug report, fix it without asking for hand-holding.
- Point at logs, errors, and failing tests, then resolve them.
- Minimize context switching for the user.
- Fix failing CI tests without being told how.

---

## Task Management

1. **Plan First**: Write the plan to `scratchpads/<feature>/tasks/todo.md` with checkable items.
2. **Verify Plan**: Check in before starting implementation when the work is non-trivial or high-risk.
3. **Track Progress**: Mark items complete as you go.
4. **Explain Changes**: Provide a high-level summary at each step.
5. **Document Results**: Add a review section to `scratchpads/<feature>/tasks/todo.md`.
6. **Capture Lessons**: Update `scratchpads/<feature>/tasks/lessons.md` after corrections.

---

## Core Principles

Challenge me on the changes and do not make a PR until I pass your tests.

The job is not done until you have proved it works.

After a mediocre fix, say: "Knowing everything you know now, scrap this and implement the elegant solution."
