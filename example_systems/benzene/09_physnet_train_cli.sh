#!/usr/bin/env bash
# Example: Train PhysNet on energies, forces, dipoles (section 03 – PhysNet)
# Run from this directory: cd cli && bash 09_physnet_train_cli.sh
# Requires: Step 08 run first (out/splits/). Edit shared.source for trainer path and ckpt dir.

PHYSNET_TRAIN_NPZ=./out/splits/aco/energies_forces_dipoles_train.npz
PHYSNET_VALID_NPZ=./out/splits/aco/energies_forces_dipoles_valid.npz
PHYSNET_NATOMS=20
PHYSNET_BATCH=16
PHYSNET_EPOCHS=10000
PHYSNET_NAME=aco1
PHYSNET_CKPT_DIR="./ckpts"
echo "=== 09: PhysNet training ==="
echo "Command: python \"\$PHYSNET_TRAINER\" --train \"\$PHYSNET_TRAIN_NPZ\" --valid \"\$PHYSNET_VALID_NPZ\" --natoms \$PHYSNET_NATOMS --epochs \$PHYSNET_EPOCHS ..."
PHYSNET_TRAINER="${PHYSNET_TRAINER:-$HOME/mmml/examples/other/co2/physnet_train/trainer.py}"
python "$PHYSNET_TRAINER" \
  --train "$PHYSNET_TRAIN_NPZ" \
  --valid "$PHYSNET_VALID_NPZ" \
  --natoms "$PHYSNET_NATOMS" \
  --epochs "$PHYSNET_EPOCHS" \
  --batch-size "$PHYSNET_BATCH" \
  --zbl \
  --name "$PHYSNET_NAME" \
  --ckpt-dir "$PHYSNET_CKPT_DIR"

echo "Output: $PHYSNET_CKPT_DIR/$PHYSNET_NAME/ (checkpoint run id may include a UUID suffix)"
