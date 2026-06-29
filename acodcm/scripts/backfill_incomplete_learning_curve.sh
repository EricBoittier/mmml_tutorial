#!/usr/bin/env bash
# Submit post-train backfill for all incomplete learning-curve sweep runs.
#
# A run is incomplete when checkpoints exist but training_curves.png or
# run_summary.json is missing (e.g. after --plot-style failures on old mmml).
#
# Usage:
#   EPOCH_TAG=e1000 bash scripts/backfill_incomplete_learning_curve.sh
#   EPOCH_TAG=e1000 bash scripts/backfill_incomplete_learning_curve.sh --submit
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EPOCH_TAG="${EPOCH_TAG:-e${NUM_EPOCHS:-1000}}"
RUNS_FILE="${ROOT}/slurm/learning_curve/${EPOCH_TAG}/runs.tsv"
OUT_EVAL_ROOT="${ROOT}/out/eval/learning_curve/${EPOCH_TAG}"
CKPT_ROOT="${ROOT}/ckpts/learning_curve/${EPOCH_TAG}"

DO_SUBMIT=0
for arg in "$@"; do
  case "$arg" in
    --submit) DO_SUBMIT=1 ;;
    -*) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

if [[ ! -f "$RUNS_FILE" ]]; then
  echo "No runs file: $RUNS_FILE" >&2
  echo "Generate with: NUM_EPOCHS=... bash scripts/submit_learning_curve_sweep.sh" >&2
  exit 1
fi

incomplete=()
while IFS=$'\t' read -r job_key dataset n_train repeat seed sbatch_file out_dir; do
  ckpt_dir="${CKPT_ROOT}/${dataset}/n${n_train}/r${repeat}"
  eval_dir="${OUT_EVAL_ROOT}/${dataset}/n${n_train}/r${repeat}"
  [[ -d "$ckpt_dir" ]] || continue
  if [[ -f "${eval_dir}/training_curves.png" && -f "${eval_dir}/run_summary.json" ]]; then
    continue
  fi
  incomplete+=("$job_key")
done < "$RUNS_FILE"

if ((${#incomplete[@]} == 0)); then
  echo "All runs complete for ${EPOCH_TAG}."
  exit 0
fi

echo "Incomplete runs (${#incomplete[@]}): ${incomplete[*]}"
for job_key in "${incomplete[@]}"; do
  if (( DO_SUBMIT )); then
    bash "${ROOT}/scripts/backfill_learning_curve_run.sh" --submit "$job_key"
  else
    bash "${ROOT}/scripts/backfill_learning_curve_run.sh" "$job_key"
  fi
done

if (( ! DO_SUBMIT )); then
  echo ""
  echo "Submit all with:"
  echo "  EPOCH_TAG=${EPOCH_TAG} bash scripts/backfill_incomplete_learning_curve.sh --submit"
fi
