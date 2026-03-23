#!/usr/bin/env bash
# Example: Train PhysNet on energies, forces, dipoles (section 03 – PhysNet)
# Run from project root: bash examples/mmml_tutorial/cli/09_physnet_train_cli.sh
# Requires: Step 08 run first (out/splits/).

echo "=== 09: PhysNet training ==="
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
echo "Command: uv run python examples/other/co2/physnet_train/trainer.py --train examples/mmml_tutorial/cli/out/splits/energies_forces_dipoles_train.npz --valid examples/mmml_tutorial/cli/out/splits/energies_forces_dipoles_valid.npz --natoms 16 --epochs 50 --batch-size 1 --name cybz_physnet --ckpt-dir examples/mmml_tutorial/cli/out/ckpts"
cd "$REPO_ROOT"
uv run python ~/mmml/examples/other/co2/physnet_train/trainer.py \
  --train ~/mmml_tutorial/cli/out/splits/energies_forces_dipoles_train.npz \
  --valid ~/mmml_tutorial/cli/out/splits/energies_forces_dipoles_valid.npz \
  --natoms 6 \
  --epochs 500 \
  --batch-size 1 \
  --name eg_physnet \
  --ckpt-dir ~/ckpts
echo "Output: examples/mmml_tutorial/cli/out/ckpts/cybz_physnet/"
