#!/usr/bin/env bash
# Example: MP2 (post-HF) energy + gradient via CLI (section 02 – QM/DFT)
# Run from project root: bash examples/mmml_tutorial/05_pyscf_mp2_cli.sh

set -e
cd "$(dirname "$0")/../.."

echo "=== 05: MP2 energy + gradient (CLI) ==="
uv run mmml pyscf-mp2 --mol "O 0 0 0; H 0.96 0 0; H -0.24 0.93 0" \
  --energy --gradient --output examples/mmml_tutorial/out/05_results
echo "Output: examples/mmml_tutorial/out/05_results.npz and .h5"
