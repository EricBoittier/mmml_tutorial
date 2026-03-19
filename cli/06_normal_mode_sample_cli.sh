#!/usr/bin/env bash
# Example: Normal mode sampling from pyscf-dft harmonic output (section 02 – QM/DFT)
# Run from project root: bash examples/mmml_tutorial/cli/06_normal_mode_sample_cli.sh
# Requires: Step 04 run first (out/04_results.h5 with harmonic data).

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== 06: Normal mode sampling ==="
<<<<<<< HEAD
echo "Command: uv run mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitude 0.1 --max-samples 10"
uv run mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitude 0.75 --max-samples 1000
=======
echo "Command: mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitude 0.1 --max-samples 10"
mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitude 0.1 --max-samples 200
>>>>>>> 3ca1dc8 (asdf)
echo "Output: out/06_sampled.npz (R, Z, N)"
