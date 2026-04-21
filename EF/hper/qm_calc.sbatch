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


mmml pyscf-evaluate -i selected_frames.npz -o selected_frames_noef_a.npz --EF --efield-sigma 0.0 --add-random-noise 0.05 --seed 42
mmml pyscf-evaluate -i selected_frames.npz -o selected_frames_ef_a.npz --EF --efield-sigma 0.001 --add-random-noise 0.05 --seed 42
mmml pyscf-evaluate -i selected_frames.npz -o selected_frames_noef_b.npz --EF --efield-sigma 0.0 --add-random-noise 0.015 --seed 42
mmml pyscf-evaluate -i selected_frames.npz -o selected_frames_ef_b.npz --EF --efield-sigma 0.001 --add-random-noise 0.015 --seed 42
