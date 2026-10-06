---
description: Implementation phase — implement, test, and dual review
argument-hint: "<phase objective>"
---
Use the subagent tool to execute this phase:

1. Invoke "implement" with: $@
2. Invoke "testing" to verify the implementation passes
3. Invoke "code-review" to review the changes
4. Invoke "peer-review" for a second opinion with a different model

If testing fails, route details back to "implement" and retry. If either review returns NEEDS_REVISION, route both summaries back to "implement" and retry.
