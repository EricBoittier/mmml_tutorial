#!/usr/bin/env bash
# Example: Active learning - extract MD frames for pyscf-evaluate (section 03 – PhysNet)
# Run from project root: bash examples/mmml_tutorial/cli/14_active_learning.sh
# Requires: Step 13 run first (physnet_ase.traj in programmatic/out/physnet_md/).
<<<<<<< HEAD
TRAJ=out/physnet_ase.traj
echo "Input: $TRAJ"
echo "Command: uv run mmml active-learning -i $TRAJ -o programmatic/out/md_sampled.npz --max-temp 300"
cd "$SCRIPT_DIR"
uv run mmml active-learning \
  -i "$TRAJ" \
  -o out/md_sampled.npz \
=======

echo "=== 14: Active learning (extract frames for pyscf-evaluate) ==="
echo "Extract frames with T < 300 K from PhysNet MD trajectory"
echo ""

cd "$SCRIPT_DIR"
mmml active-learning \
  -i "out/physnet_md/physnet_ase.traj" \
  -o out/activate_learning.npz \
>>>>>>> 3ca1dc8 (asdf)
  --max-temp 300

echo ""
echo "Output: programmatic/out/md_sampled.npz"
echo "Next: mmml pyscf-evaluate -i programmatic/out/md_sampled.npz -o programmatic/out/md_evaluated.npz --esp"
echo "Then: mmml fix-and-split --efd cli/out/splits/energies_forces_dipoles_train.npz programmatic/out/md_evaluated.npz -o cli/out/splits_extended"
