#!/usr/bin/env bash
# Example: Active learning - extract MD frames for pyscf-evaluate (section 03 – PhysNet)
# Run from project root: bash examples/mmml_tutorial/cli/14_active_learning.sh
# Requires: Step 13 run first (physnet_ase.traj in out/physnet_md/).

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== 14: Active learning (extract frames for pyscf-evaluate) ==="
echo "Extract frames with T < 300 K from PhysNet MD trajectory"
echo ""

cd "$SCRIPT_DIR"
mmml active-learning \
  -i "out/physnet_md/physnet_ase.traj" \
  -o out/activate_learning.npz \
  --max-temp 300

echo ""
echo "Output: out/activate_learning.npz"
echo "Next: mmml pyscf-evaluate -i out/activate_learning.npz -o out/md_evaluated.npz --esp"
echo "Then: mmml fix-and-split --efd out/splits/energies_forces_dipoles_train.npz out/md_evaluated.npz -o out/splits_extended"
