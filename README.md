# pi-orchestra

> A multi-agent orchestration system for structured, test-driven software development with Pi.

Port of [opencode-orchestra](https://github.com/anomalyco/opencode-orchestra) for the Pi coding agent.

The pi-orchestra keeps things simple. A clear plan phase, an implementation phase with automated quality gates, and a commit stop — that's it. No cryptic command names, no sprawling config, no plugin that takes over your entire Pi session. Just a robust, readable workflow that gets out of your way.

## Architecture

```
Conductor (main agent, read-only)
├── Planning
│   ├── Planning (expensive thinking model)
│   │   ├── Explore (cheap model, codebase research)
│   │   └── MCP (read-only, sole MCP operator)
├── Implementation
│   ├── MCP (if needed)
│   ├── Implement (sole editor, TDD + lint + typecheck; also builds & deploys)
│   └── Testing (read-only test runner)
├── Code Review (read-only)
├── Peer Review (read-only, different model)
├── Review Recommendations (read-only, efficiency-focused)
├── SDD Architect (read-only, traceable specifications)
└── Commit suggestion (user commits)
```

Quality gate: both `code-review` and `peer-review` must return `APPROVED`.

## Agents

No per-agent model is injected by default. If the `model` field is unset in an agent's frontmatter, Pi inherits the active model from the main session. Users may override per-agent by editing the agent file.

| Agent | Tools | Model | Role |
|---|---|---|---|
| `planning` | read, grep, find, ls | inherits | Complex planning (thinking model); delegates explore/MCP |
| `explore` | read, grep, find, ls | inherits | Fast codebase research, returns structured findings |
| `mcp` | read | inherits | Sole MCP operator, returns filtered summaries |
| `implement` | read, grep, find, ls, bash, edit, write | inherits | TDD implementation, lint, typecheck, build & deploy |
| `testing` | read, grep, find, ls, bash | inherits | Runs tests, returns PASS/FAIL with failure excerpts |
| `code-review` | read, grep, find, ls, bash | inherits | Reviews changes, returns structured verdict |
| `peer-review` | read, grep, find, ls, bash | inherits | Second review with a different model |
| `review-recommendations` | read, grep, find, ls, bash | inherits | Prioritised code review recommendations (efficiency-focused) |
| `sdd-architect` | read, grep, find, ls | inherits | Interactive SDD architect, produces traceable Markdown specifications |

## Installation

```bash
git clone https://github.com/your-org/pi-orchestra.git
cd pi-orchestra
./install.sh
```

The install script:
1. Copies the vendored `subagent` extension (`extensions/subagent/`, live-streaming patched) into `~/.pi/agent/extensions/`
2. Copies agent definitions to `~/.pi/agent/agents/`
3. Copies prompt templates to `~/.pi/agent/prompts/`
4. Copies skills to `~/.pi/agent/skills/`

Restart pi after installation.

## Workflow

1. **Planning**: Conductor invokes the `planning` subagent (expensive thinking model). The planning agent calls `explore` (cheap model) for codebase research and optionally `mcp` for external data, then synthesizes a structured plan. Conductor presents it to the user and stops for approval.
2. **Implementation** (per phase): Implement creates TDD code → Testing verifies it passes → Code Review + Peer Review both must approve.
3. **Build & Deploy** (on-demand): Conductor may delegate build or deploy tasks to the Implement agent, which runs the build commands and/or deploy scripts.
4. **Commit stop**: Conductor prints a suggested git commit message and command block, waits for user to commit.
5. **Completion**: Final summary when all phases done.

## Usage

```
/orchestra <goal>          # Full conductor workflow
/plan <goal>               # Planning phase only
/implement <objective>     # Implement + test + dual review
/review [focus]            # Code review + peer review
/sdd <feature idea>        # SDD architect workflow
```

## Model Configuration

Edit `models.json` in the project root to set models for all agents in one place:

```json
{
  "planning": "opencode-go/kimi-k3",
  "peer-review": "opencode-go/mimo-v2.5",
  "explore": "opencode-go/deepseek-v4-flash",
  "implement": "opencode-go/deepseek-v4-flash"
}
```

Run `./install.sh` to apply changes. The script injects the `model` field into each agent's frontmatter during installation.

When `model` is omitted, the subagent inherits the active model from the main session.

## Contributing

Add new subagents by creating `agents/<name>.md` with appropriate frontmatter and tools list.

## License

MIT
