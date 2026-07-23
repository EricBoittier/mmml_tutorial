#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --job-name=eval_e222
#SBATCH --output=/mmhome/boittier/home/mmml_tutorial/acodcm/eval_gfn2nms_f448e34c-cca7-43f6-8b8e-f4986b9403eb/slurm-%j.out

set -euo pipefail
ACODCM=/mmhome/boittier/home/mmml_tutorial/acodcm
MMML=/mmhome/boittier/home/mmml
UUID=f448e34c-cca7-43f6-8b8e-f4986b9403eb
OUT="$ACODCM/eval_gfn2nms_${UUID}"
FROZEN="$ACODCM/ckpts/_gate_frozen_e222"
PY="$MMML/.venv/bin/python"
MMML_BIN="$MMML/.venv/bin/mmml"

module unload cudnn 2>/dev/null || true
# shellcheck disable=SC1091
source "$MMML/scripts/setup_jax_cuda_env.sh"

export XLA_PYTHON_CLIENT_PREALLOCATE=false
export XLA_PYTHON_CLIENT_MEM_FRACTION=0.4

echo "host=$(hostname) cuda=$CUDA_VISIBLE_DEVICES"
"$PY" -c "import jax; print('jax', jax.__version__, jax.devices())"

# Primary: in-distribution GFN2-NMS test set
"$MMML_BIN" physnet-evaluate \
  --checkpoint "$FROZEN" \
  --data "$ACODCM/gfn2_nms_test.npz" \
  -o "$OUT/gfn2_nms_test_e222" \
  --batch-size 16 \
  --plots \
  --use-ema

# Companion: combined_dedup test (same NPZ used for orientation scan monomers)
"$MMML_BIN" physnet-evaluate \
  --checkpoint "$FROZEN" \
  --data "$ACODCM/out_combined_dedup/energies_forces_dipoles_test.npz" \
  -o "$OUT/combined_dedup_test_e222" \
  --batch-size 16 \
  --plots \
  --use-ema

echo DONE
for d in gfn2_nms_test_e222 combined_dedup_test_e222; do
  echo "=== $d ==="
  cat "$OUT/$d/metrics.json"
done
