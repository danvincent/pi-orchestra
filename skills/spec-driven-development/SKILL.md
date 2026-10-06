---
name: spec-driven-development
description: Use when turning a feature idea into a traceable SDD specification with phased checkpoints before any implementation.
---

# Spec-Driven Development

Produce a traceable, machine-readable spec. Stay read-only. Never implement. Advance only on explicit user approval. Treat the latest explicit user decision as authoritative.

## Operating rules

- Label every assumption. Never present an assumption as a requirement.
- Never fabricate paths, links, APIs, schemas, test results, or external contents.
- Resolve conflicts by precedence: explicit user decisions > approved global rules > existing repo behavior/contracts > linked external docs > earlier unapproved drafts > labelled assumptions.
- Use UTC timestamps.

## Standards

- Gate every phase on approval. Never skip ahead.
- Define negative scope (anti-goals, out of scope) explicitly.
- Express data models, schemas, and API shapes only as machine-readable contracts (TypeScript, Zod, JSON Schema, or OpenAPI). Keep prose adjacent, never as fake schema fields.
- Use the project's existing contract format when one exists; otherwise pick one canonical format and state it.
- Define request, response, error, persisted-state, and event contracts separately where applicable. Include validating examples when helpful.
- Write acceptance criteria as testable `Given / When / Then` (EARS). Avoid subjective words.
- Assign stable IDs (`REQ-001`, `AC-001`). Cite a source per requirement. Map each `AC-*` to a test target.
- If the feature is too large for one coding-agent context (INVEST), warn and propose smaller independent specs.

## Error contract minimum

```ts
interface ErrorResponse {
  code: string;
  message: string;
  retryable: boolean;
  details?: Record<string, unknown>;
}
```

Follow repo conventions; keep at least these fields.

## Phase 1 — Discovery and playback

- Read the feature proposal.
- Reply with: core goal (1 sentence); included features (bullets); known constraints (bullets); open ambiguities.
- Ask for confirmation or clarification. Stop and wait.

## Phase 2 — Context and constitution gathering

- Ask: global rules (`CONSTITUTION.md` or shared spec?). If none, record `No global constitution provided`.
- Ask: local context (exact file paths, folders, API functions). If the user cannot name them, request permission for a targeted read-only repo exploration.
- Ask: external context (Jira, PR, Confluence links). Record inaccessible links as unresolved references; never claim their contents.
- Stop and wait.

## Phase 3 — Straw-man plan

- Draft the high-level plan. Cite the source of every requirement (`[User Prompt]`, `[Jira-123]`, `[src/auth.ts:42]`).
- Ask the user to confirm directional accuracy. Stop and wait.

## Phase 4 — Grill-me interrogation

- Ask 1–2 hard questions at a time. Iterate until no major ambiguity remains.
- Cover: edge cases, error handling, failure states, retry behavior, migrations and rollback, compatibility, and what is strictly out of scope.
- Stop only when every requirement, contract, failure state, migration, scope boundary, and acceptance criterion is decided or explicitly deferred/out of scope.
- Stop and wait.

## Phase 5 — Assumption checkpoint

- Restate final technical and product assumptions.
- List unresolved risks the user deferred.
- Stamp a version (`v-YYYY.MM.DD-HHMM`, UTC).
- Ask for final approval to generate the spec. Stop and wait.

## Phase 6 — Final SDD generation

Emit one Markdown document with the version at the top and three sections:

### 1. PO view (business and scope)

- Business value, in scope, out of scope (anti-goals), acceptance criteria (`AC-001`, `Given / When / Then`).

### 2. Dev/QA view (architecture and data)

- Global context (link constitution or state `No global constitution provided`).
- Data contracts as machine-readable schemas.
- Edge cases and error matrix (trigger, code, response, retryability).
- Database migrations (steps, rollback, backfill, destructive-change policy) if applicable.
- Testing strategy mapping each `AC-*` to unit/integration/e2e targets.

### 3. Agent view (execution checklist)

- Target files (exact paths; mark unknowns `TBD` with reason and validation step).
- Sequential implementation steps.
- Constraints and guardrails.
- Verification (tests, commands, manual checks).
