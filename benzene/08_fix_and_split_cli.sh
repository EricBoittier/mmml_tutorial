#!/usr/bin/env bash
# Example: Fix units and create train/valid/test splits (section 03 – PhysNet)
# Run from this directory: cd cli && bash 08_fix_and_split_cli.sh
# Requires: Step 07 run first (out/07_evaluated.npz with E, F, Dxyz, esp, esp_grid).

set -e

shopt -s nullglob
eval_npzs=(out/07_evaluated*.npz)
if ((${#eval_npzs[@]} == 0)); then
  echo "error: no out/07_evaluated*.npz; run 07_pyscf_evaluate_cli.sh first" >&2
  exit 1
fi
# Newest file wins (pyscf-evaluate may write 07_evaluated_2.npz if 07_evaluated.npz exists).
EVAL_NPZ="$(ls -t out/07_evaluated*.npz | head -1)"

echo "=== 08: fix-and-split (train/valid/test) ==="
echo "Command: mmml fix-and-split --efd \"$EVAL_NPZ\" --output-dir out/splits"
mmml fix-and-split --efd "$EVAL_NPZ" --output-dir out/splits --atomic-ref pbe0/def2-tzvp
echo "Output: out/splits/energies_forces_dipoles_{train,valid,test}.npz, grids_esp_{train,valid,test}.npz"
