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

uuid=68783a67-7fcf-47f8-bb85-fd1b19263e63
