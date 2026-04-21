#!/usr/bin/env bash
# Example: Normal mode sampling from pyscf-dft harmonic output (section 02 – QM/DFT)
# Run from this directory: cd examples/mmml_tutorial/cli && bash 06_normal_mode_sample_cli.sh
# Requires: Step 04 run first (out/04_results.h5 with harmonic data).

set -e

echo "=== 06: Normal mode sampling ==="
echo "Command: mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitude 0.1 --max-samples 10"
#mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitude 0.1 --max-samples 200
mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled2.npz --amplitude 0.2 --max-samples 200
mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled3.npz --amplitude 0.3 --max-samples 200
mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled4.npz --amplitude 0.4 --max-samples 200
mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled5.npz --amplitude 0.5 --max-samples 200
echo "Output: out/06_sampled.npz (R, Z, N)"
