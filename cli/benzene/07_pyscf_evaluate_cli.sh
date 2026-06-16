#!/usr/bin/env bash
# Example: Evaluate sampled geometries with pyscf-dft (E, F, D, optionally ESP)
# Run from this directory: cd examples/mmml_tutorial/cli && bash 07_pyscf_evaluate_cli.sh
# Requires: Step 06 run first (out/06_sampled.npz).

set -e

echo "=== 07: pyscf-evaluate (energy, forces, dipoles, ESP) ==="
echo "Command: uv run mmml pyscf-evaluate -i out/06_sampled.npz -o out/07_evaluated.npz --esp"
mmml pyscf-evaluate -i out/06_sampled.npz -o out/07_evaluated.npz --esp
echo "Output: out/07_evaluated.npz (R, Z, N, E, F, Dxyz, esp, esp_grid)"
