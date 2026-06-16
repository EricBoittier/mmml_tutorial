#!/usr/bin/env bash
# Example: Fix units and create train/valid/test splits (section 03 – PhysNet)
# Run from this directory: cd examples/mmml_tutorial/cli && bash 08_fix_and_split_cli.sh
# Requires: Step 07 run first (out/07_evaluated.npz with E, F, Dxyz, esp, esp_grid).

set -e

echo "=== 08: fix-and-split (train/valid/test) ==="
echo "Command: uv run mmml fix-and-split --efd out/07_evaluated.npz --output-dir out/splits"
mmml fix-and-split --efd out/07_evaluated.npz --output-dir out/splits --atomic-ref pbe0/def2-tzvp
echo "Output: out/splits/energies_forces_dipoles_{train,valid,test}.npz, grids_esp_{train,valid,test}.npz"
