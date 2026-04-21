ELL=1

  #--no-include-pseudotensors
mmml ef-train \
  --train-npz out/splits_ef_sim/energies_forces_dipoles_train.npz \
  --valid-npz out/splits_ef_sim/energies_forces_dipoles_valid.npz \
  --test-npz out/splits_ef_sim/energies_forces_dipoles_test.npz \
  --clip_norm 1000 --output-dir ~/ckpts/ef_run$ELL --num_iterations 2 --max_degree $ELL \
  --batch_size 16 --features 64 --num_basis_functions 32 \
  --zbl --num_epochs 500 --field_scale 100 --forces_weight 1.0 --charge_weight 1.0  --energy_weight 1.0 --dipole_weight 1.0 --save-every 100 

