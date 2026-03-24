#!/usr/bin/env bash
# Example: DFT energy via CLI (section 02 – QM/DFT)
# Run from this directory: cd examples/mmml_tutorial/cli && bash XX_pyscf_dft_cli.sh

set -e

echo "=== 03: DFT energy (CLI) ==="
echo 'Command: uv run mmml pyscf-dft --mol "O 0 0 0; H 0.96 0 0; H -0.24 0.93 0" --energy --output out/03_results'
uv run mmml pyscf-dft --mol "O 0 0 0; H 0.96 0 0; H -0.24 0.93 0" --energy --output out/03_results
echo "Output: out/03_results.npz and .h5"
