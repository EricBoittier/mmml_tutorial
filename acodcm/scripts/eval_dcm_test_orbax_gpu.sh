#!/usr/bin/env bash
# Run on pc-studix (GPU) to export Orbax checkpoints and evaluate on the hold-out test set.
# E/F metrics only in the aggregated summary (dipole targets present only to satisfy charges=True eval path).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CKPT_DIR="${CKPT_DIR:-$ROOT/ckpts/dcm-test}"
TEST_NPZ="${TEST_NPZ:-$ROOT/out/splits/dcm/energies_forces_dipoles_test.npz}"
OUT_ROOT="${OUT_ROOT:-$ROOT/out/eval/test_ef/orbax}"
BATCH_SIZE="${BATCH_SIZE:-25}"
NATOMS="${NATOMS:-10}"
MIN_EPOCHS="${MIN_EPOCHS:-10}"

mkdir -p "$OUT_ROOT"
SUMMARY="$OUT_ROOT/summary_orbax_ef_test.jsonl"
: > "$SUMMARY"

for run_dir in "$CKPT_DIR"/dcm1-*; do
  [[ -d "$run_dir" ]] || continue
  n_epochs=$(find "$run_dir" -maxdepth 1 -type d -name 'epoch-*' | wc -l)
  if (( n_epochs < MIN_EPOCHS )); then
    echo "Skip $(basename "$run_dir") ($n_epochs epochs)"
    continue
  fi
  latest_epoch=$(find "$run_dir" -maxdepth 1 -type d -name 'epoch-*' | sort -t- -k2 -n | tail -1)
  run_name=$(basename "$run_dir")
  json_export="$CKPT_DIR/${run_name}_latest.json"
  out_dir="$OUT_ROOT/$run_name"
  mkdir -p "$out_dir"

  echo "=== $run_name | $n_epochs epochs | export $latest_epoch ==="
  mmml orbax-to-json "$latest_epoch" -o "$json_export"
  mmml physnet-evaluate \
    --checkpoint "$json_export" \
    --data "$TEST_NPZ" \
    --natoms "$NATOMS" \
    --batch-size "$BATCH_SIZE" \
    --no-save-npz \
    -o "$out_dir"

  python3 - <<PY >> "$SUMMARY"
import json
from pathlib import Path
m = json.loads(Path("$out_dir/metrics.json").read_text())
print(json.dumps({
    "run": "$run_name",
    "epochs": $n_epochs,
    "latest_epoch": "$(basename "$latest_epoch")",
    "energy_mae_kcal_mol": m["energy"]["mae_kcal_mol"],
    "energy_rmse_kcal_mol": m["energy"]["rmse_kcal_mol"],
    "forces_mae_kcal_mol": m["forces"]["mae_kcal_mol"],
    "forces_rmse_kcal_mol": m["forces"]["rmse_kcal_mol"],
    "eval_scope": "energy_and_forces_only",
}))
PY
done

echo "Orbax E/F eval complete. Summary: $SUMMARY"
