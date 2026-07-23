#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --job-name=eval_e222b
#SBATCH --output=/mmhome/boittier/home/mmml_tutorial/acodcm/eval_gfn2nms_f448e34c-cca7-43f6-8b8e-f4986b9403eb/slurm-%j.out

set -euo pipefail
ACODCM=/mmhome/boittier/home/mmml_tutorial/acodcm
MMML=/mmhome/boittier/home/mmml
UUID=f448e34c-cca7-43f6-8b8e-f4986b9403eb
OUT="$ACODCM/eval_gfn2nms_${UUID}"
FROZEN="$ACODCM/ckpts/_gate_frozen_e222"
MMML_BIN="$MMML/.venv/bin/mmml"
PY="$MMML/.venv/bin/python"

module unload cudnn 2>/dev/null || true
source "$MMML/scripts/setup_jax_cuda_env.sh"
export XLA_PYTHON_CLIENT_PREALLOCATE=false
export XLA_PYTHON_CLIENT_MEM_FRACTION=0.4

"$PY" -c "import jax; print(jax.devices())"

# GFN2-NMS test with atom refs subtracted (npz stores atom_ref_energies)
"$MMML_BIN" physnet-evaluate \
  --checkpoint "$FROZEN" \
  --data "$ACODCM/gfn2_nms_test.npz" \
  -o "$OUT/gfn2_nms_test_e222_subatom" \
  --batch-size 16 --plots --use-ema --subtract-atom-energies

# combined only if it has atom refs usable the same way
"$MMML_BIN" physnet-evaluate \
  --checkpoint "$FROZEN" \
  --data "$ACODCM/out_combined_dedup/energies_forces_dipoles_test.npz" \
  -o "$OUT/combined_dedup_test_e222_subatom" \
  --batch-size 16 --plots --use-ema --subtract-atom-energies

echo DONE
for d in gfn2_nms_test_e222_subatom combined_dedup_test_e222_subatom; do
  echo "=== $d ==="; cat "$OUT/$d/metrics.json" || true
done
