#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=12G
#SBATCH --time=03:00:00
#SBATCH --job-name=orient_b7c
#SBATCH --output=/mmhome/boittier/home/mmml_tutorial/acodcm/orient_gfn2nms_b7c117aa-27b1-46d3-9c02-4ceef4b14b17/slurm-%j.out

set -euo pipefail
ACODCM=/mmhome/boittier/home/mmml_tutorial/acodcm
MMML=/mmhome/boittier/home/mmml
PY="$MMML/.venv/bin/python"
UUID=b7c117aa-27b1-46d3-9c02-4ceef4b14b17
FROZEN=/mmhome/boittier/home/mmml_tutorial/acodcm/ckpts/_gate_frozen_b7c117aa-27b1-46d3-9c02-4ceef4b14b17_e106
OUT=/mmhome/boittier/home/mmml_tutorial/acodcm/orient_gfn2nms_b7c117aa-27b1-46d3-9c02-4ceef4b14b17
EP=106

module unload cudnn 2>/dev/null || true
source "$MMML/scripts/setup_jax_cuda_env.sh"
export CUDA_VISIBLE_DEVICES=0
export XLA_PYTHON_CLIENT_MEM_FRACTION=0.85
cd "$ACODCM"
hostname
nvidia-smi -L
"$PY" -c "import jax; print('jax devices', jax.devices())"

for RES in ACO DCM; do
  echo "=== orientation scan: $RES (epoch-$EP) ==="
  "$PY" "$MMML/scripts/scan_dimer_orientations.py" \
    --checkpoint "$FROZEN" \
    --data "$ACODCM/out_combined_dedup/energies_forces_dipoles_test.npz" \
    --resid "$RES" --n-directions 10 --n-orientations 24 --n-r 36 \
    --mm-switch-on 6.0 --use-ema \
    --out "$OUT/$RES"
  echo "=== $RES summary ==="
  cat "$OUT/$RES/summary.json"
done
echo DONE
