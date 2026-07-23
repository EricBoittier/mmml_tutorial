CUDA_VISIBLE_DEVICES=0 uv run python -m mmml.cli.misc.train_joint \
  --train-efd out/splits_dimer/energies_forces_dipoles_train.npz \
  --train-esp out/splits_dimer/grids_esp_train.npz \
  --valid-efd out/splits_dimer/energies_forces_dipoles_valid.npz \
  --valid-esp out/splits_dimer/grids_esp_valid.npz \
  --use-repo-physnet-params \
  --epochs 100 \
  --batch-size 4 \
  --name smoke_repo_physnet \
  --ckpt-dir /tmp/mmml_ckpts \
  --plot-freq 0


