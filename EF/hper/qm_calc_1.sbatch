#!/bin/bash

#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=run
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
##SBATCH --nodelist=gpu08

nvidia-smi
source /mmhome/boittier/home/mmml/.venv/bin/activate

echo "Command: uv run mmml pyscf-dft --mol xyz/initial.xyz --energy --gradient --hessian --harmonic --thermo --output out/04_results"
mmml pyscf-dft --mol "hper_a.xyz" \
  --energy --polarizability  --output out/hper_a.npz
echo "Output: out/04_results.npz and .h5"


echo "Command: uv run mmml pyscf-dft --mol xyz/initial.xyz --energy --gradient --hessian --harmonic --thermo --output out/04_results"
mmml pyscf-dft --mol "hper_b.xyz" \
  --energy --polarizability  --output out/hper_b.npz
echo "Output: out/04_results.npz and .h5"



