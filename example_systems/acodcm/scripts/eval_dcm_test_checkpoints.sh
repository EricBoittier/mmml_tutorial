#!/usr/bin/env bash
# Evaluate dcm-test PhysNet checkpoints on the hold-out test split (E/F only).
# Uses portable params JSON when present; for Orbax-only runs, export on GPU first:
#   mmml orbax-to-json <run>/epoch-<N> -o ckpts/dcm-test/<run>_epoch<N>.json
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CKPT_DIR="${CKPT_DIR:-$ROOT/ckpts/dcm-test}"
# Use the hold-out split as stored (Hartree/Hartree-Bohr); matches physnet-evaluate on this project.
TEST_NPZ="${TEST_NPZ:-$ROOT/out/splits/dcm/energies_forces_dipoles_test.npz}"
OUT_ROOT="${OUT_ROOT:-$ROOT/out/eval/test_ef}"
BATCH_SIZE="${BATCH_SIZE:-25}"
NATOMS="${NATOMS:-10}"

export JAX_PLATFORMS="${JAX_PLATFORMS:-cpu}"

mkdir -p "$OUT_ROOT"

if [[ ! -f "$TEST_NPZ" ]]; then
  echo "Missing test NPZ: $TEST_NPZ" >&2
  echo "Run the Python prep step or set TEST_NPZ." >&2
  exit 1
fi

mapfile -t CHECKPOINTS < <(
  {
    find "$CKPT_DIR" -maxdepth 1 -name 'params_dcm1_*.json' | sort
    find "$CKPT_DIR" -maxdepth 1 -type d -name 'dcm1-*' | sort
  } | awk '!seen[$0]++'
)

if [[ ${#CHECKPOINTS[@]} -eq 0 ]]; then
  echo "No checkpoints under $CKPT_DIR" >&2
  exit 1
fi

SUMMARY="$OUT_ROOT/summary.jsonl"
: > "$SUMMARY"

for ckpt in "${CHECKPOINTS[@]}"; do
  name="$(basename "$ckpt")"
  out_dir="$OUT_ROOT/$name"
  mkdir -p "$out_dir"
  echo "=== Evaluating $ckpt ==="
  if ! mmml physnet-evaluate \
    --checkpoint "$ckpt" \
    --data "$TEST_NPZ" \
    --natoms "$NATOMS" \
    --batch-size "$BATCH_SIZE" \
    --no-save-npz \
    -o "$out_dir"; then
    echo "{\"checkpoint\": \"$name\", \"status\": \"failed\"}" >> "$SUMMARY"
    continue
  fi
  if [[ -f "$out_dir/metrics.json" ]]; then
  python3 - <<PY
import json
from pathlib import Path
m = json.loads(Path("$out_dir/metrics.json").read_text())
row = {
    "checkpoint": "$name",
    "status": "ok",
    "energy_mae_kcal_mol": m["energy"]["mae_kcal_mol"],
    "energy_rmse_kcal_mol": m["energy"]["rmse_kcal_mol"],
    "forces_mae_kcal_mol": m["forces"]["mae_kcal_mol"],
    "forces_rmse_kcal_mol": m["forces"]["rmse_kcal_mol"],
}
print(json.dumps(row))
PY
  fi >> "$SUMMARY"
done

echo "Wrote per-checkpoint metrics under $OUT_ROOT and summary $SUMMARY"
