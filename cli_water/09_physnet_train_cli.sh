#!/usr/bin/env bash
# Example: Train PhysNet on energies, forces, dipoles (section 03 – PhysNet)
# Run from this directory: cd examples/mmml_tutorial/cli && bash 09_physnet_train_cli.sh
# Requires: Step 08 run first (out/splits/). Edit shared.source for trainer path and ckpt dir.

set -e
. ./shared.source

echo "=== 09: PhysNet training ==="
echo "Command: python \"\$PHYSNET_TRAINER\" --train \"\$PHYSNET_TRAIN_NPZ\" --valid \"\$PHYSNET_VALID_NPZ\" --natoms \$PHYSNET_NATOMS --epochs \$PHYSNET_EPOCHS ..."

python "$PHYSNET_TRAINER" \
  --train "$PHYSNET_TRAIN_NPZ" \
  --valid "$PHYSNET_VALID_NPZ" \
  --natoms "$PHYSNET_NATOMS" \
  --epochs "$PHYSNET_EPOCHS" \
  --batch-size "$PHYSNET_BATCH" \
  --charges \
  --zbl \
  --name "$PHYSNET_NAME" \
  --ckpt-dir "$PHYSNET_CKPT_DIR"

echo "Output: $PHYSNET_CKPT_DIR/$PHYSNET_NAME/ (checkpoint run id may include a UUID suffix)"
