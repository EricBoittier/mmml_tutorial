#!/bin/bash
#SBATCH --job-name=lc-bf-dcm-n3200-r1
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --exclusive
#SBATCH --exclude=gpu24
#SBATCH --time=02:00:00
#SBATCH --output=/mmhome/boittier/home/mmml_tutorial/acodcm/slurm/learning_curve/e1000/backfill_dcm_n3200_r1.out

set -euo pipefail
source "/mmhome/boittier/home/mmml/.venv/bin/activate"
if [[ -f "/mmhome/boittier/home/mmml/scripts/setup_jax_cuda_env.sh" ]]; then
  # shellcheck disable=SC1091
  source "/mmhome/boittier/home/mmml/scripts/setup_jax_cuda_env.sh"
fi
export JAX_PLATFORMS=cuda
export CUDA_VISIBLE_DEVICES=0
cd "/mmhome/boittier/home/mmml_tutorial/acodcm"
# shellcheck disable=SC1091
source "/mmhome/boittier/home/mmml_tutorial/acodcm/scripts/lc_common.sh"

ckpt_dir="/mmhome/boittier/home/mmml_tutorial/acodcm/ckpts/learning_curve/e1000/dcm/n3200/r1"
out_dir="/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/e1000/dcm/n3200/r1"
run_dir=$(pick_orbax_run_dir "$ckpt_dir")
echo "Run directory: $run_dir"

n_ckpt_epochs=$(find "$run_dir" -maxdepth 1 -type d -name 'epoch-*' | wc -l)
stride=$(pick_metrics_stride "$n_ckpt_epochs")
echo "Checkpoints: $n_ckpt_epochs  stride: $stride"

mmml extract-checkpoint-metrics "$run_dir" \
  -o "${out_dir}/training_curves.png" \
  --metrics-json "${out_dir}/training_metrics.json" \
  --stride "$stride" \
  --log-loss \
  --ef-only \
  $(extract_metrics_plot_style_args "google")

latest_epoch=$(latest_epoch_dir "$run_dir")
latest_num=$(basename "$latest_epoch" | sed 's/epoch-//')
echo "Latest epoch: $latest_epoch"
mmml orbax-to-json "$latest_epoch" -o "${out_dir}/latest.json"

eval_ckpt=$(pick_eval_checkpoint "$ckpt_dir" "$out_dir")
echo "Eval checkpoint: $eval_ckpt"
mmml physnet-evaluate \
  --checkpoint "$eval_ckpt" \
  --data "/mmhome/boittier/home/mmml_tutorial/acodcm/out/splits/dcm/energies_forces_dipoles_test.npz" \
  --natoms 10 \
  --batch-size 25 \
  --no-save-npz \
  -o "${out_dir}"

python3 - <<PY
import json
from pathlib import Path
out = Path("/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/e1000/dcm/n3200/r1")
metrics = json.loads((out / "metrics.json").read_text())
train = json.loads((out / "training_metrics.json").read_text())
summary = {
    "dataset": "dcm",
    "n_train": 3200,
    "n_valid": 120,
    "repeat": 1,
    "seed": 1042,
    "run_dir": str(Path("$run_dir")),
    "latest_epoch": "epoch-${latest_num}",
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
    "backfilled": True,
}
(out / "run_summary.json").write_text(json.dumps(summary, indent=2))
print(json.dumps(summary, indent=2))
PY

echo "Backfill done: ${out_dir}"
