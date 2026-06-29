#!/usr/bin/env bash
# Generate (and optionally submit) GPU Slurm jobs for dcm-test Orbax runs:
#   1) training loss curves from epoch checkpoints
#   2) hold-out test E/F evaluation on the latest epoch
#
# Usage:
#   cd ~/mmml_tutorial/acodcm
#   bash scripts/submit_dcm_test_gpu_eval.sh            # create sbatch files
#   bash scripts/submit_dcm_test_gpu_eval.sh --submit   # create + sbatch
#   bash scripts/submit_dcm_test_gpu_eval.sh --submit --summary  # also queue summary job
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CKPT_DIR="${CKPT_DIR:-$ROOT/ckpts/dcm-test}"
TEST_NPZ="${TEST_NPZ:-$ROOT/out/splits/dcm/energies_forces_dipoles_test.npz}"
OUT_ROOT="${OUT_ROOT:-$ROOT/out/eval/test_ef/orbax}"
SLURM_DIR="${SLURM_DIR:-$OUT_ROOT/slurm}"
MIN_EPOCHS="${MIN_EPOCHS:-10}"
MAIL_USER="${MAIL_USER:-ericdavid.boittier@unibas.ch}"
PARTITION="${PARTITION:-gpu}"
EXCLUDE_NODES="${EXCLUDE_NODES:-gpu24}"
VENV_ACTIVATE="${VENV_ACTIVATE:-$HOME/mmml/.venv/bin/activate}"

DO_SUBMIT=0
DO_SUMMARY=0
for arg in "$@"; do
  case "$arg" in
    --submit) DO_SUBMIT=1 ;;
    --summary) DO_SUMMARY=1 ;;
  esac
done

mkdir -p "$SLURM_DIR" "$OUT_ROOT"

pick_stride() {
  local n_epochs="$1"
  if (( n_epochs <= 200 )); then
    echo 1
  elif (( n_epochs <= 1000 )); then
    echo 5
  else
    echo $(( (n_epochs + 499) / 500 ))
  fi
}

job_ids=()
runs_file="$SLURM_DIR/runs.tsv"
: > "$runs_file"

for run_dir in "$CKPT_DIR"/dcm1-*; do
  [[ -d "$run_dir" ]] || continue
  run_name="$(basename "$run_dir")"
  n_epochs=$(find "$run_dir" -maxdepth 1 -type d -name 'epoch-*' | wc -l)
  if (( n_epochs < MIN_EPOCHS )); then
    echo "Skip $run_name ($n_epochs epochs < $MIN_EPOCHS)"
    continue
  fi
  stride="$(pick_stride "$n_epochs")"
  out_dir="$OUT_ROOT/$run_name"
  sbatch_file="$SLURM_DIR/${run_name}.sbatch"
  log_file="$SLURM_DIR/${run_name}.out"

  cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --job-name=dcm-eval
#SBATCH --mail-user=${MAIL_USER}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=${PARTITION}
#SBATCH --gres=gpu:1
#SBATCH --exclude=${EXCLUDE_NODES}
#SBATCH --time=04:00:00
#SBATCH --output=${log_file}

set -euo pipefail
echo "HOST=\$HOSTNAME  DATE=\$(date -Is)"
echo "RUN=${run_name}  EPOCHS=${n_epochs}  STRIDE=${stride}"

source "${VENV_ACTIVATE}"
# JAX CUDA runtime (cuDNN) — required on cluster GPU nodes
if [[ -f "${HOME}/mmml/scripts/setup_jax_cuda_env.sh" ]]; then
  # shellcheck disable=SC1091
  source "${HOME}/mmml/scripts/setup_jax_cuda_env.sh"
fi
export JAX_PLATFORMS=cuda
export CUDA_VISIBLE_DEVICES=0
cd "${ROOT}"
mkdir -p "${out_dir}"

echo "=== [1/3] Extract training metrics + loss curves ==="
mmml extract-checkpoint-metrics \\
  "${run_dir}" \\
  -o "${out_dir}/training_curves.png" \\
  --metrics-json "${out_dir}/training_metrics.json" \\
  --stride ${stride} \\
  --log-loss \\
  --ef-only

echo "=== [2/3] Export latest Orbax checkpoint to JSON ==="
latest_num=\$(find "${run_dir}" -maxdepth 1 -type d -name 'epoch-*' | sed 's|.*/epoch-||' | sort -n | tail -1)
latest_epoch="${run_dir}/epoch-\${latest_num}"
echo "Latest epoch: \$latest_epoch (epoch-\${latest_num})"
mmml orbax-to-json "\$latest_epoch" -o "${out_dir}/latest.json"

echo "=== [3/3] Test-set E/F evaluation (hold-out) ==="
mmml physnet-evaluate \\
  --checkpoint "${out_dir}/latest.json" \\
  --data "${TEST_NPZ}" \\
  --natoms 10 \\
  --batch-size 25 \\
  --no-save-npz \\
  -o "${out_dir}"

python3 - <<PY
import json
from pathlib import Path
out = Path("${out_dir}")
metrics = json.loads((out / "metrics.json").read_text())
train = json.loads((out / "training_metrics.json").read_text())
summary = {
    "run": "${run_name}",
    "epochs_total": ${n_epochs},
    "stride": ${stride},
    "latest_epoch": Path("\$latest_epoch").name,
    "test_eval": {
        "energy_mae_kcal_mol": metrics["energy"]["mae_kcal_mol"],
        "energy_rmse_kcal_mol": metrics["energy"]["rmse_kcal_mol"],
        "forces_mae_kcal_mol": metrics["forces"]["mae_kcal_mol"],
        "forces_rmse_kcal_mol": metrics["forces"]["rmse_kcal_mol"],
    },
    "training_final": {
        "valid_loss": train["valid_loss"][-1] if train.get("valid_loss") else None,
        "train_loss": train["train_loss"][-1] if train.get("train_loss") else None,
        "valid_energy_mae": train["valid_energy_mae"][-1] if train.get("valid_energy_mae") else None,
        "valid_forces_mae": train["valid_forces_mae"][-1] if train.get("valid_forces_mae") else None,
    },
    "eval_scope": "energy_and_forces_only",
}
(out / "run_summary.json").write_text(json.dumps(summary, indent=2))
print(json.dumps(summary, indent=2))
PY

echo "Done: ${out_dir}"
EOF
  chmod +x "$sbatch_file"
  echo "${run_name}"$'\t'"${n_epochs}"$'\t'"${stride}"$'\t'"${sbatch_file}" >> "$runs_file"
  echo "Wrote $sbatch_file (epochs=$n_epochs stride=$stride)"

  if (( DO_SUBMIT )); then
    job_id=$(sbatch --parsable "$sbatch_file")
    job_ids+=("$job_id")
    echo "  submitted job $job_id"
  fi
done

if (( DO_SUMMARY )); then
  summary_sbatch="$SLURM_DIR/summary_compare.sbatch"
  summary_log="$SLURM_DIR/summary_compare.out"
  dep=""
  if (( DO_SUBMIT )) && ((${#job_ids[@]} > 0)); then
    dep_ids=$(IFS=:; echo "${job_ids[*]}")
    dep="#SBATCH --dependency=afterok:${dep_ids}"
  fi
  cat > "$summary_sbatch" <<EOF
#!/bin/bash
#SBATCH --job-name=dcm-eval-sum
#SBATCH --mail-user=${MAIL_USER}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8000
#SBATCH --partition=short
#SBATCH --time=00:30:00
#SBATCH --output=${summary_log}
${dep}

set -euo pipefail
source "${VENV_ACTIVATE}"
cd "${ROOT}"
python3 "${ROOT}/scripts/plot_dcm_test_eval_summary.py" \\
  --orbax-root "${OUT_ROOT}" \\
  --output "${OUT_ROOT}/comparison_loss_and_test_ef.png" \\
  --summary-json "${OUT_ROOT}/aggregate_summary.json"
EOF
  chmod +x "$summary_sbatch"
  echo "Wrote $summary_sbatch"
  if (( DO_SUBMIT )); then
    sid=$(sbatch --parsable "$summary_sbatch")
    echo "Submitted summary job $sid"
  fi
fi

echo ""
echo "Slurm scripts: $SLURM_DIR"
echo "Results root:  $OUT_ROOT"
if (( ! DO_SUBMIT )); then
  echo "Submit with: bash scripts/submit_dcm_test_gpu_eval.sh --submit --summary"
fi
