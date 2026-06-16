#!/usr/bin/env bash
# Example: Normal mode sampling from pyscf-dft harmonic output (section 02 – QM/DFT)
# Run from this directory: cd examples/mmml_tutorial/cli && bash 06_normal_mode_sample_cli.sh
# Requires: Step 04 run first (out/04_results.h5 with harmonic data).

set -e

echo "=== 06: Normal mode sampling ==="
echo "Command: mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitude 0.1 --max-samples 10"
mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitudes 0.1 0.15 0.08 0.05 0.13 --max-samples 100000
echo "Output: out/06_sampled.npz (R, Z, N)"
