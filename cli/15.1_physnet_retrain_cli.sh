#!/usr/bin/env bash
# Example: PhysNet retrain with multiple extended splits (section 03 – PhysNet)
# Run from this directory: cd examples/mmml_tutorial/cli && bash 15.1_physnet_retrain_cli.sh
# Requires: splits_extended/, splits_extended2/. Edit shared.source for trainer and checkpoint.

set -e
. ./shared.source

echo "=== 15.1: PhysNet retrain (multi extended splits) ==="

python "$PHYSNET_TRAINER" \
  --train out/splits/energies_forces_dipoles_train.npz splits_extended/energies_forces_dipoles_train.npz splits_extended2/energies_forces_dipoles_train.npz \
  --valid out/splits/energies_forces_dipoles_valid.npz splits_extended/energies_forces_dipoles_valid.npz splits_extended2/energies_forces_dipoles_valid.npz \
  --natoms "$PHYSNET_NATOMS" \
  --batch-size "$PHYSNET_BATCH" \
  --epochs 1500 \
  --charges \
  --name "$PHYSNET_NAME" \
  --ckpt-dir "$PHYSNET_CKPT_DIR" \
  --restart "$PHYSNET_CHECKPOINT"

echo "Output: $PHYSNET_CKPT_DIR/$PHYSNET_NAME/"
