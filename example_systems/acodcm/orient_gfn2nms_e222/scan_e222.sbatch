#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --nodelist=gpu01
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=12G
#SBATCH --time=02:00:00
#SBATCH --job-name=orient_e222
#SBATCH --output=/mmhome/boittier/home/mmml_tutorial/acodcm/orient_gfn2nms_e222/slurm-%j.out

set -euo pipefail
ACODCM=/mmhome/boittier/home/mmml_tutorial/acodcm
MMML=/mmhome/boittier/home/mmml
PY="$MMML/.venv/bin/python"
OUT="$ACODCM/orient_gfn2nms_e222"
FROZEN="$ACODCM/ckpts/_gate_frozen_e222"

module unload cudnn 2>/dev/null || true
source "$MMML/scripts/setup_jax_cuda_env.sh"

export CUDA_VISIBLE_DEVICES=0
export XLA_PYTHON_CLIENT_MEM_FRACTION=0.85
cd "$ACODCM"
hostname
nvidia-smi -L
"$PY" -c "import jax; print('jax devices', jax.devices())"

echo "=== ACO orientation scan (Orbax epoch-222, EMA) ==="
"$PY" "$MMML/scripts/scan_dimer_orientations.py" \
  --checkpoint "$FROZEN" \
  --data "$ACODCM/out_combined_dedup/energies_forces_dipoles_test.npz" \
  --resid ACO --n-directions 10 --n-orientations 24 --n-r 36 \
  --mm-switch-on 6.0 --use-ema \
  --out "$OUT"

echo "=== done ==="
cat "$OUT/summary.json"
