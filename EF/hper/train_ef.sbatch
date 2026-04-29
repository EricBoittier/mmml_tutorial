#!/bin/bash

#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=run
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --exclude=gpu24
##SBATCH --nodelist=gpu08


echo $HOSTNAME

source ~/mmml/.venv/bin/activate

# which python

# python - <<'EOF'
# import jax
# print("JAX version:", jax.__version__)
# print("Devices:", jax.devices())
# print("Backend:", jax.default_backend())
# EOF


# mmml fix-and-split --efd selected_frames_noef_a.npz selected_frames_noef_b.npz interpolated_evaluated_ef0.npz sim_evaluated_ef0.npz --output-dir out/splits_ef00_t3 --atomic-ref pbe0/def2-tzvp


ELL=0

  #--no-include-pseudotensors
mmml ef-train \
  --no-include-pseudotensors --train-npz out/splits_ef0_t3/energies_forces_dipoles_train.npz \
  --valid-npz out/splits_ef0_t3/energies_forces_dipoles_valid.npz \
  --test-npz out/splits_ef0_t3/energies_forces_dipoles_test.npz \
  --rot-augment --rot-perturbation 1.0 \
  --clip_norm 1000 --output-dir ~/ckpts/t_ef_run$ELL --num_iterations 2 --max_degree $ELL \
  --batch_size 16 --features 64 --num_basis_functions 32 \
  --zbl --num_epochs 500 --field_scale 100 --forces_weight 1.0 --charge_weight 1.0  --energy_weight 1.0 --dipole_weight 1.0 --save-every 100


