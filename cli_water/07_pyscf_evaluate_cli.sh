#!/usr/bin/env bash
# Example: Evaluate sampled geometries with pyscf-dft (E, F, D, optionally ESP)
# Run from this directory: cd examples/mmml_tutorial/cli && bash 07_pyscf_evaluate_cli.sh
# Requires: Step 06 run first (out/06_sampled.npz).

set -e

echo "=== 07: pyscf-evaluate (energy, forces, dipoles, ESP) ==="
echo "Command: uv run mmml pyscf-evaluate -i out/06_sampled.npz -o out/07_evaluated.npz --esp"
#mmml pyscf-evaluate -i out/06_sampled.npz -o out/07_evaluated.npz --esp
#mmml pyscf-evaluate -i out/06_sampled1.npz -o out/07_evaluated1.npz --esp
mmml pyscf-evaluate -i out/06_sampled2.npz -o out/07_evaluated2.npz --esp
mmml pyscf-evaluate -i out/06_sampled3.npz -o out/07_evaluated3.npz --esp
mmml pyscf-evaluate -i out/06_sampled4.npz -o out/07_evaluated4.npz --esp
mmml pyscf-evaluate -i out/06_sampled5.npz -o out/07_evaluated5.npz --esp
echo "Output: out/07_evaluated.npz (R, Z, N, E, F, Dxyz, esp, esp_grid)"
