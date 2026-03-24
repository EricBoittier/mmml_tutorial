#!/usr/bin/env bash
# Example: MP2 (post-HF) energy + gradient via CLI (section 02 – QM/DFT)
# Run from this directory: cd examples/mmml_tutorial/cli && bash XX_pyscf_mp2_cli.sh

set -e

echo "=== 05: MP2 energy (CLI) ==="
echo 'Command: uv run mmml pyscf-mp2 --mol "O 0 0 0; H 0.96 0 0; H -0.24 0.93 0" --energy --output out/05_results'
uv run mmml pyscf-mp2 --mol "O 0 0 0; H 0.96 0 0; H -0.24 0.93 0" \
  --energy --output out/05_results
echo "Output: out/05_results.npz and .h5"
