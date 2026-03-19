#!/usr/bin/env bash
# Example: MP2 (post-HF) energy + gradient via CLI (section 02 – QM/DFT)
# Run from project root: bash examples/mmml_tutorial/cli/05_pyscf_mp2_cli.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== 05: MP2 energy (CLI) ==="
echo 'Command: uv run mmml pyscf-mp2 --mol "O 0 0 0; H 0.96 0 0; H -0.24 0.93 0" --energy --output out/05_results'
uv run mmml pyscf-mp2 --mol "O 0 0 0; H 0.96 0 0; H -0.24 0.93 0" \
  --energy --output out/05_results
echo "Output: out/05_results.npz and .h5"
