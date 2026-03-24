#!/usr/bin/env bash
# Example: PhysNet retrain with extended splits (section 03 – PhysNet)
# Run from this directory: cd examples/mmml_tutorial/cli && bash 15_physnet_retrain_cli.sh
# Requires: extended NPZs under splits_extended/. Edit shared.source for trainer and checkpoint.

set -e
. ./shared.source

echo "=== 15: PhysNet retrain (extended splits) ==="

python "$PHYSNET_TRAINER" \
  --train out/splits/energies_forces_dipoles_train.npz splits_extended/energies_forces_dipoles_train.npz \
  --valid out/splits/energies_forces_dipoles_valid.npz splits_extended/energies_forces_dipoles_test.npz \
  --natoms "$PHYSNET_NATOMS" \
  --epochs "$PHYSNET_EPOCHS" \
  --name "$PHYSNET_NAME" \
  --ckpt-dir "$PHYSNET_CKPT_DIR" \
  --restart "$PHYSNET_CHECKPOINT"

echo "Output: $PHYSNET_CKPT_DIR/$PHYSNET_NAME/"
