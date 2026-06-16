#!/usr/bin/env bash
# Example: Train PhysNet+DCMNet (joint) on energies, forces, dipoles, ESP (section 04 – DCMNet)
# Run from this directory: cd cli && bash 10_physnet_dcmnet_train_cli.sh
# Requires: Step 08 run first (out/splits/).

echo "=== 10: PhysNet+DCMNet joint training ==="
echo "Command: python -m mmml.cli.misc.train_joint ... --write-checkpoint-path out/last_joint_checkpoint.txt"
mkdir -p out
python -m mmml.cli.misc.train_joint \
<<<<<<< HEAD
  --train-efd out/splits/energies_forces_dipoles_train.npz \
  --train-esp out/splits/grids_esp_train.npz \
  --valid-efd out/splits/energies_forces_dipoles_valid.npz \
  --valid-esp out/splits/grids_esp_valid.npz \
  --use-repo-physnet-params \
=======
  --train-efd out/output_from_md2/energies_forces_dipoles_train.npz \
  --train-esp out/output_from_md2/grids_esp_train.npz \
  --valid-efd out/output_from_md2/energies_forces_dipoles_valid.npz \
  --valid-esp out/output_from_md2/grids_esp_valid.npz \
>>>>>>> a0c444a (Sena additions to EF, etc)
  --epochs 1000 \
  --dcmnet-cutoff 12.0 \
  --physnet-cutoff 12.0 \
  --batch-size 32 \
  --name eg_joint \
<<<<<<< HEAD
  --ckpt-dir ~/ckpts --plot-results --plot-freq 500 \
  --write-checkpoint-path out/last_joint_checkpoint.txt
echo "Output: ~/ckpts/eg_joint/ (path also in out/last_joint_checkpoint.txt)"
=======
  --ckpt-dir ./output_from_md_checkpnt2 --plot-results --plot-freq 0 
echo "Output: out/ckpts/cybz_joint/"
>>>>>>> a0c444a (Sena additions to EF, etc)
