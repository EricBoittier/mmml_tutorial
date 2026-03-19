#!/usr/bin/env bash
# Example: Active learning - extract MD frames for pyscf-evaluate (section 03 – PhysNet)
# Run from project root: bash examples/mmml_tutorial/cli/14_active_learning.sh
# Requires: Step 13 run first (physnet_ase.traj in programmatic/out/physnet_md/).

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT/examples/mmml_tutorial"

echo "=== 14: Active learning (extract frames for pyscf-evaluate) ==="
echo "Extract frames with T < 300 K from PhysNet MD trajectory"
echo ""

# Use physnet_ase.traj from step 13 if available
TRAJ="${1:-programmatic/out/physnet_md/physnet_ase.traj}"
if [ ! -f "$TRAJ" ]; then
  echo "Trajectory not found: $TRAJ"
  echo "Run step 13 first: mmml physnet-md --checkpoint ... -o programmatic/out/physnet_md"
  echo "Or pass trajectory path: bash 14_active_learning.sh /path/to/traj.traj"
  exit 1
fi

echo "Input: $TRAJ"
echo "Command: uv run mmml active-learning -i $TRAJ -o programmatic/out/md_sampled.npz --max-temp 300"
cd "$SCRIPT_DIR"
uv run mmml active-learning \
  -i "$TRAJ" \
  -o programmatic/out/md_sampled.npz \
  --max-temp 300

echo ""
echo "Output: programmatic/out/md_sampled.npz"
echo "Next: mmml pyscf-evaluate -i programmatic/out/md_sampled.npz -o programmatic/out/md_evaluated.npz --esp"
echo "Then: mmml fix-and-split --efd cli/out/splits/energies_forces_dipoles_train.npz programmatic/out/md_evaluated.npz -o cli/out/splits_extended"
