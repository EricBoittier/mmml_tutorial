#!/usr/bin/env bash
# Example: PhysNet MD sampling with ASE and JAX-MD (section 03 – PhysNet)
# Run from project root: bash examples/mmml_tutorial/cli/13_physnet_md.sh
# Requires: Step 09 run first (PhysNet checkpoint in cli/out/ckpts/cybz_physnet/).

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

echo "=== 13: PhysNet MD sampling (ASE + JAX-MD) ==="
echo "Command: uv run python examples/mmml_tutorial/programmatic/13_physnet_md_programmatic.py"
uv run python examples/mmml_tutorial/programmatic/13_physnet_md_programmatic.py
echo "Output: programmatic/out/13_physnet_ase.traj, 13_physnet_ase_final.xyz, 13_physnet_jaxmd.xyz"
