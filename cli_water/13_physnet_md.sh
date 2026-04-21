#!/usr/bin/env bash
# Example: PhysNet MD sampling with ASE and JAX-MD (section 03 – PhysNet)
# Run from this directory: cd examples/mmml_tutorial/cli && bash 13_physnet_md.sh
# Requires: Step 09 run first. Edit shared.source for checkpoint path and data NPZ.

set -e
. ./shared.source

echo "=== 13: PhysNet MD sampling (ASE + JAX-MD) ==="
echo "Command: mmml physnet-md --checkpoint \"\$PHYSNET_CHECKPOINT\" --data \"\$PHYSNET_TRAIN_NPZ\" -o \"\$PHYSNET_MD_OUT\""

mmml physnet-md \
  --checkpoint "$PHYSNET_CHECKPOINT" \
  --data "$PHYSNET_TRAIN_NPZ" \
  -o "$PHYSNET_MD_OUT"

echo "Output: $PHYSNET_MD_OUT/physnet_ase.traj, physnet_ase_final.xyz, physnet_jaxmd.xyz"
