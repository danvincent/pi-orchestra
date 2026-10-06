#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
EXTENSIONS_DIR="$AGENT_DIR/extensions"
AGENTS_DIR="$AGENT_DIR/agents"
PROMPTS_DIR="$AGENT_DIR/prompts"
SKILLS_DIR="$AGENT_DIR/skills"

# Find the pi subagent extension bundled with the pi package
find_subagent_ext() {
  # Search common install locations for the pi package
  for candidate in \
    "$HOME/.local/lib/node_modules/@earendil-works/pi-coding-agent" \
    /usr/local/lib/node_modules/@earendil-works/pi-coding-agent \
    /usr/lib/node_modules/@earendil-works/pi-coding-agent \
    "$HOME/.npm-global/lib/node_modules/@earendil-works/pi-coding-agent"; do
    if [[ -f "$candidate/examples/extensions/subagent/index.ts" ]]; then
      echo "$candidate/examples/extensions/subagent"
      return 0
    fi
  done
  # Try to find it via the pi binary
  local pi_script
  pi_script="$(command -v pi 2>/dev/null || true)"
  if [[ -n "$pi_script" ]]; then
    local pi_real
    pi_real="$(readlink -f "$pi_script" 2>/dev/null || echo "$pi_script")"
    local pi_dir
    pi_dir="$(dirname "$pi_real")"
    # Walk up to find the package root
    for _ in 1 2 3 4 5; do
      if [[ -f "$pi_dir/examples/extensions/subagent/index.ts" ]]; then
        echo "$pi_dir/examples/extensions/subagent"
        return 0
      fi
      if [[ -f "$pi_dir/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent/index.ts" ]]; then
        echo "$pi_dir/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent"
        return 0
      fi
      pi_dir="$(dirname "$pi_dir")"
    done
  fi
  echo "Could not locate pi subagent extension" >&2
  return 1
}

echo "Installing pi-orchestra..."
echo "  Agent dir: $AGENT_DIR"

mkdir -p "$EXTENSIONS_DIR" "$AGENTS_DIR" "$PROMPTS_DIR" "$SKILLS_DIR"

# 1. Install the subagent extension as a directory (pi requires index.ts in a dir)
SUBAGENT_SRC="$(find_subagent_ext)"
if [[ -z "${SUBAGENT_SRC:-}" ]]; then
  echo "WARNING: Could not find pi subagent extension. Install it manually:"
  echo "  mkdir -p $EXTENSIONS_DIR/subagent"
  echo "  ln -sf /path/to/pi/examples/extensions/subagent/index.ts $EXTENSIONS_DIR/subagent/index.ts"
  echo "  ln -sf /path/to/pi/examples/extensions/subagent/agents.ts $EXTENSIONS_DIR/subagent/agents.ts"
else
  mkdir -p "$EXTENSIONS_DIR/subagent"
  ln -sf "$SUBAGENT_SRC/index.ts" "$EXTENSIONS_DIR/subagent/index.ts"
  ln -sf "$SUBAGENT_SRC/agents.ts" "$EXTENSIONS_DIR/subagent/agents.ts"
  echo "  Subagent extension: $SUBAGENT_SRC"
fi

# 2. Copy agent definitions with model injection from models.json
if [[ ! -f "$REPO_ROOT/models.json" ]]; then
  echo "ERROR: models.json not found in $REPO_ROOT" >&2
  exit 1
fi

for f in "$REPO_ROOT"/agents/*.md; do
  name="$(basename "$f" .md)"
  model="$(node -e "const m=require('$REPO_ROOT/models.json');console.log(m['$name']||'')")"
  dest="$AGENTS_DIR/$(basename "$f")"
  if [[ -n "$model" ]]; then
    # Inject model field after the tools line in frontmatter
    node -e '
      const fs = require("fs");
      const content = fs.readFileSync(process.argv[1], "utf8");
      const model = process.argv[2];
      const dest = process.argv[3];
      let updated;
      if (content.includes("model:")) {
        updated = content.replace(/^model:.*$/m, "model: " + model);
      } else {
        updated = content.replace(/^(tools:.*)$/m, "$1\nmodel: " + model);
      }
      fs.writeFileSync(dest, updated);
    ' "$f" "$model" "$dest"
  else
    cp "$f" "$dest"
  fi
  echo "  Agent: $(basename "${f}")${model:+ -> $model}"
done

# 3. Copy prompt templates
for f in "$REPO_ROOT"/prompts/*.md; do
  cp "$f" "$PROMPTS_DIR/"
  echo "  Prompt: $(basename "$f")"
done

# 4. Copy skills
for d in "$REPO_ROOT"/skills/*/; do
  name="$(basename "$d")"
  mkdir -p "$SKILLS_DIR/$name"
  cp -r "$d" "$SKILLS_DIR/$name/"
  echo "  Skill: $name"
done

echo ""
echo "pi-orchestra installed!"
echo ""
echo "Restart pi. The 'subagent' tool is now available."
echo "Run /orchestra <goal> to start the conductor workflow."
echo ""
echo "To customize models per agent, edit the agent files in:"
echo "  $AGENTS_DIR"
echo "Set the 'model' frontmatter field to a provider/model ID."
