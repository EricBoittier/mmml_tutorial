ELL=0

mmml ef-train \
  --train-npz out/splits_ef0_sim/energies_forces_dipoles_train.npz \
  --valid-npz out/splits_ef0_sim/energies_forces_dipoles_valid.npz \
  --test-npz out/splits_ef0_sim/energies_forces_dipoles_test.npz \
  --clip_norm 1000 --output-dir ~/ckpts/ef0_run$ELL --num_iterations 2 --max_degree $ELL \
  --batch_size 32 --features 32 --num_basis_functions 32 \
  --zbl --num_epochs 1000 --field_scale 10 --forces_weight 1.0 --charge_weight 1.0  --energy_weight 1.0 --dipole_weight 1.0

