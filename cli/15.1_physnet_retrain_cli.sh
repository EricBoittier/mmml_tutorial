#!/usr/bin/env bash
# Example: Train PhysNet on energies, forces, dipoles (section 03 – PhysNet)
# Run from project root: bash examples/mmml_tutorial/cli/09_physnet_train_cli.sh
# Requires: Step 08 run first (out/splits/).

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== 09: PhysNet training ==="
echo "Command: python trainer.py --train examples/mmml_tutorial/cli/out/splits/energies_forces_dipoles_train.npz --valid examples/mmml_tutorial/cli/out/splits/energies_forces_dipoles_valid.npz --natoms 16 --epochs 50 --batch-size 1 --name cybz_physnet --ckpt-dir examples/mmml_tutorial/cli/out/ckpts"
cd "$REPO_ROOT"
python ~/mmml/examples/other/co2/physnet_train/trainer.py \
  --train out/splits/energies_forces_dipoles_train.npz splits_extended/energies_forces_dipoles_train.npz splits_extended2/energies_forces_dipoles_train.npz \
  --valid out/splits/energies_forces_dipoles_valid.npz splits_extended/energies_forces_dipoles_valid.npz splits_extended2/energies_forces_dipoles_valid.npz \
  --natoms 16 \
  --batch-size 1 \
  --epochs 1500 \
  --charges  --name cybz_physnet \
  --ckpt-dir ~/ckpts --restart ~/ckpts/cybz_physnet-145ff5d7-02fb-4cae-8c2e-a5633fd1c4af 

echo "Output: examples/mmml_tutorial/cli/out/ckpts/cybz_physnet/"
