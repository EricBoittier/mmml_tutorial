#!/usr/bin/env bash
# Example: Train PhysNet+DCMNet (joint) on energies, forces, dipoles, ESP (section 04 – DCMNet)
# Run from this directory: cd cli_water && bash 10_physnet_dcmnet_train_cli.sh
# Requires: Step 08 run first (out/splits/).

echo "=== 10: PhysNet+DCMNet joint training ==="
echo "Command: uv run python -m mmml.cli.misc.train_joint --train-efd out/splits_dimer/energies_forces_dipoles_train.npz --train-esp out/splits_dimer/grids_esp_train.npz --valid-efd out/splits_dimer/energies_forces_dipoles_valid.npz --valid-esp out/splits_dimer/grids_esp_valid.npz --use-repo-physnet-params --epochs 1000 --batch-size 1 --name water_dimer_joint --ckpt-dir ~/ckpts --plot-results --plot-freq 0"
uv run python -m mmml.cli.misc.train_joint \
  --train-efd out/splits_dimer/energies_forces_dipoles_train.npz \
  --train-esp out/splits_dimer/grids_esp_train.npz \
  --valid-efd out/splits_dimer/energies_forces_dipoles_valid.npz \
  --valid-esp out/splits_dimer/grids_esp_valid.npz \
  --use-repo-physnet-params \
  --epochs 1000 \
  --batch-size 1 \
  --name water_dimer_joint \
  --ckpt-dir ~/ckpts --plot-results --plot-freq 0
echo "Output: ~/ckpts/water_dimer_joint/"
