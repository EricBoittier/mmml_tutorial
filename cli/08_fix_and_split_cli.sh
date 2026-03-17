#!/usr/bin/env bash
# Example: Fix units and create train/valid/test splits (section 03 – PhysNet)
# Run from project root: bash examples/mmml_tutorial/cli/08_fix_and_split_cli.sh
# Requires: Step 07 run first (out/07_evaluated.npz with E, F, Dxyz, esp, esp_grid).

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== 08: fix-and-split (train/valid/test) ==="
echo "Command: uv run mmml fix-and-split --efd out/07_evaluated.npz --output-dir out/splits"
uv run mmml fix-and-split --efd out/07_evaluated.npz --output-dir out/splits
echo "Output: out/splits/energies_forces_dipoles_{train,valid,test}.npz, grids_esp_{train,valid,test}.npz"
