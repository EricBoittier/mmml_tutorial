#!/usr/bin/env bash
# Example: Train PhysNet+DCMNet (joint) on energies, forces, dipoles, ESP (section 04 – DCMNet)
# Run from this directory: cd cli && bash 10_physnet_dcmnet_train_cli.sh
# Requires: Step 08 run first (out/splits/).

echo "=== 10: PhysNet+DCMNet joint training ==="
echo "Command: python -m mmml.cli.misc.train_joint ... --write-checkpoint-path out/last_joint_checkpoint.txt"
mkdir -p out
python -m mmml.cli.misc.train_joint \
  --train-efd out/splits/energies_forces_dipoles_train.npz \
  --train-esp out/splits/grids_esp_train.npz \
  --valid-efd out/splits/energies_forces_dipoles_valid.npz \
  --valid-esp out/splits/grids_esp_valid.npz \
  --use-repo-physnet-params \
  --epochs 10000 \
  --batch-size 5 \
  --name eg_joint \
  --ckpt-dir ~/ckpts --plot-results --plot-freq 500 \
  --write-checkpoint-path out/last_joint_checkpoint.txt
echo "Output: ~/ckpts/eg_joint/ (path also in out/last_joint_checkpoint.txt)"
