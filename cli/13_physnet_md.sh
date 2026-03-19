#!/usr/bin/env bash
# Example: PhysNet MD sampling with ASE and JAX-MD (section 03 – PhysNet)
# Run from project root: bash examples/mmml_tutorial/cli/13_physnet_md.sh
# Requires: Step 09 run first (PhysNet checkpoint in cli/out/ckpts/cybz_physnet/).

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT/examples/mmml_tutorial"

echo "=== 13: PhysNet MD sampling (ASE + JAX-MD) ==="
echo "Command: uv run mmml physnet-md --checkpoint examples/mmml_tutorial/cli/out/ckpts/cybz_physnet --data examples/mmml_tutorial/cli/out/splits/energies_forces_dipoles_train.npz -o examples/mmml_tutorial/programmatic/out"
cd "$SCRIPT_DIR"
uv run mmml physnet-md \
  --checkpoint cli/out/ckpts/cybz_physnet \
  --data cli/out/splits/energies_forces_dipoles_train.npz \
  -o programmatic/out
echo "Output: programmatic/out/physnet_ase.traj, physnet_ase_final.xyz, physnet_jaxmd.xyz"
