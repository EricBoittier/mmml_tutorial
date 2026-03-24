#!/usr/bin/env bash
# Example: Active learning - extract MD frames for pyscf-evaluate (section 03 – PhysNet)
# Run from this directory: cd examples/mmml_tutorial/cli && bash 14_active_learning.sh
# Requires: Step 13 (trajectory at PHYSNET_MD_TRAJ). Edit shared.source for paths.

set -e
. ./shared.source

echo "=== 14: Active learning (extract frames for pyscf-evaluate) ==="
echo "Extract frames with T < 300 K from PhysNet MD trajectory"
echo ""

mmml active-learning \
  -i "$PHYSNET_MD_TRAJ" \
  -o "$ACTIVE_LEARNING_OUT" \
  --max-temp 300

echo ""
echo "Output: $ACTIVE_LEARNING_OUT"
echo "Next: mmml pyscf-evaluate -i $ACTIVE_LEARNING_OUT -o out/md_evaluated.npz --esp"
echo "Then: mmml fix-and-split --efd $PHYSNET_TRAIN_NPZ out/md_evaluated.npz -o out/splits_extended"
