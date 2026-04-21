#!/usr/bin/env bash
# Example: Train PhysNet+DCMNet (joint) on energies, forces, dipoles, ESP (section 04 – DCMNet)
# Run from project root: bash examples/mmml_tutorial/cli/10_physnet_dcmnet_train_cli.sh
# Requires: Step 08 run first (out/splits/).

echo "=== 10: PhysNet+DCMNet joint training ==="
echo "Command: uv run python -m mmml.cli.misc.train_joint --train-efd out/splits/energies_forces_dipoles_train.npz --train-esp out/splits/grids_esp_train.npz --valid-efd out/splits/energies_forces_dipoles_valid.npz --valid-esp out/splits/grids_esp_valid.npz --epochs 50 --batch-size 1 --name cybz_joint --ckpt-dir out/ckpts"
uv run python -m mmml.cli.misc.train_joint \
  --train-efd out/splits/energies_forces_dipoles_train.npz \
  --train-esp out/splits/grids_esp_train.npz \
  --valid-efd out/splits/energies_forces_dipoles_valid.npz \
  --valid-esp out/splits/grids_esp_valid.npz \
  --epochs 1000 \
  --batch-size 1 \
  --name water_mono_joint \
  --ckpt-dir ~/ckpts --plot-results --plot-freq 0
echo "Output: out/ckpts/cybz_joint/"
