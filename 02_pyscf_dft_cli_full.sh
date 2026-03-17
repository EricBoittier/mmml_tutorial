#!/usr/bin/env bash
# Example: DFT energy + gradient + hessian + harmonic + thermo via CLI
# Run from project root: bash examples/mmml_tutorial/02_pyscf_dft_cli_full.sh
# Note: Hessian/harmonic/thermo are expensive; use small molecules.

set -e
cd "$(dirname "$0")/../.."

echo "=== 02: DFT full (energy, gradient, hessian, harmonic, thermo) ==="
uv run mmml pyscf-dft --mol examples/mmml_tutorial/water.xyz \
  --energy --gradient --hessian --harmonic --thermo \
  --output examples/mmml_tutorial/out/02_results
echo "Output: examples/mmml_tutorial/out/02_results.npz and .h5"
