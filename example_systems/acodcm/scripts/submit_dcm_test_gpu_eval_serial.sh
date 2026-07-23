#!/usr/bin/env bash
# Submit dcm-test GPU eval jobs serially (one GPU job at a time) to avoid CUDA contention.
# Usage: bash scripts/submit_dcm_test_gpu_eval_serial.sh [--submit]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNS_FILE="${ROOT}/out/eval/test_ef/orbax/slurm/runs.tsv"
SLURM_DIR="${ROOT}/out/eval/test_ef/orbax/slurm"

if [[ ! -f "$RUNS_FILE" ]]; then
  bash "${ROOT}/scripts/submit_dcm_test_gpu_eval.sh"
fi

DO_SUBMIT=0
[[ "${1:-}" == "--submit" ]] && DO_SUBMIT=1

mapfile -t SBATCH_FILES < <(awk -F '\t' 'NF>=4 {print $4}' "$RUNS_FILE")

if (( DO_SUBMIT )); then
  ids=()
  for f in "${SBATCH_FILES[@]}"; do
    id=$(sbatch --parsable "$f")
    ids+=("$id")
    echo "submitted $id  ($f)"
    # Wait for completion before next job (serial GPU use)
    while squeue -j "$id" -h 2>/dev/null | grep -q .; do
      sleep 30
    done
    state=$(sacct -j "$id" --format=State -n -P 2>/dev/null | head -1 | cut -d'|' -f1)
    echo "  finished $id state=$state"
  done
  dep=$(IFS=:; echo "${ids[*]}")
  sbatch --dependency=afterany:"$dep" "$SLURM_DIR/summary_compare.sbatch"
  echo "Submitted summary job (afterany:${dep})"
else
  echo "Dry run — would run serially:"
  printf '  %s\n' "${SBATCH_FILES[@]}"
  echo "Submit with: bash scripts/submit_dcm_test_gpu_eval_serial.sh --submit"
fi
