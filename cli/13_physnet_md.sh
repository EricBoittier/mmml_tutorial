#!/usr/bin/env bash
# Example: PhysNet MD sampling with ASE and JAX-MD (section 03 – PhysNet)
# Run from project root: bash examples/mmml_tutorial/cli/13_physnet_md.sh
# Requires: Step 09 run first (PhysNet checkpoint in cli/out/ckpts/cybz_physnet/).

echo "=== 13: PhysNet MD sampling (ASE + JAX-MD) ==="
echo "Command: uv run mmml physnet-md --checkpoint examples/mmml_tutorial/cli/out/ckpts/cybz_physnet --data examples/mmml_tutorial/cli/out/splits/energies_forces_dipoles_train.npz -o examples/mmml_tutorial/programmatic/out"
cd "$SCRIPT_DIR"
mmml physnet-md \
  --checkpoint /home/ericb/ckpts/eg_physnet-61f86526-b455-45eb-902b-7edcf1ee8633 \
  --data ~/mmml_tutorial/cli/out/splits/energies_forces_dipoles_train.npz \
  -o out
echo "Output: programmatic/out/physnet_ase.traj, physnet_ase_final.xyz, physnet_jaxmd.xyz"
