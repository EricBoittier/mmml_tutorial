#!/usr/bin/env bash
# Monitor learning-curve sweep Slurm jobs and artifact completion.
#
# Usage:
#   bash scripts/monitor_learning_curve_sweep.sh
#   bash scripts/monitor_learning_curve_sweep.sh --watch   # refresh every 60s
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EPOCH_TAG="${EPOCH_TAG:-e${NUM_EPOCHS:-1000}}"
RUNS_FILE="${ROOT}/slurm/learning_curve/${EPOCH_TAG}/runs.tsv"
SLURM_DIR="${ROOT}/slurm/learning_curve/${EPOCH_TAG}"
OUT_EVAL_ROOT="${ROOT}/out/eval/learning_curve/${EPOCH_TAG}"
WATCH=0
[[ "${1:-}" == "--watch" ]] && WATCH=1

status_once() {
  echo "=== Learning-curve sweep status $(date -Is) [${EPOCH_TAG}, ${NUM_EPOCHS:-1000} epochs] ==="
  if [[ ! -f "$RUNS_FILE" ]]; then
    echo "No runs file: $RUNS_FILE"
    echo "Generate with: bash scripts/submit_learning_curve_sweep.sh"
    return 1
  fi

  local total=0 done_train=0 done_curves=0 done_eval=0 running=0 failed=0 pending=0
  printf '\n%-28s %-8s %-6s %s\n' "JOB" "SLURM" "ARTIFACTS" "TEST E MAE"
  printf '%s\n' "$(printf '%.0s-' {1..80})"

  while IFS=$'\t' read -r job_key dataset n_train repeat seed sbatch out_dir; do
    (( total++ )) || true
    log_file="${SLURM_DIR}/${job_key}.out"
    slurm_state="?"
    if [[ -f "$log_file" ]]; then
      if grep -q "Done: ${out_dir}" "$log_file" 2>/dev/null; then
        slurm_state="DONE"
      elif grep -qi "error\|traceback\|failed" "$log_file" 2>/dev/null && ! grep -q "Done: ${out_dir}" "$log_file" 2>/dev/null; then
        slurm_state="FAIL?"
      else
        slurm_state="RUN?"
      fi
    fi

    arts=""
    [[ -d "${ROOT}/ckpts/learning_curve/${EPOCH_TAG}/${dataset}/n${n_train}/r${repeat}" ]] && arts+="ckpt "
    [[ -f "${OUT_EVAL_ROOT}/${dataset}/n${n_train}/r${repeat}/training_curves.png" ]] && { arts+="curves "; (( done_curves++ )) || true; }
    [[ -f "${OUT_EVAL_ROOT}/${dataset}/n${n_train}/r${repeat}/run_summary.json" ]] && { arts+="eval "; (( done_eval++ )) || true; }
    [[ -n "$arts" ]] && (( done_train++ )) || true

    e_mae=""
    if [[ -f "${OUT_EVAL_ROOT}/${dataset}/n${n_train}/r${repeat}/run_summary.json" ]]; then
      e_mae=$(python3 - <<PY
import json
from pathlib import Path
p = Path("${OUT_EVAL_ROOT}/${dataset}/n${n_train}/r${repeat}/run_summary.json")
d = json.loads(p.read_text())
v = d.get("test_eval", {}).get("energy_mae_kcal_mol")
print(f"{v:.3f}" if v is not None else "-")
PY
)
    fi

    printf '%-28s %-8s %-6s %s\n' "$job_key" "$slurm_state" "${arts:- -}" "${e_mae:--}"
  done < "$RUNS_FILE"

  echo ""
  echo "Totals: $total jobs | curves: $done_curves | test eval: $done_eval"
  echo ""
  echo "Active Slurm (lc-*):"
  squeue -u "$USER" -o '%.10i %.9P %.20j %.8T %.10M %R' 2>/dev/null | grep -E 'JOBID|lc-' || echo "  (none)"
}

if (( WATCH )); then
  while true; do
    clear
    status_once || true
    sleep 60
  done
else
  status_once
fi
