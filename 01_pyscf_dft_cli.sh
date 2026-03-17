#!/usr/bin/env bash
# Example: DFT energy via CLI (basic)
# Run from project root: bash examples/mmml_tutorial/01_pyscf_dft_cli.sh

set -e
cd "$(dirname "$0")/../.."

echo "=== 01: DFT energy (CLI) ==="
uv run mmml pyscf-dft --mol "O 0 0 0; H 0.96 0 0; H -0.24 0.93 0" --energy --output examples/mmml_tutorial/out/01_results
echo "Output: examples/mmml_tutorial/out/01_results.npz and .h5"
