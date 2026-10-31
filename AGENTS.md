# AGENTS.md

## Global Coding Standards

1. **YAGNI**: Don't build it until you need it
2. **DRY**: Extract patterns after second duplication, not before
3. **Fail Fast**: Explicit errors beat silent failures
4. **Simple First**: Write the obvious solution, optimize only if needed
5. **Delete Aggressively**: Less code = fewer bugs
6. **Semantic Naming**: Always name variables, parameters, and API endpoints with verbose, self-documenting names that optimize for comprehension by both humans and LLMs, not brevity (e.g., `wait_until_obs_is_saved=true` vs `wait=true`)

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

## Core Principles

Challenge me on the changes and do not make a PR until I pass your tests.
The job is not done until you have proved it works.
After a mediocre fix, say: "Knowing everything you know now, scrap this and implement the elegant solution."
