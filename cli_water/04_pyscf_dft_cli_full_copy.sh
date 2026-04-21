#!/usr/bin/env bash
# Example: DFT full (energy, gradient, hessian, harmonic, thermo) via CLI (section 02 – QM/DFT)
# Run from this directory: cd examples/mmml_tutorial/cli && bash 04_pyscf_dft_cli_full.sh
# Note: Hessian/harmonic/thermo are expensive; use small molecules.

set -e
for x in out/xyz_split/*xyz ; do

echo "=== 04: DFT full (energy, gradient, hessian, harmonic, thermo) ==="
echo "Command: uv run mmml pyscf-dft --mol xyz/initial.xyz --energy --gradient --hessian --harmonic --thermo --output out/04_results"
mmml pyscf-dft --mol $x \
  --energy --gradient --hessian --harmonic  \
  --output $x.results
echo "Output: out/04_results.npz and .h5"
done

