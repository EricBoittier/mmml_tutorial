#!/bin/bash
#SBATCH --job-name=lc-dcm-n12000-r1
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --exclusive
#SBATCH --exclude=gpu24
#SBATCH --time=48:00:00
#SBATCH --output=/mmhome/boittier/home/mmml_tutorial/acodcm/slurm/learning_curve/dcm_n12000_r1.out

set -euo pipefail
echo "HOST=$HOSTNAME  DATE=$(date -Is)"
echo "JOB=dcm_n12000_r1  n_train=12000  n_valid=450  seed=1042"

source "/mmhome/boittier/home/mmml/.venv/bin/activate"
if [[ -f "/mmhome/boittier/home/mmml/scripts/setup_jax_cuda_env.sh" ]]; then
  # shellcheck disable=SC1091
  source "/mmhome/boittier/home/mmml/scripts/setup_jax_cuda_env.sh"
fi
export JAX_PLATFORMS=cuda
export CUDA_VISIBLE_DEVICES=0
cd "/mmhome/boittier/home/mmml_tutorial/acodcm"
mkdir -p "/mmhome/boittier/home/mmml_tutorial/acodcm/ckpts/learning_curve/dcm/n12000/r1" "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/dcm/n12000/r1"
# shellcheck disable=SC1091
source "/mmhome/boittier/home/mmml_tutorial/acodcm/scripts/lc_common.sh"

echo "=== [1/3] PhysNet training ==="
mmml physnet-train --config "/mmhome/boittier/home/mmml_tutorial/acodcm/configs/learning_curve/generated/dcm_n12000_r1.yaml"

run_dir=$(pick_orbax_run_dir "/mmhome/boittier/home/mmml_tutorial/acodcm/ckpts/learning_curve/dcm/n12000/r1")
echo "Run directory: $run_dir"

echo "=== [2/3] Learning curves from checkpoints ==="
n_ckpt_epochs=$(find "$run_dir" -maxdepth 1 -type d -name 'epoch-*' | wc -l)
stride=$(pick_metrics_stride "$n_ckpt_epochs")
mmml extract-checkpoint-metrics "$run_dir" \
  -o "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/dcm/n12000/r1/training_curves.png" \
  --metrics-json "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/dcm/n12000/r1/training_metrics.json" \
  --stride "$stride" \
  --log-loss \
  --ef-only \
  --plot-style google

echo "=== [3/3] Hold-out test E/F evaluation ==="
latest_epoch=$(latest_epoch_dir "$run_dir")
latest_num=$(basename "$latest_epoch" | sed 's/epoch-//')
echo "Latest epoch: $latest_epoch"
mmml orbax-to-json "$latest_epoch" -o "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/dcm/n12000/r1/latest.json"
eval_ckpt=$(pick_eval_checkpoint "/mmhome/boittier/home/mmml_tutorial/acodcm/ckpts/learning_curve/dcm/n12000/r1" "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/dcm/n12000/r1")
echo "Eval checkpoint: $eval_ckpt"
mmml physnet-evaluate \
  --checkpoint "$eval_ckpt" \
  --data "/mmhome/boittier/home/mmml_tutorial/acodcm/out/splits/dcm/energies_forces_dipoles_test.npz" \
  --natoms 10 \
  --batch-size 25 \
  --no-save-npz \
  -o "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/dcm/n12000/r1"

python3 - <<PY
import json
from pathlib import Path
out = Path("/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/dcm/n12000/r1")
metrics = json.loads((out / "metrics.json").read_text())
train = json.loads((out / "training_metrics.json").read_text())
summary = {
    "dataset": "dcm",
    "n_train": 12000,
    "n_valid": 450,
    "repeat": 1,
    "seed": 1042,
    "run_dir": str(Path("$run_dir")),
    "latest_epoch": f"epoch-{latest_num}",
    "test_eval": {
        "energy_mae_kcal_mol": metrics["energy"]["mae_kcal_mol"],
        "energy_rmse_kcal_mol": metrics["energy"]["rmse_kcal_mol"],
        "forces_mae_kcal_mol": metrics["forces"]["mae_kcal_mol"],
        "forces_rmse_kcal_mol": metrics["forces"]["rmse_kcal_mol"],
    },
    "training_final": {
        "valid_loss": train["valid_loss"][-1] if train.get("valid_loss") else None,
        "valid_energy_mae": train["valid_energy_mae"][-1] if train.get("valid_energy_mae") else None,
        "valid_forces_mae": train["valid_forces_mae"][-1] if train.get("valid_forces_mae") else None,
    },
}
(out / "run_summary.json").write_text(json.dumps(summary, indent=2))
print(json.dumps(summary, indent=2))
PY

echo "Done: /mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/dcm/n12000/r1"
