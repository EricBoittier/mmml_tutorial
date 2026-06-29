#!/usr/bin/env bash
# Post-train backfill: learning curves + hold-out test eval for one sweep run.
#
# Usage:
#   bash scripts/backfill_learning_curve_run.sh aco_n800_r1
#   bash scripts/backfill_learning_curve_run.sh --submit aco_n800_r1
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${ROOT}/scripts/lc_common.sh"

DO_SUBMIT=0
JOB_KEY=""
for arg in "$@"; do
  case "$arg" in
    --submit) DO_SUBMIT=1 ;;
    -*) echo "Unknown flag: $arg" >&2; exit 2 ;;
    *) JOB_KEY="$arg" ;;
  esac
done

if [[ -z "$JOB_KEY" ]]; then
  echo "Usage: $0 [--submit] <job_key>  e.g. aco_n800_r1" >&2
  exit 2
fi

RUNS_FILE="${ROOT}/slurm/learning_curve/runs.tsv"
line=$(awk -F '\t' -v k="$JOB_KEY" '$1==k {print; exit}' "$RUNS_FILE" || true)
if [[ -z "$line" ]]; then
  echo "Job key not in $RUNS_FILE: $JOB_KEY" >&2
  exit 1
fi

IFS=$'\t' read -r job_key dataset n_train repeat seed sbatch_file out_dir <<< "$line"

if [[ "$dataset" == "aco" ]]; then
  test_npz="${ROOT}/out/splits/aco/energies_forces_dipoles_test.npz"
  eval_natoms=20
else
  test_npz="${ROOT}/out/splits/dcm/energies_forces_dipoles_test.npz"
  eval_natoms=10
fi

ckpt_dir="${ROOT}/ckpts/learning_curve/${dataset}/n${n_train}/r${repeat}"
out_dir="${ROOT}/out/eval/learning_curve/${dataset}/n${n_train}/r${repeat}"
n_valid=$(( n_train * 300 / 8000 ))
PLOT_STYLE="${PLOT_STYLE:-google}"
MAIL_USER="${MAIL_USER:-ericdavid.boittier@unibas.ch}"
VENV_ACTIVATE="${VENV_ACTIVATE:-$HOME/mmml/.venv/bin/activate}"
SLURM_DIR="${ROOT}/slurm/learning_curve"
log_file="${SLURM_DIR}/backfill_${job_key}.out"
backfill_sbatch="${SLURM_DIR}/backfill_${job_key}.sbatch"

mkdir -p "$out_dir" "$SLURM_DIR"

cat > "$backfill_sbatch" <<EOF
#!/bin/bash
#SBATCH --job-name=lc-bf-${dataset:0:3}-n${n_train}-r${repeat}
#SBATCH --mail-user=${MAIL_USER}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --exclusive
#SBATCH --exclude=gpu24
#SBATCH --time=02:00:00
#SBATCH --output=${log_file}

set -euo pipefail
source "${VENV_ACTIVATE}"
if [[ -f "${HOME}/mmml/scripts/setup_jax_cuda_env.sh" ]]; then
  # shellcheck disable=SC1091
  source "${HOME}/mmml/scripts/setup_jax_cuda_env.sh"
fi
export JAX_PLATFORMS=cuda
export CUDA_VISIBLE_DEVICES=0
cd "${ROOT}"
# shellcheck disable=SC1091
source "${ROOT}/scripts/lc_common.sh"

ckpt_dir="${ckpt_dir}"
out_dir="${out_dir}"
run_dir=\$(pick_orbax_run_dir "\$ckpt_dir")
echo "Run directory: \$run_dir"

n_ckpt_epochs=\$(find "\$run_dir" -maxdepth 1 -type d -name 'epoch-*' | wc -l)
stride=\$(pick_metrics_stride "\$n_ckpt_epochs")
echo "Checkpoints: \$n_ckpt_epochs  stride: \$stride"

mmml extract-checkpoint-metrics "\$run_dir" \\
  -o "\${out_dir}/training_curves.png" \\
  --metrics-json "\${out_dir}/training_metrics.json" \\
  --stride "\$stride" \\
  --log-loss \\
  --ef-only \\
  --plot-style ${PLOT_STYLE}

latest_epoch=\$(latest_epoch_dir "\$run_dir")
latest_num=\$(basename "\$latest_epoch" | sed 's/epoch-//')
echo "Latest epoch: \$latest_epoch"
mmml orbax-to-json "\$latest_epoch" -o "\${out_dir}/latest.json"

eval_ckpt=\$(pick_eval_checkpoint "\$ckpt_dir" "\$out_dir")
echo "Eval checkpoint: \$eval_ckpt"
mmml physnet-evaluate \\
  --checkpoint "\$eval_ckpt" \\
  --data "${test_npz}" \\
  --natoms ${eval_natoms} \\
  --batch-size 25 \\
  --no-save-npz \\
  -o "\${out_dir}"

python3 - <<PY
import json
from pathlib import Path
out = Path("${out_dir}")
metrics = json.loads((out / "metrics.json").read_text())
train = json.loads((out / "training_metrics.json").read_text())
summary = {
    "dataset": "${dataset}",
    "n_train": ${n_train},
    "n_valid": ${n_valid},
    "repeat": ${repeat},
    "seed": ${seed},
    "run_dir": str(Path("\$run_dir")),
    "latest_epoch": "epoch-\${latest_num}",
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

echo "Backfill done: \${out_dir}"
EOF
chmod +x "$backfill_sbatch"

if (( DO_SUBMIT )); then
  id=$(sbatch --parsable "$backfill_sbatch")
  echo "Submitted backfill $id for $JOB_KEY"
  echo "Log: $log_file"
else
  echo "Wrote $backfill_sbatch"
  echo "Submit with: bash scripts/backfill_learning_curve_run.sh --submit $JOB_KEY"
fi
